#nonblockT=1200000 nonblockV=2 blockT=1750000 blockV=2
nonblockT=1130000
nonblockV=2
blockT=1750000
blockV=3

STIME=1 # sleep/ swap out time/length in us, =10ms
SPROB=1 # 0.5% sleep/ swap out probility

lowbound=0
highbound=0 # lock of [0,4], 20% chance for each one, ends 4% two threads grabbing same lock
spinLimit=200

THREADS=2

NOISETIME=100
NOISEPROB=100
NOISEVAR=100

timefreeze=0

# nonblockT=1300000
# nonblockV=4
# blockT=1750000
# blockV=10

for QPS in {0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0}
do
    mkdir -p /home/zohan/microbench/result-microsphinx-2/$QPS
    for k in {1..8}
    do
        BLOCK_TIME=${blockT} BLOCK_VAR=${blockV} NONBLOCK_TIME=${nonblockT} NONBLOCK_VAR=${nonblockV} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_VAR=${NOISEVAR} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=10 TBENCH_MAXREQS=90 TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=${lowbound} LOCKID_HIGH=${highbound} SPIN_LIMIT=${spinLimit} TIME_FREEZE=${timefreeze} ./microbench_integrated -r ${THREADS}
        echo "moving stats to /home/zohan/microbench/result-microsphinx-2/$QPS/lats-$k..."
        mv lats.bin /home/zohan/microbench/result-microsphinx-2/$QPS/lats-$k.bin
    done
done

# for QPS in {0.7,0.8,0.9,1.0}
# do
#     mkdir -p /home/zohan/microbench/result-microsphinx-2-criticaltry/$QPS
#     for k in {1,}
#     do
#         BLOCK_TIME=${blockT} BLOCK_VAR=${blockV} NONBLOCK_TIME=${nonblockT} NONBLOCK_VAR=${nonblockV} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_VAR=${NOISEVAR} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=10 TBENCH_MAXREQS=90 TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=${lowbound} LOCKID_HIGH=${highbound} SPIN_LIMIT=${spinLimit} TIME_FREEZE=${timefreeze} ./microbench_integrated -r ${THREADS}
#         echo "moving stats to /home/zohan/microbench/result-microsphinx-2-criticaltry/$QPS/lats-$k..."
#         mv lats.bin /home/zohan/microbench/result-microsphinx-2-criticaltry/$QPS/lats-$k.bin
#     done
# done

# echo "nonblockT=$nonblockT nonblockV=$nonblockV blockT=$blockT blockV=$blockV"