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


from __future__ import with_statement
import MySQLdb
import os
import subprocess
import sys

from lsst.pex.logging import Log

class MySQLBase(object):
    """
    MySQLBase class is a wrapper around MySQLdb. It contains a set of 
    low level basic database utilities such as connecting to database, 
    executing commands or loading sql scripts to database. It caches
    connections, and handles database errors.
    """
    def __init__(self, dbHostName, portNo=3306):
        self.dbHostName = dbHostName
        self.dbHostPort = portNo
        self.db = None
        self.dbOpened = None
        self.log = Log(Log.getDefaultLog(), "cat")
        # self.log.setThreshold(Log.DEBUG)

    def __del__(self):
        self.disconnect()

    def isConnected(self):
        return self.db != None

    def connect(self, dbUser, dbPassword, dbName=""):
        """
        It connects to database. If a connection is already open it will try to
        reuse it. If it can't it will disconnect it.
        """
        if self.isConnected():
            if self.dbOpened == dbName:
                return
            self.disconnect()
        try:
            self.db = MySQLdb.connect(host=self.dbHostName, 
                                      port=self.dbHostPort,
                                      user=dbUser, 
                                      passwd=dbPassword, 
                                      db=dbName)
        except MySQLdb.Error, e:
            raise RuntimeError("DB Error %d: %s. host=%s, port=%s, user=%s, pass=<hidden>" % \
                               (e.args[0], e.args[1], self.dbHostName, self.dbHostPort, dbUser))
        if dbName != "":
            self.dbOpened = dbName
        self.log.log(Log.DEBUG, "User %s connected to mysql://%s:%s/%s" %\
                     (dbUser, self.dbHostName, self.dbHostPort, dbName))

    def disconnect(self):
        if self.db == None:
            return
        try:
            self.db.commit()
            self.db.close()
        except MySQLdb.Error, e:
            raise RuntimeError("DB Error %d: %s" % (e.args[0], e.args[1]))
        self.log.log(Log.DEBUG, "Disconnected from db %s" % self.dbOpened)
        self.db = None
        self.dbOpened = None

    def createDb(self, dbName):
        self.execCommand0("CREATE DATABASE %s" % dbName)

    def dropDb(self, dbName):
        if self.dbExists(dbName):
            self.execCommand0("DROP DATABASE %s" % dbName)

    def dbExists(self, dbName, throwOnFailure=False):
        if dbName is None:
            raise RuntimeError("Invalid dbName")
        cmd = "SELECT COUNT(*) FROM information_schema.schemata "
        cmd += "WHERE schema_name = '%s'" % dbName
        count = self.execCommand1(cmd)
        if count[0] == 1:
                return True
        if throwOnFailure:
            raise RuntimeError("Database '%s' does not exist." % (dbName))
        return False

    def tableExists(self, tableName, throwOnFailure=False):
        if self.dbOpened is None:
            raise RuntimeError("Not connected to any database")
        cmd = "SELECT COUNT(*) FROM information_schema.tables "
        cmd += "WHERE table_schema = '%s' AND table_name = '%s'" % \
               (self.dbOpened, tableName)
        count = self.execCommand1(cmd)
        if count[0] == 1:
            return True
        if throwOnFailure:
            raise RuntimeError("Table '%s' does not exist in db '%s'." % \
                               (tableName, dbName))
        return False

    def userExists(self, userName, hostName):
        ret = self.execCommand1(
            "SELECT COUNT(*) FROM mysql.user WHERE user='%s' AND host='%s'" %\
            (userName, hostName))
        return ret[0] != 0

    def execCommand0(self, command):
        """
        Executes mysql commands which return no rows
        """
        return self.execCommand(command, 0)

    def execCommand1(self, command):
        """
        Executes mysql commands which return one rows
        """
        return self.execCommand(command, 1)

    def execCommandN(self, command):
        """
        Executes mysql commands which return multiple rows
        """
        return self.execCommand(command, 'n')

    def execCommand(self, command, nRowsRet):
        """
        Executes mysql commands which return any number of rows.
        Expected number of returned rows should be given in nRowSet
        """
        if not self.isConnected():
            raise RuntimeError("No connection (command: '%s')" % command)

        cursor = self.db.cursor()
        self.log.log(Log.DEBUG, "Executing %s" % command)
        cursor.execute(command)
        if nRowsRet == 0:
            ret = ""
        elif nRowsRet == 1:
            ret = cursor.fetchone()
            self.log.log(Log.DEBUG, "Got: %s" % str(ret))
        else:
            ret = cursor.fetchall()
            self.log.log(Log.DEBUG, "Got: %s" % str(ret))
        cursor.close()
        return ret

    def loadSqlScript(self, scriptPath, dbUser, dbPassword, dbName=""):
        """
        Loads sql script into the database.
        """
        if dbPassword:
            cmd = 'mysql -h%s -P%s -u%s -p%s %s' % \
                (self.dbHostName, self.dbHostPort, dbUser, dbPassword, dbName)
        else:
            cmd = 'mysql -h%s -P%s -u%s %s' % \
                (self.dbHostName, self.dbHostPort, dbUser, dbName)

        with file(scriptPath) as scriptFile:
            self.log.log(Log.DEBUG,
                         "Loading %s into db=%s on %s:%s, user=%s"% \
              (scriptPath, dbName, self.dbHostName, self.dbHostPort, dbUser))
            if subprocess.call(cmd.split(), stdin=scriptFile) != 0:
                raise RuntimeError("Failed to execute %s < %s" % \
                                       (cmd,scriptPath))

    # this works only if executed on database server. need to fix...
    def getDataDirSpaceAvailPerc(self):
        """
        Returns space available in mysql datadir (percentage volume available)
        """
        row = self.execCommand1("SHOW VARIABLES LIKE 'datadir'")
        mysqlDataDir = row[1]
        st =  os.statvfs(mysqlDataDir)
        return 100 * st.f_bavail / st.f_blocks

    def getDataDirSpaceAvail(self):
        """
        Returns space available in mysql datadir (in kilobytes)
        """
        row = self.execCommand1("SHOW VARIABLES LIKE 'datadir'")
        mysqlDataDir = row[1]
        st =  os.statvfs(mysqlDataDir)
        return st.f_bfree * st.f_bsize / 1024
