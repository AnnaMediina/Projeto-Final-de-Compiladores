#include <stdio.h>
#include <stdlib.h>
#include <string.h>


struct arvore {
    char nome [30];
    struct arvore **filho;
    int filhos;
} ;

typedef struct arvore nohS;


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


int main() {
    nohS *abacaxi, *filho1, *filho2, *neto1, *filho3, *neto2, *bisneto1, *bisneto2, *tataraneto1, *filho4, *neto3, *neto4, *neto5, *neto6, *bisneto3, *bisneto4, *tataraneto2, *tataraneto3;

    abacaxi = criaNoh("Abacaxi");

    filho1 = criaNoh("filho1");
    filho2 = criaNoh("filho2");
    filho3 = criaNoh("filho3");
    filho4 = criaNoh("filho4");

    neto1 = criaNoh("neto1");
    neto2 = criaNoh("neto2");
    neto3 = criaNoh("neto3");
    neto4 = criaNoh("neto4");
    neto5 = criaNoh("neto5");
    neto6 = criaNoh("neto6");

    bisneto1 = criaNoh("bisneto1");
    bisneto2 = criaNoh("bisneto2");
    bisneto3 = criaNoh("bisneto3");
    bisneto4 = criaNoh("bisneto4");

    tataraneto1 = criaNoh("tataraneto1");
    tataraneto2 = criaNoh("tataraneto2");
    tataraneto3 = criaNoh("tataraneto3");

    adicionaFilho(abacaxi, filho1);
    adicionaFilho(abacaxi, filho2);
    adicionaFilho(abacaxi, filho3);
    adicionaFilho(abacaxi, filho4);

    adicionaFilho(filho1, neto1);
    adicionaFilho(filho1, neto2);
    adicionaFilho(filho2, neto3);
    adicionaFilho(filho3, neto4);
    adicionaFilho(filho4, neto5);
    adicionaFilho(filho4, neto6);

    adicionaFilho(neto1, bisneto2);
    adicionaFilho(neto2, bisneto1);
    adicionaFilho(neto6, bisneto3);
    adicionaFilho(neto6, bisneto4);

    adicionaFilho(bisneto2, tataraneto1);
    adicionaFilho(bisneto4, tataraneto2);
    adicionaFilho(bisneto4, tataraneto3);

    printNoh(abacaxi, 0, NULL);
    liberaArvore(abacaxi);
    
    return 0;
}
