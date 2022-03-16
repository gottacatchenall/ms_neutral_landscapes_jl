using NeutralLandscapes
using SimpleSDMLayers
using SimpleSDMLayers: boundingbox
using Plots
using Distributions
using LinearAlgebra
using GeoStats
using StatsBase
using Random
using GeoStatsBase
using StatsPlots

ENV["SDMLAYERS_PATH"] = "/home/michael/data/"
ENV["RASTERDATASOURCES_PATH"] = "/home/michael/data/"

# ENV["SDMLAYERS_PATH"] = "/project/def-gonzalez/mcatchen/data/"
# ENV["RASTERDATASOURCES_PATH"] = "/project/def-gonzalez/mcatchen/data"

rawtemp = convert(Float16, SimpleSDMPredictor(CHELSA, BioClim, 1; left=-77, right=-70.0, bottom=44.0, top=49.0))

temp = coarsen(SimpleSDMPredictor(rawtemp.grid[1:600,1:800], boundingbox(rawtemp)...), StatsBase.mean, (8,8))
plot(temp)
temp = broadcast(x->1.0 - (maximum(temp) - x)/(maximum(temp) - minimum(temp)), temp)
xspace,yspace = (temp.right - temp.left) / size(temp)[1], (temp.top -temp.bottom) / size(temp)[2]
covergrid = map(x->isnothing(x) ? 0. : x, temp.grid)
geogrid = georef((cover=convert(Matrix{Float16}, covergrid),), origin=(temp.left,temp.right), spacing=(xspace,yspace))

#coraselc = coarsen(temp, x->nn_combine(countmap(x)), (8,8))
#xspace,yspace = (coarselandcover.right - coarselandcover.left) / size(coarselandcover)[1], (coarselandcover.top - coarselandcover.bottom) / size(coarselandcover)[2]
#geogrid = georef((cover=convert(Matrix{Float16}, coarselandcover.grid),), origin=(coarselandcover.left,coarselandcover.right), spacing=(xspace,yspace))

function propose(θ)    
   # vals = [v for v in shuffle!(collect(values(countmap(coarselandcover.grid))))]
   # pdfs = vals ./sum(vals)
   # cutoffs = vcat([0],[sum(pdfs[1:x]) for x in 1:length(pdfs)],[1])


    mpd = rand(MidpointDisplacement(θ), size(temp))
  #=  for i in eachindex(mpd)
        for j in 1:length(cutoffs)-1
            if mpd[i] > cutoffs[j] && mpd[i] < cutoffs[j+1]
               mpd[i] = j
            end 
        end
    end =#
    return SimpleSDMPredictor(mpd, boundingbox(temp)...) 
end

function ABC(prior)
    true_variogram = EmpiricalVariogram(geogrid, :cover)
   
    numsteps = 100
    ϵ = 0.00001

    hs = zeros(numsteps)
    errors = zeros(numsteps)

    cursor = 1
    count = 1
    while cursor < numsteps
        H = rand(prior)
        proposal = propose(H)
        testgrid = georef((cover=convert(Matrix{Float16}, proposal.grid),), origin=(rawtemp.left,rawtemp.right), spacing=(xspace,yspace))
        test_variogram = EmpiricalVariogram(testgrid, :cover)
        rmse = sum((true_variogram.ordinate .- test_variogram.ordinate).^2)
        count += 1
        if rmse < ϵ
            errors[cursor] = rmse
            hs[cursor] = H
            cursor += 1
            if cursor % 5 == 0 
                @info cursor
                @show "acceptrate = $(cursor/count)" 
            end
        end 
        
    end
    return hs, errors
end

### TODO rescale temp to 0,1 
@time hs, error = ABC(Uniform(0,1))


histogram(hs, bins=0:0.05:1)