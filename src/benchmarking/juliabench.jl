using NeutralLandscapes
using BenchmarkTools
using Plots
using DataFrames
ns = 1000
siz = 250, 250


ng = @benchmark rand(NoGradient(), siz) samples=ns
pg = @benchmark rand(PlanarGradient(), siz) samples=ns
eg = @benchmark rand(EdgeGradient(), siz)  samples=ns

mpd = @benchmark rand(MidpointDisplacement(0.75), siz)  samples=ns
nne = @benchmark rand(NearestNeighborElement(200), siz)  samples=ns
nnc = @benchmark rand(NearestNeighborCluster(0.4), siz)  samples=ns

mpd
heatmap(rand(NearestNeighborCluster(0.4), siz))

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