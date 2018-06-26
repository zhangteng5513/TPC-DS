#!/bin/bash

set -e
PWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $PWD/functions.sh
source_bashrc

GEN_DATA_SCALE="$1"
EXPLAIN_ANALYZE="$2"
SQL_VERSION="$3"
RANDOM_DISTRIBUTION="$4"
MULTI_USER_COUNT="$5"
RUN_COMPILE_TPCDS="$6"
RUN_GEN_DATA="$7"
RUN_INIT="$8"
RUN_DDL="$9"
RUN_LOAD="${10}"
RUN_SQL="${11}"
RUN_SINGLE_USER_REPORT="${12}"
RUN_MULTI_USER="${13}"
RUN_MULTI_USER_REPORT="${14}"
SINGLE_USER_ITERATIONS="${15}"

echo GEN_DATA_SCALE="$1"
echo EXPLAIN_ANALYZE="$2"
echo SQL_VERSION="$3"
echo RANDOM_DISTRIBUTION="$4"
echo MULTI_USER_COUNT="$5"
echo RUN_COMPILE_TPCDS="$6"
echo RUN_GEN_DATA="$7"
echo RUN_INIT="$8"
echo RUN_DDL="$9"
echo RUN_LOAD="${10}"
echo RUN_SQL="${11}"
echo RUN_SINGLE_USER_REPORT="${12}"
echo RUN_MULTI_USER="${13}"
echo RUN_MULTI_USER_REPORT="${14}"
echo SINGLE_USER_ITERATIONS="${15}"

if [[ "$GEN_DATA_SCALE" == "" || "$EXPLAIN_ANALYZE" == "" || "$SQL_VERSION" == "" || "$RANDOM_DISTRIBUTION" == "" || "$MULTI_USER_COUNT" == "" || "$RUN_COMPILE_TPCDS" == "" || "$RUN_GEN_DATA" == "" || "$RUN_INIT" == "" || "$RUN_DDL" == "" || "$RUN_LOAD" == "" || "$RUN_SQL" == "" || "$RUN_SINGLE_USER_REPORT" == "" || "$RUN_MULTI_USER" == "" || "$RUN_MULTI_USER_REPORT" == "" || "$SINGLE_USER_ITERATIONS" == "" ]]; then
	echo "You must provide the scale as a parameter in terms of Gigabytes, true/false to run queries with EXPLAIN ANALYZE option, the SQL_VERSION, and true/false to use random distrbution."
	echo "Example: ./rollout.sh 100 false tpcds false 5 true true true true true true true true true 1"
	echo "This will create 100 GB of data for this test, not run EXPLAIN ANALYZE, use standard TPC-DS, and not use random distribution."
	echo "The next nine run options indicate if you want to force the running of those steps even if the step has already completed."
	exit 1
fi

QUIET=$5

create_directories()
{
	if [ ! -d $LOCAL_PWD/log ]; then
		echo "Creating log directory"
		mkdir $LOCAL_PWD/log
	fi
}

create_directories
echo "############################################################################"
echo "TPC-DS Script for Pivotal Greenplum Database and Pivotal HAWQ."
echo "############################################################################"
echo ""
echo "############################################################################"
echo "GEN_DATA_SCALE: $GEN_DATA_SCALE"
echo "EXPLAIN_ANALYZE: $EXPLAIN_ANALYZE"
echo "SQL_VERSION: $SQL_VERSION"
echo "RANDOM_DISTRIBUTION: $RANDOM_DISTRIBUTION"
echo "MULTI_USER_COUNT: $MULTI_USER_COUNT"
echo "RUN_COMPILE_TPCDS: $RUN_COMPILE_TPCDS"
echo "RUN_GEN_DATA: $RUN_GEN_DATA"
echo "RUN_INIT: $RUN_INIT"
echo "RUN_DDL: $RUN_DDL"
echo "RUN_LOAD: $RUN_LOAD"
echo "RUN_SQL: $RUN_SQL"
echo "SINGLE_USER_ITERATIONS: $SINGLE_USER_ITERATIONS"
echo "RUN_SINGLE_USER_REPORT: $RUN_SINGLE_USER_REPORT"
echo "RUN_MULTI_USER: $RUN_MULTI_USER"
echo "RUN_MULTI_USER_REPORT: $RUN_MULTI_USER_REPORT"
echo "############################################################################"
echo ""
if [ "$RUN_COMPILE_TPCDS" == "true" ]; then
	rm -f $PWD/log/end_compile_tpcds.log
fi
if [ "$RUN_GEN_DATA" == "true" ]; then
	rm -f $PWD/log/end_gen_data.log
fi
if [ "$RUN_INIT" == "true" ]; then
	rm -f $PWD/log/end_init.log
fi
if [ "$RUN_DDL" == "true" ]; then
	rm -f $PWD/log/end_ddl.log
fi
if [ "$RUN_LOAD" == "true" ]; then
	rm -f $PWD/log/end_load.log
fi
if [ "$RUN_SQL" == "true" ]; then
	rm -f $PWD/log/end_sql.log
fi
if [ "$RUN_SINGLE_USER_REPORT" == "true" ]; then
	rm -f $PWD/log/end_single_user_reports.log
fi
if [ "$RUN_MULTI_USER" == "true" ]; then
	rm -f $PWD/log/end_testing_*.log
fi
if [ "$RUN_MULTI_USER_REPORT" == "true" ]; then
	rm -f $PWD/log/end_multi_user_reports.log
fi

AIPLAN=${AIPLANNER:=no}

for i in $(ls -d $PWD/0*); do
	echo "$i/rollout.sh"
	AIPLANNER=$AIPLAN $i/rollout.sh $GEN_DATA_SCALE $EXPLAIN_ANALYZE $SQL_VERSION $RANDOM_DISTRIBUTION $MULTI_USER_COUNT $SINGLE_USER_ITERATIONS
done
