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
import logging
import optparse
import os
import sys

# third-party library

# local
from lsst.cat.dbCat import DbCat

"""
This script adds mysql user, including setting up all needed authorizations to run
DCx runs. User will be able to start runs, and extend runs' expiration time.
Notice that users won't be able to hack in and extend runs by calling 'UPDATE' by
hand.
"""


usage = """
%prog -u userNameToAuthorize -p userPassword [-c hostToAuthorize] [-f optionFile]

Where:
  userNameToAuthorize
      mysql username of the user that is being added

  userPassword
      mysql password of the user that is being added

  hostToAuthorize
      host name authorized to access mysql server. Wildcards are allowed. 
      Default: "%" (all hosts)

  optionFile
      Option file. The option file must contain [mysql] section and standard
      connection/credential information, e.g. host/port or socket, user name,
      password. Default: ~/.lsstAdm.my.cnf.
"""


parser = optparse.OptionParser(usage)
parser.add_option("-u")
parser.add_option("-p")
parser.add_option("-c")
parser.add_option("-f")

options, arguments = parser.parse_args()

if options.u is None or options.p is None:
    sys.stderr.write(os.path.basename(sys.argv[0]) + usage[6:])
    sys.exit(1)
newUserName = options.u
newUserPass = options.p
hostToAuth = options.c if options.c is not None else '%'
optionFile = options.f if options.f is not None else "~/.lsstAdm.my.cnf"

# FIXME: this is obsolete, see ticket #3127
globalDbName = "GlobalDB"
dcVersion = "DC3b"

logging.basicConfig(
    format='%(asctime)s %(name)s %(levelname)s: %(message)s', 
    datefmt='%m/%d/%Y %I:%M:%S', 
    level=logging.DEBUG)

admin = DbCat(read_default_file=optionFile)
admin.useDb(globalDbName)

toStr = "TO `%s`@`%s`" % (newUserName, hostToAuth)

isNewUser = True
if admin.userExists(newUserName, hostToAuth):
    isNewUser = False
    print ('\n*** This account already exists, upgrading priviledges. ' +
          'User password will not change.***\n')
else:
    toStr += " IDENTIFIED BY '%s'" % newUserPass

admin.execCommand0("GRANT ALL ON `%s\_%%`.* %s" % (newUserName, toStr))

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

if isNewUser:
    admin.execCommand0("CALL scisql.scisql_grantPermissions('%s', '%s')" % \
                           (newUserName, hostToAuth))

print "User '%s' added." % newUserName
