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


# standard library
import os

#third-party

#local
import lsst.pex.policy as pexPolicy


class PolicyReader(object):
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
