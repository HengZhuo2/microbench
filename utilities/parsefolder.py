#!/usr/bin/python3

import sys
import os
import numpy as np
import functools 
from scipy import stats
from os import listdir
from os.path import isfile, join
np.set_printoptions(suppress=True,linewidth=150)

class Lat(object):
    def __init__(self, fileName):
        f = open(fileName, 'rb')
        a = np.fromfile(f, dtype=np.uint64) # a will be 1-D array of all data
        self.reqTimes = a.reshape((a.shape[0]//4, 4)) # transfer into 2-D array
        f.close()

    def parseQueueTimes(self):
        return self.reqTimes[:, 0]

    def parseSvcTimes(self):
        return self.reqTimes[:, 1]

    def parseSojournTimes(self):
        return self.reqTimes[:, 2]

    def parseSpinTimes(self):
        return self.reqTimes[:, 3]

def getLatPct(latsFile):
    assert os.path.exists(latsFile)

    latsObj = Lat(latsFile)

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
    # print ("mean latency %.3f ms | 95th latency %.3f ms | 99th latency %.3f ms | max latency %.3f ms" \
    #         % (meanLat, p95, p99, maxLat))
    # print('mean: {:.3f} ms | 95th: {:.3f} ms | 99th: {:.3f} ms; svc mean: {:.3f} ms | 95th: {:.3f} ms | 99th: {:.3f} ms'.format(meanLat, p95,p99,svcMean,svc95,svc99))
    # return np.asarray([meanLat,p95,p99,svcMean, svc95, svc99, meanSpin, spin95, spin99])
    return np.asarray([meanLat,p95,p99,svcMean, svc95, svc99])
    
def parseFolder(latsFolder, metric0, metric1, metric2):
    results = np.empty((7, 6))
    rdx = 0
    for f in (600,1200,1800,2400,3000,3600,4200):
        # print(f)
        result = np.empty((8, 6))
        result[:] = np.NaN
        idx = 0
        for f2 in listdir(join(latsFolder,str(f))):
            latsFile = join(latsFolder,str(f),f2)
            # print(latsFile)
            result[idx]=getLatPct(latsFile)
            idx = idx+1
        # print(result)
        # stds[int(f)/200-2] = np.nanstd(result, axis=0)
        results[rdx] = np.nanmean(result, axis=0)
        rdx = rdx+1
        # print(np.array2string(result, separator=','))
    swaped = np.swapaxes(results,0,1)
    print("data_"+str(metric0)+"p_"+str(metric1)+"_"+str(metric2)+"="+ np.array2string(swaped[:,:], separator=','))


baseDir = sys.argv[1]
# for upbound in (9,99):
#     botbound=0
#     sleepT=10000
#     for theads in (2,4,8,12,16):
#         latsFolder = baseDir+str(sleepT)+"-"+str(botbound)+"-"+str(upbound)+"-"+str(theads)
#         parseFolder(latsFolder,upbound,str(theads))
# botbound=1
# upbound=1
# sleepT=10000
# for theads in (2,4,8,12,16):
#     latsFolder = baseDir+str(sleepT)+"-"+str(botbound)+"-"+str(upbound)+"-"+str(theads)
#     parseFolder(latsFolder,upbound,str(theads))

for sleepT in (10000,):
    botbound=0
    upbound=9
    for theads in (2,4,6,8,10,12,14,16):
        latsFolder = baseDir+str(sleepT)+"-"+str(botbound)+"-"+str(upbound)+"-"+str(theads)
        parseFolder(latsFolder,'2',sleepT,str(theads))