# -*- python -*-
#
# Setup our environment
#
import glob, os.path, re, sys
import lsst.SConsUtils as scons

dependencies = ["python", "mysqlclient", "mysqlpython", "boost", "utils", "pex_exceptions", "daf_base", "pex_logging", "pex_policy"]

env = scons.makeEnv("cat",
                    r"$HeadURL$",
                    [["python"],
                     ["mysqlclient"],
		     ["mysqlpython"],
		     ["boost", "boost/regex.hpp", "boost_regex:C++"],
		     ["utils", "lsst/tr1/unordered_map.h", "utils:C++"],
		     ["pex_exceptions", "lsst/pex/exceptions.h", "pex_exceptions:C++"],
		     ["daf_base", "lsst/daf/base.h", "daf_base:C++"],
		     ["pex_logging", "lsst/pex/logging/Log.h", "pex_logging:C++"],
		     ["pex_policy", "lsst/pex/policy/Policy.h", "pex_policy:C++"]
                    ])
env.Help("""
LSST Catalog package
""")

###############################################################################
# Boilerplate below here

pkg = env["eups_product"]
env.libs[pkg] += env.getlibs(" ".join(dependencies))

#
# Build/install things
#
for d in Split("sql bin pipeline lib python examples tests doc"):
    if d == "python":
        d = os.path.join(d, "lsst")
        for i in pkg.split("_"):
            d = os.path.join(d, i)
    if os.path.isdir(d) and os.path.isfile(os.path.join(d, "SConscript")):
        try:
            SConscript(os.path.join(d, "SConscript"))
        except Exception, e:
            print >> sys.stderr, "%s: %s" % (os.path.join(d, "SConscript"), e)

env['IgnoreFiles'] = r"(~$|\.pyc$|^\.svn$|\.o$)"

Alias("install", [env.Install(env['prefix'], "python"),
                  env.Install(env['prefix'], "policy"),
                  env.Install(env['prefix'], "bin"),
                  env.Install(env['prefix'], "sql"),
                  env.InstallEups(os.path.join(env['prefix'], "ups"))])

scons.CleanTree(r"*~ core *.so *.os *.o")

#
# Build TAGS files
#
files = scons.filesToTag()
if files:
    env.Command("TAGS", files, "etags -o $TARGET $SOURCES")

env.Declare()
