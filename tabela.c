#include<stdio.h>
#include<string.h>
#include<stdlib.h>

#define TAM 211

typedef struct lista_linhas{
    int linha_v;
    struct lista_linhas *prox;
} Tlinhas;

typedef Tlinhas *Plinhas;

typedef struct tabela{
    char *nome;
    char *tipo_id;
    char *escopo;
    Plinhas linhas;
    struct tabela *prox;
} Ttabela;

typedef  Ttabela *Ptabela;

static Ptabela *tab_hash = NULL;

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

void f_insere(char *nome, char *tipo_id, char *escopo, int linha_v){
    int h = hash(nome);

    Ptabela ts = (Ptabela)malloc(sizeof(Ttabela));
    ts->nome = strdup(nome);
    ts->tipo_id = strdup(tipo_id);
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

void print(){
    int i;
    Plinhas l;
    Ptabela ts;

    printf("Tabela de símbolos:\n");
    printf("Nome     Tipo_id     Escopo     Linhas   \n");
    printf("-----------------------------------------\n");

    for(i = 0; i < TAM; ++i){
        if (tab_hash[i] != NULL){
            ts = tab_hash[i];
            while(ts != NULL){
                printf("%-10s", ts->nome);
                printf("%-15s", ts->tipo_id);
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

int main(){
    inicializa_tabela();
    
    f_insere("main", "funcao","global", 1);
    f_insere("x", "variavel", "main", 2);
    f_insere("y", "variavel", "main", 2);
    
    insere("x", "main", 3);
    insere("y", "main", 4);
    
    print();
    
    libera_tabela();
    
}
