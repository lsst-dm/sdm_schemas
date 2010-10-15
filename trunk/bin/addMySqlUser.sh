#!/bin/bash

# IMPORTANT: Globally change "znewuser" to new username
#            before executing this script

# This script assumes the user has already been added
# to MySQL via the phpMyAdmin application, specifying
# the option:
# "Grant all privileges on wildcard name (username\_%)"
# which executes the following command:
# GRANT ALL ON `znewuser\_%`.* TO 'znewuser'@'%' ;

mysql -u root -p <<ZZEND
GRANT SELECT ON *.* TO 'znewuser'@'%' ;
GRANT SELECT, INSERT ON \`DC3b\_DB\`.* TO 'znewuser'@'%' ;
GRANT SELECT, INSERT ON GlobalDB.RunInfo TO 'znewuser'@'%' ; 
GRANT EXECUTE ON FUNCTION GlobalDB.extendRun TO 'znewuser'@'%' ; 
ZZEND
