#!/bin/bash
PROTOCOL=$1   #name of the protocol
SAVETO=$2     #path to folder keeping the results
FUZZER=$3     #fuzzer name (e.g., peach) 
TIMEOUT=$4    #time for fuzzing
DELETE=$5
# prefuzzpeach_fuzz.sh lightftp results-lightftp peach 300

WORKDIR="/root"

# create one container for fuzz
# $PFBENCH: /root/prefuzzbench
pid=$(docker run -itd ${PROTOCOL} /bin/bash -c "cd ${WORKDIR} && ./run.sh")

# protocol的IP地址
EXTERNAL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${pid})

# 使用sed命令替换Host参数的值
sed -i -e 's|<Param name="Host" value="[^"]*"/>|<Param name="Host" value="'$EXTERNAL_IP'"/>|' "$PFBENCH/pits/${PROTOCOL}.xml"

fid=$(docker run -v $PFBENCH/pits/:${WORKDIR}/tasks/ -d -it ${FUZZER} /bin/bash -c  "timeout ${TIMEOUT} mono ${WORKDIR}/Peach/bin/peach.exe ${WORKDIR}/tasks/${PROTOCOL}.xml") 

docker wait ${fid} > /dev/null

# 等待所有后台进程结束
wait

#collect the fuzzing results from the containers
printf "\n${FUZZER^^}: Collecting results from container ${fid} and save them to ${SAVETO}"

# Copy the 'logs' folders from the container to the local directory
docker cp ${fid}:${WORKDIR}/logs ${SAVETO}/${FUZZER}_${index}_logs

if [ ! -z $DELETE ]; then
  printf "\nDeleting ${fid}"
  docker stop ${fid}
  docker rm ${fid} # Remove container now that we don't need it
fi

printf "\n${FUZZER^^}: Collecting results from container ${pid}"

# Copy the 'branch' folders from the container to the local directory
docker cp ${pid}:${WORKDIR}/branch ${SAVETO}/${FUZZER}_${index}_branch

if [ ! -z $DELETE ]; then
  printf "\nDeleting ${pid}"
  docker stop ${pid}
  docker rm ${pid} # Remove container now that we don't need it
fi

printf "\n${FUZZER^^}: I am done!\n"
