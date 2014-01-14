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
import lsst.pex.policy as pexPolicy


import getpass
import optparse
import os
import sys

"""
   This script runs various regression tests. It should be 
   executed using a non-administrative account.
"""

policyObj = pexPolicy.Policy.createPolicy(os.environ['HOME'] + '/.lsst/db-auth.paf')
subP = policyObj.getPolicy('database.authInfo')
host = subP.getString('host')
port = subP.getInt('port')
user = subP.getString('user')
pswd = subP.getString('password')

admin = MySQLBase(host, port)
admin.connect(user, pswd, 'rplante_DC3b_u_pt11final')

r = admin.execCommand1("SELECT utcToTai(5)")
r = admin.execCommand1("SELECT taiToUtc(%s)" % r)
assert(r[0] == 5)

r = admin.execCommandN("SHOW TABLES")
assert (len(r) > 0)

r = admin.execCommand1("SELECT COUNT(*) FROM Object")
assert (r[0] > 0)
