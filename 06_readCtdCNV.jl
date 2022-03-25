import Pkg; Pkg.activate("Oceanography")
using Oceanography,Plots

header, metadata, data = readCtdCNV("ctd.cnv")
ctd = Ctd(data.sal00, data.t068, data.pr, metadata["longitude"], metadata["latitude"])
plotProfile(ctd, which="SA")
savefig("06_readCtdCNV_profile_SA.pdf")
plotProfile(ctd, which="CT")
savefig("06_readCtdCNV_profile_CT.pdf")
plotTS(ctd, which="TS")
savefig("06_readCtdCNV_TS.pdf")


