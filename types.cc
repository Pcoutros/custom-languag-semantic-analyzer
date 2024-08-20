// Pete Coutros
// CMSC 430 Compiler Theory and Design
// Project 4 Skeleton
// 5/3/23

// This file contains the bodies of the type checking functions
// In addition to modifying existing functions of this file
// Several additional functions were added to assist the semantic actions of the productions

#include <string>
#include <vector>

using namespace std;

#include "types.h"
#include "listing.h"

void checkAssignment(Types lValue, Types rValue, string message) {
	if ((lValue != MISMATCH && lValue != ERROR) && (rValue != MISMATCH && rValue != ERROR) && lValue != rValue) {
		if (lValue == INT_TYPE && rValue == REAL_TYPE) {						// Check if narrowing from int declaration to real type
			appendError(GENERAL_SEMANTIC, "Illegal Narrowing " + message);
		} else {
			appendError(GENERAL_SEMANTIC, "Type Mismatch on " + message);
		}
	}
}

// ADDED by PETE COUTROS - Check if list type is same as element type
void checkListAssignment(Types left, Types right) {
	if (left != MISMATCH && right != MISMATCH && left != right) {
		appendError(GENERAL_SEMANTIC, "List Type Does Not Match Element Types");
	}
}

// ADDED by PETE COUTROS - Check if characters are compared to numbers
void checkRelation(Types left, Types right) {
	if ((left == CHAR_TYPE && (right == INT_TYPE || right == REAL_TYPE)) || (right == CHAR_TYPE && (left == INT_TYPE || left == REAL_TYPE))) {
		appendError(GENERAL_SEMANTIC, "Character Literals Cannot be Compared to Numeric Expressions");
	}
}

// ADDED by PETE COUTROS - Check that list subscript is an int
Types checkIntSubscript(Types type) {
	if(type != INT_TYPE) {
		appendError(GENERAL_SEMANTIC, "List Subscript Must Be Integer");
		return MISMATCH;
	}
	return type;
}

Types checkWhen(Types true_, Types false_) {
	if (true_ == MISMATCH || false_ == MISMATCH) {
		return MISMATCH;
	}
	if (true_ != false_) {
		appendError(GENERAL_SEMANTIC, "When Types Mismatch ");
		return ERROR;	// New Types ERROR used to differentiate an error in type matching from a mismatch in branches
	}
	return true_;
}

Types checkSwitch(Types case_, Types when, Types other) {
	if (case_ != INT_TYPE) {
		appendError(GENERAL_SEMANTIC, "Switch Expression Not Integer");
		return ERROR; // New Types ERROR used to differentiate between type matching and non integer switch expression
	}
	return checkCases(when, other);
}

Types checkCases(Types left, Types right) {
	if (left == MISMATCH || right == MISMATCH) {
		return MISMATCH;
	}
	if (left == NONE || left == right) {
		return right;
	}
	appendError(GENERAL_SEMANTIC, "Case Types Mismatch");
	return MISMATCH;
}

// ADDED by PETE COUTROS - check types of if-elsif-else
Types checkIfElse(Types ifStatement, Types elsifStatement, Types elseStatement) {
	//printf("\n\t\t%u\n", ifStatement);
	//printf("\n\t\t%u\n", elsifStatement);
	//printf("\n\t\t%u\n", elseStatement);
	if (ifStatement == MISMATCH || elseStatement == MISMATCH) {
		// appendError(GENERAL_SEMANTIC, "If-Elsif-Else Type Mismatch");
		return MISMATCH;
	}
	if (elsifStatement != NONE && elsifStatement != ERROR) {
		if (elsifStatement != ifStatement || elseStatement != ifStatement || elsifStatement != elseStatement || elsifStatement == MISMATCH) {
			appendError(GENERAL_SEMANTIC, "If-Elsif-Else Type Mismatch");
			return MISMATCH;
		}
	} 
	if (elsifStatement == ERROR) {
			return MISMATCH;
	}else {
		if (elseStatement != ifStatement) {
			appendError(GENERAL_SEMANTIC, "If-Elsif-Else Type Mismatch");
			return MISMATCH;
		}
	}
	return ifStatement;
}

// ADDED by PETE COUTROS - check types of elsifs
Types checkElsif(Types left, Types right) {
	//printf("\n%u\n", left);
	//printf("\n%u\n", right);
	if (left == right){
		return right;
	}
	if (left == MISMATCH && right == ERROR) {
		return ERROR;		// New Types ERROR used to differentiate an error in type matching from a mismatch in branches
	}
	if (right == MISMATCH || left == ERROR) {
		return ERROR;		// New Types ERROR used to differentiate an error in type matching from a mismatch in branches
	}
	if (left == NONE) {
		return right;
	}
	return MISMATCH;	
}

// ADDED by PETE COUTROS - check if expression types are the same for lists
Types checkExpressions(Types left, Types right) {
	if (left == MISMATCH || right == MISMATCH) {
		return MISMATCH;
	}
	if (left == right) {
		return right;
	}
	//if ((left == INT_TYPE && right == REAL_TYPE) || (left == REAL_TYPE && right == INT_TYPE))
	//	appendError(GENERAL_SEMANTIC, "List Element Types Do Not Match");
	//	return REAL_TYPE;
	appendError(GENERAL_SEMANTIC, "List Element Types Do Not Match");
	return MISMATCH;
}

Types checkArithmetic(Types left, Types right) {
	if (left == MISMATCH || right == MISMATCH) {
		return MISMATCH;
	}
	if (left == INT_TYPE && right == INT_TYPE) {
		return INT_TYPE;
	}
	if (left == REAL_TYPE && right == REAL_TYPE) {
		return REAL_TYPE;
	}
	// ADDED by PETE COUTROS - coerce to real if one is real and other int 
	if ((left == INT_TYPE && right == REAL_TYPE) || (left == REAL_TYPE && right == INT_TYPE)){
		return REAL_TYPE;
	}
	//appendError(GENERAL_SEMANTIC, "Integer Type Required"); -- commented out for step 8
	appendError(GENERAL_SEMANTIC, "Arithmetic Operator Requires Numeric Types"); // Added to match step 8
	return MISMATCH;
}

// ADDED by PETE COUTROS -  Check if remainder operands are both integers
Types checkRemainderArithmetic(Types left, Types right) {
	if (left == INT_TYPE && right == INT_TYPE) {
		return INT_TYPE;
	}
	appendError(GENERAL_SEMANTIC, "Remainder Operator Requires Integer Operands"); 
	return MISMATCH;
}

// ADDED by PETE COUTROS - Check if negation operand is numeric 
Types checkNegation(Types type) {
	if (type != INT_TYPE && type != REAL_TYPE) {
		appendError(GENERAL_SEMANTIC, "Arithmetic Operator Requires Numeric Types");
		return MISMATCH;
	}
	return type;
}

// ADDED by PETE COUTROS - Check if the list is an integer type
Types checkList(Types type) {
	if (type == MISMATCH) {
		return MISMATCH;	// No error reporting as it would have already been reported
	}
	if (type != INT_TYPE && type != REAL_TYPE) {
		appendError(GENERAL_SEMANTIC, "Fold Requires A Numeric List");
		return MISMATCH;
	}
	return type;
}
