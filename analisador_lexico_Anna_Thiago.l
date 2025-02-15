%{
#include <stdio.h>
#include <stdlib.h>
#include "analisador_sintatico_Anna_Thiago.tab.h"

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

"\n"		  { ++linha; }

" "			  { }
"\t"		  { }
[\r]+         { /* Ignorar */ }
.             { printf("\nERRO LÉXICO: %s LINHA: %d\n", yytext, linha); return ERRO; }

%%
