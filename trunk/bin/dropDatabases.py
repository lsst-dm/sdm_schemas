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


from lsst.cat.MySQLBase import MySQLBase
from lsst.cat.policyReader import PolicyReader

import getpass
import optparse
import os
import sys


usage = """

%prog -u <username> [-p <matchingPattern>] [-f <policyFile>]

Drops databases for given user. If matching pattern is not specified, it will drop all databases. If matching pattern is specified, it will match any database that name contains given pattern anywhere after the "<username>_".

Requires $CAT_ENV environment variable.

If the policy file is not specified, the default
one will be used: $CAT_DIR/policy/defaultProdCatPolicy.paf

"""


class DropDatabases(MySQLBase):
    def __init__(self, dbUName, dbHostName, portNo, globalDbName, dcVersion, dcDb):
        MySQLBase.__init__(self, dbHostName, portNo)

        if globalDbName == "":
            raise RuntimeError("Invalid (empty) global db name")
        self.globalDbName = globalDbName

        if dcVersion == "":
            raise RuntimeError("Invalid (empty) dcVersion name")
        self.dcVersion = dcVersion

        if dcDb == "":
            raise RuntimeError("Invalid (empty) dc db name")
        self.dcDbName = dcDb

        # Pull in sqlDir from CAT_DIR
        self.sqlDir = os.getenv('CAT_DIR')
        if not self.sqlDir:
            raise RuntimeError('CAT_DIR env variable not set')
        self.sqlDir = os.path.join(os.environ["CAT_DIR"], "sql")
        if not os.path.exists(self.sqlDir):
            raise RuntimeError("Directory '%s' not found" % self.sqlDir)

        self.dbUName = dbUName
        self.dbUPwd = getpass.getpass("MySQL password for user '%s': " % dbUName)

    def run(self, pattern):
        self.connect(self.dbUName, self.dbUPwd, self.globalDbName)

        if pattern:
            pattern = '%s_%%%s%%' % (self.dbUName, pattern)
        else:
            pattern = "%s_%%" % self.dbUName

        cmd = """
  SELECT dbName
  FROM   RunInfo
  WHERE  dbName LIKE '%s'
     AND delDate IS NULL
""" % pattern
        dbs = self.execCommandN(cmd)
        for dbN in dbs:
            print 'Deleting %s' % dbN
            self.dropDb(dbN)
            self.execCommand0("SELECT setRunDeleted('%s')" % dbN)
        self.disconnect()


parser = optparse.OptionParser(usage)
parser.add_option("-f")
parser.add_option("-p")
parser.add_option("-u")

options, arguments = parser.parse_args()

if not options.u:
    sys.stderr.write(os.path.basename(sys.argv[0]) + usage[7:])
    sys.exit(1)

if options.p:
    pattern = options.p

r = PolicyReader(options.f)
(serverHost, serverPort) = r.readAuthInfo()
(globalDbName, dcVersion, dcDb, dummy1, dummy2) = r.readGlobalSetup()

x = DropDatabases(options.u, serverHost, serverPort, 
                  globalDbName, dcVersion, dcDb)
x.run(options.p)
