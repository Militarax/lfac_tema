Filename = max

all:
	yacc -d $(Filename).y
	lex $(Filename).l
	gcc lex.yy.c y.tab.c -ll -ly -o $(Filename)
	rm lex.yy.c y.tab.h y.tab.c
