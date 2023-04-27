#!/bin/bash

echo '\i recreateMainDb.sql' | psql;
echo '\i recreateBonusDb.sql' | psql;

./run_test.sh 1;
./run_test.sh 2;
./run_test.sh 3;
./run_test.sh 4;
