#!/bin/bash

THREADS=1

TBENCH_WARMUPREQS=500 TBENCH_MAXREQS=1000 TBENCH_SERVER=localhost ./microbench_server_networked -r ${THREADS}