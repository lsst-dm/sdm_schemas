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

"""
This module provides a low-level basic database utilities. It relies on the generic
db wrapper, and adds cat-specific functionality on top.

@author  Jacek Becla, SLAC

Known issues:
 * None
"""

# standard library
import logging
import os
import sys

# third-party library

# local
from lsst.db.db import Db


####################################################################################
class DbCat(Db):
    """
    @brief Cat-specific database wrapper.

    This class implements basic database functionality, tuned for cat needs.
    """
    def __init__(self, **kwargs):
        Db.__init__(self, **kwargs)

    def getDataDirSpaceAvailPerc(self):
        """
        Return space available in mysql datadir (percentage volume available).
        Note, this works only if executed on the database server.
        """
        row = self.execCommand1("SHOW VARIABLES LIKE 'datadir'")
        mysqlDataDir = row[1]
        st =  os.statvfs(mysqlDataDir)
        return 100 * st.f_bavail / st.f_blocks

    def getDataDirSpaceAvail(self):
        """
        Return space available in mysql datadir (in kilobytes).
        Note, this works only if executed on the database server.
        """
        row = self.execCommand1("SHOW VARIABLES LIKE 'datadir'")
        mysqlDataDir = row[1]
        st =  os.statvfs(mysqlDataDir)
        return st.f_bfree * st.f_bsize / 1024
