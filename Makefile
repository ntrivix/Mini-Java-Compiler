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
	yacc -d -v $<

clean:
	rm -f $(COMPILER_CLEAN)

# testiranje kompajlera
# u petlji će se na ulaz proslediti svi test*.c fajlovi
# ako u fajlu postoji linija sa tekstom //OPIS:, ispisace se na ekranu
test: a.out
	@for test in test*.c; do \
	echo "\n\n---------------------------------------\nTesting: $$test"; \
	grep "//OPIS:" $$test; \
	./a.out < $$test; \
	done
