#ifndef CODEGENERATE_H
#define CODEGENERATE_H
void genTriCode(const char* res, const char* oper1, const char* operator, const char* oper2);

void genIfFalseGoto(const char* boolExpr, const char* gotoElseLabel);

void genRetCode(const char* expr);

void genGotoCode(const char* gotoLabel);

void genLabel(const char* labelStr);

void genCopyCode(const char* dst, const char* src);

void genParamPassCode(const char* param);

void genIfGoto(const char* boolExpression, const char* gotoLabel);

void resetTempIndex();

void genCallCode(const char* procedureName, int paramNum);

void genCallAssignCode(const char* dst, const char* procedureName, int paramNum);

void genCastCode(const char* dst, int castType, const char* src);

char* getTemp();

char* getLabel();

void genCalBoolExpr(const char* res, const char* oper1, const char* op, const char* oper2);

char* strDeepCopy(const char* src);

char* afterCast(const char* initial, int initialType, int targetType);

#endif
