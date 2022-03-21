# Q: why does this work, but fail in the package?
using Plots
abstract type Oce end
struct Ctd <: Oce
    salinity::Vector{Float64}
    temperature::Vector{Float64}
    pressure::Vector{Float64}
end
function RecipesBase.plot(ctd::Ctd, which::String="temperature")
    println("in plot(ctd,which=\"$(which)\")")
    if which == "temperature"
        plot(ctd.temperature, ctd.pressure,
             yaxis=:flip,
             legend=false,
             xmirror=true,
             xlabel="Temperature [°C]",
             ylabel="Pressure [dbar]")
    elseif which == "salinity"
        plot(ctd.salinity, ctd.pressure,
             yaxis=:flip,
             xmirror=true,
             legend=false,
             xlabel="Salinity",
             ylabel="Pressure [dbar]")
    else
        println("unrecognized 'which'")
    end
end

using CSV
using DataFrames
csv = CSV.read("ctd.csv", DataFrame)
ctd = Ctd(csv.salinity, csv.temperature, csv.pressure)
plot(ctd)
savefig("Tprofile.pdf")
plot(ctd, "salinity")
savefig("Sprofile.pdf")


