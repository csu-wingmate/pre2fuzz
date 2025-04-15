#!/bin/bash
PROTOCOL=$1   #name of the protocol
SAVETO=$2     #path to folder keeping the results
PRE=$3        #pre tool name
FUZZER=$4     #fuzzer name (e.g., peach) 
TIMEOUT=$5    #time for fuzzing
DELETE=$6
# prefuzzpeach_common.sh lightftp results-lightftp netplier:out peach 300

WORKDIR="/root"

# $PFBENCH: /opt/prefuzzbench
sudo $PFBENCH/prefuzzbench_pre.sh ${PROTOCOL} ${PRE} ${TIMEOUT}

sudo python $PFBENCH/transform.py

sudo $PFBENCH/prefuzzbench_fuzz.sh ${PROTOCOL} ${SAVETO} ${FUZZER} ${TIMEOUT}
