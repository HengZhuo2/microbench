#!/usr/bin/python3
import warnings
import sys
import os
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
from os import listdir
from os.path import isfile, join
import math #needed for definition of pi
import json

np.set_printoptions(precision=3, suppress=True, linewidth=100)

class MicroMultLat(object):
    def __init__(self, latsPath, qps,binRange):
        self.reqTimes = np.empty([0,0])
        for idx in binRange:
        # for idx in [1]:
            fileName = join(latsPath,qps)+"/lats-"+str(idx)+".bin"
            # print("looking for: ", fileName)
            # fileName = join(latsPath,'lats.bin')
            if os.path.exists(fileName):
                f = open(fileName, 'rb')
                a = np.fromfile(f, dtype=np.uint64) # a will be 1-D array of all data
                self.reqTimes = np.append(self.reqTimes, a[:], axis=None)
                # self.reqTimes = np.append(self.reqTimes, a, axis=None)
                # np.append(self.reqTimes, a.reshape((a.shape[0]//3, 3)), axis=None)
                # self.reqTimes = a.reshape((a.shape[0]//3, 3)) # transfer into 2-D array
                f.close()
            else:
                print("not found in this dir :", fileName)
        
        self.reqTimes = self.reqTimes.reshape((self.reqTimes.shape[0]//4, 4))


    def parseQueueTimes(self):
        return self.reqTimes[:, 0]

    def parseSvcTimes(self):
        return self.reqTimes[:, 1]

    def parseSojournTimes(self):
        return self.reqTimes[:, 2]
    
    # def parseSpinTimes(self):
    #     return self.reqTimes[:, 3]

def getMicroMultLatPct(latsFolder,qps,binRange):
    # print(latsFolder)
    assert os.path.exists(latsFolder)

    latsObj = MicroMultLat(latsFolder,qps,binRange)

    qTimes = [l/1e6 for l in latsObj.parseQueueTimes()]
    svcTimes = [l/1e6 for l in latsObj.parseSvcTimes()]
    sjrnTimes = [l/1e6 for l in latsObj.parseSojournTimes()]
    # spinTimes = latsObj.parseSpinTimes()
    f = open('lats.txt','w')

    f.write('%12s | %12s | %12s \n\n' \
            % ('QueueTimes', 'ServiceTimes', 'SojournTimes'))

    for (q, svc, sjrn) in zip(qTimes, svcTimes, sjrnTimes):
        f.write("%12s | %12s | %12s \n" \
                % ('%.3f' % q, '%.3f' % svc, '%.3f' % sjrn))
    f.close()
    sjrn95th = stats.scoreatpercentile(sjrnTimes, 95)
    sjrn99th = stats.scoreatpercentile(sjrnTimes, 99)
    sjrnMean = stats.tmean(sjrnTimes)
    sjrnMax = max(sjrnTimes)
    sjrn95Mean = stats.tmean(sjrnTimes, (sjrn95th, sjrnMax))
    sjrn99Mean = stats.tmean(sjrnTimes, (sjrn99th, sjrnMax))

    svc95th = stats.scoreatpercentile(svcTimes, 95)
    svc99th = stats.scoreatpercentile(svcTimes, 99)
    svcMean = stats.tmean(svcTimes)
    svcMax = max(svcTimes)
    svc95Mean = stats.tmean(svcTimes, (svc95th, svcMax))
    svc99Mean = stats.tmean(svcTimes, (svc99th, svcMax))

    print ("round mean: %.3f ms | 95th: %.3f ms | 99th: %.3f ms | service mean: %.3f ms | 95th: %.3f ms | 99th: %.3f ms" \
                % (sjrnMean,sjrn95Mean, sjrn99Mean, svcMean, svc95Mean, svc99Mean))

    data = (sjrnMean, sjrn95Mean, sjrn99Mean, svcMean, svc95Mean, svc99Mean)
    
    # print(json.dumps((meanLat,p95, p99, svcmean, svc95th, svc99th)))
    with open('/home/zohan/microbench/microbench/results-autogen/sample/1200/data.json', 'w') as jsonfile:
        json.dump(data, jsonfile)

    return np.asarray([sjrnMean, sjrn95Mean, sjrn99Mean, svcMean, svc95Mean, svc99Mean])
    # return np.asarray([sjrnMean, sjrn95th, sjrn99th, svcMean, svc95th, svc99th])

def combineMicroFolder(latsFolder, qps, binRange):
    results = np.empty((len(qps), 6))
    rdx = 0
    for f in qps:
        results[rdx]=getMicroMultLatPct(latsFolder,f, binRange)
        rdx = rdx + 1
    swaped = np.swapaxes(results,0,1)
    np.set_printoptions(precision=3)

    return swaped

    # data = (meanLat,p95, p99, svcmean, svc95th, svc99th)
    # # print(json.dumps((meanLat,p95, p99, svcmean, svc95th, svc99th)))
    # with open('/home/zohan/microbench/microbench/results-autogen/sample/data.json', 'w') as jsonfile:
    #     json.dump(data, jsonfile)

bin_range=[1,2,3,4]
microbench_dir = "/home/zohan/microbench/microbench/results-autogen/sample"
microbench_qps = ("1200")
# microbench_data = combineMicroFolder(microbench_dir,microbench_qps,bin_range)
microbench_data = getMicroMultLatPct(microbench_dir,microbench_qps,bin_range)
