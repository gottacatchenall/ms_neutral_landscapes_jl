using NeutralLandscapes
using BenchmarkTools
using Plots
using DataFrames, CSV
using StatsBase
using Statistics

ns = 250
df = DataFrame(model=[],sidelength=[], meantime=[], stdtime=[])


for s in 3:12
    @show s
    rect = falses(2^s,2^s)
    rect[1:5,1:5] .= true    
    pg = @benchmark rand(PlanarGradient(), 2^$s, 2^$s) samples=ns 
    dg = @benchmark rand(DistanceGradient(findall(vec(r))), 2^$s, 2^$s) samples=ns setup=(r=$rect)
    eg = @benchmark rand(EdgeGradient(), 2^$s, 2^$s)  samples=ns 
    random = @benchmark rand(NoGradient(), 2^$s, 2^$s)  samples=ns 
    mpd = @benchmark rand(MidpointDisplacement(0.75), 2^$s, 2^$s)  samples=ns 
    nne = @benchmark rand(NearestNeighborElement(10), 2^$s, 2^$s) samples=ns 
    perlin = @benchmark rand(PerlinNoise((4,4)), 2^$s, 2^$s) samples=ns 

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