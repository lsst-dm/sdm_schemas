# -*- python -*-
from lsst.sconsUtils import scripts
scripts.BasicSConstruct("cat")

from subprocess import Popen, PIPE
import re, os


sqlSrc = "sql" ## Source dir for .sql files
stampedDir = "build" ## Target dir for kw-subsituted .sql files

gitdescribe = Popen(["git", "describe", "--dirty"], 
                    stdout=PIPE).communicate()[0].strip()
idExpr = re.compile(r"\$Id.*\$")
def stamp_version(target, source, env):
    idStr = "$Id: %s %s $" % (source[0].name, gitdescribe)
    print "stamping %s with %s" % (source[0].name, idStr)
    t = open(str(target[0]), "w")
    s = open(str(source[0]))
    
    for line in s:
        t.write(idExpr.sub(idStr, line))
        
    pass

env = Environment(BUILDERS = {'Vstamp' : Builder(action=stamp_version)})
for f in Glob(os.path.join(sqlSrc, "*.sql")):
    env.Vstamp(os.path.join(stampedDir, f.name), f)
