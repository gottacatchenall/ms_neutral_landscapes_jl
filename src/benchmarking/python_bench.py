from nlmpy import nlmpy
import time
import numpy

methods = dict(
    random = lambda s: nlmpy.random(s,s), 
    pg = lambda s: nlmpy.planarGradient(s,s), 
    dg = lambda s: nlmpy.distanceGradient(nlmpy.planarGradient(s,s)), 
    eg = lambda s: nlmpy.edgeGradient(s,s),
    #ws = lambda: nlmpy.waveSurface(250,250, 4), 
    mpd = lambda s: nlmpy.mpd(s,s,0.8), 
    perlin = lambda s: nlmpy.perlinNoise(s,s, (2,2)),
    nne = lambda s: nlmpy.randomElementNN(s,s,10), 
    #rcnn = lambda: nlmpy.randomClusterNN(250,250, 0.4),  
)

nbatches = 1000
import csv
sidelengths = range(3, 11)



with open('artifacts/py.csv', 'w') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["model", "size", "meantime", "stdtime"])

    for s in sidelengths:
        print(2**s)
        for key in methods: 
            sum = 0.0
            vals = numpy.zeros(nbatches)
            for batch in range(0,nbatches):
                t1 = time.time()
                r = methods[key](2**s)
                t2 = time.time()

                vals[batch] = t2-t1
            mn = numpy.mean(vals)
            sdev = numpy.std(vals)
            writer.writerow([key, s, mn, sdev])

            
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