#!/usr/bin/env python

# LSST Data Management System
# Copyright 2008-2014 LSST Corporation.
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

# standard library
import getpass
import optparse
import os
import sys

# third-party library

# local
import lsst.pex.policy as pexPolicy
from lsst.cat.dbCat import DbCat
from lsst.cat.policyReader import PolicyReader

"""
   This script adds mysql user, including setting up all needed 
   authorizations to run DCx runs.
   User will be able to start runs, and extend runs' expiration time.
   Notice that users won't be able to hack in and extend runs by calling 
   'UPDATE' by hand
"""


usage = """%prog -u {userName} -p {userPassword} [-f {policyFile}] [-c {clientHost}] [-a {authFile}] 
Where:
  - userName:        mysql username of the added user
  - userPassword:    mysql password of the added user
  - clientHost:      host names authorized to access mysql server,
                     wildcards are allowed. Default: "%" (all hosts)
  - policyFile:      policy file. Default $CAT_DIR/policy/defaultProdCatPolicy.paf
  - authFile:        authorization file. Default ~/.lsst/db-auth.paf 
"""


parser = optparse.OptionParser(usage)
parser.add_option("-u")
parser.add_option("-p")
parser.add_option("-f")
parser.add_option("-c")
parser.add_option("-a")

options, arguments = parser.parse_args()

if not options.u or not options.p:
    sys.stderr.write(os.path.basename(sys.argv[0]) + usage[5:])
    sys.exit(1)

userName = options.u
userPass = options.p

if options.c:
    clientHost = options.c
else:
    clientHost = '%'

if options.a:
    dbAuthPolicy = options.a
else:
    dbAuthPolicy = os.environ['HOME'] + '/.lsst/db-auth.paf'

host = None
port = None
rootU = None
rootP = None
r = PolicyReader(options.f)

    
if os.path.isfile(dbAuthPolicy):
    policyObj = pexPolicy.Policy.createPolicy(dbAuthPolicy)
    subP = policyObj.getPolicy('database.authInfo')
    host = subP.getString('host')
    port = subP.getInt('port')
    rootU = subP.getString('admU')
    rootP = subP.getString('password')
else:
    rootU = raw_input("Enter mysql superuser account name: ")
    rootP = getpass.getpass()
    (host, port) = r.readAuthInfo()

(globalDbName, dcVersion, dcDb, dummy1, dummy2) = r.readGlobalSetup()

admin = DbCat(user=rootU, passwd=rootP, host=host, port=port)
admin.useDb(globalDbName)

toStr = "TO `%s`@`%s`" % (userName, clientHost)
if admin.userExists(userName, clientHost):
    print 'This account already exists, upgrading priviledges. User password will not change.'
else:
    toStr += " IDENTIFIED BY '%s'" % userPass

admin.execCommand0("GRANT ALL ON `%s\_%%`.* %s" % (userName, toStr))

# this is not needed because the mysql built-in annonymous
# account is used for databases starting with "test"
# See also: http://bugs.mysql.com/bug.php?id=47843
# admin.execCommand0("GRANT ALL ON `test%%`.* %s" % toStr)

admin.execCommand0("GRANT SELECT, INSERT ON `%s\_DB`.* %s" % (dcVersion, toStr))

admin.execCommand0("GRANT SELECT, INSERT ON %s.RunInfo %s" % \
                   (globalDbName, toStr))

admin.execCommand0("GRANT EXECUTE ON FUNCTION %s.extendRun %s" % \
                   (globalDbName, toStr))

admin.execCommand0("GRANT EXECUTE ON FUNCTION %s.checkIfUserCanStartRun %s" % \
                                      (globalDbName, toStr))

admin.execCommand0("GRANT EXECUTE, SELECT ON `%%\_%%`.* %s" % toStr)

admin.execCommand0("GRANT SELECT ON `Test`.* %s" % toStr)

admin.execCommand0("GRANT SHOW VIEW ON *.* %s" % toStr)

admin.execCommand0("CALL scisql.scisql_grantPermissions('%s', '%s')" % (userName, clientHost))

print "User '%s' added." % userName
