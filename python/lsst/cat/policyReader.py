#!/usr/bin/env python

from lsst.pex.logging import Log
import lsst.pex.policy as pexPolicy

import os

class PolicyReader:
    def __init__(self, fullPath=None):
        if fullPath is None:
            pDir = os.environ["CAT_DIR"]
            if pDir is None:
                raise RuntimeError('CAT_DIR env var required')
            fullPath = os.path.join(pDir, 'policy/defaultProdCatPolicy.paf')
        self.policyObj = pexPolicy.Policy.createPolicy(fullPath)
        log = Log(Log.getDefaultLog(), "cat")
        log.log(Log.DEBUG, 'Reading policy from %s' % fullPath)

    def readAuthInfo(self):
        subP = self.policyObj.getPolicy('database.authinfo')
        host = subP.getString('host')
        port = subP.getInt('port')
        return (host, port)
    
    def readGlobalSetup(self):
        subP = self.policyObj.getPolicy('database.globalSetup')
        gDb = subP.getString('globalDbName')
        dcVer = subP.getString('dcVersion')
        dcDb = subP.getString('dcDbName')
        minDiskSp = subP.getInt('minPercDiskSpaceReq')
        uRunLife = subP.getInt('userRunLife')
        return (gDb, dcVer, dcDb, minDiskSp, uRunLife)

    def readRunCleanup(self):
        subP = self.policyObj.getPolicy('database.runCleanup')
        firstN = subP.getInt('daysFirstNotice')
        finalN = subP.getInt('daysFinalNotice')
        return (firstN, finalN)
