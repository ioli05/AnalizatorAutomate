build:
	flex main.l
	gcc lex.yy.c -lfl
run:
	./a.out < ex1.in
	./a.out < ex2.in