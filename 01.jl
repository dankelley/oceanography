# Test of types for oce-like system
abstract type Oce end
struct Ctd <: Oce
    salinity::Matrix{Float64}
    temperature::Matrix{Float64}
    pressure::Matrix{Float64}
end
struct Adp <: Oce
    time::Matrix{Float64}
    velocity::Matrix{Float64}
end
function plot(ctd::Ctd, which::String="temperature")
    println("in plot(ctd), which=$(which)")
end
function plot(ctd::Adp, which::String="u1")
    println("in plot(adp), which=$(which)")
end

ctd = Ctd([34.0 35.0], [9.0 10.0], [0.0 0.0])
adp = Adp([1. 2.], [10. 20.])
plot(ctd)
plot(ctd, "salinity")
plot(adp)


