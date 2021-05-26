nonblockT=1100
nonblockV=10
blockT=1
blockV=10

STIME=45000 # sleep/ swap out time/length in us, =10ms
SPROB=1 # 0.5% sleep/ swap out probility
lowbound=0
highbound=0 # lock of [0,4], 20% chance for each one, ends 4% two threads grabbing same lock
spinLimit=200

THREADS=2
NOISETIME=4000
NOISEPROB=45
NOISEVAR=10
timefreeze=0
QPS=1000

for nonblockT in {"600","1000","1400","1800"}
do
    blockT=100
    # for blockT in {"400","500","600"}
    # do
    for QPS in {"400","500","600","700","800","900","1000","1100","1200"}
    do
        mkdir -p /home/zohan/microbench/result-length-sweep/$nonblockT-$blockT/$QPS
        # for k in {1,}
        for k in {1..8}
        do
            BLOCK_TIME=${blockT} BLOCK_VAR=${blockV} NONBLOCK_TIME=${nonblockT} NONBLOCK_VAR=${nonblockV} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_VAR=${NOISEVAR} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=$(($QPS*2)) TBENCH_MAXREQS=$(($QPS*8)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=${lowbound} LOCKID_HIGH=${highbound} SPIN_LIMIT=${spinLimit} TIME_FREEZE=${timefreeze} ./microbench_integrated -r ${THREADS}
            echo "moving stats to /home/zohan/microbench/result-length-sweep/$nonblockT-$blockT/$QPS/lats-$k..."
            mv lats.bin /home/zohan/microbench/result-length-sweep/$nonblockT-$blockT/$QPS/lats-$k.bin
        done
    done
    # done
done

# for STIME in {"16000","18000","20000"}
# do
# 	for SPROB in {"20","30","40"}
# 	do
# 		for nonblockT in {"400","500","600"}
# 		do
#             nonblockV=$nonblockT
# 			for blockT in {"400","500","600"}
# 		    do
#                 blockV=$blockT
# 			    for QPS in {"400","600","800","1000","1200","1400"}
#                 do
#                     mkdir -p /home/zohan/microbench/result-dist/$STIME-$SPROB-$nonblockT-$blockT/$QPS
#                     for k in {1,}
#                     do
#                         BLOCK_TIME=${blockT} BLOCK_VAR=${blockV} NONBLOCK_TIME=${nonblockT} NONBLOCK_VAR=${nonblockV} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_VAR=${NOISEVAR} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=$(($QPS*1)) TBENCH_MAXREQS=$(($QPS*4)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=${lowbound} LOCKID_HIGH=${highbound} SPIN_LIMIT=${spinLimit} TIME_FREEZE=${timefreeze} ./microbench_integrated -r ${THREADS}
#                         echo "moving stats to /home/zohan/microbench/result-dist/$STIME-$SPROB-$nonblockT-$blockT/$QPS/lats-$k..."
#                         mv lats.bin /home/zohan/microbench/result-dist/$STIME-$SPROB-$nonblockT-$blockT/$QPS/lats-$k.bin
#                     done
#                 done
# 		    done
# 		done
# 	done
# done