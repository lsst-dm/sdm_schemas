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



from lsst.cat.DbCat import DbCat
import os
import subprocess
import sys


class DbSetup(DbCat):
    """
    This file contains a set of utilities to manage per-user databases
    """

    def __init__(self, dbHostName, portNo, userName, userPwd):
        DbCat.__init__(self, host=dbHostName, port=portNo)
        self._sqlDir = os.path.join(os.environ["CAT_DIR"], "sql")
        if not os.path.exists(self._sqlDir):
            raise RuntimeError("Directory '%s' not found" % self._sqlDir)
        self._userDb = '%s_dev' % userName

    def setupUserDb(self):
        """
        Set up user database (create and load stored procedures/functions).
        If it exists, it will remove it first.
        """
        dbScripts = [os.path.join(self._sqlDir, "lsstSchema4mysql.sql"),
                     os.path.join(self._sqlDir, "setup_storedFunctions.sql")]
        for f in dbScripts:
            if not os.path.exists(f):
                raise RuntimeError("Can't find file '%s'" % f)
        self.dropUserDb()
        self.createDb(self._userDb)
        for f in dbScripts:
            self.loadSqlScript(f, self._userDb)

    def dropUserDb(self):
        self.dropDb(self._userDb, mustExist=False)
