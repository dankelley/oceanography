all: 01jl.out 02R.out 02jl.out
01jl.out: 01.jl
	julia $< > $@
02R.out: 02.R
	Rscript $< > $@
02jl.out: 02.jl
	julia $< > $@

