library(oce)
data(ctd)
ctd <- as.data.frame(ctd[["data"]])
write.csv(ctd, "ctd.csv", row.names=FALSE)

