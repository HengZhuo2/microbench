#!/usr/bin/python3

import sys
import os
import numpy as np
import functools 
from scipy import stats
from os import listdir
from os.path import isfile, join
np.set_printoptions(suppress=True,linewidth=150)

class MultLat(object):
    def __init__(self, latsPath):
        self.reqTimes = np.empty([0,0])
        for idx in [1,2,3,4,5,6,7,8]:
            fileName = latsPath+"/lats-"+str(idx)+".bin"
            # print("looking for: ", fileName)
            # fileName = join(latsPath,'lats.bin')
            if os.path.exists(fileName):
                f = open(fileName, 'rb')
                a = np.fromfile(f, dtype=np.uint64) # a will be 1-D array of all data
                self.reqTimes = np.append(self.reqTimes, a, axis=None)
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
    
    def parseSpinTimes(self):
        return self.reqTimes[:, 3]

def getMultLatPct(latsFolder):
    assert os.path.exists(latsFolder)

    latsObj = MultLat(latsFolder)

    qTimes = [l/1e6 for l in latsObj.parseQueueTimes()]
    svcTimes = [l/1e6 for l in latsObj.parseSvcTimes()]
    sjrnTimes = [l/1e6 for l in latsObj.parseSojournTimes()]
    spinTimes = latsObj.parseSpinTimes()
    f = open('lats.txt','w')

    f.write('%12s | %12s | %12s | %12s\n\n' \
            % ('QueueTimes', 'ServiceTimes', 'SojournTimes', 'SpinTimes'))

    for (q, svc, sjrn, spin) in zip(qTimes, svcTimes, sjrnTimes, spinTimes):
        f.write("%12s | %12s | %12s | %12s\n" \
                % ('%.3f' % q, '%.3f' % svc, '%.3f' % sjrn, '%.3f' % spin))
    f.close()
    p95 = stats.scoreatpercentile(sjrnTimes, 95)
    p99 = stats.scoreatpercentile(sjrnTimes, 99)
    meanLat = stats.tmean(sjrnTimes)
    svc95 = stats.scoreatpercentile(svcTimes, 95)
    svc99 = stats.scoreatpercentile(svcTimes, 99)
    svcMean = stats.tmean(svcTimes)
    maxLat = max(sjrnTimes)
    meanSpin = stats.tmean(spinTimes)
    spin95 = stats.scoreatpercentile(spinTimes, 95)
    spin99 = stats.scoreatpercentile(spinTimes, 99)
    maxSpinP = stats.percentileofscore(spinTimes, 5000.0)
    # print('mean: {:.3f} ms | 95th: {:.3f} ms | 99th: {:.3f} ms; svc mean: {:.3f} ms | 95th: {:.3f} ms | 99th: {:.3f} ms'.format(meanLat, p95, p99, svcMean, svc95, svc99))
    return np.asarray([meanLat,p95,p99,svcMean, svc95, svc99, maxSpinP])

def combineFolder(latsFolder, metric0, metric1, metric2):
    results = np.empty((7, 7))
    # print("combined matrix:")
    rdx = 0
    for f in ("1800","2400","3000","3600","4200","4800","5400"):
        results[rdx]=getMultLatPct(join(latsFolder,f))
        rdx = rdx + 1
    # for index in range(5):  
    #     print('{} mean: {:.3f} ms | 95th: {:.3f} ms | 99th: {:.3f} ms'.format((index+1)*2, results[index,0], results[index,1], results[index,2]))
    swaped = np.swapaxes(results,0,1)
    # print(repr(results))
    np.set_printoptions(precision=3)
    print("comdata_10000sleep_2p_10t_"+str(metric0)+"_"+str(metric1)+"p_"+str(metric2)+"="+ np.array2string(swaped[:,:], separator=','))


baseDir = "../hybrid-10000sleep-2p-10t/microbench-"

theads=10
botbound=0
upbound=49
blockTime=200
sleepT=10000
spinlimit=5000

for noiseT in ("0",):
    for noiseP in ("9999",):
        latsFolder = baseDir+noiseT+"-"+noiseP+"-"+str(spinlimit)
        combineFolder(latsFolder,noiseT,noiseP,str(spinlimit))