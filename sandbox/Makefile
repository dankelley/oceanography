all: 01jl.out 02R.out 02jl.out 03jl.out 04_plot_problem.out
01jl.out: 01.jl
	julia $< > $@
02R.out: 02.R
	Rscript $< > $@
02jl.out: 02.jl
	julia $< > $@
03jl.out: 03.jl
	julia $< > $@
04_plot_problem.out: 04_plot_problem.jl
	julia $< > $@

