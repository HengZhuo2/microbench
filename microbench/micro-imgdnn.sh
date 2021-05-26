nonblockT=3400
nonblockV=100
blockT=1000
blockV=200

STIME=40000 # sleep/ swap out time/length in us, =10ms
SPROB=5 # 0.5% sleep/ swap out probility
lowbound=0
highbound=9 # lock of [0,4], 20% chance for each one, ends 4% two threads grabbing same lock
spinLimit=200

THREADS=2
NOISETIME=7000
NOISEPROB=50
NOISEVAR=100
timefreeze=0

for QPS in {"40","80","120","160","200","240","280","320","360","400","440","480"}
do
    mkdir -p ../result-microimgdnn-2/${QPS}
    for k in {1..2}
    do
        BLOCK_TIME=${blockT} BLOCK_VAR=${blockV} NONBLOCK_TIME=${nonblockT} NONBLOCK_VAR=${nonblockV} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_VAR=${NOISEVAR} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=$(($QPS*2)) TBENCH_MAXREQS=$(($QPS*8)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=${lowbound} LOCKID_HIGH=${highbound} SPIN_LIMIT=${spinLimit} TIME_FREEZE=${timefreeze} ./microbench_integrated -r ${THREADS}

        echo "moving stats to ../result-microimgdnn-2/${QPS}/lats-$k..."
        mv lats.bin ../result-microimgdnn-2/${QPS}/lats-$k.bin
    done
done