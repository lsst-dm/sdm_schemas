#!/usr/bin/env python

from lsst.cat.MySQLBase import MySQLBase
from lsst.cat.policyReader import PolicyReader
from lsst.daf.persistence import DbAuth

import getpass
import optparse
import os
import sys


usage = """%prog -f policyFile

Destroys the Global Database and the data-challange specific database.
"""

parser = optparse.OptionParser(usage)
parser.add_option("-f")

options, arguments = parser.parse_args()
if not options.f:
    sys.stderr.write(os.path.basename(sys.argv[0]) + usage[5:])
    sys.exit(1)


r = PolicyReader(options.f)
(serverHost, serverPort) = r.readAuthInfo()
(globalDbName, dcVersion, dcDbName, dummy1, dummy2) = r.readGlobalSetup()


print """
   ** WARNING **
   You are attempting to destroy the '%s' database 
   and the '%s' database.
""" % (globalDbName, dcDbName)
rrr = raw_input("Press 'y' to proceed, any other character to abort... ")
if ( rrr != 'y' ):
    print 'Aborted'
    exit(0)

if DbAuth.available(serverHost, str(serverPort)):
    dbSUName = DbAuth.username(serverHost, str(serverPort))
    dbSUPwd = DbAuth.password(serverHost, str(serverPort))
else:
    print "Authorization unavailable for %s:%s" % (serverHost, serverPort)
    dbSUName = raw_input("Enter mysql superuser account name: ")
    dbSUPwd = getpass.getpass()

def destroyOne(x, dbName):
    if x.dbExists(dbName):
        x.dropDb(dbName)
        print "Destroyed '%s'." % dbName
    else:
        print "Db '%s' does not exist." % dbName

x = MySQLBase(serverHost, serverPort)
x.connect(dbSUName, dbSUPwd)
destroyOne(x, globalDbName)
destroyOne(x, dcDbName)
x.disconnect()
