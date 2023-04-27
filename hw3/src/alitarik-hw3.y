%{
#include "hw3.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void yyerror (const char *s){
    s = "ERROR";
    printf ("%s\n", s);
}
int yylex();

ExprNode * expFromInt(Value);
ExprNode * expFromReal(Value);
ExprNode * expFromStr(Value);
ExprNode * defaultExp();
ExprNode * sumExp(int, ExprNode*, ExprNode*);
ExprNode * subExp(int, ExprNode*, ExprNode*);
ExprNode * multExp(int, ExprNode*, ExprNode*);
ExprNode * divExp(int, ExprNode*, ExprNode*);

ExprNode ** expressions;
int expressionsSize = 1024;
int exprIndex = 0;

ExprNode* addExpressionToList(ExprNode * newExpr){
    if(exprIndex < expressionsSize)
        expressions[exprIndex++] = newExpr;
    else{
        expressionsSize = expressionsSize + expressionsSize;
        expressions = realloc(expressions, expressionsSize);
        expressions[exprIndex++] = newExpr;
    }
}

ExprNode* addExpressionToListBefore(ExprNode * newExpr, ExprNode * addBefore){
    if(!addBefore)return addExpressionToList(newExpr);
    int i = exprIndex++;
    while(expressions[i--] != addBefore)
        expressions[i] = expressions[i - 1];
    expressions[i] = newExpr;
}

%}


%union{
    Value val;
    ExprNode* exprNodePtr;
    int linenum;
}

%token <linenum> tGET tSET tFUNCTION tPRINT tIF tRETURN tADD tSUB tMUL tDIV tINC tGT tEQUALITY tDEC tLT tLEQ tGEQ tIDENT
%token <val> tNUM tREAL tSTRING

%type <exprNodePtr> expr

%%

stmt_list: '[' stmts ']';

stmts:
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
        $$ = addExpressionToList(expFromInt($1));
	}
	| tREAL {
        $$ = addExpressionToList(expFromReal($1));
	}
    | tSTRING {
        $$ = addExpressionToList(expFromStr($1));
	}
    | '[' tGET ',' tIDENT ']' {$$ = addExpressionToList(defaultExp());}
    | '[' tGET ',' tIDENT ',' expr_list ']' {$$ = addExpressionToList(defaultExp());}
    | '[' tFUNCTION ',' param_list ',' stmt_list ']' {$$ = addExpressionToList(defaultExp());}
    | '[' tADD ',' expr ',' expr ']' {$$ = addExpressionToListBefore(sumExp($2, $4, $6), $4);}
    | '[' tSUB ',' expr ',' expr ']' {$$ = addExpressionToListBefore(subExp($2, $4, $6), $4);}
    | '[' tMUL ',' expr ',' expr ']' {$$ = addExpressionToListBefore(multExp($2, $4, $6), $4);}
    | '[' tDIV ',' expr ',' expr ']' {$$ = addExpressionToListBefore(divExp($2, $4, $6), $4);}
    | cond {$$ = addExpressionToList(defaultExp());}
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
ExprNode * defaultExp() {
    ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->valType = notConst;
    return newNode;
}
ExprNode * expFromInt(Value v) {
    ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->print = 0;
    newNode->valType = intType;
    newNode->val.i = v.i;
    return newNode;
}
ExprNode * expFromReal(Value v) {
    ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->print = 0;
    newNode->valType = realType;
    newNode->val.r = v.r;
    return newNode;
}
ExprNode * expFromStr(Value v) {
    ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->print = 0;
    newNode->valType = strType;
    newNode->val.s = (char *)malloc(strlen(v.s));
    strcpy(newNode->val.s, v.s);
    return newNode;
}
ExprNode * sumExp(int linenum, ExprNode * n1, ExprNode * n2) {
    ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    
    newNode->print = 1;
    newNode->linenum = linenum;
    if(!n1 || !n2 || n1->valType == notConst || n2->valType == notConst) return NULL; 
    if(n1->valType == intType && n2->valType == intType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = intType;
        newNode->val.i = n1->val.i + n2->val.i;
    }
    else if(n1->valType == realType && n2->valType == intType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = realType;
        newNode->val.r = n1->val.r + n2->val.i;
    }
    else if(n1->valType == intType && n2->valType == realType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = realType;
        newNode->val.r = n1->val.i + n2->val.r;
    }
    else if(n1->valType == realType && n2->valType == realType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = realType;
        newNode->val.r = n1->val.r + n2->val.r;
    }
    else if(n1->valType == strType && n2->valType == strType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = strType;
        newNode->val.s = malloc(strlen(n1->val.s) + strlen(n2->val.s));
        strcpy(newNode->val.s, n1->val.s);
        strcat(newNode->val.s, n2->val.s);
    }
    else {
        newNode->valType = typeMismatch;
        if(n1->valType == typeMismatch || n2->valType == typeMismatch) newNode->print = 0;
    }
    return newNode;
}

ExprNode * subExp(int linenum, ExprNode * n1, ExprNode * n2) {
    ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->print = 1;
    newNode->linenum = linenum;
    if(!n1 || !n2 || n1->valType == notConst || n2->valType == notConst) return NULL; 
    if(n1->valType == intType && n2->valType == intType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = intType;
        newNode->val.i = n1->val.i - n2->val.i;
    }
    else if(n1->valType == realType && n2->valType == intType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = realType;
        newNode->val.r = n1->val.r - n2->val.i;
    }
    else if(n1->valType == intType && n2->valType == realType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = realType;
        newNode->val.r = n1->val.i - n2->val.r;
    }
    else if(n1->valType == realType && n2->valType == realType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = realType;
        newNode->val.r = n1->val.r - n2->val.r;
    }
    else {
        newNode->valType = typeMismatch;
        if(n1->valType == typeMismatch || n2->valType == typeMismatch) newNode->print = 0;
    }
    return newNode;
}
ExprNode * multExp(int linenum, ExprNode * n1, ExprNode * n2) {
    ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->print = 1;
    newNode->linenum = linenum;
    if(!n1 || !n2 || n1->valType == notConst || n2->valType == notConst) return NULL; 
    if(n1->valType == intType && n2->valType == intType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = intType;
        newNode->val.i = n1->val.i * n2->val.i;
    }
    else if(n1->valType == realType && n2->valType == intType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = realType;
        newNode->val.r = n1->val.r * n2->val.i;
    }
    else if(n1->valType == intType && n2->valType == realType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = realType;
        newNode->val.r = n1->val.i * n2->val.r;
    }
    else if(n1->valType == realType && n2->valType == realType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = realType;
        newNode->val.r = n1->val.r * n2->val.r;
    }
    else if(n1->valType == intType && n2->valType == strType) {
        if(n1->val.i < 0) {
            newNode->valType = typeMismatch;
            return newNode;
        }

        n1->print = 0;
        n2->print = 0;
        newNode->valType = strType;

        int count = n1->val.i;
        if(count == 0) {
            newNode->val.s = malloc(sizeof(char));
            *newNode->val.s = '\0';
        }
        else {
            char *res = malloc (strlen(n2->val.s) * count);
            strcpy (res, n2->val.s);
            while (--count > 0)
                strcat (res, n2->val.s);
            newNode->val.s = res;
        }
    }
    else {
        newNode->valType = typeMismatch;
        if(n1->valType == typeMismatch || n2->valType == typeMismatch) newNode->print = 0;
    }
    return newNode;
}
ExprNode * divExp(int linenum, ExprNode * n1, ExprNode * n2) {
    ExprNode * newNode = (ExprNode *)malloc(sizeof(ExprNode));
    newNode->print = 1;
    newNode->linenum = linenum;
    if(!n1 || !n2 || n1->valType == notConst || n2->valType == notConst) return NULL; 
    if(n1->valType == intType && n2->valType == intType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = intType;
        newNode->val.i = n1->val.i / n2->val.i;
    }
    else if(n1->valType == realType && n2->valType == intType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = realType;
        newNode->val.r = n1->val.r / n2->val.i;
    }
    else if(n1->valType == intType && n2->valType == realType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = realType;
        newNode->val.r = n1->val.i / n2->val.r;
    }
    else if(n1->valType == realType && n2->valType == realType) {
        n1->print = 0;
        n2->print = 0;
        newNode->valType = realType;
        newNode->val.r = n1->val.r / n2->val.r;
    }
    else {
        newNode->valType = typeMismatch;
        if(n1->valType == typeMismatch || n2->valType == typeMismatch) newNode->print = 0;
    }
    return newNode;
}


int main () {
    expressions = (ExprNode**)malloc(expressionsSize * sizeof(ExprNode*));

    if (yyparse()) {
        return 1;
    }
    else {
        int i = 0;
        for(;i<exprIndex;i++){
            if(!expressions[i] || !expressions[i]->print) continue;
            if(expressions[i]->valType == intType)
                printf("Result of expression on %d is (%d)\n", expressions[i]->linenum, expressions[i]->val.i);
            if(expressions[i]->valType == realType)
                printf("Result of expression on %d is (%0.1f)\n", expressions[i]->linenum, expressions[i]->val.r);
            if(expressions[i]->valType == strType)
                printf("Result of expression on %d is (%s)\n", expressions[i]->linenum, expressions[i]->val.s);
            if(expressions[i]->valType == typeMismatch)
                printf("Type mismatch on %d\n", expressions[i]->linenum);
        }
        return 0;
    }
}