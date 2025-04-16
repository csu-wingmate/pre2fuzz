# PRE2Fuzz - Bridging Protocol Reverse Engineering and Protocol Fuzzing
PRE2Fuzz is for bridging protocol reverse engineering and protocol fuzzing. It includes a suite of representative open-source network servers for popular protocols (e.g., FTP), and tools to automate experimentation.
# Folder Structure
```
pre2fuzz
├── subjects: contains different protocol implementations
│   └── FTP
│       └── lightftp
│           └── Dockerfile: for building the Docker image specific to the target server
│           └── run.sh: main script to run the experiment inside a Docker container
│           └── other necessary files
└── scripts: contains all scripts for running experiments and analyzing results
    ├── execution
    │   └── PRE2Fuzz_pre.sh: main script to run reverse experiments
    │   └── PRE2Fuzz_tran.py: main script to run transform experiments
    │   └── PRE2Fuzz_fuzz.sh: main script to run fuzzing experiments
    └── ...
└── config.ini: configuration file
└── README.md: this file
```
# Quick Start - Reversing LightFTP traffic with NetPlier and Fuzzing LightFTP server with Peach
Follow the steps below to run and collect experimental results for LightFTP, which is a lightweight File Transfer Protocol (FTP) server. The similar steps should be followed to run experiments on other subjects.
## Step-0. Set up environmental variables
```
git clone https://github.com/csu-wingmate/pre2fuzz.git
cd pre2fuzz
sudo mkdir in
sudo mkdir pits
export PFBENCH=$(pwd)
export PATH=$PATH:$PFBENCH/scripts/execution:$PFBENCH/scripts/analysis
```

## Step-1. Build a reverse tool docker image, a fuzzer docker image and a protocol docker image
```bash
cd $PFBENCH
cd fuzzers/Peach
docker build . -t peach
```
```bash
cd $PFBENCH
cd subjects/FTP/lightftp
docker build . -t lightftp
```
```bash
# netplier and netzob share a common docker image
docker pull netplier:out
```

## Step-2. Run reversing
Run PRE2Fuzz_pre.sh script to start an experiment. The script takes 3 arguments as listed below.
- ***1st argument (TRAFFIC)*** : pcap file
- ***2th argument (REVERSE_TOOL)***   : reverse tool name (e.g., netplier)
- ***3th argument (SAVETO)***  : path to keep the results

```bash
cd $PFBENCH/scripts
sudo chmod +x PRE2Fuzz_pre.sh
./PRE2Fuzz_pre.sh - i lightftp.pcap -r netplier:out -o in/lightftp.out
```
_________________
A successful script execution will produce output similar to this:
```
1.Inferring
NETPLIER:OUT: Collecting results from container and save them to $PFBENCH/in
NETPLIER:OUT: I am done!
```

## Step-3. Run transforming
- ***1st argument (FORMAT_INFERENCE)*** : format inference results file
- ***2rd argument (MESSAGE_ORDER)***   : message order file
- ***3th argument (MESSAGE_DIRECTION)***   : message direction file
- ***4th argument (SAVETO)***  : path to keep the results
The following commands refine the format inferring results and transform the reverse result to a Pit file.
Before running the script, you should edit the config.ini as your wish.
```bash
cd $PFBENCH/scripts
sudo python PRE2Fuzz_tran.py -fi lightftp.out -mo order.out -md direction.out -o out/lightftp.xml
```

## Step-4. Run fuzzing
- ***1st argument (PROTOCOL)*** : name of the protocol Implementation
- ***2rd argument (SAVETO)***   : path to a folder keeping the results
- ***3th argument (FUZZER)***   : fuzzer name (e.g., peach)
- ***4th argument (TIMEOUT)***  : time for fuzzing in seconds
- ***5th argument (TEMPLATE)***  : test template file
The following commands run an instances of Peach to fuzz LightFTP for 5 minutes.

```bash
cd $PFBENCH
sudo mkdir results
cd scripts
sudo chmod +x PRE2Fuzz_fuzz.sh
sudo ./PRE2Fuzz_fuzz.sh -p lightftp -o results -f peach -t 300 -x lightftp.xml
```

## Full process excution
You can also run the PRE2Fuzz_common script for the full process excution.
```bash
cd $PFBENCH
sudo mkdir results
cd scripts
sudo chmod +x PRE2Fuzz_common.sh
sudo ./PRE2Fuzz_common.sh -p lightftp -o results -r netplier:out -f peach -t 300 -md direction.out -mo order.out -i lightftp.pcap
```
