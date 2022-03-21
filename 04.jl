# Test of plotting
using CSV
using DataFrames
using Plots
import Pkg; Pkg.activate("Oceanography")
using Oceanography
csv = CSV.read("ctd.csv", DataFrame)
ctd = Ctd(csv.salinity, csv.temperature, csv.pressure)
plotProfile(ctd)
savefig("04_Tprofile.pdf")
plotProfile(ctd; which="salinity")
savefig("04_Sprofile.pdf")
plotProfile(ctd; which="sigma0")
savefig("04_sigma0.pdf")
plotTS(ctd)
savefig("04_TS.pdf")



