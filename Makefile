all: $(patsubst %.jl,%.out,$(wildcard *.jl))
%.out: %.jl
	julia $< &> $@
clean:
	-rm *~ *png *.out *pdf
view:
	open *.png

