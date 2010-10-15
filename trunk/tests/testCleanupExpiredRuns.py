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


from lsst.cat.administerRuns import AdminRuns
from lsst.cat.policyReader import PolicyReader
from lsst.cat.MySQLBase import MySQLBase

import getpass
import os
import subprocess

catDir = os.environ["CAT_DIR"]
policyF = os.path.join(catDir, 'policy/defaultTestCatPolicy.paf')


r = PolicyReader(policyF)
(host, port) = r.readAuthInfo()
(gDb, dcV, dcDb, minPercDiskSpaceReq, userRunLife) = r.readGlobalSetup()



sqlDir = os.path.join(catDir, "sql")


# dummy mysql users + passwords
u1 = "jacek_test"
p1 = "j"
u2 = "jacek_test2"
p2 = "j2"


rootU = raw_input("Enter mysql superuser account name: ")
rootP = getpass.getpass()


maxNIter = 30


def dropTestDbs():
    admin = MySQLBase(host, port)
    admin.connect(rootU, rootP)
    admin.dropDb(gDb)
    for n in range(1, maxNIter):
        admin.dropDb("%s_%s_u_myRun_%02i" % (u1, dcV, n))
        admin.dropDb("%s_%s_u_myRun_%02i" % (u2, dcV, n))

def resetGlobalDb():
    x = os.path.join(catDir, 'bin/destroyGlobal.py')
    cmd = '%s -f %s' % (x, policyF)
    subprocess.call(cmd.split())

    x = os.path.join(catDir, 'bin/setupGlobal.py')
    cmd = '%s -f %s' % (x, policyF)
    subprocess.call(cmd.split())



def createDummyUserAccounts():
    """
    This function makes sure the dummy user accounts required by this test
    program exist. In normal operations, these accounts should already exist
    prior to running anything.
    """
    x = os.path.join(catDir, 'bin/addMySqlUser.py')
    cmd = '%s -f %s -u %s -p %s' % (x, policyF, u1, p1)
    subprocess.call(cmd.split())
    cmd = '%s -f %s -u %s -p %s' % (x, policyF, u2, p2)
    subprocess.call(cmd.split())


dropTestDbs()
resetGlobalDb()
createDummyUserAccounts()


# one connection per user
a1 = AdminRuns(host, port, gDb, dcV, dcDb, minPercDiskSpaceReq, userRunLife)
a2 = AdminRuns(host, port, gDb, dcV, dcDb, minPercDiskSpaceReq, userRunLife)


a1.checkStatus(u1, p1, 'dummy') # non-superuser name and password
a2.checkStatus(u2, p2, 'dummy') # non-superuser name and password


b = MySQLBase(host, port)
bSU = MySQLBase(host, port)

outLogFile = open("./_cleanup.log", "w")

# u1 starts regularly one run per day, extend a couple of runs
# u2 starts regularly one run every 3 days
for n in range(1, maxNIter):
    print "\n\n************** doing ", n, " **************\n"

    a1.prepareForNewRun("myRun_%02i"%n, u1, p1)

    # manually adjust the run start time, notice, have to run as su
    bSU.connect(rootU, rootP, gDb)
    bSU.execCommand0("""
      UPDATE RunInfo 
      SET startDate = ADDTIME('2008-05-01 15:00:00', '%i 00:00:00'),
          expDate   = ADDTIME('2008-05-14 15:00:00', '%i 00:00:00')
      WHERE runName = 'myRun_%02i' 
        AND initiator = '%s'
""" % (n, n, n, u1))
    bSU.disconnect()

    # If it is May 18, extend 5th run
    if n == 18:
        b.connect(u1, p1, gDb)
        b.execCommand0("SELECT extendRun('myRun_05', '%s', '%s')" % (dcV, u1))
        b.disconnect()
    # If it is May 19 extend 15th run
    if n == 19:
        b.connect(u1, p1, gDb)
        b.execCommand0("SELECT extendRun('myRun_15', '%s', '%s')" % (dcV, u1))
        b.disconnect()

    if n % 3 == 1:
        a2.prepareForNewRun("myRun_%02i"%n, u2, p2);

    # manually adjust the run start time
    bSU.connect(rootU, rootP, gDb)
    bSU.execCommand0("""
      UPDATE RunInfo 
      SET startDate = ADDTIME('2008-05-01 15:00:00', '%i 00:00:00'),
          expDate   = ADDTIME('2008-05-14 15:00:00', '%i 00:00:00')
      WHERE runName = 'myRun_%02i' 
        AND initiator = '%s'

""" % (n, n, n, u2))
    bSU.disconnect()

    print "Currently have:"
    a2.connect(u2, p2, gDb)
    res = a2.execCommandN("SELECT * FROM RunInfo")
    a2.disconnect()

    for r in res:
        print r

    print "\n\n******** now running cleanup script **********\n"

    x = os.path.join(catDir, 'bin/cleanupExpiredRuns.py')
    cmd = '%s -f %s -d 2008-05-%i -g %s' % (x, policyF, n, gDb)

    print "calling ", cmd
    subprocess.call(cmd.split(), stdout=outLogFile)


outLogFile.close()
