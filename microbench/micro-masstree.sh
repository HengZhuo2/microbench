nonblockT=1100
nonblockV=10
blockT=1
blockV=100

STIME=45000 # sleep/ swap out time/length in us, =10ms
SPROB=1 # 0.5% sleep/ swap out probility
lowbound=0
highbound=0 # lock of [0,4], 20% chance for each one, ends 4% two threads grabbing same lock

NOISETIME=4000
NOISEPROB=45
NOISEVAR=10
spinLimit=200

THREADS=2
timefreeze=0
QPS=1000

for QPS in {"400","500","600","700","800","900","1000","1100","1200","1300","1400","1500","1600"}
# for QPS in {"400","600","800","1000","1200","1400","1600","1800"}
do
    mkdir -p /home/zohan/microbench/result-micromasstree-2/$QPS
    # for k in {1,}
    for k in {1..8}
    do
        BLOCK_TIME=${blockT} BLOCK_VAR=${blockV} NONBLOCK_TIME=${nonblockT} NONBLOCK_VAR=${nonblockV} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_VAR=${NOISEVAR} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=$(($QPS*4)) TBENCH_MAXREQS=$(($QPS*16)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=${lowbound} LOCKID_HIGH=${highbound} SPIN_LIMIT=${spinLimit} TIME_FREEZE=${timefreeze} ./microbench_integrated -r ${THREADS}
        echo "moving stats to /home/zohan/microbench/result-micromasstree-2/$QPS/lats-$k..."
        mv lats.bin /home/zohan/microbench/result-micromasstree-2/$QPS/lats-$k.bin
    done
done