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
import os


r = PolicyReader()
(host, port) = r.readAuthInfo()

usr = raw_input('Enter mysql user name: ')
pwd = getpass.getpass()

dbn = 'dummy_Test_DB_375Ef_4DRf56'
sqlDir = os.path.join(os.environ["CAT_DIR"], 'sql')

x = MySQLBase(host, port)
x.connect(usr, pwd)

throwOnFailure = True
assert not x.dbExists(dbn), 'Db %s should not exist' % dbn
x.createDb(dbn)
x.dbExists(dbn, throwOnFailure), 'Db %s should exist' % dbn
x.connect(usr, pwd, dbn)
assert not x.tableExists('xyz'), 'Table should not exist'
x.loadSqlScript(os.path.join(sqlDir, 'setup_DB_global.sql'), usr, pwd, dbn)
x.tableExists('RunInfo', throwOnFailure)
x.dropDb(dbn)
assert not x.dbExists(dbn), "droppped db '%s', but still exists" % dbn
