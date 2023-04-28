#!/bin/bash

INFO_COLOR="\\\x1B[33m";
OK_COLOR="\\\x1B[32m";
ERROR_COLOR="\\\x1B[31m";
DEFAULT_COLOR="\\\x1B[37m";
OUTPUT_COLOR="\\\x1B[35m";

HEADER_COLOR="\033[34m"

#1 - part num
run_test(){
	db_name="";
	if (( $1 != 4 )); then
		db_name='info21'
	else
		db_name='info21_bonus';
	fi

	echo -e "\t~~~~~~~~~~~~~~~~~~~~~";
	echo -e "\t>>> TESTS_PART_$1 <<<";
	echo -e "\t~~~~~~~~~~~~~~~~~~~~~";

    echo -e "$(\

    echo "\i ../tests/t_part$1.sql" |
    psql -d $db_name 2>&1 |
    sed -e "s/^psql.*INFO:[ ]*TEST\s*\(.*\)/${INFO_COLOR}TEST \1${DEFAULT_COLOR}/"\
        -e "s/^psql.*\(FNC_.*\)/${OUTPUT_COLOR} >>> OUTPUT FOR \1 <<<${DEFAULT_COLOR}/"\
        -e "s/^psql.*\(PRCDR_.*\)/${OUTPUT_COLOR} >>> OUTPUT FOR \1 <<<${DEFAULT_COLOR}/"\
        -e "s/^psql.*INFO:[ ]*\(.*\)/${INFO_COLOR} > \1${DEFAULT_COLOR}/"\
        -e "s/^psql.*INFO:[ ]*OK\.*/${OK_COLOR} > OK${DEFAULT_COLOR}/"\
        -e "s/^psql.*ERROR:[ ]*\(.*\)/${ERROR_COLOR} > \1${DEFAULT_COLOR}/"\
        -e "/^psql.*NOTICE:/d"\
        -e "/ROLLBACK/d"\
        -e "/DO/d"\
        -e "/BEGIN/d"\
        -e "/CALL/d"\
        -e "/COMMIT/d"\
        -e "/CONTEXT:/d"

    )"
}

if (( $# != 1 )); then
	exit;
fi
if (( $1 != 1 && $1 != 2 && $1 != 3 && $1 != 4)); then
	exit;
fi
run_test $1;
