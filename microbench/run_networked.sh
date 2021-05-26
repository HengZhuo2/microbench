#!/bin/bash

# THREADS=2

# TBENCH_WARMUPREQS=2400 TBENCH_MAXREQS=2500 TBENCH_SERVER=localhost ./microbench_server_networked -r ${THREADS} &
# echo $! > server.pid

# sleep 1 # Wait for server to come up

# TBENCH_QPS_ROI=800 TBENCH_QPS_WARMUP=800 ./microbench_client_networked

# ../utilities/parselats.py lats.bin

# for QPS in {200,400,600,800,1000}
# do
QPS=200
thread=1
k=1
	# for thread in {1,2,4}
	# do
        # mkdir -p ../results/microbench-1v4-spin-$thread/$QPS
		echo "starting $thread threads:"
		# for k in {1..2}
		# do
			TBENCH_WARMUPREQS=$(($QPS*2)) TBENCH_MAXREQS=$(($QPS*5)) TBENCH_SERVER=localhost ./microbench_server_networked -r ${thread} &
            sleep 2
            TBENCH_QPS_ROI=$QPS TBENCH_QPS_WARMUP=$QPS ./microbench_client_networked
			../utilities/parselats.py lats.bin
            # echo "moving stats to ./results/microbench-1v4-spin-$thread/$QPS/lats-$k..."
			# mv lats.bin ../results/microbench-1v4-spin-$thread/$QPS/lats-$k.bin
# 		done
# 	done
# done

echo "finishing microbenchmark"