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

# system library
import getpass
import logging
import optparse
import os
import sys

# local
from lsst.cat.dbCat import DbCat


usage = """
%prog [-f optionFile]

Setup LSST Global database and per-data-challenge database. 

Requires $CAT_ENV environment variable.

  optionFile
      Option file. The option file must contain [mysql] section and standard
      connection/credential information, e.g. host/port or socket, user name,
      password. Default: ~/.lsstAdm.my.cnf.
"""


class SetupGlobal(object):
    """
    Setup LSST Global database and per-data-challenge database.
    """
    def __init__(self, optionFile, globalDbName, dcVersion, dcDb):
        if globalDbName == "":
            raise RuntimeError("Invalid (empty) global db name")
        self._globalDbName = globalDbName
        if dcVersion == "":
            raise RuntimeError("Invalid (empty) dcVersion name")
        self._dcVersion = dcVersion
        if dcDb == "":
            raise RuntimeError("Invalid (empty) dc db name")
        self._dcDbName = dcDb
        # Pull in sqlDir from CAT_DIR
        self._sqlDir = os.getenv('CAT_DIR')
        if not self._sqlDir:
            raise RuntimeError('CAT_DIR env variable not set')
        self._sqlDir = os.path.join(os.environ["CAT_DIR"], "sql")
        if not os.path.exists(self._sqlDir):
            raise RuntimeError("Directory '%s' not found" % self._sqlDir)
        self._db = DbCat(read_default_file=optionFile)

    def run(self):
        """
        Create per-data-challenge database, and optionally (if it does not exist)
        the Global database. 
        """
        # create & configure Global database (if doesn't exist)
        if self._db.dbExists(self._globalDbName):
            print "'%s' exists." % self._globalDbName
        else:
            self._setupOnce(self._globalDbName, 'setup_DB_global.sql')
            print "Setup '%s' succeeded." % self._globalDbName
            
        # create and configure per-data-challange database (if doesn't exist)
        if self._db.dbExists(self._dcDbName):
            print "'%s' exists." % self._dcDbName
        else:
            self._setupOnce(self._dcDbName, 'setup_DB_dataChallenge.sql')
            # also load the regular per-run schema
            fN = "lsstSchema4mysql%s.sql" % self._dcVersion
            p = os.path.join(self._sqlDir, fN)
            self._db.loadSqlScript(p, self._dcDbName)
            print "Setup '%s' succeeded." % self._dcDbName

    def _setupOnce(self, dbName, setupScript):
        """
        Create database <dbName> and load script <setupScript>.
        """
        setupPath = os.path.join(self._sqlDir, setupScript)
        if not os.path.exists(setupPath):
            raise RuntimeError("Can't find schema file '%s'" % setupPath)
        self._db.createDb(dbName)
        self._db.loadSqlScript(setupPath, dbName)

####################################################################################
parser = optparse.OptionParser(usage)
parser.add_option("-f")

options, arguments = parser.parse_args()

optionFile = options.f if options.f is not None else "~/.lsstAdm.my.cnf"

# FIXME: this is obsolete, see ticket #3127
globalDbName = "globalDB"
dcVersion = "DC3a"
dcDb = "DC3a_DB"

logging.basicConfig(
    format='%(asctime)s %(name)s %(levelname)s: %(message)s', 
    datefmt='%m/%d/%Y %I:%M:%S', 
    level=logging.DEBUG)

x = SetupGlobal(optionFile, globalDbName, dcVersion, dcDb)
x.run()
