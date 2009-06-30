#!/usr/bin/env python

from lsst.cat.MySQLBase import MySQLBase
import os
import subprocess
import sys


class DbSetup:
    """
    This file contains a set of utilities to manage per-user databases
    """

    def __init__(self, dbHostName, portNo, userName, userPwd, dcVer):
        self.dbBase = MySQLBase(dbHostName, portNo)

        if userName == "":
            raise RuntimeError("Invalid (empty) userName")
        self.userName = userName
        self.userPwd = userPwd
        self.dcVer = dcVer
        self.sqlDir = os.path.join(os.environ["CAT_DIR"], "sql")
        if not os.path.exists(self.sqlDir):
            raise RuntimeError("Directory '%s' not found" % self.sqlDir)
        self.userDb = '%s_dev' % userName


    def setupUserDb(self):
        """
        Sets up user database (creates and loads stored procedures/functions).
        Database name: <userName>_dev.
        If the database exists, it will remove it first.
        """

        # prepare list of sql scripts to load and verify they exist
        fN = "lsstSchema4mysql%s.sql" % self.dcVer
        dbScripts = [os.path.join(self.sqlDir, fN),
                     os.path.join(self.sqlDir, "setup_storedFunctions.sql")]
        for f in dbScripts:
            if not os.path.exists(f):
                raise RuntimeError("Can't find file '%s'" % f)

        # (re-)create database
        self.dbBase.connect(self.userName, self.userPwd)
        if self.dbBase.dbExists(self.userDb):
            self.dbBase.dropDb(self.userDb)
        self.dbBase.createDb(self.userDb)
        self.dbBase.disconnect()

        # load the scripts
        for f in dbScripts:
            self.dbBase.loadSqlScript(f, self.userName, 
                                      self.userPwd, self.userDb)


    def dropUserDb(self):
        self.dbBase.connect(self.userName, self.userPwd)
        if self.dbBase.dbExists(self.userDb):
            self.dbBase.dropDb(self.userDb)
        self.dbBase.disconnect()
