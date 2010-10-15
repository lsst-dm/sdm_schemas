/* 
 * LSST Data Management System
 * Copyright 2008, 2009, 2010 LSST Corporation.
 * 
 * This product includes software developed by the
 * LSST Project (http://www.lsst.org/).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the LSST License Statement and 
 * the GNU General Public License along with this program.  If not, 
 * see <http://www.lsstcorp.org/LegalNotices/>.
 */
 

#define SELECT_QUERY "SELECT objectId, ra, decl, subChunkId FROM XXs"

#include <string>
#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

using std::string;

int 
main(int argc, char* argv[])
{
    string hostName("localhost");
    string userName("");
    string password("");
    string dbName("subChunk");
    int port(3306);
    string mysqlSocket("/var/lib/mysql/mysql.sock");
    //string mysqlSocket("/tmp/mysql.sock");
    int mysqlFlags(0);

    MYSQL* conn = mysql_init (NULL); // allocate, initialize connection handler
    if ( conn == NULL ) {
        fprintf (stderr, "mysql_init() failed\n");
        abort();
    }
    if (mysql_real_connect(conn, 
                           hostName.c_str(),
                           userName.c_str(),
                           password.c_str(),
                           dbName.c_str(), 
                           port,
                           mysqlSocket.c_str(),
                           mysqlFlags) == NULL) {
        fprintf (stderr, "mysql_real_connect() failed:\nError %u (%s)\n",
                 mysql_errno (conn), mysql_error (conn));
        abort();
    }


    // Prepare a SELECT query to fetch data from test_table
    MYSQL_STMT *stmt = mysql_stmt_init(conn);
    if (!stmt) {
        fprintf(stderr, " mysql_stmt_init(), out of memory\n");
        exit(0);
    }

    if (mysql_stmt_prepare(stmt, SELECT_QUERY, strlen(SELECT_QUERY))) {
        fprintf(stderr, " mysql_stmt_prepare(), SELECT failed\n");
        fprintf(stderr, " %s\n", mysql_stmt_error(stmt));
        exit(0);
    }
    fprintf(stdout, " prepare, SELECT successful\n");

    // Get the parameter count from the statement
    int param_count= mysql_stmt_param_count(stmt);
    fprintf(stdout, " total parameters in SELECT: %d\n", param_count);
    
    if (param_count != 0) { // validate parameter count
        fprintf(stderr, " invalid parameter count returned by MySQL\n");
        exit(0);
    }

    // Fetch result set meta information
    MYSQL_RES *prepare_meta_result = mysql_stmt_result_metadata(stmt);
    if (!prepare_meta_result) {
        fprintf(stderr,
                " mysql_stmt_result_metadata(), \
           returned no meta information\n");
        fprintf(stderr, " %s\n", mysql_stmt_error(stmt));
        exit(0);
    }

    // Get total columns in the query
    int column_count= mysql_num_fields(prepare_meta_result);
    fprintf(stdout,
            " total columns in SELECT statement: %d\n",
            column_count);

    if (column_count != 4) { // validate column count
        fprintf(stderr, " invalid column count returned by MySQL\n");
        exit(0);
    }

    // Execute the SELECT query
    if (mysql_stmt_execute(stmt)) {
        fprintf(stderr, " mysql_stmt_execute(), failed\n");
        fprintf(stderr, " %s\n", mysql_stmt_error(stmt));
        exit(0);
    }

    unsigned long length[4];
    my_bool       is_null[4];
    my_bool       error[4];

    int           id_data;
    float         ra_data;
    float         decl_data;
    int           subChunkId_data;

    // Bind the result buffers for all 4 columns before fetching them
    MYSQL_BIND bind[4];
    memset(bind, 0, sizeof(bind));

    // id INT
    bind[0].buffer_type= MYSQL_TYPE_LONG;
    bind[0].buffer= (char *)&id_data;
    bind[0].is_null= &is_null[0];
    bind[0].length= &length[0];
    bind[0].error= &error[0];

    // ra FLOAT
    bind[1].buffer_type= MYSQL_TYPE_FLOAT;
    bind[1].buffer= (char *)&ra_data;
    bind[1].is_null= &is_null[1];
    bind[1].length= &length[1];
    bind[1].error= &error[1];

    // decl FLOAT
    bind[2].buffer_type= MYSQL_TYPE_FLOAT;
    bind[2].buffer= (char *)&decl_data;
    bind[2].is_null= &is_null[2];
    bind[2].length= &length[2];
    bind[2].error= &error[2];

    // subChunkId INT
    bind[3].buffer_type= MYSQL_TYPE_LONG;
    bind[3].buffer= (char *)&subChunkId_data;
    bind[3].is_null= &is_null[3];
    bind[3].length= &length[3];
    bind[3].error= &error[3];

    // Bind the result buffers
    if (mysql_stmt_bind_result(stmt, bind)) {
        fprintf(stderr, " mysql_stmt_bind_result() failed\n");
        fprintf(stderr, " %s\n", mysql_stmt_error(stmt));
        exit(0);
    }

    // Now buffer all results to client (optional step)
    if (mysql_stmt_store_result(stmt)) {
        fprintf(stderr, " mysql_stmt_store_result() failed\n");
        fprintf(stderr, " %s\n", mysql_stmt_error(stmt));
        exit(0);
    }

    // Fetch all rows
    int row_count= 0;
    fprintf(stdout, "Fetching results ...\n");
    while (!mysql_stmt_fetch(stmt)) {
        row_count++;
        fprintf(stdout, "  row %d: %d, %4.4f, %4.4f, %d\n", 
                row_count, id_data, ra_data, decl_data, subChunkId_data);
    }
    fprintf(stdout, " total rows fetched: %d\n", row_count);

    // Free the prepared result metadata
    mysql_free_result(prepare_meta_result);

    // Close the statement
    if (mysql_stmt_close(stmt)) {
        fprintf(stderr, " failed while closing the statement\n");
        fprintf(stderr, " %s\n", mysql_stmt_error(stmt));
        exit(0);
    }
    return 0;
}


