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


from lsst.cat.DbCat import DbCat
from lsst.cat.policyReader import PolicyReader

import getpass
import optparse
import os
import sys


usage = """%prog -f policyFile

Destroys the Global Database and the data-challange specific database.
"""

parser = optparse.OptionParser(usage)
parser.add_option("-f")

options, arguments = parser.parse_args()
if not options.f:
    sys.stderr.write(os.path.basename(sys.argv[0]) + usage[5:])
    sys.exit(1)


r = PolicyReader(options.f)
(serverHost, serverPort) = r.readAuthInfo()
(globalDbName, dcVersion, dcDbName, dummy1, dummy2) = r.readGlobalSetup()


print """
   ** WARNING **
   You are attempting to destroy the '%s' database 
   and the '%s' database - think twice before proceeding!
""" % (globalDbName, dcDbName)


dbSUName = raw_input("Enter mysql superuser account name: ")
dbSUPwd = getpass.getpass()

db = DbCat(host=serverHost, port=serverPort, userName=dbSUName, passwd=dbSUPwd)

for dbName in [globalDbName, dcDbName]
    if db.dbExists(dbName):
        db.dropDb(dbName, mustExist=False)
        print "Destroyed '%s'." % dbName
    else:
        print "Db '%s' does not exist." % dbName
