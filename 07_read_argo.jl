import Pkg; Pkg.activate("Oceanography")
using Oceanography, Plots, NetCDF
# Make 32-bit matrix into a 64-bit vector.
function getVec(file, name)
    Vector{Float64}(ncread(file, name)[:,1])
end
file = "SD6901654_417.nc" # use ncinfo(file) to find names
lon = ncread(file, "LONGITUDE")[1]
lat = ncread(file, "LATITUDE")[1]
T = getVec(file, "TEMP")
p = getVec(file, "PRES")
S = getVec(file, "PSAL")
ctd = Ctd(S, T, p, lon, lat)
plotProfile(ctd, which="T")
savefig("07_read_argo_T_profile.pdf")

