#!/usr/bin/env python

import getpass
import optparse
import os
import sys

from lsst.cat.dbCat import DbCat

"""
   This script runs a command specified below for all users
   except these that already have super-user grant
"""

db = DbCat(optionFile="~/lsst.admin.cnf")

def showGrantsForAllUsers():
    users = db.execCommandN('SELECT user from mysql.user')
    for u in users:
        grants = db.execCommandN("SHOW GRANTS FOR '%s'" % u)
        print 'grants for user %s ' %u
        for g in grants:
            print '   ', g

users = db.execCommandN('SELECT DISTINCT(user) FROM mysql.tables_priv')
for u in users:
    toStr = "TO `%s`@`%%`" % u
    admin.execCommand0("GRANT ALL ON `%s\_%%`.* %s" % (userName, toStr))
    print(cmd)
    # admin.execCommand0(cmd)



