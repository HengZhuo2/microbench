nonblockT=1300
blockT=200

STIME=10000 # sleep/ swap out time/length in us, =10ms
SPROB=5 # 0.5% sleep/ swap out probility
lowbound=0
highbound=0 # lock of [0,4], 20% chance for each one, ends 4% two threads grabbing same lock
spinLimit=200

THREADS=2
QPS=400
NOISETIME=100
NOISEPROB=1000
timefreeze=0
# mkdir -p ../result-base-sweep/microbench-${NOISETIME}-${NOISEPROB}/${QPS}
for k in {1,}
do
    BLOCK_TIME=${blockT} NONBLOCK_TIME=${nonblockT} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=$(($QPS*4)) TBENCH_MAXREQS=$(($QPS*12)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=${lowbound} LOCKID_HIGH=${highbound} SPIN_LIMIT=${spinLimit} TIME_FREEZE=${timefreeze} ./microbench_integrated -r ${THREADS}
    # echo "moving stats to ../result-base-sweep/microbench-${NOISETIME}-${NOISEPROB}/${QPS}/lats-$k..."
    # mv lats.bin ../result-base-sweep/microbench-${NOISETIME}-${NOISEPROB}/${QPS}/lats-$k.bin
done

# for QPS in {"800","1000","1200","1400","1600","1800","2000","2200","2400","2600","2800","3000","3200","3400"}
# do
#     for NOISETIME in {"0","20","50","100",}
#     do
#         for NOISEPROB in {"0","10","50","100"}
#         do
#             mkdir -p ../result-noise-sweep/microbench-${NOISETIME}-${NOISEPROB}/${QPS}
#             for k in {1..8}
#             do
#                 BLOCK_TIME=${blockT} NONBLOCK_TIME=${nonblockT} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=$(($QPS*4)) TBENCH_MAXREQS=$(($QPS*12)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=0 LOCKID_HIGH=4 SPIN_LIMIT=${spinLimit} ./microbench_integrated -r ${THREADS}
#                 echo "moving stats to ../result-noise-sweep/microbench-${NOISETIME}-${NOISEPROB}/${QPS}/lats-$k..."
#                 mv lats.bin ../result-noise-sweep/microbench-${NOISETIME}-${NOISEPROB}/${QPS}/lats-$k.bin
#             done
#         done
#     done
# done