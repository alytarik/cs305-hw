%{
#include <stdio.h>
void yyerror (const char *s){
    s = "ERROR";
    printf ("%s\n", s);
}
%}

%token tSTRING tGET tSET tFUNCTION tPRINT tIF tRETURN tADD tSUB tMUL tDIV tINC tGT tEQUALITY tDEC tLT tLEQ tGEQ tIDENT tNUM
%%

stmt_list: '[' stmts ']';

stmts:
    | stmt
    | stmts stmt
;

stmt: '[' tSET ',' tIDENT ',' exp ']' 
    | '[' tIF ',' cond ','  stmt_list ']'
    | '[' tIF ',' cond ',' stmt_list stmt_list ']'
    | '[' tPRINT ',' exp ']'
    | '[' tINC ',' tIDENT ']'
    | '[' tDEC ',' tIDENT ']'
    | return
    | exp
;

cond: '[' tGEQ ',' exp ',' exp ']'
    | '[' tLEQ ',' exp ',' exp ']'
    | '[' tLT ',' exp ',' exp ']'
    | '[' tGT ',' exp ',' exp ']'
    | '[' tEQUALITY ',' exp ',' exp ']'
;

exp: tNUM
    | tSTRING
    | '[' tGET ',' tIDENT ']'
    | '[' tGET ',' tIDENT ',' exp_list ']'
    | '[' tFUNCTION ',' param_list ',' stmt_list ']'
    | '[' tADD ',' exp ',' exp ']'
    | '[' tSUB ',' exp ',' exp ']'
    | '[' tMUL ',' exp ',' exp ']'
    | '[' tDIV ',' exp ',' exp ']'
    | cond
;


param_list: '[' params ']';
params: 
    | tIDENT
    | tIDENT ',' params
;

exp_list: '[' exps ']';
exps:
    | exp
    | exp ',' exps
;

return: '[' tRETURN ']'
    | '[' tRETURN ',' exp']'
;
%%

int main () {
    if (yyparse()) {
        return 1;
    }
    else {
        printf("OK\n");
        return 0;
    }
}