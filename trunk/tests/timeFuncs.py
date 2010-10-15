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


import unittest
import os
import re
import time

import lsst.daf.persistence as dafPersist
import lsst.cat.SqlScript as SqlScript

class TimeFuncTestCase(unittest.TestCase):
    """A test case for SQL time functions."""

    def setUp(self):
        testId = int(time.time() * 10.0)

        self.dbName = "test_%d" % testId
        dbUrl = "mysql://lsst10.ncsa.uiuc.edu:3306/" + self.dbName

        self.db = dafPersist.DbStorage()

        self.db.setRetrieveLocation(dafPersist.LogicalLocation(
            "mysql://lsst10.ncsa.uiuc.edu:3306/test"))
        self.db.startTransaction()
        self.db.executeSql("CREATE DATABASE " + self.dbName)
        self.db.endTransaction()

        SqlScript.run(os.path.join(os.environ['CAT_DIR'], "sql",
            "setup_storedFunctions.sql"), dbUrl)

        self.db.setRetrieveLocation(dafPersist.LogicalLocation(dbUrl))

        self.db.startTransaction()
        self.db.setTableForQuery("DUAL", True)

    def tearDown(self):
        self.db.endTransaction()

        self.db.startTransaction()
        self.db.executeSql("DROP DATABASE " + self.dbName)
        self.db.endTransaction()

    def testMJD(self):
        mjdUtc = 45205.125
        self.db.outColumn("taiToUtc(mjdUtcToTai(%f))" % mjdUtc, True)
        self.db.outColumn("mjdUtcToTai(%f)" % mjdUtc, True)
        self.db.outColumn("taiToMjdUtc(mjdUtcToTai(%f))" % mjdUtc, True)
        self.db.outColumn("taiToMjdTai(mjdUtcToTai(%f))" % mjdUtc, True)
        self.db.query()
        haveRow = self.db.next()
        self.assert_(haveRow)
        self.assertEqual(self.db.getColumnByPosInt64(0), 399006000000000000L)
        self.assertEqual(self.db.getColumnByPosInt64(1), 399006021000000000L)
        self.assertAlmostEqual(self.db.getColumnByPosDouble(2), 45205.125)
        self.assertAlmostEqual(self.db.getColumnByPosDouble(3),
                45205.125 + 21.0 / 86400.0)
        haveRow = self.db.next()
        self.assert_(not haveRow)

    def testNsecs(self):
        nsecsUtc = 1192755473000000000L
        self.db.outColumn("taiToUtc(utcToTai(%d))" % nsecsUtc, True)
        self.db.outColumn("utcToTai(%d)" % nsecsUtc, True)
        self.db.outColumn("taiToMjdUtc(utcToTai(%d))" % nsecsUtc, True)
        self.db.query()
        haveRow = self.db.next()
        self.assert_(haveRow)
        self.assertEqual(self.db.getColumnByPosInt64(0), 1192755473000000000L)
        self.assertEqual(self.db.getColumnByPosInt64(1), 1192755506000000000L)
        self.assertAlmostEqual(self.db.getColumnByPosDouble(2), 54392.040196759262)
        haveRow = self.db.next()
        self.assert_(not haveRow)

    def testBoundaryMJD(self):
        mjdUtc = 47892.0
        self.db.outColumn("taiToUtc(mjdUtcToTai(%f))" % mjdUtc, True)
        self.db.outColumn("mjdUtcToTai(%f)" % mjdUtc, True)
        self.db.outColumn("taiToMjdUtc(mjdUtcToTai(%f))" % mjdUtc, True)
        self.db.query()
        haveRow = self.db.next()
        self.assert_(haveRow)
        self.assertEqual(self.db.getColumnByPosInt64(0), 631152000000000000L)
        self.assertEqual(self.db.getColumnByPosInt64(1), 631152025000000000L)
        self.assertEqual(self.db.getColumnByPosDouble(2), 47892.0)
        haveRow = self.db.next()
        self.assert_(not haveRow)

    def testCrossBoundaryNsecs(self):
        nsecsUtc = 631151998000000000L
        self.db.outColumn("taiToUtc(utcToTai(%d))" % nsecsUtc, True)
        self.db.outColumn("utcToTai(%d)" % nsecsUtc, True)
        self.db.query()
        haveRow = self.db.next()
        self.assert_(haveRow)
        self.assertEqual(self.db.getColumnByPosInt64(0), 631151998000000000L)
        self.assertEqual(self.db.getColumnByPosInt64(1), 631152022000000000L)
        haveRow = self.db.next()
        self.assert_(not haveRow)

    def testNsecsTAI(self):
        nsecsTai = 1192755506000000000L
        self.db.outColumn("taiToUtc(%d)" % nsecsTai, True)
        self.db.outColumn("utcToTai(taiToUtc(%d))" % nsecsTai, True)
        self.db.outColumn("taiToMjdUtc(%d)" % nsecsTai, True)
        self.db.query()
        haveRow = self.db.next()
        self.assert_(haveRow)
        self.assertEqual(self.db.getColumnByPosInt64(0), 1192755473000000000L)
        self.assertEqual(self.db.getColumnByPosInt64(1), 1192755506000000000L)
        self.assertAlmostEqual(self.db.getColumnByPosDouble(2), 54392.040196759262)
        haveRow = self.db.next()
        self.assert_(not haveRow)

def suite():
    return unittest.makeSuite(TimeFuncTestCase)

if __name__ == '__main__':
    unittest.main()
