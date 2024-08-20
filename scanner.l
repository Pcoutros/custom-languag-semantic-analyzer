/* Pete Coutros
   Project 4 - Semantic Analyzer
   5/3/24
   CMSC 430 Compiler Theory and Design

   MODIFIED by PETE COUTROS - additional lexemes and token names added (
   {comment2}, "-", "/", "%", "^", "~", "|", "!", "=", "<>", ">", ">=", 
   "<=", else, elsif, endfold, endif, fold, if, left, real, right, then,
   {hexadec}, and {reallit}.

   Some regular expressions modified/added (comment2 - added, id - modified,
   hexadec - added, reallit - added, char - modified)

   Note: The comment, id, hex, real, and char lexeme regular expressions were
   modified from Project 1 to the current state with the help of an email
   the professor sent with the correct regular expression definitions.
*/

/* This file contains flex input file */

%{
#include <cstdio>
#include <string>
#include <vector>

using namespace std;

#include "types.h"
#include "listing.h"
#include "tokens.h"

%}

%option noyywrap

ws		[ \t\r]+
comment		("//"|"--").*\n
line		[\n]
id		[A-Za-z](_?_?[A-Za-z0-9])*
digit		[0-9]
dec		{digit}+
hex		#[0-9a-fA-F]+
real		{digit}*"."{digit}+([eE][+-]?{digit}+)?
char		'.'|'\\[btnrf]'
punc		[\(\),:;]
%%

{ws}		{ ECHO; }
{comment}	{ ECHO; nextLine(); }
{line}		{ ECHO; nextLine(); }
"+"		{ ECHO; return(ADDOP); }
"-"		{ ECHO; return(ADDOP); }
"*"		{ ECHO; return(MULOP); }
"/"		{ ECHO; return(MULOP); }
"%"		{ ECHO; return(REMOP); }
"^"		{ ECHO; return(EXPOP); }
"~"		{ ECHO; return(NEGOP); }
"&"		{ ECHO; return(ANDOP); }
"|"		{ ECHO; return(OROP); }
"!"		{ ECHO; return(NOTOP); }
"<"		{ ECHO; return(RELOP); }
"="		{ ECHO; return(RELOP); }
"<>"		{ ECHO; return(RELOP); }
">"		{ ECHO; return(RELOP); }		
">="		{ ECHO; return(RELOP); }
"<="		{ ECHO; return(RELOP); }
"=>"		{ ECHO; return(ARROW); }
begin		{ ECHO; return(BEGIN_); }
case		{ ECHO; return(CASE); }
character	{ ECHO; return(CHARACTER); }
end		{ ECHO; return(END); }
endswitch	{ ECHO; return(ENDSWITCH); }
function	{ ECHO; return(FUNCTION); }
integer		{ ECHO; return(INTEGER); }
is		{ ECHO; return(IS); }
list		{ ECHO; return(LIST); }
of		{ ECHO; return(OF); }
others		{ ECHO; return(OTHERS); }
returns		{ ECHO; return(RETURNS); }
switch		{ ECHO; return(SWITCH); }
when		{ ECHO; return(WHEN); }
else		{ ECHO; return(ELSE); }
elsif		{ ECHO; return(ELSIF); }
endfold		{ ECHO; return(ENDFOLD); }
endif		{ ECHO; return(ENDIF); }
fold		{ ECHO; return(FOLD); }
if		{ ECHO; return(IF); }
left		{ ECHO; return(LEFT); }
real		{ ECHO; return(REAL); }
right		{ ECHO; return(RIGHT); }
then		{ ECHO; return(THEN); }

{id}		{ ECHO; yylval.iden = (CharPtr)malloc(yyleng + 1); 
			strcpy(yylval.iden, yytext); return(IDENTIFIER);}
{dec}		{ ECHO; yylval.type = INT_TYPE; return(INT_LITERAL); }
{hex}		{ ECHO; yylval.type = INT_TYPE; return(INT_LITERAL); }
{real}		{ ECHO; yylval.type = REAL_TYPE; return(REAL_LITERAL); }
{char}		{ ECHO; yylval.type = CHAR_TYPE; return(CHAR_LITERAL); }
{punc}		{ ECHO; return(yytext[0]); }
.		{ ECHO; appendError(LEXICAL, yytext); }
%%

