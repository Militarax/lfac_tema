%{
#include <stdio.h>
#include "max.h"
#include "y.tab.h"
%}
%%
"int"|"float"|"string"|"boolean"|"char" 						{ yylval.value.strval=strdup(yytext); return TYPE; }
"do you really need it?" 										{ return LET; }
"main"															{ return MAIN; }
"This guys will not change"										{ return CONST; }
"I have not seen this class before"								{ return USERTYPE; }
"variables"														{ return VARS; }
"functions"														{ return FUNCTIONS; }	
"~"																{ return BGIN; }
"/~"															{ return END; }
"True"															{ return TRUE; }
"False"															{ return FALSE; }
"and"															{ return AND;}
"or"															{ return OR;}
"not"															{ return NOT; }
"call"															{ return CALL;}
"you shall not pass!!!"											{ return BREAK; }
"I need this:"													{ return IMPORT; }
"if"															{ return IF; }
"elseif"														{ return ELSEIF; }
"else"															{ return ELSE; }
"for"															{ return FOR; }
"while"															{ return WHILE; }
"eval"															{ return EVAL; }
"return"														{ return RETURN;}
"<=" 															{ return LEQ; }
"==" 															{ return EQ; }
"!=" 															{ return NEQ; }
"<"																{ return LE; }
">"																{ return GE; }
"=>"															{ return GEQ;}
"//" 															{ return DIV; }
"%"	 															{ return MOD; }
"<=="															{ return ASSIGN; }
"-"																{ return MINUS; }
"+"																{ return PLUS; }
"*"																{ return MUL; }
"/"																{ return IMP; }		
[0-9]+															{ yylval.value.intval=atoi(yytext); yylval.value.type = 3; return INTNUMBER; }
[0-9]+"."[0-9]+													{ yylval.value.floatval=atof(yytext); yylval.value.type = 4; return FLOATNUMBER; }	
"["[1-9][0-9]*"]"												{ yylval.value.intval=atoi(yytext); yylval.value.type = 3; return DIM; }
[_A-Za-z][_A-Za-z0-9]* 											{ yylval.value.strval=strdup(yytext); return ID; }
\"[^\"\n]*\"													{ yylval.value.strval=strdup(yytext); return STRING; }
\'.\'															{ yylval.value.charval=yytext[1]; return CHAR; }
[ \t] ;
\n 																{ yylineno++; }
. 																{ return yytext[0]; }
