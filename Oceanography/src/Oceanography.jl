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
    plotProfile(ctd::Ctd; which::String="temperature", lon=-30.0, lat=30.0,
        seriestype=:path, markerstrokealpha=0.1, markerstrokewidth=0.1, linewidth=1,
        debug::Bool=false)

Plot an oceanographic profile for data contained in `ctd`, showing how the
variable named by `which` depends on pressure.  The variable is drawn on the x
axis and pressure on the y axis. Pressure increases downwards on the page, and
the x axis is drawn at the top.  Allowed values of `which` are `"T"` for
in-situ temperature, `"CT"` for Conservative Temperature, `"S"` for Practical
Salinity, `"SA"` for Absolute Salinity, or `"sigma0"` for density anomaly
referenced to the surface. The `seriestype` and other arguments have the same
meaning as for general julia plots.
"""
function plotProfile(ctd::Ctd; which::String="CT", lon=-30.0, lat=30.0,
        seriestype=:path, markerstrokealpha=0.1, markerstrokewidth=0.1, linewidth=1,
        debug::Bool=false)
    if debug
        println("in plotProfile(ctd,which=\"$(which))")
    end
    S = ctd.salinity
    T = ctd.temperature
    p = ctd.pressure
    if which == "SA" || which == "CT" || which == "sigma0"
        SA = gsw_sa_from_sp.(S, p, lon, lat)
        CT = gsw_ct_from_t.(SA, T, p)
        if which == "sigma0"
            sigma0 = gsw_sigma0.(SA, CT)
        end
    end
    if which == "T" || which == "CT"
        plot(which == "CT" ? CT : T,
             p,
             yaxis=:flip, xmirror=true, legend=false,
             seriestype=seriestype, linewidth=linewidth,
             markerstrokealpha=markerstrokealpha, markerstrokewidth=markerstrokewidth,
             xlabel=which == "CT" ? "Conservative Temperature [°C]" : "Temperature [°C]",
             ylabel="Pressure [dbar]")
    elseif which == "S" || which == "SA"
        plot(which == "SA" ? SA : S,
             p,
             yaxis=:flip, xmirror=true, legend=false,
             seriestype=seriestype, linewidth=linewidth,
             markerstrokealpha=markerstrokealpha, markerstrokewidth=markerstrokewidth,
             xlabel=which == "SA" ? "Absolute Salinity [g/kg]" : "Practical Salinity",
             ylabel="Pressure [dbar]")
    elseif which == "sigma0" # gsw formulation
        plot(sigma0,
             p,
             yaxis=:flip, xmirror=true, legend=false,
             seriestype=seriestype, linewidth=linewidth,
             markerstrokealpha=markerstrokealpha, markerstrokewidth=markerstrokewidth,
             xlabel="Potential Density Anomaly, σ₀ [kg/m³]",
             ylabel="Pressure [dbar]")
    else
        println("unrecognized 'which'")
    end
end

"""
    plotTS(ctd::Ctd, lon=-30.0, lat=30.0,
           seriestype=:path, markerstrokealpha=0.1, markerstrokewidth=0.1, linewidth=1,
           drawFreezing=true)

Plot an oceanographic TS diagram, with the Gibbs Seawater equation of state.
Contours of σ₀ are shown with dotted lines.  If `drawFreezing` is true, then
the freezing-point curve is added, with a dashed blue line type.

"""
function plotTS(ctd::Ctd; lon=-30.0, lat=30.0,
        seriestype=:path, markerstrokealpha=0.1, markerstrokewidth=0.1,
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
