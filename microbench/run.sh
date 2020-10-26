#!/bin/bash
THREADS=1

TBENCH_WARMUPREQS=1 TBENCH_MAXREQS=100 TBENCH_QPS=100 TBENCH_MINSLEEPNS=10000 TBENCH_RANDSEED=333 ./microbench_integrated -r ${THREADS}

../utilities/parselats.py lats.bin