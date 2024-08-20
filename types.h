// Pete Coutros
// CMSC 430 Compiler Theory and Design
// Project 4 Skeleton
// 5/3/23

// This file contains type definitions and the function
// prototypes for the type checking functions

// Several function prototypes added to meet the requirements

typedef char* CharPtr;

enum Types {MISMATCH, INT_TYPE, CHAR_TYPE, REAL_TYPE, NONE, ERROR};

void checkAssignment(Types lValue, Types rValue, string message);
void checkListAssignment(Types left, Types right);
void checkRelation(Types left, Types right);
Types checkWhen(Types true_, Types false_);
Types checkSwitch(Types case_, Types when, Types other);
Types checkCases(Types left, Types right);
Types checkIfElse(Types ifStatement, Types elsifStatement, Types elseStatement);
Types checkExpressions(Types left, Types right);
Types checkArithmetic(Types left, Types right);
Types checkIntSubscript(Types type);
Types checkNegation(Types type);
Types checkRemainderArithmetic(Types left, Types right);
Types checkList(Types type);
Types checkElsif(Types left, Types right);