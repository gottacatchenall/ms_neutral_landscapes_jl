using NeutralLandscapes
using BenchmarkTools
using Plots
using DataFrames, CSV
using StatsBase
using Statistics

ns = 1000
df = DataFrame(model=[],sidelength=[], meantime=[], stdtime=[])


for s in 3:12
    @show s
    rect = falses(2^s,2^s)
    rect[1:5,1:5] .= true    
    pg = @benchmark rand(PlanarGradient(), siz) samples=ns setup=(siz=(2^$s, 2^$s))
    dg = @benchmark rand(DistanceGradient(findall(vec(r)))) setup=(siz=(2^$s, 2^$s), r=$rect)
    #eg = @benchmark rand(EdgeGradient(), siz)  samples=ns setup=(siz=(2^$s, 2^$s))
    random = @benchmark rand(NoGradient(), siz)  samples=ns setup=(siz=(2^$s, 2^$s))
    mpd = @benchmark rand(MidpointDisplacement(0.75), siz)  samples=ns setup=(siz=(2^$s, 2^$s))
    nne = @benchmark rand(NearestNeighborElement(10), siz) samples=ns setup=(siz=(2^$s, 2^$s))
    perlin = @benchmark rand(PerlinNoise((4,4)), siz) samples=ns setup=(siz=(2^$s, 2^$s))

    models = Dict("pg" => pg, 
    "eg" => eg, 
    "random" => random, 
    "mpd" => mpd, 
    "nne" => nne, 
    "dg" => dg,
    "perlin" => perlin)
    for (k,v) in models
        push!(df.model, k)
        push!(df.sidelength, 2^s)
        push!(df.meantime, mean(v.times) / 10^9) #converts to seconds
        push!(df.stdtime, std(v.times) / 10^9) #converts to seconds
    end
    
end

df

using CSV
CSV.write("artifacts/julia.csv",df)