# Demo plot problem.
using CSV, DataFrames, Plots
import Pkg; Pkg.activate("Oceanography")
using Oceanography

csv = CSV.read("ctd.csv", DataFrame)
ctd = Ctd(csv.salinity, csv.temperature, csv.pressure)
S = ctd.salinity
T = ctd.temperature
p = ctd.pressure
p1 = plot(S, p, yaxis=:flip, xmirror=true, legend=false)
p2 = plotProfile(ctd; which="S")
plot(p1, p2)
savefig("04_plot_problem.png")
