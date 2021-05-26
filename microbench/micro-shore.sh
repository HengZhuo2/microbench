nonblockT=100
nonblockV=10
blockT=100
blockV=10

STIME=1400 # sleep/ swap out time/length in us, =10ms
SPROB=40 # 0.5% sleep/ swap out probility
lowbound=0
highbound=4 # lock of [0,4], 20% chance for each one, ends 4% two threads grabbing same lock
spinLimit=2000

THREADS=1
QPS=400
NOISETIME=400
NOISEPROB=500
NOISEVAR=5
timefreeze=0
NOISEBOUND=0

for QPS in {"1400","2200","2600","2800"}
do
    mkdir -p ../result-microshore/${QPS}
    for k in {1..8}
    do
        BLOCK_TIME=${blockT} BLOCK_VAR=${blockV} NONBLOCK_TIME=${nonblockT} NONBLOCK_VAR=${nonblockV} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_VAR=${NOISEVAR} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=$(($QPS*2)) TBENCH_MAXREQS=$(($QPS*8)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=${lowbound} LOCKID_HIGH=${highbound} SPIN_LIMIT=${spinLimit} TIME_FREEZE=${timefreeze} ./microbench_integrated -r ${THREADS}

        echo "moving stats to ../result-microshore/${QPS}/lats-$k..."
        mv lats.bin ../result-microshore/${QPS}/lats-$k.bin
    done
done