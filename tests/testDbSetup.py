#!/usr/bin/env python

from lsst.cat.dbSetup import DbSetup
from lsst.cat.policyReader import PolicyReader

import getpass

r = PolicyReader()
(host, port) = r.readAuthInfo()
(gDb, dcVer, dcDb, dummy1, dummy2) = r.readGlobalSetup()

usr = raw_input("Enter mysql account name: ")
pwd = getpass.getpass()

x = DbSetup(host, port, usr, pwd, dcVer)
x.setupUserDb()
