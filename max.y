%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "max.h"
extern FILE* yyin;
extern int yylineno;
int yyerror(char *s);
extern int yylex();

char debug = 0;
char toFile = 1;

char* tmp[100];
int tmpCount = 0;
struct node* tmpParam;
int insideObject = 0;
int currentConstant = 0;
char currentScope[100];


int getIntType(char* type)
{
	int result = 0;
	if( strcmp(type, "int") == 0)
		result = 3;
	else if(strcmp(type, "boolean") == 0)
		result = 3;
	else if(strcmp(type, "char") == 0)
		result = 2;
	else if(strcmp(type, "float") == 0)
		result = 4;
	else if(strcmp(type, "string") == 0)
		result = 5;
	else result = 6;
	free(type);
	return result;
}

void addToParam(int type)
{
	struct node* lastNode = tmpParam;
	if (lastNode->type != 0)
	{
		while(lastNode->next)
			lastNode = lastNode->next;
		lastNode->next = (struct node*)malloc(sizeof(struct node));
		lastNode = lastNode->next;
	}
	lastNode->type = type;
}

struct symbolTable
{
	struct basicEntry* varBegin;
	struct basicEntry* varEnd;
	struct functionEntry* functionBegin;
	struct functionEntry* functionEnd;
};

struct symbolTable globalTable;


struct basicEntry* getCleanBasicEntry()
{
	struct basicEntry* result = (struct basicEntry*)malloc(sizeof(struct basicEntry));
	strcpy(result->name, "");
	strcpy(result->scope, "");
	result->boolvalue = 0;
	result->charvalue = '\0';
	result->intvalue = 0;
	result->floatvalue = 0;
	result->strvalue = NULL;
	result->isConstant = 0;
	result->isDefined = 0;
	result->type = 0;
	result->dimension = 0;
	result->next = NULL;
	return result;	
}

struct functionEntry* getCleanFunctionEntry()
{
	struct functionEntry* result = (struct functionEntry*)malloc(sizeof(struct functionEntry));
	strcpy(result->name, "");
	strcpy(result->scope, "");
	result->signature = NULL;
	result->type = 0;
	result->next = NULL;
}

int sameSignature(struct node* signature1, struct node* signature2)
{
	struct node* it1 = signature1;
	struct node* it2 = signature2;
	while (it1 && it2)
	{
		// printf("VERIFICAM %d si %d\n", it1->type, it2->type);
		if (it1->type != it2->type)
			return 0;

		it1 = it1->next;
		it2 = it2->next;
	}
	if ((it1 == NULL && it2 != NULL) || (it1 != NULL && it2 == NULL))
		return 0;
	return 1;
}

void addBasicEntryToTable(struct basicEntry* entry, struct symbolTable* table)
{
	// printf("am fost apelat introducere in tabel pentru '%s'\n", entry->name);
	if (table->varEnd == NULL)
	{
		table->varEnd = entry;
		table->varBegin = entry;
	}
	else
	{
		table->varEnd->next = entry;
		table->varEnd = entry;
	}
}

void insertToTable(int type)
{
	int error = 0;
	for(int i = 0; i < tmpCount; i++)
	{
		error = 0;
		struct basicEntry* iterator = globalTable.varBegin;
		while(iterator && error == 0)
		{
			// printf("iterator name: %s, tmp name: %s\n", iterator->name, tmp[i]);
			if (strcmp(iterator->name, tmp[i]) == 0)
			{
				printf("ERROR Variable '%s' already declared\n", tmp[i]);
				error = 1;
			}
			iterator = iterator->next;
		}
		if (error == 0)
		{
			struct basicEntry* result = getCleanBasicEntry();
			result->type = type;
			result->isConstant = currentConstant;
			strcpy(result->name, tmp[i]);
			addBasicEntryToTable(result, &globalTable);
		}
		free(tmp[i]);
	}

	tmpCount = 0;
}

void addFunctionEntryToTable(struct functionEntry* entry, struct symbolTable* table)
{
	if (table->functionEnd == NULL)
	{
		table->functionEnd = entry;
		table->functionBegin = entry;
	}
	else
	{
		int error = 0;
		struct functionEntry* iterator = table->functionBegin;
		while(iterator && error == 0)
		{
			// printf("%s   ---   %s\n", iterator->name, entry->name);
			if(strcmp(iterator->name, entry->name) == 0)
			{
				// printf("ERROR Function '%s' already declared\n", iterator->name);
				if (sameSignature(entry->signature, iterator->signature))
				{
					error = 1;
					yyerror("Function with same name and signature already declared");
				}
			}
			iterator = iterator->next;
		}
		if (error == 0)
		{
			table->functionEnd->next = entry;
			table->functionEnd = entry;
		}
	}
}

struct functionEntry* checkFunction(char* name)
{
	struct functionEntry* iterator = globalTable.functionBegin;
	while(iterator)
	{
		if (strcmp(iterator->name, name) == 0 && sameSignature(iterator->signature, tmpParam))
		{
			free(name);
			return iterator;
		}
		iterator = iterator->next;
	}
	free(name);
	return NULL;
}

struct basicEntry* checkVariable(char* name)
{
	struct basicEntry* iterator = globalTable.varBegin;
	while(iterator)
	{
		if (strcmp(iterator->name, name) == 0)
		{
			free(name);
			return iterator;
		}
		iterator = iterator->next;
	}
	free(name);
	return NULL;
}

void printToFile()
{
	FILE* fisierOut = fopen("symbolTable.txt", "w+");
	fprintf(fisierOut, "Variabile:\n");
	struct basicEntry* biterator = globalTable.varBegin;
	while(biterator != NULL)
	{
		fprintf(fisierOut, "Nume: %s, ", biterator->name);
		if (biterator->type == 4)
			fprintf(fisierOut, "tip: float, constanta: %d, valoare: %f\n", biterator->isConstant, biterator->floatvalue);
		else if (biterator->type == 3)
			fprintf(fisierOut, "tip: int, constanta: %d, valoare: %d\n", biterator->isConstant, biterator->intvalue);
		else if (biterator->type == 2)
			fprintf(fisierOut, "tip: char, constanta: %d, valoare: %c\n", biterator->isConstant, biterator->charvalue);
		else if (biterator->type == 5)
			fprintf(fisierOut, "tip: string, constanta: %d, valoare: %s\n", biterator->isConstant, biterator->strvalue);
		biterator = biterator->next;
	}
	fprintf(fisierOut, "\n\nFunctii:\n");
	struct functionEntry* fiterator = globalTable.functionBegin;
	while (fiterator != NULL)
	{
		fprintf(fisierOut, "Nume: %s, ", fiterator->name);
		if (fiterator->type == 4)
			fprintf(fisierOut, "tip: float");
		else if (fiterator->type == 3)
			fprintf(fisierOut, "tip: int");
		else if (fiterator->type == 2)
			fprintf(fisierOut, "tip: char");
		else if (fiterator->type == 5)
			fprintf(fisierOut, "tip: string");
		struct node* paramIt = fiterator->signature;
		if (paramIt != NULL)
			fprintf(fisierOut, " si are nevoie de ");
		while(paramIt)
		{
			if(paramIt->type == 3)
				fprintf(fisierOut, "int ");
			else if(paramIt->type == 4)
				fprintf(fisierOut, "float ");
			else if(paramIt->type == 5)
				fprintf(fisierOut, "string ");
			else if(paramIt->type == 2)
				fprintf(fisierOut, "char ");
			paramIt = paramIt->next;
		}
		fprintf(fisierOut, "\n");
		fiterator = fiterator->next;
	}
}

void freeList(struct node* list)
{
	if (list->next != NULL)
		freeList(list->next);
	free(list);
}

void printDestroyTable()
{
	if (toFile)
		printToFile();
	struct basicEntry* biterator = globalTable.varBegin;
	while(biterator != NULL)
	{
		if (debug == 1)
		{
			printf("Type: %d, name: '%s'\n", biterator->type, biterator->name);
			if (biterator->type == 4)
				printf("Valoare: %f\n", biterator->floatvalue);
			else if (biterator->type == 3)
				printf("Valoare: %d\n", biterator->intvalue);
			else if (biterator->type == 2)
				printf("Valoare: %c\n", biterator->charvalue);
			else if (biterator->type == 5)
				printf("Valoare: %s\n", biterator->strvalue);
		}
		globalTable.varBegin = biterator->next;

		free(biterator);
		biterator = globalTable.varBegin;
	}

	struct functionEntry* fiterator = globalTable.functionBegin;
	
	while(fiterator != NULL)
	{
		if (debug == 1)
		{
			printf("Type: %d, name: '%s'\n", fiterator->type, fiterator->name);
			struct node* paramIt = fiterator->signature;
			printf("Functia are nevoie de");
			while(paramIt)
			{
				printf(" %d", paramIt->type);
				paramIt = paramIt->next;
			}
			printf("\n");
		}
		globalTable.functionBegin = fiterator->next;
		freeList(fiterator->signature);
		free(fiterator);
		fiterator = globalTable.functionBegin;
	}

}

%}
%token MAIN LET DIM BGIN END CONST TRUE FALSE USERTYPE VARS FUNCTIONS ASSIGN AND NOT OR LEQ EQ NEQ GE GEQ MOD DIV CALL BREAK IMPORT IF ELSE ELSEIF FOR WHILE PLUS MINUS EVAL MUL IMP RETURN
%left ASSIGN
%left PLUS MINUS
%left MOD MUL IMP DIV
%left AND OR
%left NOT
%left NEQ EQ LEQ LE GE GEQ
%union {
	struct basicTypes value;
};
%token <value> INTNUMBER FLOATNUMBER ID TYPE STRING CHAR;
%type <value> number expression;



%start s
%%
s 	:	import userdeftypes constants declaration_vars  functions main 	{printf("works!\n");}
	;

import	: import IMPORT STRING ';'
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

def_function 	:	TYPE ID '(' list_def ')' '{' content RETURN expression';' '}'	{//struct node* it = tmpParam;
																					// while(it)
																					// 	{
																					// 		printf("'%d'\n", it->type);
																					// 		it = it->next;
																					// 	}
																					struct functionEntry* result = (struct functionEntry*)malloc(sizeof(struct functionEntry));
																					result->type = getIntType(strdup($1.strval));
																					strcpy(result->name, $2.strval);
																					result->signature = tmpParam;
																					tmpParam = (struct node*)malloc(sizeof(struct node));
																					addFunctionEntryToTable(result, &globalTable);
																					
																					}
				|	ID ID '(' list_def ')' '{' content RETURN expression';' '}'
				;

list_def	:	TYPE ID 						{addToParam(getIntType(strdup($1.strval)));}
			|	ID ID 							{addToParam(getIntType(strdup($1.strval)));}
			|	list_def ',' TYPE ID 			{addToParam(getIntType(strdup($3.strval)));}
			|	list_def ',' ID ID 				{addToParam(getIntType(strdup($3.strval)));}
			|	TYPE ID dim 					{addToParam(getIntType(strdup($1.strval)));}
			|	ID ID dim 						{addToParam(getIntType(strdup($1.strval)));}
			|	list_def ',' TYPE ID dim     	{addToParam(getIntType(strdup($3.strval)));}
			|	list_def ',' ID ID dim 			{addToParam(getIntType(strdup($3.strval)));}
			|
			;

function 	:	ID '(' list_call ')' 			{struct functionEntry* ourGuy = checkFunction(strdup($1.strval));
												if (ourGuy == NULL)
													yyerror("Nu exista asa functie/functie cu asa signatura");
												// else if (!sameSignature(ourGuy->signature, tmpParam))
												// {
												// 	yyerror("Signatura nu coincide");
												// 	free(tmpParam);
												// 	tmpParam = (struct node*)malloc(sizeof(struct node));
												// }
												}
			|	ID '('')' 						{struct functionEntry* ourGuy = checkFunction(strdup($1.strval));
												printf("param acum: %d\n", tmpParam->type);
												if (ourGuy == NULL)
													yyerror("Nu exista asa functie");
												else if (ourGuy->signature->type != 0)
												{
													printf("%d\n", ourGuy->signature->type);
													yyerror("Signatura nu coincide esk");
												}
												}
			;

list_call	:	expression 						{addToParam($1.type);}
			|	list_call ',' expression 		{addToParam($3.type);}
			;

object_method_call	:	ID '.' function
					|	object_method_call '.' ID '.' function
					;

object_var	:	ID '.' ID
			;
dim : DIM
	| dim DIM
	;

expression	:	TRUE						{$$.type = 3; $$.intval = 1;}
		  	|	FALSE						{$$.type = 3; $$.intval = 0;}
		   	|	number						{if ($1.type == 3) { $$.intval = $1.intval; $$.type = 3;}
		   										else if ($1.type == 4) { $$.floatval = $1.floatval; $$.type = 4;}
		   									
		   									}
		   	|	STRING						{int length = strlen($1.strval);
		   									$$.type = 5; strncpy($$.strval, $1.strval+1, length-2); $$.strval[length-2] = '\0';}
		   	|	ID 							{struct basicEntry* ourGuy = checkVariable(strdup($1.strval));
		   									if (ourGuy != NULL)
		   									{
		   										if (ourGuy->type == 4)
	   											{
	   												$$.type = 4;
	   												$$.floatval = ourGuy->floatvalue;
	   											}
	   											else if (ourGuy->type == 3)
	   											{
	   												$$.type = 3;
	   												$$.intval = ourGuy->intvalue;
	   											}
	   											else if(ourGuy->type == 5)
	   											{
	   												$$.type = 5;

	   											}
		   									}
		   									else
		   									{
		   										yyerror("Nu exista asa variabila");
		   										$$.type = 3;
		   										$$.intval = 0;
		   									}
		   									} 
		   	|	ID dim 						{$$.type = 3; $$.intval = 0;}
		   	|	CHAR 						{$$.type = 2; $$.charval = $1.charval; /*printf("char: %c %c\n", $1.charval, $$.charval);*/}
		   	|	function 					{$$.type = 3; $$.intval = 0;}
		   	|	object_method_call			{$$.type = 3; $$.intval = 0;}
		   	|	object_var					{$$.type = 3; $$.intval = 0;}
		   	|	expression PLUS expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = $1.intval + $3.intval;
		   									}
		   									else if ($1.type == 4 && $1.type == 4)
		   									{
		   										$$.type = 4;
		   										$$.floatval = $1.floatval + $3.floatval;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	expression MINUS expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = $1.intval - $3.intval;
		   									}
		   									else if ($1.type == 4 && $1.type == 4)
		   									{
		   										$$.type = 4;
		   										$$.floatval = $1.floatval - $3.floatval;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	expression MUL expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = $1.intval * $3.intval;
		   									}
		   									else if ($1.type == 4 && $1.type == 4)
		   									{
		   										$$.type = 4;
		   										$$.floatval = $1.floatval * $3.floatval;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	expression IMP expression	{if ($1.type == 4 && $3.type == 4)
		   									{
		   										$$.type = 4;
		   										$$.intval = $1.floatval / $3.floatval;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		    |	expression DIV expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = $1.intval / $3.intval;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	| 	expression MOD expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = $1.intval % $3.intval;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	expression NEQ expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.intval != $3.intval : 0;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	expression EQ expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.intval == $3.intval : 0;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	expression AND expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.intval && $3.intval : 0;
		   									}
		   									else if ($1.type == 4 && $1.type == 4)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.floatval && $3.floatval : 0;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	expression OR expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.intval || $3.intval : 0;
		   									}
		   									else if ($1.type == 4 && $1.type == 4)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.floatval || $3.floatval : 0;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	NOT expression				{if ($2.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $2.intval : 0;
		   									}
		   									else if ($2.type == 4)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $2.floatval : 0;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	expression LEQ expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.intval <= $3.intval : 0;
		   									}
		   									else if ($1.type == 4 && $1.type == 4)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.floatval <= $3.floatval : 0;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	expression LE expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.intval < $3.intval : 0;
		   									}
		   									else if ($1.type == 4 && $1.type == 4)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.floatval < $3.floatval : 0;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	expression GEQ expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.intval >= $3.intval : 0;
		   									}
		   									else if ($1.type == 4 && $1.type == 4)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.floatval >= $3.floatval : 0;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	expression GE expression	{if ($1.type == 3 && $3.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.intval > $3.intval : 0;
		   									}
		   									else if ($1.type == 4 && $1.type == 4)
		   									{
		   										$$.type = 3;
		   										$$.intval = 1 ? $1.floatval > $3.floatval : 0;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	'(' expression ')'			{if ($2.type == 3)
		   									{
		   										$$.type = 3;
		   										$$.intval = $2.intval;
		   									}
		   									else if ($2.type == 4)
		   									{
		   										$$.type = 4;
		   										$$.floatval = $2.floatval;
		   									}
		   									else
		   										yyerror("Tip invalid");
		   									}
		   	|	ID ASSIGN expression		{
		   									struct basicEntry* ourGuy = checkVariable(strdup($1.strval));
		   									if (ourGuy == NULL)
		   										yyerror("Nu exista asa variabila");
		   									else if(ourGuy->isConstant && ourGuy->isDefined)
		   										yyerror("Asignare constantei imposibila");
		   									else if ($3.type == 3) //INT
		   									{
		   										if (ourGuy->type == 3)
		   										{
		   											ourGuy->intvalue = $3.intval;
		   											ourGuy->isDefined = 1;
		   											$$.type = 3;
		   											$$.intval = $3.intval;
		   										}
		   										else
		   											yyerror("Tip invalid");
		   									}
		   									else if ($3.type == 4) //FLOAT
		   									{
		   										// printf("float val: %f\n", $3.floatval);
		   										if (ourGuy->type == 4)
		   										{
		   											ourGuy->floatvalue = $3.floatval;
		   											ourGuy->isDefined = 1;
		   											$$.type = 4;
		   											$$.floatval = $3.floatval;
		   										}
		   										else
		   											yyerror("Tip invalid");
		   									}
		   									else if ($3.type == 2) //CHAR
		   									{
		   									//	printf("char val: %c\n", $3.charval);
		   										if (ourGuy->type == 2)
		   										{
		   											ourGuy->charvalue = $3.charval;
		   											ourGuy->isDefined = 1;
		   											$$.type = 2;
		   											$$.charval = $3.charval;
		   										}
		   										else
		   											yyerror("Tip invalid");
		   									}
		   									else if ($3.type == 5) //STRING
		   									{
		   										// printf("string val: %s\n", $3.strval);
		   										if (ourGuy->type == 5)
		   										{
		   											ourGuy->strvalue = $3.strval;
		   											ourGuy->isDefined = 1;
		   											$$.type = 5;
		   											$$.strval = $3.strval;
		   										}
		   										else
		   											yyerror("Tip invalid");
		   									}
		   									else
		   									{
		   										yyerror("Tip invalid");
		   									}
		   									}
		   	;

number	:	INTNUMBER			{$$.intval = $1.intval; $$.type = 3;}
		|	FLOATNUMBER 		{$$.floatval = $1.floatval; $$.type = 4; /*printf("%f\n", $$.floatval);*/}
		| 	MINUS INTNUMBER 	{$$.intval = $2.intval * -1; $$.type = 3;}
		|	PLUS INTNUMBER 		{$$.intval = $2.intval; $$.type = 3;}
		|	MINUS FLOATNUMBER 	{$$.floatval = $2.floatval * -1; $$.type = 4;}
		|	PLUS FLOATNUMBER  	{$$.floatval = $2.floatval; $$.type = 4;}
		;

constants :	constants constant
		  |
		  ;

constant :	CONST '(' TYPE ')' def_constants ';' 			{currentConstant = 1;
															insertToTable(getIntType(strdup($3.strval)));
															currentConstant = 0;}
		 |	CONST '(' ID ')' def_constants ';'
		 ;

declaration_vars	:	line_of_vars 
					|	declaration_vars line_of_vars
					;

def_constants : ID 											{tmp[tmpCount] = strdup($1.strval); tmpCount++;}
			  |	ID dim 										{tmp[tmpCount] = strdup($1.strval); tmpCount++;}
			  | def_constants ',' ID    					{tmp[tmpCount] = strdup($3.strval); tmpCount++;}
			  |	def_constants ',' ID dim 					{tmp[tmpCount] = strdup($3.strval); tmpCount++;}
			  ;

line_of_vars	:	LET '(' TYPE ')' var ';' 	{
												//printf("Am gasit un %s\n", $3);
// 												if (strcmp($3.strval, "int") == 0)
// 												{
													insertToTable(getIntType(strdup($3.strval)));
												// 	// for(int i = 0; i < tmpCount; i++)
												// 	// {
												// 	// 	printf("eksetit\n");
												// 	// 	printf("%s\n", tmp[i]);
												// 	// }
												// 	// createIntEntry(&globalTable);
												// 	// printf("Adresa ultimei: %p\n", globalTable.varEnd);
												// }
												// else if (strcmp($3.strval, "boolean") == 0)
												// 	insertToTable(1);
												// else if (strcmp($3.strval, "string") == 0)
												// 	insertToTable(5);
												// else if (strcmp($3, "float") == 0)
												// 	insertToTable(4);
												}
				|	LET '(' ID ')' var ';'		//{insertToTable(6);}
				;


var 	:	ID 									{tmp[tmpCount] = strdup($1.strval);
												tmpCount++;
												}
		|	ID dim 								{tmp[tmpCount] = strdup($1.strval);
												tmpCount++;
												}
		|	var ',' ID 							{tmp[tmpCount] = strdup($3.strval);
												tmpCount++;
												}
		|	var ',' ID dim 						{tmp[tmpCount] = strdup($3.strval);
												tmpCount++;
												}
		// | 	ID ASSIGN expression
		// |	ID DIM ASSIGN expression
		// |	var ',' ID ASSIGN expression
		// |	var ',' ID dim ASSIGN expression
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
			|	EVAL '(' expression ')' ';' {printf("Expresia de pe linia %d are valoarea %d\n", yylineno, $3.intval);}
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
	globalTable.varBegin = NULL;
	globalTable.varEnd = NULL;
	globalTable.functionBegin = NULL;
	globalTable.functionEnd = NULL;
	tmpParam = (struct node*)malloc(sizeof(struct node));

	strcpy(currentScope, "");

	yyin=fopen(argv[1], "r");
	yyparse();

	printDestroyTable();
} 