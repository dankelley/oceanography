import Pkg; Pkg.activate("Oceanography")
using Oceanography, Plots, NetCDF
function readArgo(filename)
    getVec(file, name) = Vector{Float64}(ncread(file, name)[:,1])
    lon = ncread(file, "LONGITUDE")[1]
    lat = ncread(file, "LATITUDE")[1]
    T = getVec(file, "TEMP")
    p = getVec(file, "PRES")
    S = getVec(file, "PSAL")
    Ctd(S, T, p, lon, lat)
end
file = "SD6901654_417.nc" # use ncinfo(file) to find names
# ncinfo(file)
ctd = readArgo(file)
plotProfile(ctd, which="SA")
savefig("07_read_argo_SA_profile.pdf")
plotProfile(ctd, which="CT")
savefig("07_read_argo_CT_profile.pdf")
plotTS(ctd)
savefig("07_read_argo_TS.pdf")

