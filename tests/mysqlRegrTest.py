#!/usr/bin/env python
# 
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
import sys

from lsst.db.db import Db


"""
   This script runs various regression tests. It should be 
   executed using a non-administrative account.
"""

logging.basicConfig(
    format='%(asctime)s %(name)s %(levelname)s: %(message)s', 
    datefmt='%m/%d/%Y %I:%M:%S', 
    level=logging.DEBUG)

db = Db(read_default_file="~/.lsst.my.cnf")
db.useDb('rplante_DC3b_u_pt11final')

r = db.execCommand1("SELECT utcToTai(5)")
r = db.execCommand1("SELECT taiToUtc(%s)" % r)
assert(r[0] == 5)

r = db.execCommandN("SHOW TABLES")
assert (len(r) > 0)

r = db.execCommand1("SELECT COUNT(*) FROM Object")
assert (r[0] > 0)
