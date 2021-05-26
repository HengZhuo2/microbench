#!/usr/bin/python3
import warnings
import sys
import os
import numpy as np
from scipy import stats
import json

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

        # print ("95th percentile latency %.3f ms | 99th latency %.3f ms | max latency %.3f ms | mean latency %.3f ms" \
        #         % (p95, p99, maxLat, meanLat))
        # print ("round mean: %.3f ms | 95th: %.3f ms | 99th: %.3f ms | service mean: %.3f ms | 95th: %.3f ms | 99th: %.3f ms | spin mean: %.3f cycles" \
        #         % (meanLat,p95, p99, svcmean, svc95th, svc99th, meanSpin))
        
        print ("round mean: %.3f ms | 95th: %.3f ms | 99th: %.3f ms | service mean: %.3f ms | 95th: %.3f ms | 99th: %.3f ms" \
                % (sjrnMean,sjrn95Mean, sjrn99Mean, svcMean, svc95Mean, svc99Mean))
        # print ("%.3f %.3f %.3f %.3f" \
        #         % (meanLat, p95, p99, maxLat))
        data = (sjrnMean,sjrn95Mean, sjrn99Mean, svcMean, svc95Mean, svc99Mean)
        # print(json.dumps((meanLat,p95, p99, svcmean, svc95th, svc99th)))
        with open('/home/zohan/microbench/microbench/results-autogen/sample/1200/data.json', 'w') as jsonfile:
            json.dump(data, jsonfile)


    latsFile = sys.argv[1]
    getLatPct(latsFile)