#include "SyntaxTree.h"
#include <stdlib.h>
#include "globals.h"
#include <stdio.h>
static char* typeStr[4] = {"integer", "real", "boolean", "array"};
int printTrunk[1000] = {0};
FILE* treeOut;

synTreenode* mkTreenode(treenodecontent* content) {
    synTreenode* newNode = (synTreenode*)malloc(sizeof(synTreenode));
    newNode->nodeContent = content;
    newNode->son = NULL;
    newNode->brother = NULL;
}

synTreenode* insertSonNode(synTreenode* root, synTreenode* newSon) {
    synTreenode* ret = NULL;
    if(root == NULL) {//no such node
        ret = newSon;
    } else {
        synTreenode* travel = root->son;
        while(travel != NULL && travel->brother != NULL) {
            travel = travel->brother;
        }
        if(travel == NULL) {//root has no son
            root->son = newSon;
        } else {
            travel->brother = newSon;
        }
        ret = root;
    }
    return ret;
}
/*
enum NonTerminaltype{
    program = 0, method, formalparams, formalparam, type, block, statements, statement, localvardecl, assignstmt, returnstmt, ifstmt, writestmt, readstmt, expression, mexpression, pexpression, bexpression, aparams
};
*/
void loadNonTerminalStr() {
    NonTerminalStr[program] = "Program";
    NonTerminalStr[method] = "MethodDecl";
    NonTerminalStr[formalparams] = "FormalParams";
    NonTerminalStr[formalparam] = "FormalParam";
    NonTerminalStr[type] = "Type";
    NonTerminalStr[block] = "Block";
    NonTerminalStr[statements] = "Statements";
    NonTerminalStr[statement] = "Statement";
    NonTerminalStr[localvardecl] = "LocalVarDecl";
    NonTerminalStr[assignstmt] = "AssignStmt";
    NonTerminalStr[returnstmt] = "ReturnStmt";
    NonTerminalStr[ifstmt] = "IfStmt";
    NonTerminalStr[writestmt] = "WriteStmt";
    NonTerminalStr[readstmt] = "ReadStmt";
    NonTerminalStr[expression] = "Expression";
    NonTerminalStr[mexpression] = "MultiplicativeExpr";
    NonTerminalStr[pexpression] = "PrimaryExpr";
    NonTerminalStr[bexpressions] = "BoolExpressions";
    NonTerminalStr[bexpression] = "BoolExpression";
    NonTerminalStr[aparams] = "ActualParams";
    NonTerminalStr[whilestmt] = "WhileStmt";
    NonTerminalStr[constindexs] = "ConstIndexs";
    NonTerminalStr[varindexs] = "VarIndexs";

}

void printAttr(synTreenode* root) {
    if(root->nodeContent->a.exprA.dataType >= 0 && root->nodeContent->lexType != constindexs && root->nodeContent->lexType != varindexs)
        fprintf(treeOut, " ,dataType = %s", typeStr[root->nodeContent->a.exprA.dataType]);
}




void printTree(synTreenode* root, int depth) {
    if(root != NULL) {
        for(int i = 0; i < depth; i++) {
            fprintf(treeOut, "    ");
            if(printTrunk[i] == 1) {
                fprintf(treeOut, "|");
            }
        }
        fprintf(treeOut, "    |\n");
        for(int i = 0; i < depth; i++) {
            fprintf(treeOut, "    ");
            if(printTrunk[i] == 1) {
                fprintf(treeOut, "|");
            }
        }
        fprintf(treeOut, "    |");
        if(root->brother != NULL) {
            printTrunk[depth] = 1;
        } else {
            printTrunk[depth] = 0;
        }
        if(root->nodeContent->tokenStr != NULL) {
            fprintf(treeOut, "- Token = %s", root->nodeContent->tokenStr);
        } else {
            fprintf(treeOut, "- Nonterminal = %s", root->nodeContent->nonTerminalStr);
        }
        printAttr(root);
        fprintf(treeOut, "\n");
        synTreenode* travel = root->son;
        while(travel != NULL) {
            printTree(travel, depth + 1);
            travel = travel->brother;
        }
        printTrunk[depth] = 0;
    }
}

void freeTree(synTreenode* root) {
    if(root != NULL) {
        freeTree(root->son);
        freeTree(root->brother);
        free(root->nodeContent->tokenStr);
        free(root->nodeContent);
        free(root->nodeContent->a.exprA.resIndex);
        free(root);
    }
}

void setType(synTreenode* r, int typenum) {
    r->nodeContent->a.exprA.dataType = typenum;
}

int getType(synTreenode* r) {
    return r->nodeContent->a.exprA.dataType;
}

char* getResIndex(synTreenode* r) {
    return r->nodeContent->a.exprA.resIndex;
}

void setResIndex(synTreenode* r, char* resIndex) {
    r->nodeContent->a.exprA.resIndex = resIndex;
}

int operType(synTreenode* r1, synTreenode* r2) {
    if(r1->nodeContent->a.exprA.dataType == real || r2->nodeContent->a.exprA.dataType == real)return real;
    if(r1->nodeContent->a.exprA.dataType == integer || r2->nodeContent->a.exprA.dataType == integer)return integer;
    return boolean;
}

void setIndexsDim(synTreenode* r, unsigned int dimension) {
    r->nodeContent->a.indexsA.dimension = dimension;
}

unsigned int getIndexsDim(synTreenode* r) {
    return r->nodeContent->a.indexsA.dimension;
}

void setIndexsOffset(synTreenode* r, unsigned int offset) {
    r->nodeContent->a.indexsA.offset = offset;
}

unsigned int getIndexsOffset(synTreenode* r) {
    return r->nodeContent->a.indexsA.offset;
}


