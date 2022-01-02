from nlmpy import nlmpy
import time

nlm = nlmpy.mpd(nRow=50, nCol=50, h=0.75)


methods = dict(
    random = lambda: nlmpy.random(250,250), 
    pg = lambda: nlmpy.planarGradient(250,250), 
    dg = lambda: nlmpy.distanceGradient(nlmpy.planarGradient(250,250)), 
    eg = lambda: nlmpy.edgeGradient(250,250),
    ws = lambda: nlmpy.waveSurface(250,250, 4), 
    mpd = lambda: nlmpy.mpd(256,256,0.8), 
    perlin = lambda: nlmpy.perlinNoise(250,250, (2,2)),
    renn = lambda: nlmpy.randomElementNN(250,250,10), 
    rcnn = lambda: nlmpy.randomClusterNN(250,250, 0.4),  
)

nbatches = 1000
import csv
with open('pybench.csv', 'w') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["method", "batch", "mean_execution_time"])

    for key in methods: 
        for batch in range(0,nbatches):
            t1 = time.time()
            r = methods[key]()
            t2 = time.time()
            writer.writerow([key, batch, t2-t1])

            
"""
with open('py_scalebench.csv', 'w') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["size", "batch", "time_seconds"])
    nbatches = 50
    for sideexp in range(3, 11):
        for batch in range(0,nbatches):
            t1 = time.time()
            r = nlmpy.mpd(2**sideexp,2**sideexp,0.8),
            t2 = time.time()
            writer.writerow([2**sideexp, batch, t2-t1])

            
"""