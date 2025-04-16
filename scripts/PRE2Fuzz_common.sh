#!/bin/bash

INPUT=""
REVERSE_TOOL=""
MESSAGE_ORDER=""
MESSAGE_DIRECTION=""
PROTOCOL=""
FUZZER=""
TIMEOUT=""
SAVETO=""

while getopts "i:r:mo:md:p:f:x:t:o:" opt; do
  case $opt in
    i)
      INPUT=$OPTARG
      ;;
    r)
      REVERSE_TOOL=$OPTARG
      ;;
    mo)
      MESSAGE_ORDER=$OPTARG
      ;;
    md)
      MESSAGE_DIRECTION=$OPTARG
      ;;
    p)
      PROTOCOL=$OPTARG
      ;;
    f)
      FUZZER=$OPTARG
      ;;
    t)
      TIMEOUT=$OPTARG
      ;;
    o)
      SAVETO=$OPTARG
      ;;
    ?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$INPUT" ] || [ -z "$REVERSE_TOOL" ] || [ -z "$MESSAGE_ORDER" ] || [ -z "$MESSAGE_DIRECTION" ] || [ -z "$PROTOCOL" ] || [ -z "$FUZZER" ] || [ -z "$TIMEOUT" ] || [ -z "$SAVETO" ]; then
  echo "Usage: $0 -i <input> -r <reverse_tool> -mo <message_order> -md <message_direction> -p <protocol> -f <fuzzer> -t <timeout> -o <save_to>"
  exit 1
fi

WORKDIR="/root"
PFBENCH="/opt/pre2fuzz"

sudo $PFBENCH/PRE2Fuzz_pre.sh -i $INPUT -r $REVERSE_TOOL -o $SAVETO

sudo python $PFBENCH/PRE2Fuzz_tran.py -fi ${PROTOCOL}.out -mo $MESSAGE_ORDER -md $MESSAGE_DIRECTION -o $SAVETO

sudo $PFBENCH/PRE2Fuzz_fuzz.sh -p $PROTOCOL -f $FUZZER -x ${PROTOCOL}.xml -t $TIMEOUT -o $SAVETO
