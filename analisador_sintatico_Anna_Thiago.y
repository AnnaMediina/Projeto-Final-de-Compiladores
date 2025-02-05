%{

#include <iostream>
using namespace std;

extern "C"
{
  int yyparse(void);
  int yylex(void);
}

void yyerror(char *);
%}

%start programa
%token ID NUM FIMLIN ERRO
%left ADD SUB
%left MULT DIV

%token IF ELSE INT VOID WHILE RETURN
%token AB_COL FE_COL AB_PRT FE_PRT AB_CV FE_CV PT_VG VG
%token MAIOR MENOR IGUAL
%token MEN_IGL MAI_IGL COMP_IGL DIFF_IGL

%%

programa: declaracao_lista
    ;
declaracao_lista: declaracao_lista declaracao
    |    declaracao
	;
declaracao: var_declaracao
    |    fun_declaracao
	;
var_declaracao: tipo_especificador ID PT_VG
    |   tipo_especificador ID AB_COL NUM FE_COL PT_VG
	;
tipo_especificador: INT
    | VOID
	;
fun_declaracao: tipo_especificador ID AB_PRT params FE_PRT composto_decl
    ;
params: param_lista
    | VOID
	;
param_lista: param_lista VG param
    | param
	;
param: tipo_especificador ID
    | tipo_especificador ID AB_COL FE_COL
	;
composto_decl: AB_CV local_declaracoes statement_lista FE_CV
    ;
local_declaracoes: /*  vazio  */
    | local_declaracoes var_declaracao
	;
statement_lista: /*  vazio  */
    | statement_lista statement
	;
statement: expressao_decl
    | composto_decl
	| selecao_decl
	| iteracao_decl
	| retorno_decl
	;
expressao_decl: expressao PT_VG
    | PT_VG
	;
selecao_decl: IF AB_PRT expressao FE_PRT statement
    | IF AB_PRT expressao FE_PRT statement ELSE statement
	;
iteracao_decl: WHILE AB_PRT expressao FE_PRT statement
    ;
retorno_decl: RETURN PT_VG
    | RETURN expressao
	;
expressao: var IGUAL expressao
    | simples_expressao
	;
var: ID
    | ID AB_COL expressao FE_COL
	;
simples_expressao: soma_expressao relacional soma_expressao
    | soma_expressao
	;
relacional: MAI_IGL
	| MENOR
    | MAIOR
	| MEN_IGL
	| COMP_IGL
	| DIFF_IGL
	;
soma_expressao: soma_expressao soma termo
    | termo
	;
soma: ADD
    | SUB
	;
termo: termo mult fator
    | fator
	;
mult: MULT
    | DIV
	;
fator: AB_PRT expressao FE_PRT
    | var
	| ativacao
	| NUM
	;
ativacao: ID AB_PRT args FE_PRT
    ;
args: /*  vazio  */
    | arg_lista
    ;
arg_lista: arg_lista VG expressao
    | expressao
	;


%%

int main()
{
  cout << "\nParser em execução...\n";
  return yyparse();
}

void yyerror(char * msg)
{
  extern char* yytext;
  cout << msg << ": " << yytext << endl;
}

