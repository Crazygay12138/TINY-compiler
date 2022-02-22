#ifndef TreeNodeContent
#define TreeNodeContent
#include "table.h"
enum dataType {
    integer = 0, real, boolean, array
};

typedef struct {
    unsigned int dimension;
    unsigned int offset;
}indexsAttr;

typedef struct {
    int dataType;
    char* resIndex;
}exprAttr;

typedef union {
    exprAttr exprA;
    indexsAttr indexsA;
}attr;

typedef struct {
    int lexType;
    char* tokenStr;
    char* nonTerminalStr;
    attr a;
}treenodecontent;
treenodecontent* mkTreeNodeContent(int typenum);
#endif
