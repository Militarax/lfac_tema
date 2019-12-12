%{
#include <stdio.h>
extern FILE* yyin;
extern int yylineno;
%}
%token ID TYPE MAIN LET FLOAT DIM BGIN END CONST TRUE FALSE USERTYPE VARS FUNCTIONS ASSIGN INTNUMBER FLOATNUMBER STRING AND NOT OR LEQ EQ NEQ GE GEQ MOD DIV CHAR CALL BREAK IMPORT IF ELSE ELSEIF FOR WHILE
%left AND
%left OR
%left NOT
%left DIV
%left MOD
%left '*'
%left '/'
%left '+'
%left '-'
%left NEQ
%left EQ
%left LEQ
%left LE
%left GE
%left GEQ
%left ASSIGN
%start s
%%
s 	:	import userdeftypes constants declaration_vars main 	{printf("works!\n");}
	;
import	: import IMPORT STRING
		|
		;
userdeftypes : userdeftypes USERTYPE ID BGIN object END
			 |
			 ;
object	:	VARS ':' data FUNCTIONS ':' functions
		|	VARS ':' data
		|	FUNCTIONS ':' functions
		;
data 	:	userdeftypes declaration_vars
		;
functions 	:	def_function
			| 	functions def_function
			;
def_function 	:	ID '(' list_def ')' ';'
				;
list_def	:	TYPE ID
			|	list_def ',' TYPE ID
			|	
			;
function 	:	ID '(' list_call ')'
			|	ID '('')'
			;
list_call	:	expression
			|	list_call ',' expression
			;

object_method_call	:	ID '.' function
					|	object_method_call '.' ID '.' function
					;
object_var	:	ID '.' ID
expression	:	TRUE						{printf("e->TRUE\n");}
		  	|	FALSE						{printf("e->FALSE\n");}
		   	|	number						{printf("e->number\n");}
		   	|	STRING						{printf("e->string\n");}
		   	|	ID 							{printf("e->ID\n");}
		   	|	ID DIM 						{printf("e->ARR\n");}
		   	|	CHAR 						{printf("e->CHAR\n");}
		   	|	function 					{printf("function\n");}
		   	|	object_method_call			{printf("object_method\n");}
		   	|	object_var					{printf("object_var\n");}
		   	|	expression '+' expression	{printf("e->e+e\n");}
		   	|	expression '-' expression	{printf("e->e-e\n");}
		   	|	expression '*' expression	{printf("e->e*e\n");}
		   	|	expression '/' expression	{printf("e->e/e\n");}
		    |	expression DIV expression	{printf("e->e//e\n");}
		   	| 	expression MOD expression	{printf("e->e mod e\n");}
		   	|	expression NEQ expression	{printf("e->e!=e\n");}
		   	|	expression EQ expression	{printf("e->e==e\n");}
		   	|	expression AND expression	{printf("e->e and e\n");}
		   	|	expression OR expression	{printf("e->e or e\n");}
		   	|	NOT expression				{printf("e->not e\n");}
		   	|	expression LEQ expression	{printf("e->e <= e\n");}
		   	|	expression LE expression	{printf("e->e < e\n");}
		   	|	expression GEQ expression	{printf("e->e => e\n");}
		   	|	expression GE expression	{printf("e->e > e\n");}
		   	|	'(' expression ')'			{printf("e->(e)\n");}
		   	|	expression ASSIGN expression {printf("ASSIGN");}
		   	;


number	:	INTNUMBER
		|	FLOATNUMBER
		;
constants :	constants constant
		  |
		  ;

constant :	CONST '(' TYPE ')' var ';'
		 ;

declaration_vars	:	line_of_vars
					|	declaration_vars line_of_vars
line_of_vars	:	LET '(' TYPE ')' var ';'
				;
var 	:	ID
		|	ID DIM
		|	var ',' ID
		|	var ',' ID DIM
		| 	ID ASSIGN expression
		|	ID DIM ASSIGN expression
		|	var ',' ID ASSIGN expression
		|	var ',' ID DIM ASSIGN expression
		;
main 	: BGIN content END
		;	
content	:	content statement
		|
		;
statement	:	ifstatement
			|	forstatement
			|	whilestatement
			|	expression ';'
			|	BREAK ';'
			;
ifstatement	:	ifbegin elsenotf elsef
			;
ifbegin		:	IF '('expression')' BGIN content END
			;
elsef 		:	ELSE BGIN content END
			|
			;
elsenotf 	:	elsenotf ELSEIF '(' expression ')' BGIN content END
			|
			;
forstatement	:	FOR '(' var ';' expression ';' expression ')' BGIN content END
				;
whilestatement	:	WHILE '(' expression ')' BGIN content END
				;
%% 

int yyerror(char * s){
 printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
 yyin=fopen(argv[1], "r");
 yyparse();
} 