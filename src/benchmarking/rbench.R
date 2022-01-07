#install.packages("NLMR")
#install.packages("microbenchmark")

library("NLMR")
library("microbenchmark")


makedf = function(df, modeldf, name, s){
    newdf = data.frame(matrix(nrow=1,ncol=4))
    colnames(newdf) = c("model", "sidelength", "meantime", "stdtime")

    newdf$model = c(name)
    newdf$sidelength = c(s)
    newdf$meantime = mean(modeldf$time) / 10^9   # convert from ns
    newdf$stdtime = sd(modeldf$time) / 10^9      # convert from ns 

    return(rbind(df, newdf))
}


makebenchforallmodels = function (sz){

    rectsmall = max(as.integer(0.05*sz[1]), 1)
    rectlarge =  as.integer(0.4*sz[1])

    rand = microbenchmark(nlm_random(sz[1],sz[2],1))
    dg = microbenchmark(nlm_distancegradient(sz[1], sz[2], origin=c(1,1,1,1)))
    eg = microbenchmark(nlm_edgegradient(sz[1],sz[2]))
    mpd = microbenchmark(nlm_mpd(sz[1], sz[2]))
    # rrc = microbenchmark(nlm_randomrectangularcluster(sz[1], sz[2], minl=rectlarge, maxl=rectlarge))
    nne = microbenchmark(nlm_mosaictess(sz[1], sz[2],germs=10))
    #nnc = microbenchmark(nlm_randomcluster(250,250, p=0.4),times=1000)

    df = data.frame(matrix(nrow=1,ncol=4))
    colnames(df) = c("model", "sidelength", "meantime", "stdtime")

    df = makedf(df, rand, "random", sz[1])
    df = makedf(df, dg, "dg", sz[1])
    df = makedf(df, eg, "eg", sz[1])
    df = makedf(df, mpd, "mpd", sz[1])
#  df = makedf(df, rrc, "rectangle cluster",sz[1])
    df = makedf(df, nne, "nne",sz[1])
    return(df)
}



df = data.frame(matrix(nrow=1,ncol=4))
colnames(df) = c("model", "sidelength", "meantime", "stdtime")

sidelen = seq(3,12)
for (i in sidelen){
    df = rbind(df, makebenchforallmodels(c(2^i,2^i)))
}

write.csv(df, "artifacts/r.csv")

sz=c(250,250)
mpd = microbenchmark(nlm_mpd(sz[1], sz[2]))
mpd$time
