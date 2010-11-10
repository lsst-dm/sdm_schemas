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


import optparse
import os
import re
import sys

###############################################################################
# Configuration information
###############################################################################

# Tagged values for columns in EA that map directly to fields in the metadata.
columnTags = ["description", "type", "ucd", "unit"]

# Tagged values for columns in EA that need renaming.
remapTags = {"duplicates" : "notNull"}

# Fields for tables in the metadata (values obtained with custom code).
tableFields = ["engine",  "description"]

# Fields for columns in the metadata.  Any not listed in the Tags variables
# are generated using custom code.
columnFields = ["description", "type", "notNull", "defaultValue",
    "unit", "ucd", "displayOrder"]

# Fields with numeric contents.
numericFields = ["notNull", "displayOrder"]

###############################################################################
# DDL for creating database and tables
###############################################################################

databaseDDL = """
DROP DATABASE IF EXISTS lsst_schema_browser;
CREATE DATABASE lsst_schema_browser;
USE lsst_schema_browser;

"""

# Names of fields in these tables after "name" must match the names in the
# Fields variables above.

tableDDL = """
CREATE TABLE md_Table (
	tableId INTEGER NOT NULL UNIQUE PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE,
	engine VARCHAR(255),
	description VARCHAR(255)
);

CREATE TABLE md_Column (
	columnId INTEGER NOT NULL UNIQUE PRIMARY KEY,
	tableId INTEGER NOT NULL REFERENCES md_Table (tableId),
	name VARCHAR(255) NOT NULL,
	description VARCHAR(255),
	type VARCHAR(255),
	notNull INTEGER DEFAULT 0,
	defaultValue VARCHAR(255),
	unit VARCHAR(255),
	ucd VARCHAR(255),
        displayOrder INTEGER NOT NULL,
	INDEX md_Column_idx (tableId, name)
);

"""


###############################################################################
# Standard header to be prepended
###############################################################################

LSSTheader = """
-- LSST Database Metadata
-- $Revision$
-- $Date$
--
-- See <http://dev.lsstcorp.org/trac/wiki/Copyrights>
-- for copyright information.

"""

###############################################################################
# Usage and command line processing
###############################################################################

usage = """%prog exportFile_{version}.xml [-m {message}]

Everything between the first underscore and a trailing ".xml" in the argument
filename is taken as a version string.  Any non-alphanumeric characters in the
version string are translated to underscores ("_").

The file is translated from XML to SQL DML for loading the catalog metadata
tables with descriptions of each table and column in the catalog.  SQL DDL for
creating the metadata tables is prepended to the file.

A "CREATE TABLE AAA_Version_{version}" statement is also prepended to the
file, as is a standard comment header.

The file is renamed without the underscore and version string, and with .xml
changed to .sql.
"""

parser = optparse.OptionParser(usage)
options, arguments = parser.parse_args()

if len(arguments) != 1:
    sys.stderr.write(os.path.basename(sys.argv[0]) + usage[6:])
    sys.exit(1)
filename = arguments[0]

pos = filename.find("_")
if pos == -1 or filename[-4:] != ".xml":
    sys.stderr.write(os.path.basename(sys.argv[0]) + usage[6:])
    sys.exit(1)

origVersion = filename[pos + 1:-4]
r = re.compile(r'\W')
version = r.sub("_", origVersion)

destFilename = filename[0:pos] + ".sql"

src = open(filename, mode='r')
dest = open(destFilename, mode='wt')

dest.write(LSSTheader)
dest.write(databaseDDL)
dest.write("\nCREATE TABLE AAA_Version_" + version + " (version CHAR);\n\n")
dest.write(tableDDL)

###############################################################################
# Parse XML
###############################################################################

in_class = None
in_attr = None
type = ""
table = {}

classStart = re.compile(
    r'<UML:Class name="(\w+)" xmi.id="(\w+)" .* isRoot="false"')
classEnd = re.compile(r'</UML:Class>')
attrStart = re.compile(r'<UML:Attribute name="(\w+)"')
attrEnd = re.compile(r'</UML:Attribute>')
tag = re.compile(r'<UML:TaggedValue tag="(.+?)" value="(.+?)"')
expr = re.compile(r'<UML:Expression body="(.+?)"')
engineTag = re.compile(
  r'<UML:TaggedValue tag="(Type|ENGINE)" .* value="(.+?)" modelElement="(\w+)"')

colNum = 1
line = src.readline()

while line != "":

    m = classStart.search(line)
    if m is not None:
        if m.group(2) not in table:
            table[m.group(2)] = {}
        table[m.group(2)]["name"] = m.group(1)
        colNum = 1
        in_class = table[m.group(2)]
    elif classEnd.search(line):
        in_class = None

    if in_class is None:

        m = engineTag.search(line)
        if m is not None:
            table[m.group(3)]["engine"] = m.group(2)

    else:

        m = attrStart.search(line)
        if m is not None:
            in_attr = {"name" : m.group(1)}
            in_attr["displayOrder"] = str(colNum)
            colNum += 1
            if "columns" not in in_class:
                in_class["columns"] = []
            in_class["columns"].append(in_attr)
        elif attrEnd.search(line):
            in_attr = None

        m = tag.search(line)
        if in_attr is None:
            if m is not None and m.group(1) == "documentation":
                in_class["description"] = m.group(2)
        else:
            if m is not None:
                if m.group(1) in columnTags:
                    in_attr[m.group(1)] = m.group(2)
                elif m.group(1) in remapTags:
                    in_attr[remapTags[m.group(1)]] = m.group(2)
                elif m.group(1) == "length":
                    if in_attr["type"] == "CHAR" or \
                            in_attr["type"] == "VARCHAR":
                        in_attr["type"] += "(" + m.group(2) + ")"
            else:
                m = expr.search(line)
                if m is not None:
                    in_attr["defaultValue"] = m.group(1)

    line = src.readline()

###############################################################################
# Output DML
###############################################################################

def handleField(ptr, field, indent):
    if field not in ptr:
        return
    q = '"'
    if field in numericFields:
        q = ''
    dest.write(",\n")
    dest.write("".join(["\t" for i in xrange(indent)]))
    dest.write(field + " = " + q + ptr[field] + q)

tableId = 0
colId = 0
for k in sorted(table.keys(), key=lambda x: table[x]["name"]):
    t = table[k]
    tableId += 1
    dest.write("".join(["-- " for i in xrange(25)]) + "\n\n")
    dest.write("INSERT INTO md_Table\n")
    dest.write('SET tableId = %d, name = "%s"' % (tableId, t["name"]))
    for f in tableFields:
        handleField(t, f, 1)
    dest.write(";\n\n")

    if "columns" in t:
        for c in t["columns"]:
            colId += 1
            dest.write("\tINSERT INTO md_Column\n")
            dest.write('\tSET columnId = %d, tableId = %d, name = "%s"' %
                    (colId, tableId, c["name"]))
            for f in columnFields:
                handleField(c, f, 2)
            dest.write(";\n\n")
