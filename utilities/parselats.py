#!/usr/bin/python3
import warnings
import sys
import os
import numpy as np
from scipy import stats

warnings.simplefilter(action='ignore', category=FutureWarning)

class Lat(object):
    def __init__(self, fileName):
        f = open(fileName, 'rb')
        a = np.fromfile(f, dtype=np.uint64)
        # print(repr(a))
        self.reqTimes = a.reshape((a.shape[0]//4, 4))
        # print((self.reqTimes))
        f.close()

    def parseQueueTimes(self):
        return self.reqTimes[:, 0]

    def parseSvcTimes(self):
        return self.reqTimes[:, 1]

    def parseSojournTimes(self):
        return self.reqTimes[:, 2]

    def parseSpinTimes(self):
        return self.reqTimes[:, 3]

if __name__ == '__main__':
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

        meanSpin = stats.tmean(spinTimes)
        spin95 = stats.scoreatpercentile(spinTimes, 95)
        spin99 = stats.scoreatpercentile(spinTimes, 99)
        # maxLat = max(sjrnTimes)

        svcmean = stats.tmean(svcTimes)
        svc95th = stats.scoreatpercentile(svcTimes, 95)
        svc99th = stats.scoreatpercentile(svcTimes, 99)

        # print ("95th percentile latency %.3f ms | 99th latency %.3f ms | max latency %.3f ms | mean latency %.3f ms" \
        #         % (p95, p99, maxLat, meanLat))
        # print ("round mean: %.3f ms | 95th: %.3f ms | 99th: %.3f ms | service mean: %.3f ms | 95th: %.3f ms | 99th: %.3f ms | spin mean: %.3f cycles" \
        #         % (meanLat,p95, p99, svcmean, svc95th, svc99th, meanSpin))
        
        print ("round mean: %.3f ms | 95th: %.3f ms | 99th: %.3f ms | service mean: %.3f ms | 95th: %.3f ms | 99th: %.3f ms | spin mean: %.3f cycles | 95th: %.3f cycles | 99th: %.3f cycles" \
                % (meanLat,p95, p99, svcmean, svc95th, svc99th, meanSpin, spin95, spin99))
        # print ("%.3f %.3f %.3f %.3f" \
        #         % (meanLat, p95, p99, maxLat))
        
    latsFile = sys.argv[1]
    getLatPct(latsFile)
        
