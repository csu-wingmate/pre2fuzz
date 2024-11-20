#!/bin/bash
PROTOCOL=$1   #name of the protocol
PRE=$2        #pre tool name
TIMEOUT=$3    #time for fuzzing
DELETE=$4
# prefuzzbench_pre.sh lightftp netplier:out 300

WORKDIR="/root"

# create one container for pre
# $PFBENCH: /root/prefuzzbench
pid=$(docker run -v $PFBENCH/pcaps/:$/opt/ -itd ${PRE} /bin/bash -c "python /root/NetPlier/netplier/main.py -i /opt/${PROTOCOL}.pcap -o zwl_result/MODBUS_1out -r /opt/${PROTOCOL}.out -l 5")

docker wait ${pid} > /dev/null

#collect the pre result from the container
printf "\n${PRE^^}: Collecting results from container ${pid} and save them to ${PFBENCH}/in"
docker cp ${pid}:$/opt/${PROTOCOL}.out $PFBENCH/in/

# 等待所有后台进程结束
wait

if [ ! -z $DELETE ]; then
printf "\nDeleting ${pid}"
docker stop ${pid}
docker rm ${pid} # Remove container now that we don't need it
fi

printf "\n${PRE^^}: I am done!\n"
