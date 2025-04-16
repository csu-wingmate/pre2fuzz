#!/bin/bash

PROTOCOL=""
FUZZER=""
TEMPLATE=""
TIMEOUT=""
SAVETO=""
DELETE=""

while getopts "p:f:x:t:o:" opt; do
  case $opt in
    p)
      PROTOCOL=$OPTARG
      ;;
    f)
      FUZZER=$OPTARG
      ;;
    x)
      TEMPLATE=$OPTARG
      ;;
    t)
      TIMEOUT=$OPTARG
      ;;
    o)
      SAVETO=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$PROTOCOL" ] || [ -z "$FUZZER" ] || [ -z "$TEMPLATE" ] || [ -z "$TIMEOUT" ] || [ -z "$SAVETO" ]; then
  echo "Usage: $0 -p <protocol> -f <fuzzer> -x <template> -t <timeout> -o <save_path>"
  exit 1
fi

WORKDIR="/root"

pid=$(docker run -itd${PROTOCOL} /bin/bash -c "cd ${WORKDIR} && ./run.sh")

EXTERNAL_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'${pid})

sed -i -e 's|<Param name="Host" value="[^"]*"/>|<Param name="Host" value="'$EXTERNAL_IP'"/>|' "$TEMPLATE"

fid=$(docker run -v$(dirname "$TEMPLATE"):${WORKDIR}/tasks/ -d -it ${FUZZER} /bin/bash -c  "timeout${TIMEOUT} mono ${WORKDIR}/Peach/bin/peach.exe${WORKDIR}/tasks/$(basename "$TEMPLATE")") 

docker wait ${fid} > /dev/null

wait

printf "\n${FUZZER^^}: Collecting results from container${fid} and save them to ${SAVETO}"

docker cp ${fid}:${WORKDIR}/logs ${SAVETO}/${FUZZER}_logs

if [ ! -z "$DELETE" ]; then
  printf "\nDeleting ${fid}"
  docker stop ${fid}
  docker rm ${fid}
fi

printf "\n${FUZZER^^}: Collecting results from container${pid}"

docker cp ${pid}:${WORKDIR}/branch ${SAVETO}/${FUZZER}_branch

if [ ! -z "$DELETE" ]; then
  printf "\nDeleting ${pid}"
  docker stop ${pid}
  docker rm ${pid}
fi

printf "\n${FUZZER^^}: I am done!\n"
