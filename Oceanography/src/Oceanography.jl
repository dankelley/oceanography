module Oceanography

using DataFrames
using GibbsSeaWater
using Plots
using CSV

# Structs
export Oce
export Ctd

# Functions
export coordinateFromString
export plotProfile
export plotTS
export T90fromT48
export T90fromT68

abstract type
    Oce
end

struct Ctd <: Oce
    salinity::Vector{Float64}
    temperature::Vector{Float64}
    pressure::Vector{Float64}
    longitude::Float64
    latitude::Float64
end

"""
    degree = coordinateFromString(s::String)

Try to extract a longitude or latitude from a string. If there are two
(space-separated) tokens in the string, the first is taken as the decimal
degrees, and the second as decimal minutes. The goal is to parse hand-entered
strings, which might contain letters like `"W"` and `"S"` (or the same
in lower case) to indicate the hemisphere. Humans are quite good at writing
confusing strings, so this function is not always helpful.

# Examples
```julia-repl
coordinateFromString("1.5")   # 1.5
coordinateFromString("1 30")  # 1.5
coordinateFromString("1S 30") # -1.5
```
"""
function coordinateFromString(s::String)
    sign = occursin(r"[wWsS]", s) ? -1.0 : 1.0
    s = replace(s, r"[nNsSeEwW]" => "")
    tokens = split(s)
    if length(tokens) == 1
        return sign * parse(Float64, s)
    elseif length(tokens) == 2
        return sign * (parse(Float64, tokens[1]) + parse(Float64, tokens[2]) / 60.0)
    else
        error("malformed coordinate string $(s)")
    end
end


# Convenience function, defaulting to a mid-Atlantic location.
function Ctd(salinity::Vector{Float64},
        temperature::Vector{Float64},
        pressure::Vector{Float64})
    Ctd(salinity, temperature, pressure, -30.0, 30.0)
end

"""
    plotProfile(ctd::Ctd; which::String="CT", legend=false, debug::Bool=false, kwargs...)

Plot an oceanographic profile for data contained in `ctd`, showing how the
variable named by `which` depends on pressure.  The variable is drawn on the x
axis and pressure on the y axis. Pressure increases downwards on the page, and
the x axis is drawn at the top.  Allowed values of `which` are `"T"` for
in-situ temperature, `"CT"` for Conservative Temperature, `"S"` for Practical
Salinity, `"SA"` for Absolute Salinity, or `"sigma0"` for density anomaly
referenced to the surface. The `seriestype` and other arguments have the same
meaning as for general julia plots, e.g. using `seriestype=:path` joins the
data points, and `seriestype=:scatter` shows a symbol at each point.

The `kwargs...` argument is used to represent other arguments that will be sent
to `plot()`.  For example, the default way to display the profile diagram is
constructed with a blue line connecting points, but using e.g.

    plotProfile(ctd, seriestype=:scatter, seriescolor=:red)

will use red-filled circles, instead; see https://docs.juliaplots.org/stable/ for
more on such issues.

See also [`plotTS`](@ref).
"""
function plotProfile(ctd::Ctd; which::String="CT", legend=false, debug::Bool=false, kwargs...)
    if debug
        println("in plotProfile(ctd,which=\"$(which)\")")
    end
    S = ctd.salinity
    T = ctd.temperature
    p = ctd.pressure
    if which == "SA" || which == "CT" || which == "sigma0"
        SA = gsw_sa_from_sp.(S, p, ctd.longitude, ctd.latitude)
        CT = gsw_ct_from_t.(SA, T, p)
        if which == "sigma0"
            sigma0 = gsw_sigma0.(SA, CT)
        end
    end
    if which == "T" || which == "CT"
        plot(which == "CT" ? CT : T,
             p,
             yaxis=:flip, xmirror=true, legend=false,
             xlabel=which == "CT" ? "Conservative Temperature [°C]" : "Temperature [°C]",
             ylabel="Pressure [dbar]";
             kwargs...)
    elseif which == "S" || which == "SA"
        plot(which == "SA" ? SA : S,
             p,
             yaxis=:flip, xmirror=true, legend=false,
             xlabel=which == "SA" ? "Absolute Salinity [g/kg]" : "Practical Salinity",
             ylabel="Pressure [dbar]";
             kwargs...)
    elseif which == "sigma0" # gsw formulation
        plot(sigma0,
             p,
             yaxis=:flip, xmirror=true, legend=false,
             xlabel="Potential Density Anomaly, σ₀ [kg/m³]",
             ylabel="Pressure [dbar]",
             kwargs...)
    else
        println("Unrecognized 'which'='$(which). Try 'T', 'CT', 'S', 'SA' or 'sigma0'.")
    end
end

"""
    plotTS(ctd::Ctd; drawFreezing=true, legend=false, debug::Bool=false, kwargs...,)

Plot an oceanographic TS diagram, with the Gibbs Seawater equation of state.
Contours of σ₀ are shown with dotted lines.  If `drawFreezing` is true, then
the freezing-point curve is added, with a dashed blue line type.

The `kwargs...` argument is used to represent other arguments that will be sent
to `plot()`.  For example, the default way to display the TS diagram is
constructed with a blue line connecting TS values, but using e.g.

    plotTS(ctd, seriestype=:scatter, seriescolor=:red)

will use red-filled circles, instead; see https://docs.juliaplots.org/stable/ for
more on such issues.

See also [`plotProfile`](@ref).
"""
function plotTS(ctd::Ctd; drawFreezing=true, legend=false, debug::Bool=false, kwargs...)
    if debug
        println("in plotTS(ctd)")
    end
    S = ctd.salinity
    T = ctd.temperature
    p = ctd.pressure
    SA = gsw_sa_from_sp.(S, p, ctd.longitude, ctd.latitude)
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
    # Data
    plot(SA, CT, legend=legend,
         xlim=xlim, ylim=ylim,
         xlabel="Absolute Salinity [g/kg]",
         ylabel="Conservative Temperature [°C]";
         kwargs...)
    # Density contours on 300x300 grid
    SAc = range(xlim[1], xlim[2], length=300)
    CTc = range(ylim[1], ylim[2], length=300)
    contour!(SAc, CTc, (SAc,CTc)->gsw_sigma0(SAc,CTc),
             linestyle=:dot, color=:black)
    # Finally add freezing curve, if requested
    if drawFreezing
        plot!(SAf, CTf, color=:blue, linewidth=1, linestyle=:dash)
    end
end

"""
    T90 = T90fromT68(T68::Float64)

Convert a temperature from the T68 scale to the T90 scale.

See also [`T90fromT48`](@ref).
"""
T90fromT68(T48::Float64) = T48 / 1.00024
T90fromT68(T48::Vector{Float64}) = T48 ./ 1.00024

"""
    T90 = T90fromT48(T48::Float64)

Convert a temperature from the T48 scale to the T90 scale.

See also [`T90fromT68`](@ref).
"""
T90fromT48(T48::Float64) = (T48-4.4e-6*T48*(100.0-T48))/1.00024
T90fromT48(T48::Vector{Float64}) = (T48.-4.4e-6.*T48.*(100.0.-T48))./1.00024


end # module Oceanography
