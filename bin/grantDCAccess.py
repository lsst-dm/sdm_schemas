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

import getpass
import logging
import optparse
import os
import re
import sys

# local 
from lsst.cat.dbCat import DbCat

"""
This script grants appropriate data-challenge-specific privileges for all users
except these that already have super-user grant and "test"
"""


usage = """
%prog [-c hostToAuthorize] [-f optionFile]

Where:
  hostToAuthorize
      host name authorized to access mysql server. Wildcards are allowed. 
      Default: "%" (all hosts)

  optionFile
      Option file. The option file must contain [mysql] section and standard
      connection/credential information, e.g. host/port or socket, user name,
      password. Default: ~/.lsstAdm.my.cnf.
"""


parser = optparse.OptionParser(usage)
parser.add_option("-c")
parser.add_option("-f")

options, arguments = parser.parse_args()

hostToAuth = options.c if options.c is not None else '%'
optionFile = options.f if options.f is not None else "~/.lsstAdm.my.cnf"

globalDbName = "GlobalDB"

# FIXME: this is obsolete, see ticket #3127
dcVersion = "DC3b"

grantAll = re.compile('GRANT ALL PRIVILEGES ON \*.\* TO')

logging.basicConfig(
    format='%(asctime)s %(name)s %(levelname)s: %(message)s', 
    datefmt='%m/%d/%Y %I:%M:%S', 
    level=logging.DEBUG)

db = DbCat(read_default_file=optionFile)
db.useDb(globalDbName)

users = db.execCommandN('SELECT user, host from mysql.user WHERE ' +
                        'user != "root" AND user != "sysbench" AND user != "test"')
for u in users:
    grants = db.execCommandN("SHOW GRANTS FOR '%s'@'%s'" % u)
    isSU = 0
    for g in grants:
        if grantAll.match(g[0]):
            isSU = 1
    if isSU:
        logger = logging.getLogger('cat.grantDbAccess')
        logger.info("Skipping superuser %s" % u[0])
    else:
        toStr = "TO `%s`@`%s`" % (u[0], hostToAuth)
        cmd = "GRANT SELECT, INSERT ON `%s\_DB`.* %s" % (dcVersion, toStr)
        db.execCommand0(cmd)
