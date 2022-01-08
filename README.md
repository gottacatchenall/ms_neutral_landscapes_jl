# Introduction

Neutral landscapes are increasingly used in ecological and
evolutionary studies to provide a  null expectation spatial variation
of a given measurement. Originally developed to simulate the spatially
autocorrelated data [@Gardner1987NeuMod; @Milne1992SpaAgg], the have
seen use in a wide range of disciplines: from landscape genetics
[@Storfer2007PutLan], to landscape and spatial ecology
[@Tinker2004HisRan; @Remmel2013CatCla], and biogeography
[@Albert2017BarDis].

We present `NeutralLandscapes.jl`, a package in `Julia` for neutral
landscapes.  The two primary packages used to simulate neutral
landscapes are `NLMR` in (the `R` language) [@Sciaini2018NlmLan] and
`NLMpy` [in Python; @Etherington2015NlmPyt].  Here we demonstrate that
`NeutralLandscapes.jl`, depending on the method, is orders of
magnitude faster than previous neutral landscape packages.

As biodiversity science becomes increasingly concerned with temporal
change and its consequences, its clear there is a gap in methodology
in generating neutral landscapes that change over time.  In addition
we present a novel method for generating landscape change with
prescribed  levels of spatial and temporal autocorrelation, which is
implemented in `NeutralLandscapes.jl`


# Software Overview

This software can generate neutral landscapes using several methods,
enables masking and works with other julia packages.

@fig:allmethods shows a replica of Figure 1 from
@Etherington2015NlmPyt, which shows the capacity of the library to
generate different types of neutral landscapes, and then apply masks
and categorical classifcation to them.

![Recreation of the figure in `nlmpy` paper and the source, supplied in less than 40 lines of code.](./figures/figure1.png){#fig:allmethods}


## Interoperability

Ease of use with other julia packages

Mask of neutral variable masked across quebec in 3 lines.

```
using NeutralLandscapes
using SimpleSDMLayers

quebec = SimpleSDMPredictor(WorldClim, BioClim; left=-90., right=-50., top=75., bottom=40.)
qcmask = fill(true, size(quebec))
qcmask[findall(isnothing, quebec.grid)] .= false

pltsettings = (cbar=:none, frame=:box)

plot(
    heatmap(rand(MidpointDisplacement(0.8), size(layer), mask=qcmask); pltsettings),
    heatmap(rand(PlanarGradient(), size(layer), mask=qcmask); pltsettings),
    heatmap(rand(PerlinNoise((4,4)), size(layer), mask=qcmask); pltsettings),
    heatmap(rand(NearestNeighborCluster(0.5), size(layer), mask=qcmask); pltsettings),
    dpi=400
)
```

![todo](./figures/interoperable.png)

# Benchmark comparison to `nlmpy` and `NLMR`

It's fast. As the scale and resolution of raster data increases,
neutral models must be able to scale to match those data dimensions.

![todo](./figures/benchmark.png)

# Generating dynamic neutral landscapes

We implement methods for generating change that are temporally
autocorrelated, spatially-autocorrelated, or both.

$M_t = M_{t-1} + f(M(t-1))$

## Models of change

### Directional

### Temporally autocorrelation

$r$: rate, $v$: variability, $U$ matrix of draws from standard $\text{Normal}(0,1)$.

Here $v$ replects the amount of temporal autocorrelation.



$f_{T}(M_{ij}) = r + vU_{ij}$

Results in an expected value of change of $r$ per timestep with variance $v$.

### Spatial autocorrelation

Generate a matrix $\delta$ with a NL generator.

$r$: rate, $v$: variability, $[Z(\delta)]_{ij}$: the $(i,j)$ entry of the zscore of the $\delta$ matrix

$f_{S}(M_{ij}) = r + v \cdot [Z(\delta)]_{ij}$

### Spatiotemporal autocorrelation

$f_{ST}(M_{ij}) = r + v \cdot [Z(\delta)]_{ij}$

![todo](./figures/temporal.png)


## Rescaling to mimic real data

# Discussion

# References
