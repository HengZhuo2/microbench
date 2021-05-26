nonblockT=MICRO_nonBlockT
nonblockV=10
blockT=1
blockV=100

STIME=MICRO_sTime # sleep/ swap out time/length in us, =10ms
SPROB=1 # 0.5% sleep/ swap out probility
lowbound=0
highbound=0 # lock of [0,4], 20% chance for each one, ends 4% two threads grabbing same lock

NOISETIME=MICRO_noiseT
NOISEPROB=45
NOISEVAR=10
spinLimit=200

THREADS=2
timefreeze=0
QPS=1200

mkdir -p /home/zohan/microbench/microbench/results-autogen/sample/$QPS
for k in {1,2,3,4}
do
    BLOCK_TIME=${blockT} BLOCK_VAR=${blockV} NONBLOCK_TIME=${nonblockT} NONBLOCK_VAR=${nonblockV} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_VAR=${NOISEVAR} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=$(($QPS*4)) TBENCH_MAXREQS=$(($QPS*16)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=${lowbound} LOCKID_HIGH=${highbound} SPIN_LIMIT=${spinLimit} TIME_FREEZE=${timefreeze} ./microbench_integrated -r ${THREADS} >> dump.out
    echo "moving stats to /home/zohan/microbench/microbench/results-autogen/sample/$QPS/lats-$k..."
    mv lats.bin /home/zohan/microbench/microbench/results-autogen/sample/$QPS/lats-$k.bin
done