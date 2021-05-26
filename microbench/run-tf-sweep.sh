nonblockT=1300
blockT=200

STIME=10000 # sleep/ swap out time/length in us, =10ms
SPROB=5 # 0.5% sleep/ swap out probility
lowbound=0
highbound=4 # lock of [0,4], 20% chance for each one, ends 4% two threads grabbing same lock
spinLimit=1000
THREADS=5

NOISETIME=100
NOISEPROB=100

timefreeze=0
for QPS in {"1200","1600","2000","2400","2800","3200","3600"}
do
    for NOISETIME in {"10","100",}
    do
        for spinLimit in {"10","100","1000"}
        do
            mkdir -p ../result-base-sweep/microbench-${NOISETIME}-${NOISEPROB}-${spinLimit}/${QPS}
            for k in {1..8}
            do
                BLOCK_TIME=${blockT} NONBLOCK_TIME=${nonblockT} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=$(($QPS*4)) TBENCH_MAXREQS=$(($QPS*12)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=${lowbound} LOCKID_HIGH=${highbound} SPIN_LIMIT=${spinLimit} TIME_FREEZE=${timefreeze} ./microbench_integrated -r ${THREADS}
                echo "moving stats to ../result-base-sweep/microbench-${NOISETIME}-${NOISEPROB}-${spinLimit}/${QPS}/lats-$k..."
                mv lats.bin ../result-base-sweep/microbench-${NOISETIME}-${NOISEPROB}-${spinLimit}/${QPS}/lats-$k.bin
            done
        done
    done
done

timefreeze=1
for QPS in {"1200","1600","2000","2400","2800","3200","3600"}
do
    for NOISETIME in {"10","100",}
    do
        for spinLimit in {"10","100","1000"}
        do
            mkdir -p ../result-tf-sweep/microbench-${NOISETIME}-${NOISEPROB}-${spinLimit}/${QPS}
            for k in {1..8}
            do
                BLOCK_TIME=${blockT} NONBLOCK_TIME=${nonblockT} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=$(($QPS*4)) TBENCH_MAXREQS=$(($QPS*12)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=${lowbound} LOCKID_HIGH=${highbound} SPIN_LIMIT=${spinLimit} TIME_FREEZE=${timefreeze} ./microbench_integrated -r ${THREADS}
                echo "moving stats to ../result-tf-sweep/microbench-${NOISETIME}-${NOISEPROB}-${spinLimit}/${QPS}/lats-$k..."
                mv lats.bin ../result-tf-sweep/microbench-${NOISETIME}-${NOISEPROB}-${spinLimit}/${QPS}/lats-$k.bin
            done
        done
    done
done