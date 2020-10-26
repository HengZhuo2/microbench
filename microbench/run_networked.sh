#!/bin/bash

THREADS=2

TBENCH_WARMUPREQS=1 TBENCH_MAXREQS=2500 TBENCH_SERVER=localhost ./microbench_server_networked -r ${THREADS} &
echo $! > server.pid

sleep 1 # Wait for server to come up

TBENCH_QPS_ROI=800 TBENCH_QPS_WARMUP=800 ./microbench_client_networked

../utilities/parselats.py lats.bin