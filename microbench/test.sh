nonblockT=1300
blockT=200

spinLimit=100000

STIME=10000 # sleep/ swap out times
THREADS=10 # 10 threads for 10 ms sleep time compare to 1.5 thread time
SLOWBOUND=0
SUPBOUND=49 # 2% sleep/ swap out probility
lowbound=0
highbound=9 # lock of [0,9], 10% chance for each one, ends 1% two threads grabbing same lock
spinLimit=5000

NOISETIME=0
NOISEPROB=0
for QPS in {"1800","2400","3000","3600","4200","4800","5400",}
do
    mkdir -p ../hybrid-10000sleep-2p-10t/microbench-${NOISETIME}-9999-${spinLimit}/${QPS}
    for k in {1..8}
    do
        NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} SLEEP_TIME=${STIME} SLEEP_LOWBOUND=${SLOWBOUND} SLEEP_UPBOUND=${SUPBOUND} TBENCH_WARMUPREQS=$(($QPS*4)) TBENCH_MAXREQS=$(($QPS*12)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} ./microbench_integrated -r ${THREADS} -t ${nonblockT} -n ${blockT} -l ${lowbound} -p ${highbound} -s ${spinLimit}
        echo "moving stats to ../hybrid-10000sleep-2p-10t/microbench-${NOISETIME}-9999-${spinLimit}/${QPS}/lats-$k..."
        mv lats.bin ../hybrid-10000sleep-2p-10t/microbench-${NOISETIME}-9999-${spinLimit}/${QPS}/lats-$k.bin
    done
done