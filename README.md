This repository holds some tests that might shed light on the utility and
practicality of creating a Julia package for oceanographic analysis.

# Struct ideas

The basic problem (by analogy with oce) is that we don't have a "list" elment
in Julia.  (Or can a dict store big things?)

R-like: but what should 'data' be?  I guess another struct but we want to be
able to add new things.  A DataFrame lets us add but things are only columns,
so e.g. what about adcp?

struct ctd<:Oce
    metadata
        originalNames # a dict
    data # DataFrame OK for ctd but what about e.g. adcp?
end


ADCP: easy if we know from start what it will contain. But we DO NOT know that;


struct adp<:Oce
    metadata
        originalNames # a dict
        time
        distance::Vector{Float64}
    u = Array{Float64}(undef, 4, 20, 100);
    b # ...
    q # ...
end

