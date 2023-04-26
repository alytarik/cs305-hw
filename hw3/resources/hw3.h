#ifndef __HW3_H
#define __HW3_H

// typedef enum Operation {add, sub, mul, dvs}; 
enum ValType {intType, realType, strType}; 
typedef enum ValType ValType;

typedef struct IntNode
{
    int val;
    int lineNum;
} IntNode;

typedef struct RealNode
{
    float val;
    int lineNum;
} RealNode;

typedef struct StrNode
{
    char* val;
    int lineNum;
} StrNode;

typedef union Value
{
    int i;
    float r;
    char* s;
} ValNode;

typedef struct ExprNode
{
   ValNode val;
   ValType valType;
   int lineNum;
} ExprNode;

#endif