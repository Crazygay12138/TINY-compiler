#ifndef TABLE_H
#define TABLE_H
#define MAX_ARGC 30
#define MAX_LOCVAR 256
#define MAX_DIMENSION 30

typedef struct {
    int arrDataType;
    unsigned int dimension;
    unsigned int dimensionSize[MAX_DIMENSION];
}arrInfo;

typedef struct {
    char* varName;
    int dataType;
    unsigned int offset;
    arrInfo* arrinfo;
}varTuple;

typedef struct {
    char* fName;
    int returnType;
    int argNum;
    int argsType[MAX_ARGC];
    int varNum;
    varTuple varTable[MAX_LOCVAR];
}fTuple;

int addFunc(char* fName, int returnType);

int addVar(char* varName, int dataType, unsigned int offset);

int addArg(char* argName, int dataType, unsigned int offset);

int addArr(char* varName, int dataType, unsigned int dimension, int dimensionSize[]);

unsigned int getSubSpaceSize(char* varName, unsigned int dimensionIndex);

unsigned int getArrDimSize(char* varName, unsigned int dimensionIndex);

unsigned int getOffset(int dataType);

int checkArr(const char* varName);

int getArrType(char* varName);

int checkVar(const char* varName);

int checkFunc(const char* funcName);

int getVarType(const char* varName);

int checkActualParams(const char* funcName, int actualParamsStack[], int paramStackTop);

int checkReturnType(int programerRetType);

char* getCurrentFuncName();

int getFuncRetType(const char* funcName);

void printTable();

void freeTable();


#endif
