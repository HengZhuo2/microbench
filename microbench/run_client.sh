#!/bin/bash

thread=2
echo "starting $thread threads:"
nonblockT=100
blockT=100
# for QPS in {"120",}
# do
#   # for lowbound in {"0",}
#   # do
#   #   for highbound in {"9",}
#   #   do
#   #     mkdir -p ../results/microbench-${nonblockT}-${blockT}-${thread}-${lowbound}-${highbound}/${QPS}
#   #     for k in {1..10}
#   #     do
#   #         sleep 2
#   #         TBENCH_QPS_ROI=$QPS TBENCH_QPS_WARMUP=$QPS TBENCH_CLIENT_THREADS=2 TBENCH_SERVER=169.254.53.19 ./microbench_client_networked
#   #         echo "moving stats to ../results/microbench-${nonblockT}-${blockT}-${thread}-${lowbound}-${highbound}/${QPS}/lats-$k..."
#   #         mv lats.bin ../results/microbench-${nonblockT}-${blockT}-${thread}-${lowbound}-${highbound}/${QPS}/lats-$k.bin
#   #     done
#   #   done
#   # done
#   lowbound=1
#   highbound=1
#   mkdir -p ../results/microbench-${nonblockT}-${blockT}-${thread}-${lowbound}-${highbound}/${QPS}
#   for k in {1..10}
#   do
#       sleep 2
#       TBENCH_QPS_ROI=$QPS TBENCH_QPS_WARMUP=$QPS TBENCH_CLIENT_THREADS=2 TBENCH_SERVER=169.254.53.19 ./microbench_client_networked
#       echo "moving stats to ../results/microbench-${nonblockT}-${blockT}-${thread}-${lowbound}-${highbound}/${QPS}/lats-$k..."
#       mv lats.bin ../results/microbench-${nonblockT}-${blockT}-${thread}-${lowbound}-${highbound}/${QPS}/lats-$k.bin
#   done
# done

nonblockT=10
blockT=10
for QPS in {"1","2","4","6","8","10","12",}
do
    lowbound=0
    for highbound in {"0","1","3","9",}
    do
	mkdir -p ../results/microbench-${nonblockT}-${blockT}-${thread}-${lowbound}-${highbound}/${QPS}
	for k in {1..10}
	do
            sleep 2
            TBENCH_QPS_ROI=$QPS TBENCH_QPS_WARMUP=$QPS TBENCH_CLIENT_THREADS=2 TBENCH_SERVER=169.254.53.19 ./microbench_client_networked
            echo "moving stats to ../results/microbench-${nonblockT}-${blockT}-${thread}-${lowbound}-${highbound}/${QPS}/lats-$k..."
            mv lats.bin ../results/microbench-${nonblockT}-${blockT}-${thread}-${lowbound}-${highbound}/${QPS}/lats-$k.bin
	done
    done
    lowbound=1
    highbound=1
    mkdir -p ../results/microbench-${nonblockT}-${blockT}-${thread}-${lowbound}-${highbound}/${QPS}
    for k in {1..10}
    do
	sleep 2
	TBENCH_QPS_ROI=$QPS TBENCH_QPS_WARMUP=$QPS TBENCH_CLIENT_THREADS=2 TBENCH_SERVER=169.254.53.19 ./microbench_client_networked
	echo "moving stats to ../results/microbench-${nonblockT}-${blockT}-${thread}-${lowbound}-${highbound}/${QPS}/lats-$k..."
	mv lats.bin ../results/microbench-${nonblockT}-${blockT}-${thread}-${lowbound}-${highbound}/${QPS}/lats-$k.bin
    done
done

echo "finishing microbench"
