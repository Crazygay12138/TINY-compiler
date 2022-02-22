/*
enum tokentype{
    IF = 0, ELSE, WRITE, READ, RETURN, BGN, END, MAIN, INT, REAL,//keywords
    ID,//identifier
    NUMBER,//number
    STRING, COMMENT,
    SEMICOLON, COMMA, LEFTBRACKETS, RIGHTBRACKETS,// ;  ,  (  )
    PLUS, MINUS, MULTI, DIV,// +  -  *   /
    ASSIGN, EQUAL, NOTEQUAL,// :=  ==  !=
    WID
};
*/
#ifndef GLOBALSH
#define GLOBALSH
/*
char* type[26] = {
    "IF", "ELSE", "WRITE", "READ", "RETURN", "BGN", "END", "MAIN", "INT", "REAL",
    "ID",
    "NUMBER",
    "STRING", "COMMENT",
    "SEMICOLON", "COMMA", "LEFTBRACKETS", "RIGHTBRACKETS",
    "PLUS", "MINUS", "MULTI", "DIV",
    "ASSIGN", "EQUAL", "NOTEQUAL",
    "WID"
};
*/
enum NonTerminaltype{
    program = 0, method, formalparams, formalparam, type, block, statements, statement, localvardecl, assignstmt, returnstmt, ifstmt, writestmt, readstmt, expression, mexpression, pexpression, bexpressions, bexpression, aparams, whilestmt, constindexs, varindexs
};

#endif
