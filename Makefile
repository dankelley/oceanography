all: $(patsubst %.jl,%.out,$(wildcard *.jl))
%.out: %.jl
	/Applications/Julia-1.10.app/Contents/Resources/julia/bin/julia $< &> $@
clean:
	-rm *~ *png *.out *pdf
view:
	open *.png

