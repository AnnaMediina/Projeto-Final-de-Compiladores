%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "analisador_sintatico_Anna_Thiago.tab.h"

#define TAM 211
#define INTEIRO 1
#define VO_ID 0
#define NONE -1

// Declaração das funções e variáveis globais


typedef struct lista_linhas{
    int linha_v;
    struct lista_linhas *prox;
} Tlinhas;

typedef Tlinhas *Plinhas;

typedef struct tabela{
    char *nome;
    int tipo_dado; //int ou void
    char *tipo; //func ou variav
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
int tipoT = NONE;
int par = 0;
int open = 0;
int open_qnt = 0;
char *nome;
esc global = {
    .escopo = "global",
    .prev = NULL,
};
esc *atual = &global;

int id(char *id) {
    if (!busca_id(id, atual->escopo)) {
        if (atual->prev != NULL){
            if (!busca_id(id, atual->prev->escopo)) {
                nome = malloc(sizeof(char)*strlen(id));
                strcpy(nome, id);
                if (tipoT == NONE) {
                    printf("\nERRO Semantico: %s LINHA: %d\n", yytext, linha);
                    return ERRO;
                }
                par = 1;
            }
            else {
                if (tipoT == INTEIRO || tipoT == VO_ID) {
                    printf("\nERRO Semantico: %s LINHA: %d\n", yytext, linha);
                    return ERRO;
                }
                insere(id, atual->prev->escopo, linha);
            }
        }
        else {
            nome = malloc(sizeof(char)*strlen(id));
            strcpy(nome, id);
            if (tipoT == NONE) {
                printf("\nERRO Semantico: %s LINHA: %d\n", yytext, linha);
                return ERRO;
            }
            par = 1;
        }
    }
    else {
        if (tipoT == INTEIRO || tipoT == VO_ID) {
            printf("\nERRO Semantico: %s LINHA: %d\n", yytext, linha);
            return ERRO;
        }
        insere(id, atual->escopo, linha);
    }
    return ID;
}

int abprt() {
    if (par) {
        if (tipoT == INTEIRO) { // Para variar tipo de variavel ou funcao
            f_insere(nome, INTEIRO, "funcao", atual->escopo, linha);
            tipoT = NONE;
        }
        else if (tipoT == VO_ID) {
            f_insere(nome, VO_ID, "funcao", atual->escopo, linha);
            tipoT = NONE;
        }
        else{
            printf("\nERRO Semantico: %s LINHA: %d\n", yytext, linha);
            return ERRO;
        }
        esc *new_escopo = malloc(sizeof(esc));
        new_escopo->escopo = malloc(sizeof(char)*strlen(nome));
        strcpy(new_escopo->escopo, nome);
        new_escopo->prev = atual;
        atual = new_escopo;
        par = 0;
        open = 1;
    }
    return AB_PRT;
}

int ptvg() {
    if (par) {
        if (tipoT == INTEIRO) { // Para variar tipo de variavel ou funcao
            f_insere(nome, INTEIRO, "variavel", atual->escopo, linha);
            tipoT = NONE;
        }
        else{
            printf("\nERRO Semantico: %s LINHA: %d\n", yytext, linha);
            return ERRO;
        }
        par = 0;
    }
    return PT_VG;
}

int vg() {
    if (par) {
        if (tipoT == INTEIRO) { // Para variar tipo de variavel ou funcao
            f_insere(nome, INTEIRO, "variavel", atual->escopo, linha);
            tipoT = NONE;
        }
        else{
            printf("\nERRO Semantico: %s LINHA: %d\n", yytext, linha);
            return ERRO;
        }
        par = 0;
    }
    return VG;
}

int feprt() {
    if (par) {
        if (tipoT == INTEIRO) { // Para variar tipo de variavel ou funcao
            f_insere(nome, INTEIRO, "variavel", atual->escopo, linha);
            tipoT = NONE;
        }
        else{
            printf("\nERRO Semantico: %s LINHA: %d\n", yytext, linha);
            return ERRO;
        }
        par = 0;
    }
    tipoT = NONE;
    return FE_PRT;
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
"int"         { tipoT = INTEIRO; return INT; }
"void"        { tipoT = VO_ID; return VOID; }
"if"          { return IF; }
"else"        { return ELSE; }
"return"      { return RETURN; }
"while"       { return WHILE; }

[0-9]+        { return NUM; }
[A-Za-z]+     { return id(yytext); }

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
"("           { return abprt(); }
")"           { return feprt(); }
"{"           { abcv(); return AB_CV; }
"}"           { fecv(); return FE_CV; }
";"           { return ptvg(); }
","           { return vg(); }

"\n"		  { ++linha; }

" "			  { }
"\t"		  { }
[\r]+         { /* Ignorar */ }
.             { printf("\nERRO LÉXICO: %s LINHA: %d\n", yytext, linha); return ERRO; }

%%
