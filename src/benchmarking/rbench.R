#install.packages("NLMR")
#install.packages("microbenchmark")

library("NLMR")
library("microbenchmark")

rand = microbenchmark(nlm_random(250,250,1), times=1000)
dg = microbenchmark(nlm_distancegradient(250,250, origin=c(1,1,1,1)), times=1000)
eg = microbenchmark(nlm_edgegradient(250,250), times=1000)
mpd = microbenchmark(nlm_mpd(256, 256), times=1000)
rrc = microbenchmark(nlm_randomrectangularcluster(250,250, minl=10, maxl=150), times=1000)
nne = microbenchmark(nlm_mosaictess(250,250,germs=10),times=1000)
#nnc = microbenchmark(nlm_randomcluster(250,250, p=0.4),times=1000)

df = data.frame(matrix(nrow=1,ncol=3))
colnames(df) = c("model", "replicate", "time_nanoseconds")

makedf = function(df, modeldf, name){
    newdf = data.frame(matrix(nrow=1000,ncol=3))
    colnames(newdf) = c("model", "replicate", "time_nanoseconds")

    newdf$model = rep(name, 1000)
    newdf$replicate = seq(1,1000)
    newdf$time_nanoseconds = modeldf$time
    return(rbind(df, newdf))
}

df = makedf(df, rand, "random")
df = makedf(df, dg, "distance gradient")
df = makedf(df, eg, "edge gradient")
df = makedf(df, mpd, "midpoint displacement")
df = makedf(df, rrc, "rectangle cluster")
df = makedf(df, nne, "nearest neighbor element")

write.csv(df, "rbench_differentmodels.csv")

# scale dep 

sideexp = seq(3,13)

df = data.frame(sidelength=c(0), time_nanoseconds=c(0))
for (s in sideexp){
    bm = microbenchmark(nlm_mpd(2^s, 2^s), times=50)  
    newdf = data.frame(sidelength=2^s, time_nanoseconds=mean(bm$time))
    df = rbind(df, newdf)
}

df$time_sec = df$time_nanoseconds / 10^9
write.csv(df, "r_scalebench.csv")



