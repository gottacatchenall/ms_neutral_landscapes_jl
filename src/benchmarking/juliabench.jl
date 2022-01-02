using NeutralLandscapes
using BenchmarkTools
using Plots
using DataFrames, CSV
ns = 1000
siz = 250, 250


pg = @benchmark rand(PlanarGradient(), siz) samples=ns
eg = @benchmark rand(EdgeGradient(), siz)  samples=ns
random = @benchmark rand(NoGradient(), siz)  samples=ns
mpd = @benchmark rand(MidpointDisplacement(0.75), siz)  samples=ns
nne = @benchmark rand(NearestNeighborElement(10), siz)  samples=ns
nnc = @benchmark rand(NearestNeighborCluster(0.4), siz)  samples=ns
rect = @benchmark rand(RectangularCluster(10,150), siz) samples=ns
perlin = @benchmark rand(PerlinNoise((4,4)), siz) samples=ns



pg, eg, random, mpd, nne, rect

pgdf = DataFrame(model=["planar gradient" for i in 1:length(pg.times)], time_nanoseconds=pg.times)
egdf = DataFrame(model=["edge gradient" for i in 1:length(eg.times)], time_nanoseconds=eg.times)
randomdf = DataFrame(model=["random" for i in 1:length(random.times)], time_nanoseconds=random.times)
mpddf = DataFrame(model=["midpoint displacement" for i in 1:length(mpd.times)], time_nanoseconds=mpd.times)
nnedf = DataFrame(model=["nearest neighbor element" for i in 1:length(nne.times)], time_nanoseconds=nne.times)
nncdf = DataFrame(model=["nearest neighbor cluster" for i in 1:length(nnc.times)], time_nanoseconds=nnc.times)
perlindf = DataFrame(model=["perlin" for i in 1:length(perlin.times)], time_nanoseconds=perlin.times)

df = [pgdf;egdf;randomdf;mpddf;nnedf;nncdf;perlindf]

CSV.write("juliabench_differentmodels.csv", df)










function scalebench()
    df = DataFrame(side=[], meantime_ns=[])
    for s in collect(3:13)
        thistime = @benchmark rand(MidpointDisplacement(0.8), 2^s, 2^s) setup=(s=$s) 
        newdf = DataFrame(side=[s], meantime_ns=[mean(thistime.times)])
        df = [df;newdf]
    end
    df
end

df = scalebench()

df.time_seconds = df.meantime_ns ./ 10^9

using CSV
CSV.write("juliascaling.csv",df)