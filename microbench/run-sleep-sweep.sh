nonblockT=500
blockT=1000
lowbound=1
highbound=1
spinLimit=100000
STIME=10000

for QPS in {"600","1200","1800","2400","3000","3600","4200",}
do
    for THREADS in {"2","4","6","8","10","12","14","16"}
    do
        SLOWBOUND=0
        for SUPBOUND in {"19","49",}
        do
            mkdir -p ../results-norm-0.1-sleep-sweep/microbench-${STIME}-${SLOWBOUND}-${SUPBOUND}-${THREADS}/${QPS}
            for k in {1..8}
            do
                NOISE_TIME=0 NOISE_BOUND=0 SLEEP_TIME=${STIME} SLEEP_LOWBOUND=${SLOWBOUND} SLEEP_UPBOUND=${SUPBOUND} TBENCH_WARMUPREQS=$(($QPS*4)) TBENCH_MAXREQS=$(($QPS*12)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} ./microbench_integrated -r ${THREADS} -t ${nonblockT} -n ${blockT} -l ${lowbound} -p ${highbound} -s 10000000
                echo "moving stats to ../results-norm-0.1-sleep-sweep/microbench-${STIME}-${SLOWBOUND}-${SUPBOUND}-${THREADS}/${QPS}/lats-$k..."
                mv lats.bin ../results-norm-0.1-sleep-sweep/microbench-${STIME}-${SLOWBOUND}-${SUPBOUND}-${THREADS}/${QPS}/lats-$k.bin
            done
        done
        # SLOWBOUND=1
        # SUPBOUND=1
        # mkdir -p ../results-norm-0.1-sleep-sweep/microbench-${STIME}-${SLOWBOUND}-${SUPBOUND}-${THREADS}/${QPS}
        # for k in {1..8}
        # do
        #     NOISE_TIME=0 NOISE_BOUND=0 SLEEP_TIME=200 SLEEP_LOWBOUND=${SLOWBOUND} SLEEP_UPBOUND=${SUPBOUND} TBENCH_WARMUPREQS=$(($QPS*4)) TBENCH_MAXREQS=$(($QPS*12)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} ./microbench_integrated -r ${THREADS} -t ${nonblockT} -n ${blockT} -l ${lowbound} -p ${highbound} -s 10000000
        #     echo "moving stats to ../results-norm-0.1-sleep-sweep/microbench-${STIME}-${SLOWBOUND}-${SUPBOUND}-${THREADS}/${QPS}/lats-$k..."
        #     mv lats.bin ../results-norm-0.1-sleep-sweep/microbench-${STIME}-${SLOWBOUND}-${SUPBOUND}-${THREADS}/${QPS}/lats-$k.bin
        # done
    done
done