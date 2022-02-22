%{
//#include "globals.h"
#include "treenodecontent.h"
#include "SyntaxTree.h"
#define YYSTYPE synTreenode*
#include "grammer.tab.h"
#include <stdio.h>
#include <stdlib.h>
extern void printToken();
extern void loadYylval();
extern void printTable();
extern void yyerror(char const*);
FILE* tokenOut;
%}

%option yylineno

delim   [ \t\n]
ws      {delim}+
letter  [A-Za-z]
digit   [0-9]
id      {letter}({letter}|{digit})*
wrongid {digits}{letter}+
digits  {digit}+
integernumber  [-]*{digits}
realnumber  [-]*{digits}\.{digits}
string  \".*\"
comment "/**"([^*/]|[*]*[^/]*)*"**/"

%%

{ws}                {/*do nothing*/}
"IF"                {loadYylval(IF);return IF;}
"ELSE"              {loadYylval(ELSE);return ELSE;}
"WHILE"             {loadYylval(WHILE);return WHILE;}
"WRITE"             {loadYylval(WRITE);return WRITE;}
"READ"              {loadYylval(READ);return READ;}
"RETURN"            {loadYylval(RETURN);return RETURN;}
"BEGIN"             {loadYylval(BGN);return BGN;}
"END"               {loadYylval(END);return END;}
"MAIN"              {loadYylval(MAIN);return MAIN;}
"INT"               {loadYylval(INT);return INT;}
"REAL"              {loadYylval(REAL);return REAL;}
{id}                {loadYylval(ID);return ID;}
{integernumber}     {loadYylval(INTNUMBER);return INTNUMBER;}
{realnumber}        {loadYylval(REALNUMBER);return REALNUMBER;}
{wrongid}           {yyerror("error");fprintf(stderr, "Invalid identifier name : %s\n", yytext);loadYylval(WID);return WID;}
{string}            {loadYylval(STRING);return STRING;}
{comment}           {}
";"                 {loadYylval(SEMICOLON);return SEMICOLON;}
","                 {loadYylval(COMMA);return COMMA;}
"("                 {loadYylval(LEFTBRACKETS);return LEFTBRACKETS;}
")"                 {loadYylval(RIGHTBRACKETS);return RIGHTBRACKETS;}
"["                 {loadYylval(LEFTSQUAREBRACKETS);return LEFTSQUAREBRACKETS;}
"]"                 {loadYylval(RIGHTSQUAREBRACKETS);return RIGHTSQUAREBRACKETS;}
"+"                 {loadYylval(PLUS);return PLUS;}
"-"                 {loadYylval(MINUS);return MINUS;}
"*"                 {loadYylval(MULTI);return MULTI;}
"/"                 {loadYylval(DIV);return DIV;}
":="                {loadYylval(ASSIGN);return ASSIGN;}
"=="                {loadYylval(EQUAL);return EQUAL;}
"!="                {loadYylval(NOTEQUAL);return NOTEQUAL;}
">"                 {loadYylval(GT);return GT;}
"<"                 {loadYylval(LT);return LT;}
">="                {loadYylval(GE);return GE;}
"<="                {loadYylval(LE);return LE;}
"&&"                {loadYylval(AND);return AND;}
"||"                {loadYylval(OR);return OR;}

%%

void loadYylval(int typenum) {
    treenodecontent* lexUnit = (treenodecontent*)malloc(sizeof(treenodecontent));
    lexUnit->lexType = typenum;
    lexUnit->tokenStr = (char*)malloc(sizeof(char) * (strlen(yytext) + 1));
    strcpy(lexUnit->tokenStr, yytext);
    lexUnit->a.exprA.dataType = -1;
    lexUnit->a.exprA.resIndex = NULL;
    yylval = mkTreenode(lexUnit);
    fprintf(tokenOut, "(token = %s, type = %d)\n", yytext, typenum);
}

