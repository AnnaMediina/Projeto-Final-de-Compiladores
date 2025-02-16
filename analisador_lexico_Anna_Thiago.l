%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "analisador_sintatico_Anna_Thiago.tab.h"

#define TAM 211

// Declaração das funções e variáveis globais


typedef struct lista_linhas{
    int linha_v;
    struct lista_linhas *prox;
} Tlinhas;

typedef Tlinhas *Plinhas;

typedef struct tabela{
    char *nome;
    char *tipo;
    int tipo_dado;
    char *escopo;
    Plinhas linhas;
    struct tabela *prox;
} Ttabela;

typedef  Ttabela *Ptabela;

Ptabela *tab_hash = NULL;


int hash(char* k){
    int temp = 0;
    int i = 0;
    while (k[i] != '\0'){
        temp = ((temp << 4) + k[i]) % TAM;
        ++i;
    }
    return temp;
}

void f_insere(char *nome, int tipo_dado, char *tipo, char *escopo, int linha_v){
    int h = hash(nome);

    Ptabela ts = (Ptabela)malloc(sizeof(Ttabela));
    ts->nome = strdup(nome);
    ts->tipo_dado = tipo_dado;
    ts->tipo = strdup(tipo);
    ts->escopo = strdup(escopo);

    ts->linhas = (Plinhas)malloc(sizeof(Tlinhas));
    ts->linhas->linha_v = linha_v;
    ts->linhas->prox = NULL;

    ts->prox = tab_hash[h];
    tab_hash[h] = ts; 
}

void insere(char *nome, char *escopo, int linha_v){
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


struct sup {
    char* escopo;
    struct sup *prev;
};
typedef struct sup esc;

int linha = 1;
int tipoB = 0;
int tipoT = 0;
int par = 0;
int open = 0;
int open_qnt = 0;
char *nome;
esc global = {
    .escopo = "global",
    .prev = NULL,
};
esc *atual = &global;

void id(char *id) {
    if (!busca_id(id, atual->escopo)) {
        if (atual->prev != NULL){
            if (!busca_id(id, atual->prev->escopo)) {
                nome = malloc(sizeof(char)*strlen(id));
                strcpy(nome, id);
                par = 1;    
            }
            else {
                insere(id, atual->prev->escopo, linha);
            }
        }
        else {
            nome = malloc(sizeof(char)*strlen(id));
            strcpy(nome, id);
            par = 1;
        }
    }
    else {
        insere(id, atual->escopo, linha);
    }
}

void abprt() {
    if (par) {
        if (tipoT) { // Para variar tipo de variavel ou funcao
            f_insere(nome, tipoT, "funcao", atual->escopo, linha);
        }
        else {
            f_insere(nome, tipoT, "funcao", atual->escopo, linha);
        }
        esc *new_escopo = malloc(sizeof(esc));
        new_escopo->escopo = malloc(sizeof(char)*strlen(nome));
        strcpy(new_escopo->escopo, nome);
        new_escopo->prev = atual;
        atual = new_escopo;
        par = 0;
        tipoB = 0;
        open = 1;
    }
}

void ptvg() {
    if (par) {
        if (tipoT) { // Para variar tipo de variavel ou funcao
            f_insere(nome, tipoT, "variavel", atual->escopo, linha);
        }
        else {
            f_insere(nome, tipoT, "variavel", atual->escopo, linha);
        }
        par = 0;
        tipoB = 0;
    }
}

void abcv() {
    if (open) {
        open_qnt++;
    }
}

void fecv() {
    if (open) {
        open_qnt --;
        if (open_qnt <= 0) {
            open = 0;
            esc *antigo = atual;
            atual = antigo->prev;
            free(antigo->escopo);
            free(antigo);
        }
    }
}


%}


%%
"int"         { tipoT = 1; return INT; }
"void"        { tipoT = 0; return VOID; }
"if"          { return IF; }
"else"        { return ELSE; }
"return"      { return RETURN; }
"while"       { return WHILE; }

[0-9]+        { return NUM; }
[A-Za-z]+     { id(yytext); return ID; }

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
"("           { abprt(); return AB_PRT; }
")"           { ptvg(); return FE_PRT; }
"{"           { abcv(); return AB_CV; }
"}"           { fecv(); return FE_CV; }
";"           { ptvg(); return PT_VG; }
","           { ptvg(); return VG; }

"\n"		  { ++linha; }

" "			  { }
"\t"		  { }
[\r]+         { /* Ignorar */ }
.             { printf("\nERRO LÉXICO: %s LINHA: %d\n", yytext, linha); return ERRO; }

%%
