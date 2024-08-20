/* Pete Coutros
   Project 4 - Semantic Analyzer
   5/3/24
   CMSC 430 Compiler Theory and Design

   Project 2 Parser 

   Tokens from project 1 "tokens.h" file added in the definitions section.
   Grammars expanded on to include all syntactic additions/changes in the requirements.
   Error recovery added to grammars per the requirements.

   Project 4 skeleton added to this code

   Additional Semantic actions added to productions to fulfill the requirements of the project

   token and type attributes added to terminals and non terminals respectively

*/

%{

#include <string>
#include <vector>
#include <map>

using namespace std;

#include "types.h"
#include "listing.h"
#include "symbols.h"

int yylex();
Types find(Symbols<Types>& table, CharPtr identifier, string tableName);
int checkDuplicate(Symbols<Types>& table, string tableName, CharPtr identifier);
void yyerror(const char* message);

Symbols<Types> scalars;
Symbols<Types> lists;

%}

%define parse.error verbose

%union {
	CharPtr iden;
	Types type;
}

%token <iden> IDENTIFIER 

%token <type> INT_LITERAL CHAR_LITERAL REAL_LITERAL

%token ADDOP MULOP ANDOP RELOP ARROW OROP NOTOP REMOP EXPOP NEGOP

%token BEGIN_ CASE CHARACTER ELSE END ENDSWITCH FUNCTION INTEGER IS LIST OF OTHERS
	RETURNS SWITCH WHEN ELSIF ENDFOLD ENDIF FOLD IF LEFT REAL RIGHT THEN

%type <type> list expressions body type statement_ statement cases case expression
	term primary secondary elsifs elsif list_choice function function_header

%%

function:	
	function_header optional_variables body {checkAssignment($1, $3, "Function Return");};

function_header:	
	FUNCTION IDENTIFIER optional_parameters RETURNS type ';' {$$ = $5;}|
	error ';' {$$ = MISMATCH;} ;

optional_parameters:
	parameters | 
	%empty;

parameters:
	parameters ',' parameter |
	parameter ;

parameter:
	IDENTIFIER ':' type ;

type:
	INTEGER {$$ = INT_TYPE;} |
	REAL {$$ = REAL_TYPE;} |
	CHARACTER {$$ = CHAR_TYPE;} ;
	
optional_variables:
	optional_variables optional_variable |
	%empty ;
 
optional_variable:
	variable ;
    
variable:	
	IDENTIFIER ':' type IS statement ';' {checkAssignment($3, $5, "Variable Initialization"); if(checkDuplicate(scalars, "Scalar", $1) == 0) {scalars.insert($1, $3);}}|
	IDENTIFIER ':' LIST OF type IS list ';' {checkListAssignment($5, $7); if(checkDuplicate(lists, "List", $1) == 0) {lists.insert($1, $5);}} |
	error ';' ;

list:
	'(' expressions ')' {$$ = $2;} ;

expressions:
	expressions ',' expression {$$ = checkExpressions($1, $3);} | 
	expression ;

body:
	BEGIN_ statement_ END ';' {$$ = $2;} ;

statement_:
	statement ';' {$$ = $1;} |
	error ';' {$$ = MISMATCH;} ;
    
statement:
	expression {$$ = $1;} |
	WHEN condition ',' expression ':' expression {$$ = checkWhen($4, $6);} |
	SWITCH expression IS cases OTHERS ARROW statement_ ENDSWITCH {$$ = checkSwitch($2, $4, $7);} |
	IF condition THEN statement_ elsifs ELSE statement_ ENDIF {$$ = checkIfElse($4, $5, $7);} |
	FOLD direction operator list_choice ENDFOLD {$$ = checkList($4);} ;

direction:
	LEFT |
	RIGHT ;

operator:
	ADDOP |
	MULOP ;

list_choice:
	list {$$ = $1;} |
	IDENTIFIER {$$ = find(lists, $1, "List");} ;

elsifs:
	elsifs elsif {$$ = checkElsif($1, $2);} |
	%empty {$$ = NONE;} ;

elsif:
	ELSIF condition THEN statement ';' {$$ = $4;} ;

cases:
	cases case {$$ = checkCases($1, $2);} |
	%empty {$$ = NONE;} ;
	
case:
	CASE INT_LITERAL ARROW statement ';' {$$ = $4;} |
	error ';' {$$ = MISMATCH;}; 

condition:
	condition OROP relation_tertiary |
	relation_tertiary ;

relation_tertiary:
	relation_tertiary ANDOP relation_secondary |
	relation_secondary ;

relation_secondary:
	NOTOP relation |
	relation ;

relation:
	'(' condition ')' |
	expression RELOP expression {checkRelation($1, $3);} ;

expression:
	expression ADDOP term {$$ = checkArithmetic($1, $3);} |
	term ;
      
term:
	term MULOP secondary {$$ = checkArithmetic($1, $3);} |
	term REMOP secondary {$$ = checkRemainderArithmetic($1, $3);} |
	secondary ;

secondary:
	primary EXPOP secondary {$$ = checkArithmetic($1, $3);} |
	primary;

primary:
	'(' expression ')' {$$ = $2;} |
	NEGOP primary {$$ = checkNegation($2);} |
	INT_LITERAL |
	CHAR_LITERAL |	REAL_LITERAL | 	
	IDENTIFIER '(' expression ')' {if(checkIntSubscript($3) != MISMATCH){$$ = find(lists, $1, "List");}else{$$ = MISMATCH;}} |
	IDENTIFIER {$$ = find(scalars, $1, "Scalar");} ;

%%


Types find(Symbols<Types>& table, CharPtr identifier, string tableName) {
	Types type;
	if (!table.find(identifier, type)) {
		appendError(UNDECLARED, tableName + " " + identifier);
		return MISMATCH;
	}
	return type;
}

// ADDED by PETE COUTROS - check if identifier is already initialized
int checkDuplicate(Symbols<Types>& table, string tableName, CharPtr identifier) {
	Types type;
	if (table.find(identifier, type)) {
		appendError(GENERAL_SEMANTIC, "Duplicate " + tableName + " " + identifier);
		return 1;
	}
	return 0;
}

void yyerror(const char* message) {
	appendError(SYNTAX, message);
}

int main(int argc, char *argv[]) {
	firstLine();
	yyparse();
	lastLine();
	return 0;
} 
