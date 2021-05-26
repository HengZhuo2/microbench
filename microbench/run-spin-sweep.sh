nonblockT=500
blockT=1000
THREADS=2
for QPS in {"200","400","800","1200","1600","2000","2400",}
do
    for SPIN in {"4000","8000","12000","16000","20000",}
    do
        lowbound=0
        for highbound in {"0","1",}
        do
            mkdir -p ../results-norm-0.1-spin-sweep/microbench-${nonblockT}-${blockT}-${lowbound}-${highbound}-${SPIN}/${QPS}
            for k in {1..10}
            do
                TBENCH_WARMUPREQS=$(($QPS*4)) TBENCH_MAXREQS=$(($QPS*12)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} ./microbench_integrated -r ${THREADS} -t ${nonblockT} -n ${blockT} -l ${lowbound} -p ${highbound} -s ${SPIN}
                echo "moving stats to ../results-norm-0.1-spin-sweep/microbench-${nonblockT}-${blockT}-${lowbound}-${highbound}-${SPIN}/${QPS}/lats-$k..."
                mv lats.bin ../results-norm-0.1-spin-sweep/microbench-${nonblockT}-${blockT}-${lowbound}-${highbound}-${SPIN}/${QPS}/lats-$k.bin
            done
        done

        lowbound=1
        highbound=1
        mkdir -p ../results-norm-0.1-spin-sweep/microbench-${nonblockT}-${blockT}-${lowbound}-${highbound}-${SPIN}/${QPS}
        for k in {1..10}
        do
            TBENCH_WARMUPREQS=$(($QPS*4)) TBENCH_MAXREQS=$(($QPS*12)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} ./microbench_integrated -r ${THREADS} -t ${nonblockT} -n ${blockT} -l ${lowbound} -p ${highbound} -s ${SPIN}
            echo "moving stats to ../results-norm-0.1-spin-sweep/microbench-${nonblockT}-${blockT}-${lowbound}-${highbound}-${SPIN}/${QPS}/lats-$k..."
            mv lats.bin ../results-norm-0.1-spin-sweep/microbench-${nonblockT}-${blockT}-${lowbound}-${highbound}-${SPIN}/${QPS}/lats-$k.bin
        done
    done
done