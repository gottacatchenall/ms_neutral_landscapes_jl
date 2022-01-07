using DataFrames, CSV, DataFramesMeta
using Plots
using LaTeXStrings
using Plots.PlotMeasures

jl = CSV.read("src/benchmarking/artifacts/julia.csv", DataFrame)
r = CSV.read("src/benchmarking/artifacts/r.csv", DataFrame) 
r = filter(x-> "NA" ∉ x, r)
r.sidelength = parse.(Float32, r.sidelength)
r.meantime = parse.(Float32, r.meantime)

py = CSV.read("src/benchmarking/artifacts/py.csv", DataFrame) 

jlsets = (label="", mc=:dodgerblue)
rsets = (label="", mc=:mediumpurple)
pysets = (label="", mc=:green)


function makeplt(jl, r, py, name, titlestr)

    jldf, rdf, pydf = map(df->filter(x->x.model==name,df), [jl,r,py])

    juliacolor = :dodgerblue
    pycolor = :forestgreen
    rcolor = :mediumpurple

    markersettings = (ms=5,msw=2,ma=0.9)
    linesettings = (ls=1.5)
    ugh = [L"2^3", L"2^4", L"2^5", L"2^6", L"2^7", L"2^8", L"2^9", L"2^{10}", L"2^{11}", L"2^{12}"]
ylab = [L"10^{-5}",L"10^{-4}",L"10^{-3}",L"10^{-2}",L"10^{-1}",L"10^{0}", L"10^{1}", L"10^{2}",  ]

    plot(log2.(jldf.sidelength), jldf.meantime; linesettings)
    title!(titlestr)
    scatter!(log2.(jldf.sidelength), jldf.meantime,
        label="",
        fontfamily = "computer modern",
        xlabel="Raster side length",
        ylabel="Execution time (seconds)",
        frame=:box,
        legend=:none,
        tickfontsize=10,
        mc=juliacolor,
        msc=juliacolor,
        yscale=:log10, 
        ylim=(10^-5, 10^2),
        xlim=(3,12.1),
        yticks=([10.0^i for i in -5:2], ylab),
        xticks=(3:12,ugh),
        dpi=500,
        size=(300, 300); markersettings...)

    plot!(log2.(rdf.sidelength), rdf.meantime, lc=rcolor; linesettings)
    scatter!(log2.(rdf.sidelength), rdf.meantime, msc=rcolor; markersettings)
    
    plot!(pydf.size, pydf.meantime, lc=pycolor; linesettings)
    scatter!(pydf.size, pydf.meantime, msc=pycolor; markersettings) 
end


legendplot = scatter(frame=:none, msc=:forestgreen, axis=:none, xlim=(0,1), ylim=(0,1),[-1,-1], size=(500,500), dpi=300, ms=2, mc=:forestgreen, label="NLMpy")
scatter!(legendplot, [-1,-1], ms=2, msc=:mediumpurple, mc=:mediumpurple, label="NLMR")
scatter!(legendplot,[-1,-1], ms=2, msc=:dodgerblue, mc=:dodgerblue, label="NeutralLandscapes.jl")

l = @layout [ a{0.05w} grid(2,3) ]

plt =plot(
    legendplot, 
    makeplt(jl, r, py, "random", "Random"),
    makeplt(jl, r, py, "dg", "Distance Gradient"),
    makeplt(jl, r, py, "eg", "Edge Gradient"),
    makeplt(jl, r, py, "perlin", "Perlin Noise"),
    makeplt(jl, r, py, "mpd", "Midpoint Displacement"),
    makeplt(jl, r, py, "nne", "Nearest Neighbor Element"),
    size=(1400, 700),
    margin=10mm,
    layout=l)


savefig(plt, "benchmark.png", )
