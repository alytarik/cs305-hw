%{
#include "hw3.h"
#include <stdio.h>
#include <string.h>
void yyerror (const char *s){
    s = "ERROR";
    printf ("%s\n", s);
}

ExprNode * expFromInt(IntNode);
ExprNode * expFromReal(RealNode);
ExprNode * expFromStr(StrNode);
ExprNode * sumExp(ExprNode*, ExprNode*);
%}


%union{
    IntNode intNode;
    RealNode realNode;
    StrNode strNode;
    ExprNode* exprNodePtr;
    int lineNum;
}

%token tGET tSET tFUNCTION tPRINT tIF tRETURN tADD tSUB tMUL tDIV tINC tGT tEQUALITY tDEC tLT tLEQ tGEQ tIDENT
%token <intNode> tNUM
%token <realNode> tREAL
%token <strNode> tSTRING

%type <exprNodePtr> expr

%%

stmt_list: '[' stmts ']';

stmts:
    | stmt
    | stmts stmt
;

stmt: '[' tSET ',' tIDENT ',' expr ']' 
    | '[' tIF ',' cond ','  stmt_list ']'
    | '[' tIF ',' cond ',' stmt_list stmt_list ']'
    | '[' tPRINT ',' expr ']'
    | '[' tINC ',' tIDENT ']'
    | '[' tDEC ',' tIDENT ']'
    | return
    | expr
;

cond: '[' tGEQ ',' expr ',' expr ']'
    | '[' tLEQ ',' expr ',' expr ']'
    | '[' tLT ',' expr ',' expr ']'
    | '[' tGT ',' expr ',' expr ']'
    | '[' tEQUALITY ',' expr ',' expr ']'
;

expr: tNUM {
        $$ = expFromInt($1);
	}
	| tREAL {
        $$ = expFromReal($1);
	}
    | tSTRING {
        $$ = expFromStr($1);
	}
    | '[' tGET ',' tIDENT ']'
    | '[' tGET ',' tIDENT ',' expr_list ']'
    | '[' tFUNCTION ',' param_list ',' stmt_list ']'
    | '[' tADD ',' expr ',' expr ']' {
        $$ = sumExp($4, $6);
    }
    | '[' tSUB ',' expr ',' expr ']'
    | '[' tMUL ',' expr ',' expr ']'
    | '[' tDIV ',' expr ',' expr ']'
    | cond
;

param_list: '[' params ']';
params: 
    | tIDENT
    | tIDENT ',' params
;

expr_list: '[' exprs ']';
exprs:
    | expr
    | expr ',' exprs
;

return: '[' tRETURN ']'
    | '[' tRETURN ',' expr']'
;
%%

ExprNode * expFromInt(IntNode n) {
    ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->lineNum = n.lineNum;
    newNode->valType = intType;
    newNode->val.i = n.val;
    return newNode;
}
ExprNode * expFromReal(RealNode n) {
    ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->lineNum = n.lineNum;
    newNode->valType = realType;
    newNode->val.r = n.val;
    return newNode;
}
ExprNode * expFromStr(StrNode n) {
    ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->lineNum = n.lineNum;
    newNode->valType = strType;
    newNode->val.s = (char *)malloc(strlen(n.val));
    strcpy(newNode->val.s, n.val);
    return newNode;
}
ExprNode * sumExp(ExprNode * n1, ExprNode * n2) {
    ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->lineNum = n1->lineNum;

    if(n1->valType == intType && n2->valType == intType) {
        newNode->valType = intType;
        newNode->val.i = n1->val.i + n2->val.i;
    }
    else if(n1->valType == realType && n2->valType == intType) {
        newNode->valType = realType;
        newNode->val.r = n1->val.r + n2->val.i;
    }
    else if(n1->valType == intType && n2->valType == realType) {
        newNode->valType = realType;
        newNode->val.r = n1->val.i + n2->val.r;
    }
    else if(n1->valType == realType && n2->valType == realType) {
        newNode->valType = realType;
        newNode->val.r = n1->val.r + n2->val.r;
    }
    else if(n1->valType == strType && n2->valType == strType) {
        newNode->valType = strType;
        newNode->val.s = malloc(strlen(n1->val.s));
        strcpy(newNode->val.s, n1->val.s);
        strcat(newNode->val.s, n2->val.s);
    }
    else {
        printf("Type mismatch on X\n");
    }
    return newNode;
}

int main () {
    if (yyparse()) {
        return 1;
    }
    else {
        printf("OK\n");
        return 0;
    }
}