all:
	bison -d analisador_sintatico_Anna_Thiago.y
	flex analisador_lexico_Anna_Thiago.l
	gcc -c lex.yy.c
	gcc -o analisador lex.yy.o analisador_sintatico_Anna_Thiago.tab.c -lfl

run:
	./analisador < ./sort.txt

clean:
	@echo "Limpando arquivos gerados..."
	rm -f analisador lex.yy.c lex.yy.o analisador_sintatico_Anna_Thiago.tab.c analisador_sintatico_Anna_Thiago.tab.h
	@echo "Limpeza concluída!"
