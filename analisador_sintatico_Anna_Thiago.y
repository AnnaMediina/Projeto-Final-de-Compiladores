%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

int yyparse(void);
int yylex(void);
void yyerror(const char *);

extern int linha;

struct arvore {
    char nome [30];
    struct arvore **filho;
    int filhos;
} ;

typedef struct arvore nohS;

%}

%union {
    nohS *noh;
}

%token <noh> INT VOID ID NUM IF ELSE WHILE RETURN 
%token <noh> AB_COL FE_COL AB_PRT FE_PRT AB_CV FE_CV PT_VG VG
%token <noh> MAIOR MENOR IGUAL MEN_IGL MAI_IGL COMP_IGL DIFF_IGL ADD SUB MULT DIV

%type <noh> programa declaracao_lista declaracao var_declaracao
%type <noh> tipo_especificador fun_declaracao params param_lista param
%type <noh> composto_decl local_declaracoes statement_lista statement
%type <noh> expressao_decl selecao_decl iteracao_decl retorno_decl
%type <noh> expressao var simples_expressao relacional soma_expressao
%type <noh> termo soma mult fator ativacao args arg_lista

%start programa
%token FIMLIN ERRO
%left ADD SUB
%left MULT DIV
%nonassoc IFX
%nonassoc AB_PRT
%left ELSE

%%

programa: declaracao_lista  
    {$$ = criaNoh("programa");
    $1 = criaNoh("declaracao_lista");
    adicionaFilho($$, $1);}
    ;
declaracao_lista: declaracao_lista declaracao
    {$1 = criaNoh("declaracao_lista");
    $2 = criaNoh("declaracao");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    }
    | declaracao    
    {$1 = criaNoh("declaracao");
    adicionaFilho($$, $1);}
    ;
declaracao: var_declaracao  
    {$1 = criaNoh("var_declaracao");
    adicionaFilho($$, $1);}
    | fun_declaracao    
    {$1 = criaNoh("fun_declaracao");
    adicionaFilho($$, $1);}
    ;
var_declaracao: tipo_especificador ID PT_VG
    {$1 = criaNoh("tipo_especificador");
    $2 = criaNoh("ID");
    $3 = criaNoh(";")
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
    }
    | tipo_especificador ID AB_COL NUM FE_COL PT_VG
    {$1 = criaNoh("tipo_especificador");
    $2 = criaNoh("ID");
    $3 = criaNoh("[");
    $4 = criaNoh("NUM");
    $5 = criaNoh("]");
    $6 = criaNoh(";");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
    adicionaFilho($$, $4);
    adicionaFilho($$, $5);
    adicionaFilho($$, $6);
    }
    ;
tipo_especificador: INT
    {$1 = criaNoh("INT");
    adicionaFilho($$, $1);}
    | VOID
    {$1 = criaNoh("VOID");
    adicionaFilho($$, $1);}
    ;
fun_declaracao: tipo_especificador ID AB_PRT params FE_PRT composto_decl
    {$1 = criaNoh("tipo_especificador");
    $2 = criaNoh("ID");
    $3 = criaNoh("(");
    $4 = criaNoh("params");
    $5 = criaNoh(")");
    $6 = criaNoh("composto_decl");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
    adicionaFilho($$, $4);
    adicionaFilho($$, $5);
    adicionaFilho($$, $6);
    }
    ;
params: param_lista 
    {$1 = criaNoh("params");
    adicionaFilho($$, $1);}
    | VOID
    {$1 = criaNoh("VOID");
    adicionaFilho($$, $1);}
    ;
param_lista: param_lista VG param
    {$1 = criaNoh("param_lista");
    $2 = criaNoh(",");
    $3 = criaNoh("param");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
    }
    | param 
    {$1 = criaNoh("param");
    adicionaFilho($$, $1);}
    ;
param: tipo_especificador ID
    {$1 = criaNoh("tipo_especificador");
    $2 = criaNoh("ID");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    }
    | tipo_especificador ID AB_COL FE_COL
    {$1 = criaNoh("tipo_especificador");
    $2 = criaNoh("ID");
    $3 = criaNoh("[");
    $4 = criaNoh("]");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
    adicionaFilho($$, $4);
    } 
    ;
composto_decl: AB_CV local_declaracoes statement_lista FE_CV
    {$1 = criaNoh("{");
    $2 = criaNoh("local_declaracoes");
    $3 = criaNoh("statement_lista");
    $4 = criaNoh("}");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
    adicionaFilho($$, $4);
    }
    ;
local_declaracoes: /* vazio */  
    | local_declaracoes var_declaracao
    {$1 = criaNoh("local_declaracoes");
    $2 = criaNoh("var_declaracao");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    }
    ;
statement_lista: /* vazio */    
    | statement_lista statement
    {$1 = criaNoh("statement_lista");
    $2 = criaNoh("statement");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    }
    ;
statement: expressao_decl   
    {$$ = criaNoh("expressao_decl");
    adicionaFilho($$, $1);}
    | composto_decl 
    {$$ = criaNoh("composto_decl");
    adicionaFilho($$, $1);}
    | selecao_decl  
    {$$ = criaNoh("selecao_decl");
    adicionaFilho($$, $1);}
    | iteracao_decl 
    {$$ = criaNoh("iteracao_decl");
    adicionaFilho($$, $1);}
    | retorno_decl  
    {$$ = criaNoh("retorno_decl");
    adicionaFilho($$, $1);}
    ;
expressao_decl: expressao PT_VG
    {$1 = criaNoh("expressao");
    $2 = criaNoh(";");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    }
    | PT_VG
    {$1 = criaNoh(";");
    adicionaFilho($$, $1);}
    ;
selecao_decl: IF AB_PRT expressao FE_PRT statement %prec IFX
    {$1 = criaNoh("IF");
    $2 = criaNoh("(");
    $3 = criaNoh("expressao");
    $4 = criaNoh(")");
    $5 = criaNoh("statement");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
    adicionaFilho($$, $4);
    adicionaFilho($$, $5);
    }
    | IF AB_PRT expressao FE_PRT statement ELSE statement
    {$1 = criaNoh("IF");
    $2 = criaNoh("(");
    $3 = criaNoh("expressao");
    $4 = criaNoh(")");
    $5 = criaNoh("statement");
    $6 = criaNoh("ELSE");
    $7 = criaNoh("statement");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
    adicionaFilho($$, $4);
    adicionaFilho($$, $5);
    adicionaFilho($$, $6);
    adicionaFilho($$, $7);
    }
    ;
iteracao_decl: WHILE AB_PRT expressao FE_PRT statement
    {$1 = criaNoh("WHILE");
    $2 = criaNoh("(");
    $3 = criaNoh("expressao");
    $4 = criaNoh(")");
    $5 = criaNoh("statement");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
    adicionaFilho($$, $4);
    adicionaFilho($$, $5);
    }
    ;
retorno_decl: RETURN PT_VG
    {$1 = criaNoh("RETURN");
    $2 = criaNoh(";")
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    }
    | RETURN expressao PT_VG
    {$1 = criaNoh("RETURN");
    $2 = criaNoh("expressao");
    $3 = criaNoh(";")
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
    }
    ;
expressao: var IGUAL expressao
    {$1 = criaNoh("var");
    $2 = criaNoh("=");
    $3 = criaNoh("expressao")
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
    }
    | simples_expressao 
    {$1 = criaNoh("simples_expressao");
    adicionaFilho($$, $1);}
    ;
var: ID
    {$1 = criaNoh("ID");
    adicionaFilho($$, $1);}
    | ID AB_COL expressao FE_COL
    {$1 = criaNoh("ID");
    $2 = criaNoh("[");
    $3 = criaNoh("expressao");
    $4 = criaNoh("]");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
    adicionaFilho($$, $4);
    }
    ;
simples_expressao: soma_expressao relacional soma_expressao
    {$1 = criaNoh("soma_expressao");
    $2 = criaNoh("relacional");
    $3 = criaNoh("soma_expressao");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);}
    | soma_expressao    
    {$1 = criaNoh("soma_expressao");
    adicionaFilho($$, $1);}
    ;
relacional: MAI_IGL
    {$$ = criaNoh("relacional");
    adicionaFilho($$, $1);}
    | MENOR
    {$$ = criaNoh("relacional");
    adicionaFilho($$, $1);}
    | MAIOR
    {$$ = criaNoh("relacional");
    adicionaFilho($$, $1);}
    | MEN_IGL
    {$$ = criaNoh("relacional");
    adicionaFilho($$, $1);}
    | COMP_IGL
    {$$ = criaNoh("relacional");
    adicionaFilho($$, $1);}
    | DIFF_IGL
    {$$ = criaNoh("relacional");
    adicionaFilho($$, $1);}
    ;
soma_expressao: soma_expressao soma termo
    {adicionaFilho($1, $2);
    adicionaFilho($1, $3);
    $$ = $1;}
    | termo 
    {$$ = criaNoh("soma_expressao");
    adicionaFilho($$, $1);}
    ;
soma: ADD
    {$$ = criaNoh("soma");
    adicionaFilho($$, $1);}
    | SUB
    {$$ = criaNoh("soma");
    adicionaFilho($$, $1);}
    ;
termo: termo mult fator
    {adicionaFilho($1, $2);
    adicionaFilho($1, $3);
    $$ = $1;}
    | fator 
    {$$ = criaNoh("termo");
    adicionaFilho($$, $1);}
    ;
mult: MULT
    {$$ = criaNoh("mult");
    adicionaFilho($$, $1);}
    | DIV
    {$$ = criaNoh("mult");
    adicionaFilho($$, $1);}
    ;
fator: AB_PRT expressao FE_PRT
    {$$ = criaNoh("fator");
    // adicionaFilho($$, "(");
    adicionaFilho($$, $2);
    // adicionaFilho($$, ")");
    }
    | var
    {$$ = criaNoh("fator");
    adicionaFilho($$, $1);} 
    | ativacao  
    {$$ = criaNoh("fator");
    adicionaFilho($$, $1);}
    | NUM
    {$$ = criaNoh("fator");
    adicionaFilho($$, "NUM");}
    ;
ativacao: ID AB_PRT args FE_PRT
    {$$ = criaNoh("ativacao");
    adicionaFilho($$, $1);
    // adicionaFilho($$, "(");
    adicionaFilho($$, $3);
    // adicionaFilho($$, ")");
    }
    ;
args: /* vazio */
    {$$ = NULL;}
    | arg_lista
    {$$ = criaNoh("args");
    adicionaFilho($$, $1);}
    ;
arg_lista: arg_lista VG expressao
    {adicionaFilho($1, $3);
    $$ = $1;}
    | expressao 
    {$$ = criaNoh("arg_lista");
    adicionaFilho($$, $1);}
    ;

%%

nohS* criaNoh(char *nome) {
    nohS *novo = malloc(sizeof(nohS));
    strcpy(novo->nome, nome);
    novo->filho = NULL;
    novo->filhos = 0;
    return novo;
}

void adicionaFilho(nohS *pai, nohS *filho) {
    if (pai->filho == NULL){
        pai->filho = malloc(sizeof(nohS*));
        pai->filho[0] = filho;
        pai->filhos = 1;
    }
    else {
        pai->filhos += 1; 
        pai->filho = (nohS**) realloc(pai->filho, pai->filhos*sizeof(nohS));
        pai->filho[pai->filhos - 1] = filho;
    }
    return;
}

void printNoh (nohS *pai, int deep, int *ultimo) {
    int i;
    int *ant = malloc((deep + 1)*sizeof(int));
    for (i = 0; i < deep; i ++) {
        if (ultimo[i] == 1) printf(" |  ");
        else if (ultimo[i] == 2){
            printf(" \\  ");
            ultimo[i] = 0;    
        }
        else printf("    ");
        ant[i] = ultimo[i];
    }
    ant[deep] = 1;
    printf("%s\n", pai->nome);
    for (i = 0; i < pai->filhos - 1; i ++) {
        printNoh(pai->filho[i], deep + 1, ant);
    }
    ant[deep] = 2;
    if (pai->filhos) printNoh(pai->filho[i], deep + 1, ant);
    free(ant);
}

void liberaArvore(nohS *pai) {
    int i;
    for (i = 0; i < pai->filhos; i++){
        liberaArvore(pai->filho[i]);
    }
    free(pai->filho);
    free(pai);
}

void yyerror(const char * msg)
{
  extern char* yytext;
  printf("ERRO SINTÁTICO: %s LINHA: %d\n", yytext, linha);
}

int main()
{
  printf("Início análise sintática");
  int resultado = yyparse();

  if(resultado == 0){
    printf("Análise sintática feita com sucesso!\n");
    printNoh(programa, 0, NULL);
  }
}
