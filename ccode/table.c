#include "table.h"
#include "treenodecontent.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
static char* typeStr[4] = {"integer", "real", "boolean", "array"};
#define MAX_FUNCNUM 256
fTuple funcTable[MAX_FUNCNUM];

int funcTop = -1;
unsigned int currentOffset = 0;

extern void yyerror(const char*);

FILE* tableOut;

int addFunc(char* fName, int returnType) {
    for(int i = 0; i <= funcTop; i++) {
        if(strcmp(fName, funcTable[i].fName) == 0) {
            return 1;//multiple function name
        }
    }
    if(funcTop + 1 >= MAX_FUNCNUM) return -1;//table is full
    funcTop += 1;
    funcTable[funcTop].fName = fName;
    funcTable[funcTop].returnType = returnType;
    funcTable[funcTop].argNum = 0;//initialize to 0, might increases later
    funcTable[funcTop].varNum = 0;//initialize to 0, might increases later
    currentOffset = 0;
    return 0;
}

int addVar(char* varName, int dataType, unsigned int offset) {
    if(funcTop < 0)return 1;//Can not define var outside of function
    if(funcTable[funcTop].varNum >= MAX_ARGC)return -1;//variable tabel is full
    varTuple* varT = &(funcTable[funcTop].varTable[funcTable[funcTop].varNum]);
    for(int i = 0; i <= funcTable[funcTop].varNum - 1; i++) {
        if(strcmp(varName, funcTable[funcTop].varTable[i].varName) == 0) {
            return 1;//multiple local var name
        }
    }
    varT->varName = varName;
    varT->dataType = dataType;
    varT->offset = currentOffset;
    currentOffset += offset;
    funcTable[funcTop].varNum += 1;//add one var
    return 0;
}


unsigned int getOffset(int dataType) {
    unsigned int offset = 0;
    switch(dataType){
        case integer :
            offset = 4;
            break;
        
        case real :
            offset = 8;
            break;
            
        case boolean :
            offset = 1;
            break;
            
        default :
            offset = 4;
            break;
    }
    return offset;
}

int addArr(char* varName, int dataType, unsigned int dimension, int dimensionSize[]) {
    /*treat varName as a pointer, it's size is 4 bytes*/
    if(dimension > MAX_DIMENSION){
        yyerror("error");
        fprintf(stderr, "array's dimension(%u) should not be larger than %u\n", dimension, MAX_DIMENSION);
        return 1;
    }
    for(unsigned int i = 0; i <= dimension - 1; i++) {
        if(dimensionSize[i] <= 0){
            yyerror("error");
            fprintf(stderr, "array's dimension size should be larger than 0.\n");
            return 1;
        }
    }
    if(addVar(varName, array, 4))return 1;//invalid
    varTuple* varT = &(funcTable[funcTop].varTable[funcTable[funcTop].varNum - 1]);//modify the varTuple
    varT->arrinfo = (arrInfo*)malloc(sizeof(arrInfo));
    varT->arrinfo->arrDataType = dataType;
    varT->arrinfo->dimension = dimension;
    int totalEles = 1;
    for(unsigned int i = 0; i <= dimension - 1; i++) {
        varT->arrinfo->dimensionSize[i] = dimensionSize[i];
        totalEles *= dimensionSize[i];
    }
    currentOffset += totalEles * getOffset(dataType);
    return 0;
}

unsigned int getArrDimSize(char* varName, unsigned int dimensionIndex) {
    if(funcTop < 0)return 0;//Can not refer to var that is outside of function
    int varIndex = -1;
    for(int i = 0; i <= funcTable[funcTop].varNum - 1 && varIndex == -1; i++) {
        if(strcmp(varName, funcTable[funcTop].varTable[i].varName) == 0) {
            varIndex = i;
        }
    }
    if(varIndex != -1) {
        arrInfo* arrinfo = funcTable[funcTop].varTable[varIndex].arrinfo;
        if(dimensionIndex <= arrinfo->dimension - 1 && dimensionIndex >= 0) {
            return arrinfo->dimensionSize[dimensionIndex];
        }
    }
    return 0;
}

unsigned int getSubSpaceSize(char* varName, unsigned int dimensionIndex) {
    if(funcTop < 0)return -1;//Can not refer to var that is outside of function
    int varIndex = -1;
    for(int i = 0; i <= funcTable[funcTop].varNum - 1 && varIndex == -1; i++) {
        if(strcmp(varName, funcTable[funcTop].varTable[i].varName) == 0) {
            varIndex = i;
        }
    }
    unsigned int size = 0;
    if(varIndex != -1) {
        arrInfo* arrinfo = funcTable[funcTop].varTable[varIndex].arrinfo;
        unsigned int dataOffset = getOffset(arrinfo->arrDataType);
        if(dimensionIndex <= arrinfo->dimension - 1 && dimensionIndex >= 0) {
            unsigned int eleSize = 1;
            for(unsigned int i = dimensionIndex + 1; i <= arrinfo->dimension - 1; i++) {
                eleSize *= arrinfo->dimensionSize[i];
            }
            size = eleSize * dataOffset;
        }
    }
    return size;
}

int getArrType(char* varName) {
    if(funcTop < 0)return -1;//Can not refer to var that is outside of function
    int haveDefined = 0;
    int isArr = 0;
    int index = -1;
    for(int i = 0; i <= funcTable[funcTop].varNum - 1 && haveDefined == 0; i++) {
        if(strcmp(varName, funcTable[funcTop].varTable[i].varName) == 0) {
            haveDefined = 1;
            if(funcTable[funcTop].varTable[i].dataType == array) {
                isArr = 1;
                index = i;
            }
        }
    }
    if(haveDefined && isArr){
        return funcTable[funcTop].varTable[index].arrinfo->arrDataType;
    }
    return integer;//integer for default
}

int addArg(char* argName, int dataType, unsigned int offset) {
    if(addVar(argName, dataType, offset)) return 1;//invalid
    funcTable[funcTop].argsType[funcTable[funcTop].argNum] = dataType;
    funcTable[funcTop].argNum += 1;
}



int checkVar(const char* varName) {
    if(funcTop < 0)return 1;//Can not refer to var that is outside of function
    int haveDefined = 0;
    for(int i = 0; i <= funcTable[funcTop].varNum - 1 && haveDefined == 0; i++) {
        if(strcmp(varName, funcTable[funcTop].varTable[i].varName) == 0) {
            haveDefined = 1;
        }
    }
    if(haveDefined){
        return 0;
    }
    char errorMsg[256];
    strcpy(errorMsg, "Undefined reference to ");
    yyerror("error");
    fprintf(stderr, "%s\n", strncat(errorMsg, varName, 255 - strlen("Undefined reference to ")));
    return 1;
}

int checkArr(const char* varName) {
    if(funcTop < 0)return 1;//Can not refer to var that is outside of function
    int haveDefined = 0;
    int isArr = 0;
    for(int i = 0; i <= funcTable[funcTop].varNum - 1 && haveDefined == 0; i++) {
        if(strcmp(varName, funcTable[funcTop].varTable[i].varName) == 0) {
            haveDefined = 1;
            if(funcTable[funcTop].varTable[i].dataType == array) {
                isArr = 1;
            }
        }
    }
    if(haveDefined && isArr){
        return 0;
    }
    char errorMsg[256];
    if(haveDefined == 0) {
        strcpy(errorMsg, "Undefined reference to ");
        yyerror("error");
        fprintf(stderr, "%s\n", strncat(errorMsg, varName, 255 - strlen("Undefined reference to ")));
    }else {
        yyerror("error");
        fprintf(stderr, "%s is not an array\n", varName);
    }
    
    return 1;
}

int checkFunc(const char* funcName) {
    if(funcTop < 0)return 1;//Can not refer to var that is outside of function
    int haveDefined = 0;
    for(int i = 0; i <= funcTop && haveDefined == 0; i++) {
        if(strcmp(funcName, funcTable[i].fName) == 0) {
            haveDefined = 1;
        }
    }
    if(haveDefined){
        return 0;
    }
    char errorMsg[256];
    strcpy(errorMsg, "Undefined reference to ");
    yyerror("error");
    fprintf(stderr, "%s\n", strncat(errorMsg, funcName, 255 - strlen("Undefined reference to ")));
    return 1;
}

int checkActualParams(const char* funcName, int actualParamsStack[], int paramStackTop) {
    int index = -1;
    int notValid = 0;
    for(int i = 0; i <= funcTop; i++) {
        if(strcmp(funcName, funcTable[i].fName) == 0) {
            index = i;
        }
    }
    if(index != -1 && paramStackTop + 1 != funcTable[index].argNum) {
        yyerror("error");
        fprintf(stderr, "Function %s expects %d parameters but pass %d parameters\n", funcName, funcTable[index].argNum, paramStackTop + 1);
        notValid = 1;
    }
    if(index != -1 && paramStackTop + 1 == funcTable[index].argNum) {
        for(int i = 0; i <= paramStackTop; i++) {
            if(actualParamsStack[i] != funcTable[index].argsType[i]) {
                yyerror("error");
                fprintf(stderr, "Function %s's %dth parameter expects type %s but pass type %s\n", funcName, i + 1, typeStr[funcTable[index].argsType[i]], typeStr[actualParamsStack[i]]);
                notValid = 1;
            }
        }
    }
    return notValid;
}

int checkReturnType(int programerRetType) {
    int notValid = 1;
    if(programerRetType == getFuncRetType(getCurrentFuncName())) notValid = 0;
    if(notValid) {
        yyerror("error");
        fprintf(stderr, "Function %s's return value type is %s but you return value with type %s\n", getCurrentFuncName(), typeStr[getFuncRetType(getCurrentFuncName())], typeStr[programerRetType]);
    }
}

int getVarType(const char* varName) {
    int type = integer;//default to integer
    if(funcTop < 0)return 1;//Can not refer to var that is outside of function
    for(int i = 0; i <= funcTable[funcTop].varNum - 1; i++) {
        if(strcmp(varName, funcTable[funcTop].varTable[i].varName) == 0) {
            type = funcTable[funcTop].varTable[i].dataType;
        }
    }
    return type;
}

int getFuncRetType(const char* funcName) {
    int type = integer;//default to integer
    for(int i = 0; i <= funcTop; i++) {
        if(strcmp(funcName, funcTable[i].fName) == 0) {
            type = funcTable[i].returnType;
        }
    }
    return type;
}

char* getCurrentFuncName() {
    char* ret = NULL;
    if(funcTop >= 0) {
        ret = funcTable[funcTop].fName;
    }
    return ret;
}

void printTable() {
    fprintf(tableOut, "\n\n--------------Function Table---------------\n\n");
    for(int i = 0; i <= funcTop; i++) {
        fprintf(tableOut, "Function%d : %s\n", i + 1, funcTable[i].fName);
        fprintf(tableOut, "\tArgument type :");
        for(int j = 0; j <= funcTable[i].argNum - 1; j++) {
            fprintf(tableOut, "  %s", typeStr[funcTable[i].argsType[j]]);
        }
        fprintf(tableOut, "\n\tVariable table:\n");
        for(int j = 0; j <= funcTable[i].varNum - 1; j++) {
            fprintf(tableOut, "\t\t%s  %s  %u", funcTable[i].varTable[j].varName, typeStr[funcTable[i].varTable[j].dataType], funcTable[i].varTable[j].offset);
            if(funcTable[i].varTable[j].dataType == array) {
                fprintf(tableOut, "  dimension:");
                for(int k = 0; k <= funcTable[i].varTable[j].arrinfo->dimension - 1; k++) {
                    fprintf(tableOut, "%u  ", funcTable[i].varTable[j].arrinfo->dimensionSize[k]);
                }
            }
            fprintf(tableOut, "\n");
        }
    }
}

void freeTable() {
    for(int i = 0; i <= funcTop; i++) {
        for(int j = 0; j <= funcTable[i].varNum - 1; j++) {
            if(funcTable[i].varTable[j].dataType == array) {
                free(funcTable[i].varTable[j].arrinfo);
            }
        }
    }
}



