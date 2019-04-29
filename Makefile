COMPILER_BUILD = lex.yy.c y.tab.c symtab.c semantic.c
COMPILER_DEPENDS = $(COMPILER_BUILD) defs.h
COMPILER_CLEAN = lex.yy.c y.tab.c y.tab.h y.output a.out *.?~

LEX_SRC = scanner.l
YACC_SRC = parser.y

.PHONY: clean
.PHONY: test

a.out: $(COMPILER_DEPENDS)
	gcc -o $@ $(COMPILER_BUILD)

lex.yy.c: $(LEX_SRC) y.tab.c
	lex -I $<

y.tab.c: $(YACC_SRC)
	bison -dy -v $<

clean:
	rm -f $(COMPILER_CLEAN)

