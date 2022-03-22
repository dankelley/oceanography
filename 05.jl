# Test of plotting
using CSV
using DataFrames
using Plots
using GibbsSeaWater
import Pkg; Pkg.activate("Oceanography")
using Oceanography

csv = CSV.read("ctd.csv", DataFrame)
ctd = Ctd(csv.salinity, csv.temperature, csv.pressure)
S = ctd.salinity
T = ctd.temperature
p = ctd.pressure
lon = -30.0
lat = 30.0
SA = gsw_sa_from_sp.(S, p, lon, lat)
CT = gsw_ct_from_t.(SA, T, p)
plot(SA, p, yaxis=:flip, xmirror=true, legend=false)
savefig("05_SA_profile_by_hand.pdf")

plotProfile(ctd) # defaults to CT
savefig("05_profile_CT.pdf")

plotProfile(ctd; which="S")
savefig("05_profile_S.pdf")

plotProfile(ctd; which="S", seriestype=:scatter)
savefig("05_profile_S_scatter.pdf")

plotProfile(ctd; which="SA")
savefig("05_profile_SA.pdf")

plotProfile(ctd; which="SA", seriestype=:scatter)
savefig("05_profile_SA_scatter.pdf")

plotProfile(ctd; which="sigma0")
savefig("05profile__sigma0.pdf")

plotTS(ctd)
savefig("05_TS.pdf")

