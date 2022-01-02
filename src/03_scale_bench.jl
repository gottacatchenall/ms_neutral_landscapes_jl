using CSV, DataFrames
using DataFramesMeta
using Plots
using LaTeXStrings
using Unitful: mm

jl = CSV.read("src/benchmarking/juliascaling_means.csv", DataFrame)
r = CSV.read("src/benchmarking/r_scalebench.csv", DataFrame)
py = CSV.read("src/benchmarking/py_scalebench.csv", DataFrame)

rgrp = groupby(r, :sidelength)
rmean = @combine(rgrp, :time = mean(:time_sec))

pygrp = groupby(py, :size)
pymean = @combine(pygrp, :time = mean(:time_seconds))


jl
ugh = [L"2^3", L"2^4", L"2^5", L"2^6", L"2^7", L"2^8", L"2^9", L"2^{10}", L"2^{11}", L"2^{12}"]

ylab = [L"10^{-5}",L"10^{-4}",L"10^{-3}",L"10^{-2}",L"10^{-1}",L"10^{0}", L"10^{1}", L"10^{2}",  ]

plot(jl.side, jl.time_seconds, lw=1.5,lc=:dodgerblue,    label="NeutralLandscapes.jl")
scatter!(jl.side, jl.time_seconds,
    label="",
    fontfamily = "computer modern",
    xlabel="Raster side length",
    ylabel="Execution time (seconds)",
    frame=:box,
    grid=:scientific,
    legend=:outerright,
    tickfontsize=10,
    mc=:white,
    msw=2,
    ms=4,
    ma=0.9,
    msc=:dodgerblue,
    yscale=:log10, 
    xlim=(3,12.1),
    yticks=([10.0^i for i in -5:2], ylab),
    xticks=(3:12,ugh),
    ylim=(10^-5, 10^1),
    dpi=500,
    size=(700, 450))


plot!(log2.(rmean.sidelength), label="NLMR (using C++)", lc=:mediumpurple, rmean.time,lw=1.5, la=0.95)
scatter!(log2.(rmean.sidelength), rmean.time, 
    label="", msw=2, ms=4, mc=:white, msc=:mediumpurple, ma=0.9)


plot!(log2.(pymean.size), pymean.time, label="nlmpy", lc=:green, la=0.95)
scatter!(log2.(pymean.size), pymean.time, ms=4,
    ma=0.95, mc=:white, msw=2, msc=:green,
    label="")

title!("Midpoint displacement benchmark", titlefontsize=12)

savefig("figures/figure3.png")