#!/bin/bash

INPUT_FILE=""
TOOL=""
OUTPUT_DIR=""

while getopts "i:r:o:" opt; do
  case $opt in
    i)
      INPUT_FILE=$OPTARG
      ;;
    r)
      TOOL=$OPTARG
      ;;
    o)
      OUTPUT_DIR=$OPTARG
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

if [ -z "$INPUT_FILE" ] || [ -z "$TOOL" ] || [ -z "$OUTPUT_DIR" ]; then
  echo "Usage: $0 -i <input_file> -r <tool> -o <output_dir>"
  exit 1
fi

PROTOCOL=$(basename "$INPUT_FILE" .pcap)

WORKDIR="/root"

PFBENCH="/root/pre2fuzz"
pid=$(docker run -v "$PFBENCH/pcaps:/opt/" -itd "$TOOL" /bin/bash -c "python /root/NetPlier/netplier/main.py -i /opt/$INPUT_FILE -o zwl_result/MODBUS_1out -r /opt/$PROTOCOL.out -l 5")

docker wait "$pid" > /dev/null

printf "\n${TOOL^^}: Collecting results from container$pid and save them to $OUTPUT_DIR"
sudo docker cp "$pid:/opt/$PROTOCOL.out" "$OUTPUT_DIR/"

wait

if [ ! -z "$DELETE" ]; then
  printf "\nDeleting $pid"
  docker stop "$pid"
  docker rm "$pid"
fi

printf "\n${TOOL^^}: I am done!\n"
