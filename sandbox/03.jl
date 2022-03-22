using Plots
struct Ctd
    salinity::Vector{Float64}
    temperature::Vector{Float64}
    pressure::Vector{Float64}
end

function RecipesBase.plot(d::Ctd)
    println("in plot(Dan) ... S=$(d.salinity), p=$(d.pressure)")
    plot(d.temperature, d.pressure)
    #plot([1.0;2.0;3.0], [1.0;9.0;1.0])
end

ctd = Ctd([32.0,33.0], [12.0, 10.0], [0.0, 5.0])
plot(ctd)
savefig("04.pdf")


