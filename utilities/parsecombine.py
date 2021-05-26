import warnings
import sys
import os
import numpy as np
from scipy import stats
from os import listdir
from os.path import isfile, join
import math #needed for definition of pi

np.set_printoptions(precision=3, suppress=True, linewidth=120)

class TailMultLat(object):
    def __init__(self, latsPath):
        self.reqTimes = np.empty([0,0])
        for idx in range(1,9,1):
            fileName = latsPath+"/lats-"+str(idx)+".bin"
            # print("looking for: ", fileName)
            # fileName = join(latsPath,'lats.bin')
            if os.path.exists(fileName):
                f = open(fileName, 'rb')
                a = np.fromfile(f, dtype=np.uint64) # a will be 1-D array of all data
                # print(len(a))
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

    # def parseSpinTimes(self):
    #     return self.reqTimes[:, 3]

def getTailMultLatPct(latsFolder):
    # print(latsFolder)
    assert os.path.exists(latsFolder)

    latsObj = TailMultLat(latsFolder)

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

        return np.asarray([sjrnMean, sjrn95Mean, sjrn99Mean, svcMean, svc95Mean, svc99Mean, svc95th, svc99th])

def combineTailFolder(latsFolder, qps):
    results = np.empty((len(qps), 8))
    rdx = 0
    for f in qps:
        results[rdx]=getTailMultLatPct(join(latsFolder,f))
        rdx = rdx + 1
        swaped = np.swapaxes(results,0,1)
        np.set_printoptions(precision=3)
        # print(np.array2string(swaped[:,:], separator=','))
    
    return swaped

latsFolder = "/home/zohan/microbench/result-micromasstree-2"
qps = ("400","500","600","700","800","900","1000","1100","1200","1300","1400","1500","1600")
data = combineTailFolder(latsFolder,qps)
# print(data)
print(np.array2string(data[:,:], separator=','))