#!/bin/bash

INFO_COLOR='\x1b[1;33m';
OK_COLOR='\x1b[0;32m';
ERROR_COLOR='\x1b[0;31m';
HEADER_COLOR='\x1b[0;36m'
DEFAULT_COLOR='\x1b[0m';

#1 - part num
run_test(){
	db_name="";
	if (( $1 != 4 )); then
		db_name='info21'
	else
		db_name='info21_bonus';
	fi

	echo -e ${HEADER_COLOR};
	echo -e "\t~~~~~~~~~~~~~~~~~~~~~";
	echo -e "\t>>> TESTS_PART_$1 <<<";
	echo -e "\t~~~~~~~~~~~~~~~~~~~~~";
	echo -e -n ${DEFAULT_COLOR};

	echo "\i ../tests/t_part$1.sql" |
	psql -d $db_name 2>&1 |
	sed -e "s/^psql.*INFO:\s*TEST\s*\(.*\)/${INFO_COLOR}TEST \1${DEFAULT_COLOR}/"\
		-e "s/^psql.*INFO:\s*OK\.*/${OK_COLOR} > OK${DEFAULT_COLOR}/"\
		-e "s/^psql.*ERROR:\s*\(.*\)/${ERROR_COLOR} > \1${DEFAULT_COLOR}/"\
		-e "s/^psql.*INFO:\s*\(.*\)/${HEADER_COLOR}\1${DEFAULT_COLOR}/"\
		-e '/^psql.*NOTICE:/d'\
		-e '/ROLLBACK/d'\
		-e '/DO/d'\
		-e '/BEGIN/d'\
		-e '/CALL/d'\
		-e '/COMMIT/d'\
		-e '/CONTEXT:/d'
}

if (( $# != 1 )); then
	exit;
fi
if (( $1 != 1 && $1 != 2 && $1 != 3 && $1 != 4)); then
	exit;
fi
run_test $1;
