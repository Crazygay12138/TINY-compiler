#ifndef SYNTAXTREE_H
#define SYNTAXTREE_H
#include "treenodecontent.h"
typedef struct synTreenode{
    treenodecontent* nodeContent;
    struct synTreenode* son;
    struct synTreenode* brother;
}synTreenode;
synTreenode* mkTreenode(treenodecontent* content);
synTreenode* insertSonNode(synTreenode* root, synTreenode* newSon);
void freeTree(synTreenode* root);
void printTree(synTreenode* root, int depth);
void loadNonTerminalStr();

char myCompare(synTreenode* r1, synTreenode* r2);
void setType_getVal(synTreenode* r, int typenum);
int operType(synTreenode* r1, synTreenode* r2);
void setType(synTreenode* r, int typenum);
void copyVal(synTreenode* dst, synTreenode* src);
int getType(synTreenode* r);
char* getResIndex(synTreenode* r);
void setResIndex(synTreenode* r, char* resIndex);
void setIndexsDim(synTreenode* r, unsigned int dimension);
unsigned int getIndexsDim(synTreenode* r);
char* NonTerminalStr[1000];
#endif
