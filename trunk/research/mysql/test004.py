#!/usr/local/bin/python

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


import MySQLdb

# building sub-partitions

# assumptions:
# x100k table (100k rows)
# required columns: subChunkId
# It can be built eg by doing
# update x100k set subChunkId=objectId%100;
#
#
# table cab be sorted by subChunkId using:
# myisamchk -dvv # to get key ids
# myisamchk /u1/mysql_data/usnob/x100k.MYI --sort-record=3


db = MySQLdb.connect(host='localhost',
                     user='becla',
                     passwd='',
                     db='usnob')

cursor = db.cursor()

for n in xrange(1,100):
    cmd = 'CREATE TABLE sp_%s ENGINE=MEMORY SELECT * FROM x100k where subChunkId=%s' % (n,n)
    #cmd = 'DROP TABLE sp_%s' % (n)
    cursor.execute(cmd)

db.close()
