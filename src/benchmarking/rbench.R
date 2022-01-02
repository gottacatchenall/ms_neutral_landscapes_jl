#install.packages("NLMR")
#install.packages("microbenchmark")

library("NLMR")
library("microbenchmark")

rand = microbenchmark(nlm_random(250,250,1), 1000)

dg = nlm_distancegradient(250,250, origin=c(1,1,1,1))

eg = nlm_edgegradient(250,250)
mpd = microbenchmark(nlm_mpd(256, 256), times=1000)
rrc = nlm_randomrectangularcluster(250,250, minl=10, maxl=150)


#nne = nlm_neigh(250,250, p_neigh=0.1,p_empty=0)
nnc = nlm_randomcluster(250,250, p=0.9)


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



