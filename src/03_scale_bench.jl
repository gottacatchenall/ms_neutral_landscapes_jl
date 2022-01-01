using CSV, DataFrames
using Plots
using LaTeXStrings

jl = CSV.read("src/benchmarking/juliascaling_means.csv", DataFrame)
r = CSV.read("src/benchmarking/r_scalebench.csv", DataFrame)
py = CSV.read("src/benchmarking/py_scalebench.csv", DataFrame)

rmean = 
pymean = 


jl
ugh = [L"2^3", L"2^4", L"2^5", L"2^6", L"2^7", L"2^8", L"2^9", L"2^{10}", L"2^{11}", L"2^{12}"]

scatter(jl.side, jl.time_seconds,
    label="NeutralLandscapes.jl", 
    xlabel="Raster side length",
    ylabel="Execution time (seconds)",
    frame=:box,
    grid=:scientific,
    legend=:outerright,
    yscale=:log10, 
    xlim=(2.5,12.5),
    xticks=(3:12,ugh),
    ylim=(10^-5, 10^2),
    dpi=300)
plot!(jl.side, jl.time_seconds, c=:dodgerblue)

scatter!(log2.(r.sidelength), (r.time_sec), 
    label="NLMR (using C++)", 
    ma=0.1)
scatter!(log2.(py.size), py.time_seconds, 
    ma=0.1,
    label="nlmpy")