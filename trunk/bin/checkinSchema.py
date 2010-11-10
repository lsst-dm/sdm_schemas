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


import optparse
import os
import re
import subprocess
import sys

LSSTheader = """
-- LSST Database Schema
-- $Author$
-- $Revision$
-- $Date$
--
-- See <http://lsstdev.ncsa.uiuc.edu/trac/wiki/Copyrights>
-- for copyright information.

"""

usage = """%prog schemaFile_{version}.sql [-m {message}]

Everything between the first underscore and a trailing ".sql" in the argument
filename is taken as a version string.  Any non-alphanumeric characters in the
version string are translated to underscores ("_").

A "CREATE TABLE AAA_Version_{version}" statement is prepended to the file.
A standard header is also prepended.

The file is renamed without the underscore and version string.  Any end of
line characters in the file are translated to the current system's standard.

The file is then checked into SVN using the optional message if present.
"""

parser = optparse.OptionParser(usage)
parser.add_option("-m")
options, arguments = parser.parse_args()

if len(arguments) != 1:
    sys.stderr.write(os.path.basename(sys.argv[0]) + usage[6:])
    sys.exit(1)
filename = arguments[0]

pos = filename.find("_")
if pos == -1 or filename[-4:] != ".sql":
    sys.stderr.write(os.path.basename(sys.argv[0]) + usage[6:])
    sys.exit(1)

origVersion = filename[pos + 1:-4]
r = re.compile(r'\W')
version = r.sub("_", origVersion)

destFilename = filename[0:pos] + ".sql"

src = open(filename, mode='rU')
dest = open(destFilename, mode='wt')

dest.write(LSSTheader)
dest.write("\nCREATE TABLE AAA_Version_" + version + " (version CHAR);\n\n")
dest.writelines(src)

src.close()
dest.close()

# Don't delete the original, just in case there's a problem.
# os.unlink(filename)

message = "LSST schema version " + origVersion + "."
if options.m != None:
    message += " " + options.m

subprocess.call(["svn", "commit", destFilename, "-m", message])
