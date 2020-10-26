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
        self.reqTimes = a.reshape((a.shape[0]//3, 3))
        f.close()

    def parseQueueTimes(self):
        return self.reqTimes[:, 0]

    def parseSvcTimes(self):
        return self.reqTimes[:, 1]

    def parseSojournTimes(self):
        return self.reqTimes[:, 2]

if __name__ == '__main__':
    def getLatPct(latsFile):
        assert os.path.exists(latsFile)

        latsObj = Lat(latsFile)

        qTimes = [l/1e6 for l in latsObj.parseQueueTimes()]
        svcTimes = [l/1e6 for l in latsObj.parseSvcTimes()]
        sjrnTimes = [l/1e6 for l in latsObj.parseSojournTimes()]
        f = open('lats.txt','w')

        f.write('%12s | %12s | %12s\n\n' \
                % ('QueueTimes', 'ServiceTimes', 'SojournTimes'))

        for (q, svc, sjrn) in zip(qTimes, svcTimes, sjrnTimes):
            f.write("%12s | %12s | %12s\n" \
                    % ('%.3f' % q, '%.3f' % svc, '%.3f' % sjrn))
        f.close()
        p95 = stats.scoreatpercentile(sjrnTimes, 95)
        p99 = stats.scoreatpercentile(sjrnTimes, 99)
        meanLat = stats.tmean(sjrnTimes)
        # maxLat = max(sjrnTimes)

        svcmean = stats.tmean(svcTimes)
        svc95th = stats.scoreatpercentile(svcTimes, 95)
        svc99th = stats.scoreatpercentile(svcTimes, 99)

        # print ("95th percentile latency %.3f ms | 99th latency %.3f ms | max latency %.3f ms | mean latency %.3f ms" \
        #         % (p95, p99, maxLat, meanLat))
        print ("round mean: %.3f ms | 95th: %.3f ms | 99th: %.3f ms | service mean: %.3f ms | 95th: %.3f ms | 99th: %.3f ms" \
                % (meanLat,p95, p99, svcmean, svc95th, svc99th))
        # print ("%.3f %.3f %.3f %.3f" \
        #         % (meanLat, p95, p99, maxLat))
        
    latsFile = sys.argv[1]
    getLatPct(latsFile)
        
