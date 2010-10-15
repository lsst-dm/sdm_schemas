To build it, use

g++ -g -c main.cc -I/usr/include/mysql
g++ -g -o run main.o -I/usr/include/mysql -lmysqlclient -L/usr/lib/mysql

The implementation is based on:
http://dev.mysql.com/doc/refman/5.0/en/mysql-stmt-fetch.html
