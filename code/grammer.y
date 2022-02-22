%{
#include <stdio.h>
#include <stdlib.h>
#include "SyntaxTree.h"
#define YYSTYPE synTreenode*
#include "globals.h"
#include "table.h"
#include "CodeGenerate.h"
extern void yyerror();
extern int yylex();
extern YYSTYPE yylval;
extern FILE* yyin;
extern FILE* yyout;
extern int yylineno;
synTreenode* root = NULL;
int actualParamsTypeStack[MAX_ARGC];
char* actualParamsNameStack[MAX_ARGC];
int actualParamsTop = -1;
char* LabelStack[1024] = {NULL};
int LabelStackTop = -1;
int dimensionSizeStack[1024];
int dimensionSizeStackTop = -1;
char* dimensionOffsetStack[1024];
int dimensionOffsetStackTop = -1;
extern FILE* tokenOut;
extern FILE* treeOut;
extern FILE* tableOut;
%}

%token IF WRITE READ RETURN BGN END MAIN INT REAL ID INTNUMBER REALNUMBER STRING COMMENT SEMICOLON COMMA LEFTBRACKETS RIGHTBRACKETS PLUS MINUS MULTI DIV ASSIGN EQUAL NOTEQUAL WID WHILE GT LT GE LE LEFTSQUAREBRACKETS RIGHTSQUAREBRACKETS

%left OR

%left AND

%nonassoc IFX
%nonassoc ELSE

%error-verbose
%%



Program : Program MethodDecl {insertSonNode(root, $2);}
    |
;

MethodDecl : Type MAIN ID {addFunc($3->nodeContent->tokenStr, getType($1));genLabel($3->nodeContent->tokenStr);} LEFTBRACKETS FormalParams RIGHTBRACKETS Block {
    $$ = mkTreenode(mkTreeNodeContent(method));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    insertSonNode($$, $5);
    insertSonNode($$, $6);
    insertSonNode($$, $7);
    insertSonNode($$, $8);
}
    | Type ID {addFunc($2->nodeContent->tokenStr, getType($1));genLabel($2->nodeContent->tokenStr);} LEFTBRACKETS FormalParams RIGHTBRACKETS Block {
    $$ = mkTreenode(mkTreeNodeContent(method));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $4);
    insertSonNode($$, $5);
    insertSonNode($$, $6);
    insertSonNode($$, $7);
}
;

FormalParams : FormalParam {
    $$ = mkTreenode(mkTreeNodeContent(formalparams));
    insertSonNode($$, $1);
}
    | FormalParams COMMA FormalParam {
        $$ = mkTreenode(mkTreeNodeContent(formalparams));
        insertSonNode($$, $1);
        insertSonNode($$, $2);
        insertSonNode($$, $3);
    }
    | {$$ = mkTreenode(mkTreeNodeContent(formalparams));}
;

FormalParam : Type ID {
    $$ = mkTreenode(mkTreeNodeContent(formalparam));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    addArg($2->nodeContent->tokenStr, getType($1), getOffset(getType($1)));
}
;

Type : INT {
    $$ = mkTreenode(mkTreeNodeContent(type));
    insertSonNode($$, $1);
    setType($$, integer);
}
    | REAL{
        $$ = mkTreenode(mkTreeNodeContent(type));
        insertSonNode($$, $1);
        setType($$, real);
    }
    ;
    
Block : BGN Statements END {
    $$ = mkTreenode(mkTreeNodeContent(block));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
}
    | BGN END {//empty block
        $$ = mkTreenode(mkTreeNodeContent(block));
        insertSonNode($$, $1);
        insertSonNode($$, $2);
    }
;

Statements : Statements Statement {
    $$ = mkTreenode(mkTreeNodeContent(statements));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
}
    | Statement {
        $$ = mkTreenode(mkTreeNodeContent(statements));
        insertSonNode($$, $1);
    }
    | error Statement {
        fprintf(stderr, "not statement(s)\n");
        $$ = mkTreenode(mkTreeNodeContent(statements));
        insertSonNode($$, $2);
    }
;

Statement : Block {
        $$ = mkTreenode(mkTreeNodeContent(statement));
        insertSonNode($$, $1);
    }
    | LocalVarDecl {
        $$ = mkTreenode(mkTreeNodeContent(statement));
        insertSonNode($$, $1);
    }
    | AssignStmt {
        $$ = mkTreenode(mkTreeNodeContent(statement));
        insertSonNode($$, $1);
    }
    | ReturnStmt {
        $$ = mkTreenode(mkTreeNodeContent(statement));
        insertSonNode($$, $1);
    }
    | IfStmt {
        $$ = mkTreenode(mkTreeNodeContent(statement));
        insertSonNode($$, $1);
    }
    | WhileStmt {
        $$ = mkTreenode(mkTreeNodeContent(statement));
        insertSonNode($$, $1);
    }
    | WriteStmt {
        $$ = mkTreenode(mkTreeNodeContent(statement));
        insertSonNode($$, $1);
    }
    | ReadStmt {
        $$ = mkTreenode(mkTreeNodeContent(statement));
        insertSonNode($$, $1);
    }
    | SEMICOLON {
        $$ = mkTreenode(mkTreeNodeContent(statement));
        insertSonNode($$, $1);
    }
;

LocalVarDecl : Type ID SEMICOLON {
    $$ = mkTreenode(mkTreeNodeContent(localvardecl));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    addVar($2->nodeContent->tokenStr, getType($1), getOffset(getType($1)));
}
    | Type ID ConstIndexs SEMICOLON {
        $$ = mkTreenode(mkTreeNodeContent(localvardecl));
        insertSonNode($$, $1);
        insertSonNode($$, $2);
        insertSonNode($$, $3);
        insertSonNode($$, $4);
        addArr($2->nodeContent->tokenStr, getType($1), getIndexsDim($3), dimensionSizeStack + dimensionSizeStackTop + 1 - getIndexsDim($3));
        dimensionSizeStackTop -= getIndexsDim($3);
    }
;

ConstIndexs : ConstIndexs LEFTSQUAREBRACKETS INTNUMBER RIGHTSQUAREBRACKETS {
    $$ = mkTreenode(mkTreeNodeContent(constindexs));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    insertSonNode($$, $4);
    int dSize;
    sscanf($3->nodeContent->tokenStr, "%d", &dSize);
    dimensionSizeStack[++dimensionSizeStackTop] = dSize;
    setIndexsDim($$, getIndexsDim($1) + 1);
}
    | LEFTSQUAREBRACKETS INTNUMBER RIGHTSQUAREBRACKETS {
        $$ = mkTreenode(mkTreeNodeContent(constindexs));
        insertSonNode($$, $1);
        insertSonNode($$, $2);
        insertSonNode($$, $3);
        int dSize;
        sscanf($2->nodeContent->tokenStr, "%d", &dSize);
        dimensionSizeStack[++dimensionSizeStackTop] = dSize;
        setIndexsDim($$, 1);
    }
    
;

VarIndexs : VarIndexs LEFTSQUAREBRACKETS Expression RIGHTSQUAREBRACKETS {
    $$ = mkTreenode(mkTreeNodeContent(varindexs));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    insertSonNode($$, $4);
    setResIndex($3, afterCast(getResIndex($3), getType($3), integer));
    dimensionOffsetStack[++dimensionOffsetStackTop] = getResIndex($3);
    setIndexsDim($$, getIndexsDim($1) + 1);
}
    | LEFTSQUAREBRACKETS Expression RIGHTSQUAREBRACKETS {
        $$ = mkTreenode(mkTreeNodeContent(varindexs));
        insertSonNode($$, $1);
        insertSonNode($$, $2);
        insertSonNode($$, $3);
        setResIndex($2, afterCast(getResIndex($2), getType($2), integer));
        dimensionOffsetStack[++dimensionOffsetStackTop] = getResIndex($2);
        setIndexsDim($$, 1);
    }

;

AssignStmt : ID ASSIGN Expression SEMICOLON {
    $$ = mkTreenode(mkTreeNodeContent(assignstmt));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    insertSonNode($$, $4);
    checkVar($1->nodeContent->tokenStr);
    //generate code
    setResIndex($3, afterCast(getResIndex($3), getType($3), getVarType($1->nodeContent->tokenStr)));
    genCopyCode($1->nodeContent->tokenStr, getResIndex($3));
    resetTempIndex();//Expression's value is used, reset temp var
}
| ID VarIndexs ASSIGN Expression SEMICOLON {
    $$ = mkTreenode(mkTreeNodeContent(assignstmt));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    insertSonNode($$, $4);
    insertSonNode($$, $5);
    if(checkArr($1->nodeContent->tokenStr) == 0) {//valid
        char* offsetVar = getTemp();
        unsigned int size;
        char t[256];
        genCopyCode(offsetVar, "0");
        for(int i = dimensionOffsetStackTop, c = getIndexsDim($2); c >= 1; c--, i--) {
            sprintf(t, "%s * %u", dimensionOffsetStack[i], getSubSpaceSize($1->nodeContent->tokenStr, c - 1));
            genTriCode(offsetVar, offsetVar, "+", t);
        }
        sprintf(t, "%s[%s]", $1->nodeContent->tokenStr, offsetVar);
        setResIndex($4, afterCast(getResIndex($4), getType($4), getArrType($1->nodeContent->tokenStr)));
        genCopyCode(t, getResIndex($4));
        dimensionOffsetStackTop -= getIndexsDim($2);
    }
    
}
;

ReturnStmt : RETURN Expression SEMICOLON {
    $$ = mkTreenode(mkTreeNodeContent(returnstmt));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    //generate code
    checkReturnType(getType($2));
    setResIndex($2, afterCast(getResIndex($2), getType($2), getFuncRetType(getCurrentFuncName())));
    genRetCode(getResIndex($2));
    resetTempIndex();//Expression's value is used, reset temp var
}
;

IfStmt : IF LEFTBRACKETS BoolExpressions GenIfCode RIGHTBRACKETS Statement %prec IFX {
    $$ = mkTreenode(mkTreeNodeContent(ifstmt));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    insertSonNode($$, $5);
    insertSonNode($$, $6);
    genLabel(LabelStack[LabelStackTop]);
    free(LabelStack[LabelStackTop]);
    LabelStackTop -= 1;
    resetTempIndex();
}
    | IF LEFTBRACKETS BoolExpressions GenIfCode RIGHTBRACKETS Statement ELSE 
    {LabelStack[++LabelStackTop] = getLabel();genGotoCode(LabelStack[LabelStackTop]);genLabel(LabelStack[LabelStackTop - 1]);} 
    Statement {
        $$ = mkTreenode(mkTreeNodeContent(ifstmt));
        insertSonNode($$, $1);
        insertSonNode($$, $2);
        insertSonNode($$, $3);
        insertSonNode($$, $5);
        insertSonNode($$, $6);
        insertSonNode($$, $7);
        insertSonNode($$, $9);
        genLabel(LabelStack[LabelStackTop]);
        free(LabelStack[LabelStackTop]);
        free(LabelStack[LabelStackTop - 1]);
        LabelStackTop -= 2;
        resetTempIndex();
    }
;

WhileStmt : WHILE {LabelStack[++LabelStackTop] = getLabel();genLabel(LabelStack[LabelStackTop]);/*lay begin label*/} LEFTBRACKETS BoolExpressions GenIfCode RIGHTBRACKETS Statement {
    $$ = mkTreenode(mkTreeNodeContent(writestmt));
    insertSonNode($$, $1);
    insertSonNode($$, $3);
    insertSonNode($$, $4);
    insertSonNode($$, $6);
    insertSonNode($$, $7);
    //generate code
    genGotoCode(LabelStack[LabelStackTop - 1]);/*back to begin*/
    genLabel(LabelStack[LabelStackTop]);/*jump out while*/
    free(LabelStack[LabelStackTop]);
    free(LabelStack[LabelStackTop - 1]);
    LabelStackTop -= 2;/*pop out while stmt's label*/
    resetTempIndex();
}
;

GenIfCode : {LabelStack[++LabelStackTop] = getLabel();genIfFalseGoto(getResIndex($0), LabelStack[LabelStackTop]);}
;

WriteStmt : WRITE LEFTBRACKETS Expression COMMA STRING RIGHTBRACKETS SEMICOLON {
    $$ = mkTreenode(mkTreeNodeContent(writestmt));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    insertSonNode($$, $4);
    insertSonNode($$, $5);
    insertSonNode($$, $6);
    insertSonNode($$, $7);
    genParamPassCode(getResIndex($3));
    genParamPassCode($5->nodeContent->tokenStr);
    genCallCode("WRITE", 2);
    resetTempIndex();//Expression's value is used, reset temp var
}
;

ReadStmt : READ LEFTBRACKETS ID COMMA STRING RIGHTBRACKETS SEMICOLON {
    $$ = mkTreenode(mkTreeNodeContent(readstmt));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    insertSonNode($$, $4);
    insertSonNode($$, $5);
    insertSonNode($$, $6);
    insertSonNode($$, $7);
    //generate code
    genParamPassCode($3->nodeContent->tokenStr);
    genParamPassCode($5->nodeContent->tokenStr);
    genCallCode("READ", 2);
    //check if ID is defined
    checkVar($3->nodeContent->tokenStr);
}
;

Expression : Expression PLUS MultiplicativeExpr {
    $$ = mkTreenode(mkTreeNodeContent(expression));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    setType($$, operType($1, $3));
    //generate code
    setResIndex($$, getTemp());
    setResIndex($1, afterCast(getResIndex($1), getType($1), getType($$)));
    setResIndex($3, afterCast(getResIndex($3), getType($3), getType($$)));
    genTriCode(getResIndex($$), getResIndex($1), "+", getResIndex($3));
    
}
    | Expression MINUS MultiplicativeExpr {
        $$ = mkTreenode(mkTreeNodeContent(expression));
        insertSonNode($$, $1);
        insertSonNode($$, $2);
        insertSonNode($$, $3);
        setType($$, operType($1, $3));
        //generate code
        setResIndex($$, getTemp());
        setResIndex($1, afterCast(getResIndex($1), getType($1), getType($$)));
        setResIndex($3, afterCast(getResIndex($3), getType($3), getType($$)));
        genTriCode(getResIndex($$), getResIndex($1), "-", getResIndex($3));
}
    | MultiplicativeExpr {
        $$ = mkTreenode(mkTreeNodeContent(expression));
        insertSonNode($$, $1);
        setType($$, getType($1));
        //simply inherit child's result
        setResIndex($$, strDeepCopy(getResIndex($1)));
    }
;

MultiplicativeExpr : MultiplicativeExpr MULTI PrimaryExpr {
    $$ = mkTreenode(mkTreeNodeContent(mexpression));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    setType($$, operType($1, $3));
    //generate code
    setResIndex($$, getTemp());
    setResIndex($1, afterCast(getResIndex($1), getType($1), getType($$)));
    setResIndex($3, afterCast(getResIndex($3), getType($3), getType($$)));
    genTriCode(getResIndex($$), getResIndex($1), "*", getResIndex($3));

}
    | MultiplicativeExpr DIV PrimaryExpr {
        $$ = mkTreenode(mkTreeNodeContent(mexpression));
        insertSonNode($$, $1);
        insertSonNode($$, $2);
        insertSonNode($$, $3);
        setType($$, operType($1, $3));
        //generate code
        setResIndex($$, getTemp());
        setResIndex($1, afterCast(getResIndex($1), getType($1), getType($$)));
        setResIndex($3, afterCast(getResIndex($3), getType($3), getType($$)));
        genTriCode(getResIndex($$), getResIndex($1), "/", getResIndex($3));
    }
    | PrimaryExpr {
        $$ = mkTreenode(mkTreeNodeContent(mexpression));
        insertSonNode($$, $1);
        setType($$, getType($1));
        //simply inherit child's result
        setResIndex($$, strDeepCopy(getResIndex($1)));
    }
;

PrimaryExpr : INTNUMBER {
    $$ = mkTreenode(mkTreeNodeContent(pexpression));
    insertSonNode($$, $1);
    setType($$, integer);
    //simply inherit child's result
    setResIndex($$, strDeepCopy($1->nodeContent->tokenStr));
}
    | REALNUMBER {
        $$ = mkTreenode(mkTreeNodeContent(pexpression));
        insertSonNode($$, $1);
        setType($$, real);
        //simply inherit child's result
        setResIndex($$, strDeepCopy($1->nodeContent->tokenStr));
    }
    | ID {
        $$ = mkTreenode(mkTreeNodeContent(pexpression));
        insertSonNode($$, $1);
        //need id table to check whether it exists
        checkVar($1->nodeContent->tokenStr);
        setType($$, getVarType($1->nodeContent->tokenStr));
        //generate code
        setResIndex($$, strDeepCopy($1->nodeContent->tokenStr));
    }
    | ID VarIndexs {
        $$ = mkTreenode(mkTreeNodeContent(pexpression));
        insertSonNode($$, $1);
        insertSonNode($$, $2);
        //check var table
        //generate code
        if(checkArr($1->nodeContent->tokenStr) == 0) {//valid
            char* offsetVar = getTemp();
            unsigned int size;
            char t[256];
            genCopyCode(offsetVar, "0");
            for(int i = dimensionOffsetStackTop, c = getIndexsDim($2); c >= 1; c--, i--) {
                sprintf(t, "%s * %u", dimensionOffsetStack[i], getSubSpaceSize($1->nodeContent->tokenStr, c - 1));
                genTriCode(offsetVar, offsetVar, "+", t);
            }
            sprintf(t, "%s[%s]", $1->nodeContent->tokenStr, offsetVar);
            setResIndex($$, strDeepCopy(t));
            setType($$, getArrType($1->nodeContent->tokenStr));
            dimensionOffsetStackTop -= getIndexsDim($2);
        } else {
            setResIndex($$, strDeepCopy("ERROR"));
            setType($$, integer);//default type
        }
        
    }
    | LEFTBRACKETS Expression RIGHTBRACKETS {
        $$ = mkTreenode(mkTreeNodeContent(pexpression));
        insertSonNode($$, $1);
        insertSonNode($$, $2);
        insertSonNode($$, $3);
        $$->nodeContent->a.exprA.dataType = $2->nodeContent->a.exprA.dataType;
        setType($$, getType($2));
        //simply inherit child's result
        setResIndex($$, strDeepCopy(getResIndex($2)));
    }
    | ID LEFTBRACKETS ActualParams RIGHTBRACKETS {
        $$ = mkTreenode(mkTreeNodeContent(pexpression));
        insertSonNode($$, $1);
        insertSonNode($$, $2);
        insertSonNode($$, $3);
        //need to check id(function) return value's type
        checkFunc($1->nodeContent->tokenStr);
        setType($$, getFuncRetType($1->nodeContent->tokenStr));
        //check actual parameters vaildation
        checkActualParams($1->nodeContent->tokenStr, actualParamsTypeStack, actualParamsTop);
        //generate code
        for(int i = 0; i <= actualParamsTop; i++) {
            genParamPassCode(actualParamsNameStack[i]);
        }
        setResIndex($$, getTemp());
        genCallAssignCode(getResIndex($$), $1->nodeContent->tokenStr, actualParamsTop + 1);
        //reset actual parameters stack
        actualParamsTop = -1;
    }
;

BoolExpressions : BoolExpressions AND BoolExpressions {
    $$ = mkTreenode(mkTreeNodeContent(bexpressions));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    setType($$, boolean);
    setResIndex($$, getTemp());
    //generate code
    char* falseLabel = getLabel();
    char* escapeLabel = getLabel();
    genIfFalseGoto(getResIndex($1), falseLabel);
    genIfFalseGoto(getResIndex($3), falseLabel);
    genCopyCode(getResIndex($$), "True");//The result is true
    genGotoCode(escapeLabel);
    genLabel(falseLabel);
    genCopyCode(getResIndex($$), "False");
    genLabel(escapeLabel);
    free(falseLabel);
    free(escapeLabel);
    
}

    | BoolExpressions OR BoolExpressions {
        $$ = mkTreenode(mkTreeNodeContent(bexpressions));
        insertSonNode($$, $1);
        insertSonNode($$, $2);
        insertSonNode($$, $3);
        setType($$, boolean);
        setResIndex($$, getTemp());
        //generate code
        char* trueLabel = getLabel();
        char* escapeLabel = getLabel();
        genIfGoto(getResIndex($1), trueLabel);
        genIfGoto(getResIndex($3), trueLabel);
        genCopyCode(getResIndex($$), "False");//The result is false
        genGotoCode(escapeLabel);
        genLabel(trueLabel);
        genCopyCode(getResIndex($$), "True");//The result is true
        genLabel(escapeLabel);
        free(trueLabel);
        free(escapeLabel);
    }
    
    |BoolExpression {
        $$ = mkTreenode(mkTreeNodeContent(bexpressions));
        insertSonNode($$, $1);
        setType($$, boolean);
        //inherit child's result
        setResIndex($$, getResIndex($1));
    }

;

BoolExpression : Expression EQUAL Expression {
    $$ = mkTreenode(mkTreeNodeContent(bexpression));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    setType($$, boolean);
    //generate code
    setResIndex($$, getTemp());
    setResIndex($1, afterCast(getResIndex($1), getType($1), operType($1, $3)));
    setResIndex($3, afterCast(getResIndex($3), getType($3), operType($1, $3)));
    genCalBoolExpr(getResIndex($$), getResIndex($1), "==", getResIndex($3));
}
    | Expression NOTEQUAL Expression {
    $$ = mkTreenode(mkTreeNodeContent(bexpression));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    setType($$, boolean);
    //generate code
    setResIndex($$, getTemp());
    setResIndex($1, afterCast(getResIndex($1), getType($1), operType($1, $3)));
    setResIndex($3, afterCast(getResIndex($3), getType($3), operType($1, $3)));
    genCalBoolExpr(getResIndex($$), getResIndex($1), "!=", getResIndex($3));
}
    | Expression GT Expression {
    $$ = mkTreenode(mkTreeNodeContent(bexpression));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    setType($$, boolean);
    //generate code
    setResIndex($$, getTemp());
    setResIndex($1, afterCast(getResIndex($1), getType($1), operType($1, $3)));
    setResIndex($3, afterCast(getResIndex($3), getType($3), operType($1, $3)));
    genCalBoolExpr(getResIndex($$), getResIndex($1), ">", getResIndex($3));
}
    | Expression LT Expression {
    $$ = mkTreenode(mkTreeNodeContent(bexpression));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    setType($$, boolean);
    //generate code
    setResIndex($$, getTemp());
    setResIndex($1, afterCast(getResIndex($1), getType($1), operType($1, $3)));
    setResIndex($3, afterCast(getResIndex($3), getType($3), operType($1, $3)));
    genCalBoolExpr(getResIndex($$), getResIndex($1), "<", getResIndex($3));
}
    | Expression GE Expression {
    $$ = mkTreenode(mkTreeNodeContent(bexpression));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    setType($$, boolean);
    //generate code
    setResIndex($$, getTemp());
    setResIndex($1, afterCast(getResIndex($1), getType($1), operType($1, $3)));
    setResIndex($3, afterCast(getResIndex($3), getType($3), operType($1, $3)));
    genCalBoolExpr(getResIndex($$), getResIndex($1), ">=", getResIndex($3));
}
    | Expression LE Expression {
    $$ = mkTreenode(mkTreeNodeContent(bexpression));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    setType($$, boolean);
    //generate code
    setResIndex($$, getTemp());
    setResIndex($1, afterCast(getResIndex($1), getType($1), operType($1, $3)));
    setResIndex($3, afterCast(getResIndex($3), getType($3), operType($1, $3)));
    genCalBoolExpr(getResIndex($$), getResIndex($1), "<=", getResIndex($3));
}
;

ActualParams : ActualParams COMMA Expression {
    $$ = mkTreenode(mkTreeNodeContent(aparams));
    insertSonNode($$, $1);
    insertSonNode($$, $2);
    insertSonNode($$, $3);
    //push actual parameter's type and name into stack
    actualParamsTop++;
    actualParamsTypeStack[actualParamsTop] = getType($3);
    actualParamsNameStack[actualParamsTop] = getResIndex($3);
}
    | Expression {
        $$ = mkTreenode(mkTreeNodeContent(aparams));
        insertSonNode($$, $1);
        //push actual parameter's type and name into stack
        actualParamsTop++;
        actualParamsTypeStack[actualParamsTop] = getType($1);
        actualParamsNameStack[actualParamsTop] = getResIndex($1);
    }
    | {$$ = mkTreenode(mkTreeNodeContent(aparams));}
;

;
%%
void yyerror (char const *s) {
    fprintf (stderr, "%s at line %d:", s, yylineno);
}


void printToken() {
    treenodecontent* node = (treenodecontent*)yylval->nodeContent;
    printf("(type=%d", node->lexType);
    switch(node->lexType){
        case INTNUMBER :
        case REALNUMBER :
            printf(", numVal=%s)\n", node->tokenStr);
            break;
        
        case ID :
            printf(", idName=%s)\n", node->tokenStr);
            break;
        
        case STRING :
            printf(", string=%s)\n", node->tokenStr);
            break;
            
        default : 
            printf(")\n");
            break;
    }
}

treenodecontent* mkTreeNodeContent(int typenum) {
    treenodecontent* ret = (treenodecontent*)malloc(sizeof(treenodecontent));
    ret->lexType = typenum;
    ret->nonTerminalStr = NonTerminalStr[typenum];
    ret->a.exprA.dataType = -1;
    ret->a.exprA.resIndex = NULL;
    return ret;
}

int main( int argc, char* argv[]) {
    if(argc < 2 || argc > 3) {
        printf("Usage:./a.out filename\n");
        return 1;
    }
    yyout = fopen("./interCode", "w");
    tokenOut = fopen("./tokenSeq", "w");
    treeOut = fopen("./syntaxTree", "w");
    tableOut = fopen("./symbolTable", "w");
    loadNonTerminalStr();
    yyin = fopen(argv[1], "r");
    root = (synTreenode*)malloc(sizeof(synTreenode));
    root->nodeContent = (treenodecontent*)malloc(sizeof(treenodecontent));
    root->nodeContent->lexType = 0;
    root->nodeContent->nonTerminalStr = NonTerminalStr[program];
    root->nodeContent->a.exprA.dataType = -1;
    root->son = NULL;
    root->brother = NULL;
    yyparse();
    printTree(root, 1);
    printTable();
    freeTree(root);
    freeTable();
    fclose(yyin);
}

