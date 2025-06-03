# %%
abstract type Oce end
struct Adp <: Oce
    metadata::Dict
    data::Dict
end
a = Adp(Dict(), Dict())
a.metadata["filename"] = "README.jl"
ntime = 2
ncell = 3
nbeam = 4
a.metadata["ntime"] = ntime
a.metadata["nbeam"] = nbeam
a.metadata["ncell"] = ncell
#a.data["u"] = Array{Float64}(undef, ntime, ncell, nbeam)
#a.data["u"] = Array{Float64}(missing, ntime, ncell, nbeam)
a.data["u"] = zeros(ntime, ncell, nbeam)
a.data["distance"] = range(0, 100, length=ncell)
a.metadata
# %%
for i in 1:ntime
    for j in 1:ncell
        for k in 1:nbeam
            println(i)
            a.data["u"][i, j, k] = round(i + j / 10 + k / 100.0, digits=3)
        end
    end
end
println(a.data["u"])
