using DataFrames, CSV, DataFramesMeta
using Plots


jl = CSV.read("src/benchmarking/juliabench_differentmodels.csv", DataFrame)
r = CSV.read("src/benchmarking/rbench_differentmodels.csv", DataFrame)
py = CSV.read("src/benchmarking/pybench_differentmodels.csv", DataFrame)

r.time = r.time_nanoseconds ./ 10^9
jl.time = jl.time_nanoseconds ./ 10^9
py.time = py.mean_execution_time


jlsets = (label="", mc=:dodgerblue, ma=0.01)
rsets = (label="", mc=:mediumpurple, ma=0.01)
pysets = (label="", mc=:green, ma=0.01)

plot(xlim=(0,7), dpi=300, size=(600,300), frame=:box, legend=:outerright, yscale=:log10, xrotation=-90, ylim=(10^-3.5, 0.1), xticks=(0:7, ["", "random", "edge gradient", "planar grad", "NNE", "NNC","Perlin Noise"]))

jl_random = filter(r->r.model=="random", jl) |> DataFrame
py_random = filter(r->r.method=="random", py) |> DataFrame
r_random = filter(r->r.model=="random", r) |> DataFrame
scatter!(
    [1 for i in 1:length(jl_random.time)] .- 0.2rand(1000), 
    jl_random.time_nanoseconds ./ 10^9,
    ;jlsets...)

scatter!(
    [1 for i in 1:length(r_random.time)] .- 0.1.-0.2rand(1000),  
    r_random.time_nanoseconds ./ 10^9,
    ; rsets...)

scatter!(
    [1 for i in 1:length(jl_random.time_nanoseconds)] .+ 0.2rand(1000), 
    py_random.time,
    ; pysets...)

jl_eg = filter(r->r.model=="edge gradient", jl) |> DataFrame
py_eg = filter(r->r.method=="eg", py) |> DataFrame
r_eg = filter(r->r.model=="edge gradient", r) |> DataFrame
scatter!(
    [2 for i in 1:length(jl_random.time_nanoseconds)] .+ 0.2rand(1000), 
    jl_eg.time ,
    ; jlsets...)
scatter!(
    [2 for i in 1:length(r_random.time_nanoseconds)].+ 0.2rand(1000) .- 0.1, 
    r_eg.time,
    ; rsets...)
scatter!(
    [2 for i in 1:length(jl_random.time_nanoseconds)] .- 0.2rand(1000) .+ 0.1, 
    py_eg.time,
    ; pysets...)


jl_pg = filter(r->r.model=="planar gradient", jl) |> DataFrame
py_pg = filter(r->r.method=="pg", py) |> DataFrame
#r_pg = filter(r->r.model=="midpoint displacement", r) |> DataFrame
scatter!(
    [3 for i in 1:length(jl_pg.time)] .+ 0.2rand(length(jl_pg.time_nanoseconds)), 
    jl_pg.time,
    ; jlsets...)
scatter!(
    [3 for i in 1:length(py_pg.time)] .- 0.2rand(1000) .+ 0.1, 
    py_pg.time,
    ; pysets...)




jl_nne = filter(r->r.model=="nearest neighbor element", jl) |> DataFrame
py_nne = filter(r->r.method=="renn", py) |> DataFrame
r_nne = filter(r->r.model=="nearest neighbor element", r) |> DataFrame
scatter!(
    [4 for i in 1:length(jl_mpd.time)] .+ 0.2rand(length(jl_mpd.time_nanoseconds)), 
    jl_nne.time,
    ; jlsets...)
scatter!(
    [4 for i in 1:length(py_mpd.time)].+ 0.2rand(1000) .- 0.1, 
    py_nne.time,
    ; pysets...)
scatter!(
    [4 for i in 1:length(r_mpd.time)] .- 0.2rand(1000) .+ 0.1, 
    r_nne.time,
    ; rsets...)



jl_nnc = filter(r->r.model=="nearest neighbor cluster", jl) |> DataFrame
py_nnc = filter(r->r.method=="rcnn", py) |> DataFrame
scatter!(
    [5. for i in 1:length(jl_nnc.time)],
    jl_nnc.time,
    ; jlsets...)
scatter!(
    [5 for i in 1:length(py_nnc.time)].+ 0.2rand(1000), 
    py_nnc.time,
    ; pysets...)


jl_perlin = filter(r->r.model=="perlin", jl) |> DataFrame
py_perlin = filter(r->r.method=="perlin", py) |> DataFrame
scatter!(
    [6 for i in 1:length(jl_perlin.time)] .- 0.2rand(length(jl_perlin.time_nanoseconds)), 
    jl_nne.time,
    ; jlsets...)
scatter!(
    [6 for i in 1:length(py_perlin.time)].+ 0.2rand(1000), 
    py_perlin.time,
    ; rsets...)




scatter!([1], [100], mc=:dodgerblue, label="Julia")
scatter!([1], [100], mc=:mediumpurple, label="R")
scatter!([1], [100], mc=:green, label="Python")
