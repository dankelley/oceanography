import Pkg; Pkg.activate("Oceanography")
using DataFrames,Oceanography,Plots

# # Development notes
# name 0 = scan: scan number
# name 1 = timeS: time [s]
# name 2 = pr: pressure [db]
# name 3 = depS: depth, salt water [m]
# name 4 = t068: temperature, IPTS-68 [deg C]
# name 5 = sal00: salinity, PSS-78 [PSU]
# name 6 = flag:  0.000e+00

"""
header, metadata, data = readCtdCnv(filename)

Read a CTD file named `filename` that is in SeaBird CNV format. This returns
`header` (a vector of strings, one per line from the start down to a line
containing `#END`), `metadata` (a Dict with some items scanned from the header)
and `data` (a `dataFrame` holding the data). Note that the column names in
`data` are taken from the CNV file, so the user will need to have some
familiarity with the SeaBird conventions; for example, notice how a temperature
is converted from the T68 scale to the T90 scale, which is required by other
oceanographic software, especially the `gsw` package.

**FIXME:** parse the header, first with just column names but eventually
(perhaps ... but this is *very* labourious, as we know from R/oce) with
translated names, units, etc.

# Examples
```julia-repl
header, metadata, data = readCtdCnv("ctd.cnv")
ctd = Ctd(data.sal00,
    T90fromT68.(data.t068),
    data.pr,
    metadata["longitude"],
    metadata["latitude"])
plotProfile(ctd, which="SA")
savefig("readcnv_profile_SA.pdf")
plotProfile(ctd, which="CT")
savefig("readcnv_profile_CT.pdf")
plotTS(ctd, which="TS")
savefig("readcnv_TS.pdf")
```
"""
function readCtdCnv(filename::String, debug::Bool=false)
    open(filename) do file
        return readCtdCnv(file, debug)
    end
end
function readCtdCnv(stream::IOStream, debug::Bool=false)
    lines = readlines(stream)
    header = ""
    dataStart = 0
    dataNames = Vector{String}()
    metadata = Dict{String,Any}()
    for i = 1:length(lines)
        line = chomp(lines[i])
        if occursin(r"^# name ", line)
            tokens = split(line)
            name = replace(tokens[5], ":" => "")
            push!(dataNames, name)
        end
        if occursin(r"^\*\*.*:", line)
            tokens = split(line, ":")
            item = lowercase(replace(tokens[1], "** " => ""))
            value = replace(tokens[2], r"^ *" => "")
            if occursin(r"^longitude", item) || occursin(r"^latitude", item)
                value = coordinateFromString(value)
            end
            metadata[item] = value
        end
        if occursin(r"^\*END\*$", line)
            dataStart = i + 1
            header = lines[1:i]
            break
        end
    end
    if dataStart == 0
        error("This file has no *END* line, so columns cannot be identified")
    end
    if length(dataNames) == 0
        error("No '# name' lines in header, so columns cannot be identifed")
    end
    ncols = length(split(lines[dataStart]))
    if ncols != length(dataNames)
        error("ncols=$(ncols) does not match length(dataNames)=$(length(dataNames))")
    end
    nrows = length(lines) - dataStart + 1
    if debug
        println("will try to read nrows=$(nrows), ncols=$(ncols)")
    end
    data = Array{Float64,2}(undef, nrows, ncols)
    irow = 1
    for i in dataStart:length(lines)
        if debug
            println("reading row $(i)")
        end
        d = parse.(Float64, split(lines[i]))
        data[irow,:] = d
        irow = irow + 1
    end
    data = DataFrame(data, dataNames)
    if debug
        println("NOTE: not yet renaming data or parsing units")
    end
    return header, metadata, data
end

header, metadata, data = readCtdCnv("ctd.cnv")
ctd = Ctd(data.sal00, data.t068, data.pr, metadata["longitude"], metadata["latitude"])
plotProfile(ctd, which="SA")
savefig("readcnv_profile_SA.pdf")
plotProfile(ctd, which="CT")
savefig("readcnv_profile_CT.pdf")
plotTS(ctd, which="TS")
savefig("readcnv_TS.pdf")


