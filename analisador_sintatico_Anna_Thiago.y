%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TAM 211

int yyparse(void);
int yylex(void);
void yyerror(const char *);

extern int linha;

typedef struct lista_linhas{
    int linha_v;
    struct lista_linhas *prox;
} Tlinhas;

typedef Tlinhas *Plinhas;

typedef struct tabela{
    char *nome;
    char tipo;
    char *escopo;
    Plinhas linhas;
    struct tabela *prox;
} Ttabela;

typedef  Ttabela *Ptabela;

static Ptabela *tab_hash = NULL;

struct arvore{
    char nome [30];
    struct arvore **filho;
    int filhos;
};

typedef struct arvore nohS;

nohS *raiz = NULL; // Defina a raiz global da árvore

nohS* criaNoh(char *nome);

void adicionaFilho(nohS *pai, nohS *filho);

%}

%union {
    struct arvore *noh;
}

%token <noh> IF ELSE INT VOID WHILE RETURN ID NUM
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

programa: declaracao_lista {
    $$ = $1; // Arvore sintática será a de declaracao_lista
    raiz = $$;
};
declaracao_lista: declaracao_lista declaracao {
    $$ = $1; 
    adicionaFilho($$, $2); 
}
| declaracao {
    $$ = $1; // Arvore sintática será a declaracao
};
declaracao: var_declaracao {
    $$ = $1; // Arvore sintática será a var_declaracao
}
| fun_declaracao {
    $$ = $1; // Arvore sintática será a fun_declaracao
};
var_declaracao: tipo_especificador ID PT_VG {
    $$ = criaNoh("var_declaracao");
    adicionaFilho($$, $1);
    $2 = criaNoh("ID");
    adicionaFilho($$, $2);
}
| tipo_especificador ID AB_COL NUM FE_COL PT_VG {
    $$ = criaNoh("var_declaracao");
    adicionaFilho($$, $1);
    $2 = criaNoh("ID");
    adicionaFilho($$, $2);
    $4 = criaNoh("NUM");
    adicionaFilho($$, $4);
};
tipo_especificador: INT {
    $$ = criaNoh("INT");
}
| VOID {
    $$ = criaNoh("VOID");
};
fun_declaracao: tipo_especificador ID AB_PRT params FE_PRT composto_decl {
    $$ = criaNoh("fun_declaracao");
    adicionaFilho($$, $1);
    $2 = criaNoh("ID");
    adicionaFilho($$, $2);
    adicionaFilho($$, $4);
    adicionaFilho($$, $6);
};
params: param_lista {
    $$ = $1; // A arvore dos parametros
}
| VOID {
    $$ = criaNoh("VOID");
};
param_lista: param_lista VG param {
    $$ = $1;
    adicionaFilho($$, $3);
}
| param {
    $$ = $1;
};
param: tipo_especificador ID {
    $$ = criaNoh("param");
    adicionaFilho($$, $1);
    $2 = criaNoh("ID");
    adicionaFilho($$, $2);
}
| tipo_especificador ID AB_COL FE_COL {
    $$ = criaNoh("param_array");
    adicionaFilho($$, $1);
    $2 = criaNoh("ID");
    adicionaFilho($$, $2);
};

composto_decl: AB_CV local_declaracoes statement_lista FE_CV {
    $$ = criaNoh("composto_decl");
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
};

local_declaracoes: /* vazio */ {
    $$ = criaNoh("local_declaracoes");
}
| local_declaracoes var_declaracao {
    $$ = $1; // A árvore da lista local_declaracoes é preservada
    adicionaFilho($$, $2);
};

statement_lista: /* vazio */ {
    $$ = criaNoh("statement_lista");
}
| statement_lista statement {
    $$ = $1; // A árvore da lista de statements é preservada
    adicionaFilho($$, $2);
};

statement: expressao_decl {
    $$ = $1; // A árvore sintática da expressão
}
| composto_decl {
    $$ = $1; // A árvore do bloco de declarações
}
| selecao_decl {
    $$ = $1; // A árvore do if
}
| iteracao_decl {
    $$ = $1; // A árvore do while
}
| retorno_decl {
    $$ = $1; // A árvore do return
};

expressao_decl: expressao PT_VG {
    $$ = criaNoh("expressao_decl");
    adicionaFilho($$, $1);
}
| PT_VG {
    $$ = criaNoh("expressao_decl_vazia");
};

selecao_decl: IF AB_PRT expressao FE_PRT statement %prec IFX {
    $$ = criaNoh("selecao_decl");
    adicionaFilho($$, $3);
    adicionaFilho($$, $5);
}
| IF AB_PRT expressao FE_PRT statement ELSE statement {
    $$ = criaNoh("selecao_decl_com_else");
    adicionaFilho($$, $3);
    adicionaFilho($$, $5);
    adicionaFilho($$, $7);
};

iteracao_decl: WHILE AB_PRT expressao FE_PRT statement {
    $$ = criaNoh("iteracao_decl");
    adicionaFilho($$, $3);
    adicionaFilho($$, $5);
};

retorno_decl: RETURN PT_VG {
    $$ = criaNoh("retorno_decl");
}
| RETURN expressao PT_VG {
    $$ = criaNoh("retorno_decl_com_expressao");
    adicionaFilho($$, $2);
};

expressao: var IGUAL expressao {
    $$ = criaNoh("expressao_atribuicao");
    adicionaFilho($$, $1);
    adicionaFilho($$, $3);
}
| simples_expressao {
    $$ = $1; // A árvore da simples_expressao
};

var: ID {
    $$ = criaNoh("ID");
    //adicionaFilho($$, $1);
}
| ID AB_COL expressao FE_COL {
    $$ = criaNoh("var_array");
    $1 = criaNoh("ID");
    adicionaFilho($$, $1);
    adicionaFilho($$, $3);
};

simples_expressao: soma_expressao relacional soma_expressao {
    $$ = criaNoh("simples_expressao_relacional");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
}
| soma_expressao {
    $$ = $1; // A árvore da soma_expressao
};

relacional: MAI_IGL {
    $$ = criaNoh(">=");
}
| MENOR {
    $$ = criaNoh("<");
}
| MAIOR {
    $$ = criaNoh(">");
}
| MEN_IGL {
    $$ = criaNoh("<=");
}
| COMP_IGL {
    $$ = criaNoh("==");
}
| DIFF_IGL {
    $$ = criaNoh("!=");
};

soma_expressao: soma_expressao soma termo {
    $$ = criaNoh("soma_expressao");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3);
}
| termo {
    $$ = $1; // A árvore do termo
};

soma: ADD {
    $$ = criaNoh("+");
}
| SUB {
    $$ = criaNoh("-");
};

termo: termo mult fator {
    $$ = criaNoh("termo");
    adicionaFilho($$, $1);
    adicionaFilho($$, $2);
    adicionaFilho($$, $3); 
}
| fator {
    $$ = $1; // A árvore do fator
};

mult: MULT {
    $$ = criaNoh("*");
}
| DIV {
    $$ = criaNoh("/");
};

fator: AB_PRT expressao FE_PRT {
    $$ = criaNoh("fator_parenteses");
    adicionaFilho($$, $2);
}
| var {
    $$ = $1; // A árvore da variável
}
| ativacao {
    $$ = $1; // A árvore da ativação
}
| NUM {
    $$ = criaNoh("NUM");
    //adicionaFilho($$, $1);
};

ativacao: ID AB_PRT args FE_PRT {
    $$ = criaNoh("ativacao");
    $1 = criaNoh("ID");
    adicionaFilho($$, $1);
    adicionaFilho($$, $3);
};

args: /* vazio */ {
    $$ = criaNoh("args");
}
| arg_lista {
    $$ = $1; // Lista de argumentos
};

arg_lista: arg_lista VG expressao {
    $$ = $1;
    adicionaFilho($$, $3);
}
| expressao {
    $$ = $1; // Um único argumento
};


%%

nohS* criaNoh(char *nome) {
    nohS *novo = malloc(sizeof(nohS));
    strcpy(novo->nome, nome);
    novo->filho = NULL;
    novo->filhos = 0;
    return novo;
}

void adicionaFilho(nohS *pai, nohS *filho) {
    if (filho == NULL) return;
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
    //printf("nome: ");
    //fflush(stdout);
    printf("%s\n", pai->nome);
    for (i = 0; i < pai->filhos - 1; i ++) {
        // printf("%d for", deep);
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

void inicializa_tabela(){
    int i;

    tab_hash = (Ptabela*)malloc(TAM * sizeof(Ptabela));
    for(i = 0; i < TAM; i++) {
        tab_hash[i] = NULL;
    }
}

int hash(char* k){
    int temp = 0;
    int i = 0;
    while (k[i] != '\0'){
        temp = ((temp << 4) + k[i]) % TAM;
        ++i;
    }
    return temp;
}

void f_insere(char *nome, int tipo, char *escopo, int linha_v){
    int h = hash(nome);

    Ptabela ts = (Ptabela)malloc(sizeof(Ttabela));
    ts->nome = strdup(nome);
    ts->tipo = tipo;
    ts->escopo = strdup(escopo);

    ts->linhas = (Plinhas)malloc(sizeof(Tlinhas));
    ts->linhas->linha_v = linha_v;
    ts->linhas->prox = NULL;

    ts->prox = tab_hash[h];
    tab_hash[h] = ts; 
}

void insere(char *nome, int linha_v, char *escopo){
    int h = hash(nome);
    Ptabela ts = tab_hash[h];
    Plinhas l, noval;

    while(ts != NULL){
        if(strcmp(nome, ts->nome) == 0 && strcmp(escopo, ts->escopo) == 0){
            l = ts->linhas;

            while(l->prox != NULL) l = l->prox;

            noval = (Plinhas)malloc(sizeof(Tlinhas));
            noval->linha_v = linha_v;
            noval->prox = NULL;
            l->prox = noval;
            return;
        }
        ts = ts->prox;
    }
}

int busca_id(char *nome, char*escopo){
    int h = hash(nome);
    Ptabela ts = tab_hash[h];

    while(ts != NULL){
        if(strcmp(nome, ts->nome) == 0 && strcmp(escopo, ts->escopo) == 0){
            return 1;
        }
        ts = ts->prox;
    }
    return 0;
}

void print(){
    int i;
    Plinhas l;
    Ptabela ts;

    printf("Tabela de símbolos:");
    printf("   Nome     Tipo     Escopo     Linhas   \n");
    printf("-----------------------------------------\n");

    for(i = 0; i < TAM; ++i){
        if (tab_hash[i] != NULL){
            ts = tab_hash[i];
            while(ts != NULL){
                printf("%-10s", ts->nome);
                printf("%-8d", ts->tipo);
                printf("%-10s ", ts->escopo);
                
                l = ts->linhas;
                while(l != NULL){
                    printf("%d ", l->linha_v);
                    l = l->prox;
                }
                printf("\n");
                ts = ts->prox;
            }
        }
    }
}

void libera_tabela(){
    Ptabela atual, temp;
    Plinhas l, temp_l;
    int i;

    if (tab_hash == NULL) return;
    
    for(i = 0; i < TAM; i++){
        atual = tab_hash[i];
        while(atual != NULL){
            temp = atual;
            atual = atual->prox;
            
    
            l = temp->linhas;
            while(l != NULL){
                temp_l = l;
                l = l->prox;
                free(temp_l);
            }
            
            free(temp->nome);
            free(temp->escopo);
            free(temp);
        }
    }
    free(tab_hash);
    tab_hash = NULL;
}

void yyerror(const char * msg)
{
  extern char* yytext;
  printf("ERRO SINTÁTICO: %s LINHA: %d\n", yytext, linha);
}

int main()
{
  printf("Início análise sintática\n");
  int resultado = yyparse();

  if(resultado == 0){
    printf("Análise sintática feita com sucesso!\n");
    if (raiz != NULL) {
      printNoh(raiz, 0, NULL);
      liberaArvore(raiz);
    }
  }
}
