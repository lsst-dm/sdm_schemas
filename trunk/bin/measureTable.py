#!/usr/bin/env python

# 
# LSST Data Management System
# Copyright 2008, 2009, 2010 LSST Corporation.
# 
# This product includes software developed by the
# LSST Project (http://www.lsst.org/).
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the LSST License Statement and 
# the GNU General Public License along with this program.  If not, 
# see <http://www.lsstcorp.org/LegalNotices/>.
#

"""Command-line script to measure the size of a database table
based on its schema. The schema is read from stdin and the report
printed to stdout. Errors are reported to stderr. To use:

./measureTable.py <schema.sql
"""
import sys
import math
import re

MaxEnumItems = 65535
MaxSetItems = 64

class TableInfo(object):
    """Collect information about a MySQL database table.
    
    Warning: assumes latin-1 character set.
    """
    SkipCols = set((
        "primary",
        "foreign",
        "key",
        "unique",
        "index",
        "comment",
    ))

    SimpleFixedSizes = dict(
        tinyint = 1,
        smallint = 2,
        mediumint = 3,
        int = 4,
        integer = 4,
        bigint = 8,
        float = 4,
        double = 8,
        real = 8,
        bit = 1,
        date = 3,
        datetime = 4,
        timestamp = 4,
        time = 3,
        year = 1,
    )
    
    SimpleVarSizes = dict(
        tinyblob = (1, 1 + 2**8),
        tinytext = (1, 1 + 2**8),
        blob= (2, 2 + 2**16),
        text= (2, 2 + 2**16),
        mediumblob= (3, 3 + 2**24),
        mediumtext= (3, 3 + 2**24),
        longblob= (4, 4 + 2**32),
        longtext= (4, 4 + 2**32),
    )
    
    DecimalCols = set((
        "decimal",
        "numeric",
    ))
    
    UserFixedCols = set((
        "char",
        "binary",
    ))
    
    UserVarCols = set((
        "varchar",
        "varbinary",
    ))

    # special cases:
    # double [precision] (ignore the precision)
    # enum
    # set
    
    DataTypeRE = re.compile(r'([a-z]+) *(?:\( *(\d+)(?: *, *(\d+))? *\))?')

    def __init__(self, name):
        self.name = name
        self.numFixedCols = 0
        self.fixedBytes = 0
        self.numVarCols = 0
        self.minVarBytes = 0
        self.maxVarBytes = 0
        
        # info for simple columns; dict of:
        # type: # of columns of that type
        self.simpleColInfo = dict()
        # info for user-adjustable adjustable columns; dict of:
        # type: list of widths or of (width0, width1) of that type
        self.userColInfo = dict()
    
    def addCol(self, line):
        line = line.lower()
        lineWords = line.split(None, 1)
        if len(lineWords) < 2:
            return
        if lineWords[0] in self.SkipCols:
            return
        typeWord = lineWords[1].split("comment", 1)[0]
            
        # special cases
        if typeWord.startswith("double"):
            self.addSimpleFixed("double")
            return
        
        if typeWord.startswith("enum"):
            numItems = len(typeWord.split(","))
            self.addEnum(numItems)
            return
    
        if typeWord.startswith("set"):
            numItems = len(typeWord.split(","))
            self.addSet(numItems)
            return
    
        dataTypeMatch = self.DataTypeRE.match(typeWord)
        if not dataTypeMatch:
            # not an error yet -- need to handle keys and such first
            # but I'm not sure the details so just report it for now
            raise RuntimeError("No match for %s" % (typeWord,))
        
        dataType, size0, size1 = dataTypeMatch.groups()
        if dataType in self.SimpleFixedSizes:
            self.addSimpleFixed(dataType)
        elif dataType in self.DecimalCols:
            self.addDecimal(dataType, size0, size1)
        elif dataType in self.UserFixedCols:
            self.addUserFixed(dataType, size0)
        elif dataType in self.SimpleVarSizes:
            self.addSimpleVar(dataType)
        elif dataType in self.UserVarCols:
            self.addUserVar(dataType, size0)
    
    def addDecimal(self, dataType, m, d):
        """Add a decimal or numeric column
        """
        dataType = dataType.lower()
        if dataType not in self.DecimalCols:
            raise RuntimeError("%s not in DecimalCols = %s" % \
            (dataType, self.DecimalCols))
        m = int(m)
        d = int(d)
        if m < d:
            raise RuntimeError(
                "number of digits m = %d < number after decimal d = %d" % (m, d)
            )
        self.numFixedCols += 1
        for ndig in (m - d, d):
            self.fixedBytes += self.getDecimalBytes(ndig)
        self.userColInfo[dataType] = (m, d)
    
    def addEnum(self, numItems):
        """Add an enum column"""
        numItems = int(numItems)
        if numItems > MaxEnumItems:
            raise RuntimeError("Invalid enum %s: more than %s items." % \
                (firstWord, MaxEnumItems))
        self.numFixedCols += 1
        if numItems <= 255:
            self.fixedBytes += 1
        else:
            self.fixedBytes += 2
        self.userColInfo["enum"] = numItems
    
    def addSet(self, numItems):
        """Add a set column"""
        numItems = int(numItems)
        if numItems > MaxSetItems:
            raise RuntimeError("Invalid set %s: more than %s items." % \
                (firstWord, MaxSetItems))

        numBytes = int(math.ceil(numItems + 7.0) / 8.0)
        if numBytes > 4:
            numBytes = 8
        self.numFixedCols += 1
        self.fixedBytes += numBytes
        self.userColInfo["set"] = numItems
    
    def addSimpleFixed(self, dataType):
        """Add a simple (non-user-settable) colum with a fixed size, e.g. int.
        dataType must be a single word that is in SimpleFixedSizes.
        """
        dataType = dataType.lower()
        self.numFixedCols += 1
        self.fixedBytes += self.SimpleFixedSizes[dataType]
        currCount = self.simpleColInfo.get(dataType, 0)
        self.simpleColInfo[dataType] = currCount + 1
    
    def addSimpleVar(self, dataType):
        """Add a simple colum with data-dependent size, e.g. text.
        """
        dataType = dataType.lower()
        minumBytes, maxBytes = self.SimpleVarSizes[dataType]
        self.minVarBytes += minumBytes
        self.maxVarBytes += maxBytes
        self.numVarCols += 1
        currCount = self.simpleColInfo.get(dataType, 0)
        self.simpleColInfo[dataType] = currCount + 1
    
    def addUserFixed(self, dataType, numBytes):
        """Add user-set width column with fixed size, e.g. char.
        """
        dataType = dataType.lower()
        numBytes = int(numBytes)
        if dataType not in self.UserFixedCols:
            raise RuntimeError("%s not in %s" % (dataType, self.UserFixedCols))
        self.numFixedCols += 1
        self.fixedBytes += numBytes
        self.userColInfo[dataType] = numBytes
    
    def addUserVar(self, dataType, maxChars):
        """Add user-set width column with data-dependent size, e.g. varchar.
        """
        dataType = dataType.lower()
        maxChars = int(maxChars)
        extraBytes = 0
        temp = maxChars
        while temp > 0:
            temp = temp // 256
            extraBytes += 1
        self.minVarBytes += extraBytes
        self.maxVarBytes += maxChars + extraBytes
        self.numVarCols += 1
        self.userColInfo[dataType] = maxChars
    
    def getDecimalBytes(self, ndig):
        if ndig < 0:
            raise ValueError("ndig = %s < 0" % (ndig,))
        return (4 * (ndig // 9)) + (((ndig % 9) + 1) // 2)
    
    def __str__(self):
        return "Table %s: %s fixed bytes in %s cols; %s-%s var bytes in %d cols" % \
            (self.name, self.fixedBytes, self.numFixedCols,
            self.minVarBytes, self.maxVarBytes, self.numVarCols)

def run():
    lineNum = 0
    tableList = list()
    tableInfo = None
    for line in sys.stdin:
        lineNum += 1
        line = line.strip()
        if not line:
            continue
        if line.startswith("--"):
            continue
        
        if not tableInfo:
            if line.lower().split()[0:2] == ["create", "table"]:
                tableName = line.split()[2]
                tableInfo = TableInfo(tableName)
                tableList.append(tableInfo)
            continue
        
        if line.startswith("("):
            continue
        if line.startswith(")"):
            tableInfo = None
            continue
        
        try:
            tableInfo.addCol(line)
        except Exception, e:
            print "Error on line %d: %s; line=\n%s" % (lineNum, e, line)
            raise
            
    for tableInfo in tableList:
        print "Details for table %s" % (tableInfo.name)
        print "Simple fields (# of each):"
        keys = tableInfo.simpleColInfo.keys()
        keys.sort()
        for key in keys:
            print "  %s\t%s" % (key, tableInfo.simpleColInfo[key])
        print "User-set width fields (sizes of each):"
        keys = tableInfo.userColInfo.keys()
        keys.sort()
        for key in keys:
            print "  %s\t%s" % (key, tableInfo.userColInfo[key])
        print
    
    print "Summary"
    print "Table\tFixedBytes\tFixedCols\tMinVarBytes\tMaxVarBytes\tVarCols"
    for tableInfo in tableList:
        print "%s\t%s\t%s\t%s\t%s\t%s" % (tableInfo.name,
        tableInfo.fixedBytes, tableInfo.numFixedCols,
        tableInfo.minVarBytes, tableInfo.maxVarBytes, tableInfo.numVarCols)

if __name__ == "__main__":
    run()
