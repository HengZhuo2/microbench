nonblockT=2000
nonblockV=2000
blockT=2000
blockV=2000

STIME=1 # sleep/ swap out time/length in us, =10ms
SPROB=1 # 0.5% sleep/ swap out probility
lowbound=0
highbound=0 # lock of [0,4], 20% chance for each one, ends 4% two threads grabbing same lock
spinLimit=200

THREADS=2
NOISETIME=1500
NOISEPROB=200
NOISEVAR=100
timefreeze=0

for QPS in {"160","200","240","280","320","360",}
do
	mkdir -p /home/zohan/microbench/result-microimgdnn/$QPS
	for k in {1,}
	do
		BLOCK_TIME=${blockT} BLOCK_VAR=${blockV} NONBLOCK_TIME=${nonblockT} NONBLOCK_VAR=${nonblockV} NOISE_TIME=${NOISETIME} NOISE_PROB=${NOISEPROB} NOISE_VAR=${NOISEVAR} NOISE_AMP=1 SLEEP_TIME=${STIME} SLEEP_PROB=${SPROB} TBENCH_WARMUPREQS=$(($QPS*2)) TBENCH_MAXREQS=$(($QPS*8)) TBENCH_QPS_ROI=${QPS} TBENCH_QPS_WARMUP=${QPS} LOCKID_LOW=${lowbound} LOCKID_HIGH=${highbound} SPIN_LIMIT=${spinLimit} TIME_FREEZE=${timefreeze} ./microbench_integrated -r ${THREADS}
		echo "moving stats to /home/zohan/microbench/result-microimgdnn/$QPS/lats-$k..."
		mv lats.bin /home/zohan/microbench/result-microimgdnn/$QPS/lats-$k.bin
	done
done