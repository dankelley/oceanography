module Oceanography

using GibbsSeaWater
using Plots
using CSV
#import RecipesBase

export Oce
export Ctd
export plotProfile
export plotTS

#export RecipesBase.plot
#export plot

abstract type
    Oce
end

struct Ctd <: Oce
    salinity::Vector{Float64}
    temperature::Vector{Float64}
    pressure::Vector{Float64}
end

"""
    plotProfile(ctd::Ctd; which::String="temperature")


Plot a CTD profile of a specified water property.
"""
function plotProfile(ctd::Ctd; which::String="temperature")
    println("in plotProfile(ctd,which=\"$(which)\")")
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
    elseif which == "sigma0"
        lon = -30.0 # FIXME
        lat = 30.0 # FIXME
        S = ctd.salinity
        T = ctd.temperature
        p = ctd.pressure
        SA = gsw_sa_from_sp.(S, p, lon, lat)
        CT = gsw_ct_from_t.(SA, T, p)
        sigma0 = gsw_sigma0.(SA, CT)
        plot(sigma0, ctd.pressure,
             yaxis=:flip,
             xmirror=true,
             legend=false,
             xlabel="Potential Density Anomaly, σ₀ [kg/m³]",
             ylabel="Pressure [dbar]")
    else
        println("unrecognized 'which'")
    end
end

"""
    plotTS(ctd::Ctd, lon=-30.0, lat=30.0,
           seriestype=:scatter, markerstrokealpha=0.1, markerstrokewidth=0.1,
           linewidth=1,
           drawFreezing=true)

Plot an oceanographic TS diagram, with the Gibbs Seawater equation of state.
Contours of σ₀ are shown with dotted lines.  If `drawFreezing` is true, then
the freezing-point curve is added, with a dashed blue line type.

"""
function plotTS(ctd::Ctd; lon=-30.0, lat=30.0,
        seriestype=:scatter, markerstrokealpha=0.1, markerstrokewidth=0.1,
        linewidth=1,
        legend=false,
        drawFreezing=true)
    println("in plotTS(ctd)")
    S = ctd.salinity
    T = ctd.temperature
    p = ctd.pressure
    SA = gsw_sa_from_sp.(S, p, lon, lat)
    CT = gsw_ct_from_t.(SA, T, p)
    xlim = [minimum(SA) maximum(SA)]
    ylim = [minimum(CT) maximum(CT)]
    # Must alter ylim if drawing a freezing-point curve
    if drawFreezing
        pf = 0.0
        SAf = range(xlim[1], xlim[2], length=100)
        saturation_fraction = 0.0
        CTf = gsw_ct_freezing.(SAf, pf, saturation_fraction)
        ylim[1] = minimum([minimum(CTf) minimum(CT)])
    end
    plot(SA, CT, legend=legend,
         seriestype=seriestype,
         markerstrokealpha=markerstrokealpha, markerstrokewidth=markerstrokewidth,
         linewidth=linewidth,
         xlim=xlim, ylim=ylim,
         xlabel="Absolute Salinity [g/kg]",
         ylabel="Conservative Temperature [°C]")
    # Density contours
    SAc = range(xlim[1], xlim[2], length=300)
    CTc = range(ylim[1], ylim[2], length=300)
    contour!(SAc, CTc, (SAc,CTc)->gsw_sigma0(SAc,CTc),
             linewidth=linewidth, linestyle=:dot, color=:black)
    # Finally add freezing curve, if requested
    if drawFreezing
        plot!(SAf, CTf, color=:blue, linewidth=linewidth, linestyle=:dash)
    end
end

end # module Oceanography
