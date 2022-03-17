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
tempplt = plot(temp, cbar=:none, frame=:box, xlabel="Longitude", ylabel="Longitude")
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

# difference is proposal score - current score
acceptprobability(difference, α) = 1.0/(1.0+exp(-α*difference))

function ABC(prior, α=1000)
    true_variogram = EmpiricalVariogram(geogrid, :cover)
   
    numsteps = 1000

    Hchain = zeros(numsteps)
    currentscore = zeros(numsteps)

    currentscore[begin] = 1.0
    for s in 2:numsteps
        H = rand(prior)
        proposal = propose(H)
        testgrid = georef((cover=convert(Matrix{Float16}, proposal.grid),), origin=(rawtemp.left,rawtemp.right), spacing=(xspace,yspace))
        test_variogram = EmpiricalVariogram(testgrid, :cover)
        
        proposal_rmse = sum((true_variogram.ordinate .- test_variogram.ordinate).^2)
        current_rmse = currentscore[s-1]
        
        p = acceptprobability(current_rmse-proposal_rmse, α)
        if rand() < p
            currentscore[s] = proposal_rmse
            Hchain[s] = H
        else  
            currentscore[s] = currentscore[s-1]
            Hchain[s] = Hchain[s-1]
        end 
        if s % 100 == 0 
            @info s
        end     
    end
    return Hchain, currentscore
end

### TODO rescale temp to 0,1 
@time hs, error = ABC(Uniform(0,1), 10^5.5)


burnin = 100
histogram(hs[burnin:end], bins=0:0.025:1, frame=:box, label="", xlim=(0,1), xlabel="H", ylabel="Posterior Frequency", size=(500,500), dpi=250, c=:mediumpurple4, fa=0.5)




using Plots, CSV, DataFrames

df = CSV.read("./src/posterior_H.csv", DataFrame)

histplt =histogram(df.posterior_H, legend=:topleft, label="Posterior", bins=0:0.01:1, normalize=:probability, fc=:steelblue4, fa=0.5, frame=:box, size=(500,500), dpi=300, xlim=(0,1))
hline!([0.01], label="Prior", lw=2, c=:forestgreen)

xlabel!("H")
ylabel!("Probability")


using UnitfulPlots
plot(tempplt, histplt, size=(700, 300), margin=3UnitfulPlots.mm)
savefig("posterior.png")