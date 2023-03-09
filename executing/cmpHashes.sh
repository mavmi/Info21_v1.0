#!/bin/bash

####################################################
## Check if `COPY TO` and `COPY FROM`` works fine ##
####################################################

PSQL_PORT=5432;
PSQL_USERNAME="pmaryjo";
DEFAULT_DATABASE="pmaryjo";
PROJECT_ROOT="/Users/pmaryjo/Desktop/Info21_v1.0";

# $1 - postgresql_cmd
# $2 - database
function run_psql_cmd(){
    echo $1 | psql -U $PSQL_USERNAME -p $PSQL_PORT -d $2 > /dev/null;
}
# $1 - db_name
function drop_db(){
    run_psql_cmd "select pg_terminate_backend(pid) from pg_stat_activity where datname='$1';" $DEFAULT_DATABASE;
    run_psql_cmd "drop database if exists $1;" $DEFAULT_DATABASE;
}
# $1 - db_name
function recreate_db(){
    drop_db $1
    run_psql_cmd "create database $1;" $DEFAULT_DATABASE;
}
# $1 - filename
function check_hashsums(){
    out1=($(shasum $PROJECT_ROOT/table1/$1));
    out2=($(shasum $PROJECT_ROOT/table2/$1));
    if [[ $out1 == $out2 ]]; then
        echo $1 "OK";
    else
        echo $1 "ERROR"
        echo $out1 $out2;
    fi
}

table1="info21_1";
table2="info21_2";

mkdir table1;
mkdir table2;
rm -f cvs/*.cvs;

recreate_db $table1 > /dev/null;
recreate_db $table2 > /dev/null;

run_psql_cmd "\i $PROJECT_ROOT/part1.sql" $table1;
run_psql_cmd "\i $PROJECT_ROOT/part1.sql" $table2;

run_psql_cmd "call fill_tables();" $table1;
run_psql_cmd "\i $PROJECT_ROOT/toFile.sql" $table1;
run_psql_cmd "\i $PROJECT_ROOT/fromFile.sql" $table2;

mv cvs/*.cvs table1/.
run_psql_cmd "\i $PROJECT_ROOT/toFile.sql" $table2;
mv cvs/*.cvs table2/.

check_hashsums "checks.cvs";
check_hashsums "friends.cvs";
check_hashsums "p2p.cvs";
check_hashsums "peers.cvs";
check_hashsums "recommendations.cvs";
check_hashsums "tasks.cvs";
check_hashsums "time_tracking.cvs";
check_hashsums "transferred_points.cvs";
check_hashsums "verter.cvs";
check_hashsums "xp.cvs";

rm -rf table1 table2;
drop_db $table1;
drop_db $table2;
