nonblockT=500
blockT=1000
THREADS=2
lowbound=0
highbound=0
spinLimit=100000
for QPS in {"200","400","800","1200","1600","2000","2400",}
do
    for noiseT in {"100","200","400",}
    do
        for noiseBound in {"1","9","99",}
        do
            mkdir -p ../results-norm-0.1-noise-sweep/microbench-${noiseT}-0-${noiseBound}/${QPS}
            for k in {1..4}
            do
                TBENCH_WARMUPREQS=$(($QPS*4)) TBENCH_MAXREQS=$(($QPS*12)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} ./microbench_integrated -r ${THREADS} -t ${nonblockT} -n ${blockT} -l ${lowbound} -p ${highbound} -s ${spinLimit} -d ${noiseT} -c ${noiseBound}
                echo "moving stats to ../results-norm-0.1-noise-sweep/microbench-${noiseT}-0-${noiseBound}/${QPS}/lats-$k..."
                mv lats.bin ../results-norm-0.1-noise-sweep/microbench-${noiseT}-0-${noiseBound}/${QPS}/lats-$k.bin
            done
        done
    done
done