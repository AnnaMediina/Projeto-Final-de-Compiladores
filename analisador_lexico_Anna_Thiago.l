%{
#include <stdio.h>
#include <stdlib.h>

//"/*"([^*]|\*+[^*/])*"*"+"/"   { return COMENTARIO; }
//"//"[^\n]*	{ return COMENTARIO; }
//yylval = atoi(yytext)
// Declaração das funções e variáveis globais
int linha = 1;



%}


%%
"int"         { return INT; }
"void"        { return VOID; }
"if"          { return IF; }
"else"        { return ELSE; }
"return"      { return RETURN; }
"while"       { return WHILE; }

[0-9]+        { return NUM; }
[A-Za-z]+     { return ID; }

"+"           { return ADD; }
"-"           { return SUB; }
"*"           { return MULT; }
"/"           { return DIV; }
">"           { return MAIOR; }
"<"           { return MENOR; }
"<="          { return MEN_IGL; }
">="          { return MAI_IGL; }
"=="          { return COMP_IGL; }
"!="          { return DIFF_IGL; }

"["           { return AB_COL; }
"]"           { return FE_COL; }
"="           { return IGUAL; }
"("           { return AB_PRT; }
")"           { return FE_PRT; }
"{"           { return AB_CV; }
"}"           { return FE_CV; }
";"           { return PT_VG; }
","           { return VG; }

"\n"		  { ++linha; return FIMLIN; }

" "			  { }
"\t"		  { }
[\r]+         { /* Ignorar */ }
.             { printf("\nERRO LÉXICO: %s, LINHA: %d\n", yytext, linha+1); return ERRO; }

%%

int obter_token(){
    return yylex();
}

int main(int argc, char **argv){
    // Inicia o analisador léxico
    yylex();
    return 0;
}
