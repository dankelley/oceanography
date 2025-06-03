---
output: pdf_document
---

This repository holds some tests that might shed light on the utility and
practicality of creating a Julia package for oceanographic analysis.

# Struct ideas

This might work

```julia
abstract type Oce end
struct Adp<:Oce
    metadata::Dict
    data::Dict
end
a = Adp(Dict(), Dict())
a.metadata["filename"] = "food"
ncell = 10
a.data["u"] = Array{Float64}(undef, 200, ncell, 4);
a.data["distance"] = range(0, 100, length=ncell)
a
```
