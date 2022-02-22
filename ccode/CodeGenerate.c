#include <string.h>
#include <stdio.h>
#include <stdlib.h>

extern FILE* yyin;
extern FILE* yyout;
static int tempIndex;
static int labelIndex;
static char* typeStr[4] = {"integer", "real", "boolean", "array"};

void genTriCode(const char* res, const char* oper1, const char* operator, const char* oper2) {
    fprintf(yyout, "\t%s = %s %s %s\n", res, oper1, operator, oper2);
}

void genIfFalseGoto(const char* boolExpr, const char* gotoElseLabel) {
    fprintf(yyout, "\tif False %s goto %s\n", boolExpr, gotoElseLabel);
}

void genRetCode(const char* expr) {
    fprintf(yyout, "\treturn %s\n", expr);
}

void genGotoCode(const char* gotoLabel) {
    fprintf(yyout, "\tgoto %s\n", gotoLabel);
}

void genLabel(const char* labelStr) {
    fprintf(yyout, "%s:\n", labelStr);
}

void genCopyCode(const char* dst, const char* src) {
    fprintf(yyout, "\t%s = %s\n", dst, src);
}

void genParamPassCode(const char* param) {
    fprintf(yyout, "\tParam %s\n", param);
}

void genCallCode(const char* procedureName, int paramNum) {
    fprintf(yyout, "\tcall %s, %d\n", procedureName, paramNum);
}

void genCallAssignCode(const char* dst, const char* procedureName, int paramNum) {
    fprintf(yyout, "\t%s = call %s, %d\n", dst, procedureName, paramNum);
}

void genCastCode(const char* dst, int castType, const char* src) {
    fprintf(yyout, "\t%s = (%s)%s\n", dst, typeStr[castType], src);
}

void genIfGoto(const char* boolExpression, const char* gotoLabel) {
    fprintf(yyout, "\tif %s goto %s\n", boolExpression, gotoLabel);
}

char* getLabel() {
    char* lStr = (char*)malloc(sizeof(char) * 12);
    sprintf(lStr, "L%d", labelIndex);
    labelIndex += 1;
    return lStr;
}

void genCalBoolExpr(const char* res, const char* oper1, const char* op, const char* oper2) {
    char* labelT = getLabel();
    char* labelO = getLabel();
    fprintf(yyout, "\tif %s %s %s goto %s\n", oper1, op, oper2, labelT);
    fprintf(yyout, "\t%s = False\n", res);
    genGotoCode(labelO);
    genLabel(labelT);
    fprintf(yyout, "\t%s = True\n", res);
    genLabel(labelO);
    free(labelT);
    free(labelO);
}

char* getTemp() {
    char* tStr = (char*)malloc(sizeof(char) * 12);
    sprintf(tStr, "T%d", tempIndex);
    tempIndex += 1;
    return tStr;
}



char* strDeepCopy(const char* src) {
    char* dst = (char*)malloc(sizeof(char) * strlen(src) + 1);
    strcpy(dst, src);
    return dst;
}
char* afterCast(char* initial, int initialType, int targetType) {
    if(initialType == targetType) return initial;
    char* casted = getTemp();
    genCastCode(casted, targetType, initial);
    free(initial);
    return casted;
}

void resetTempIndex() {
    tempIndex = 0;
}




