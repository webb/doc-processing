
.SECONDARY:

sources = ${wildcard *.dot.m4}
targets = ${sources:%.dot.m4=%.png} 

.PHONY: default open clean

default: ${targets}

tmp/%.dot: %.dot.m4
	mkdir -p tmp
	m4 -P $< > $@

%.png: tmp/%.dot
	dot -Tpng -o$@ $<

open: ${targets}
	open ${targets}

clean:
	rm -f ${targets}
	rm -rf tmp
