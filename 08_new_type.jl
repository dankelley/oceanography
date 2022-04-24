# object idea

abstract type Oce end

struct Adp<:Oce
    metadata::Dict
    data::Dict
end
function Adp()
    Adp(Dict(), Dict())
end
adp = Adp() # could also use Adp(Dict(), Dict())
adp.metadata["filename"] = "some_file.pd0"
adp.data["u"] = Array{Float64}(undef, 4, 3, 5);
println("filename: $(adp.metadata["filename"])")
println("u: $(adp.data["u"])")

#struct Ctd<:Oce
#    metadata::Dict # usually contains longitude, latitude, filename, ...
#    data::Dict # usually contains salinity, temperature, pressure, ...
#end
#Ctd() = Ctd(Dict(), Dict())
#"""
#    Plot a profile
#"""
#function plotProfile(ctd::Ctd; which::String="CT", legend=false, debug::Bool=false, lwargs...)
#    println("in plotProfile")
#end

ctd = Ctd() # could also use Ctd(Dict(), Dict())
ctd.metadata["filename"] = "some_file.cnv"
ctd.data["pressure"] = range(0.0, 20.0, length=10)
ctd.data["temperature"] = range(10.0, 5.0, length=10)
ctd.data["salinity"] = range(30.0, 35.0, length=10)
println("filename: $(ctd.metadata["filename"])")
println("pressure: $(ctd.data["pressure"])")
println("data: $(ctd.data)")
plotProfile(ctd)

ctd.metadata["filename"] = "NEWsome_file.cnv"
println("after mods, filename: $(ctd.metadata["filename"])")
