#ifndef __HW3_H
#define __HW3_H

// typedef enum Operation {add, sub, mul, dvs}; 
enum ValType {intType, realType, strType, typeMismatch, notConst}; 
typedef enum ValType ValType;

typedef union Value
{
    int i;
    float r;
    char* s;
} Value;

typedef struct ExprNode
{
   Value val;
   ValType valType;
   int linenum;
   char print;
} ExprNode;

#endif