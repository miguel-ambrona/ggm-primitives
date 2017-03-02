OCAMLBUILDFLAGS=-cflags "-w +a-e-9-44-48" -use-menhir -menhir "menhir -v" -classic-display -use-ocamlfind -quiet -ocamlc ocamlc -ocamlopt ocamlopt
COREFLAGS=-pkg core_kernel \
    -tag short_paths \
    -cflags -strict-sequence

.PHONY: install tests.native ibe.native

all: ibe.native test

ibe.native:
	ocamlbuild $(COREFLAGS) $(OCAMLBUILDFLAGS) ./ibe.native

test:
	ocamlbuild $(COREFLAGS) $(OCAMLBUILDFLAGS) ./tests.native

OCAMLDEP= ocamlfind ocamldep -package core_kernel \
            -I src one-line

dev:
	ocamlbuild $(COREFLAGS) $(OCAMLBUILDFLAGS) Parser.cmx

%.deps :
	$(OCAMLDEP) src/$(basename $@).ml> .depend
	ocamldot .depend > deps.dot
	dot -Tsvg deps.dot >deps.svg

depgraph :
	$(OCAMLDEP) src/*.ml src/*.mli \
        | grep -v Test | grep -v Extract > .depend
	ocamldot .depend > deps.dot
	dot -Tsvg deps.dot >deps.svg
