using NeutralLandscapes
using SimpleSDMLayers
using Plots
ENV["RASTERDATASOURCES_PATH"] = "/home/michael/data/"


quebec = SimpleSDMPredictor(WorldClim, BioClim; left=-150., right=-50., top=75., bottom=45.)
qcmask = fill(true, size(quebec)) 
qcmask[findall(isnothing, quebec.grid)] .= false

pltsettings = (cbar=:none, frame=:box)

plot(
    heatmap(rand(MidpointDisplacement(0.8), size(quebec), mask=qcmask); pltsettings),
    heatmap(rand(PlanarGradient(), size(quebec), mask=qcmask); pltsettings),
    heatmap(rand(PerlinNoise((4,4)), size(quebec), mask=qcmask); pltsettings),
    heatmap(rand(NearestNeighborCluster(0.5), size(quebec), mask=qcmask); pltsettings),
    dpi=400
)

savefig("interoperable.png")



heatmap(rand(MidpointDisplacement(0.8), size(quebec), mask=qcmask); frame=:none, c=:cork, axis=:none, colorbar=:none, pltsettings)
savefig("etc.png")

heatmap(rand(PerlinNoise((6,6)), size(quebec), mask=qcmask); frame=:none, axis=:none, colorbar=:none, pltsettings)
savefig("access.png")

heatmap(rand(MidpointDisplacement(0.2), size(quebec), mask=qcmask); frame=:none, axis=:none, colorbar=:none, c=:viridis)
savefig("climvelocity.png")

heatmap(rand(MidpointDisplacement(0.3), size(quebec), mask=qcmask); frame=:none, axis=:none, colorbar=:none, pltsettings)


heatmap(rand(NearestNeighborCluster(0.005), size(quebec), mask=qcmask); frame=:none, axis=:none, c=:summer, colorbar=:none)
savefig("lc.png")