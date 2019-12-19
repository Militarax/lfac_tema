%{
#include <stdio.h>
#include "y.tab.h"
%}
%%
"int"|"float"|"string"|"boolean"|"char" 						{ return TYPE; }
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
[0-9]+															{ return INTNUMBER; }
[0-9]+"."[0-9]+													{ return FLOATNUMBER; }	
"["[1-9][0-9]*"]"												{ return DIM; }
[_A-Za-z][_A-Za-z0-9]* 											{ return ID; }
\"[^\"\n]*\"													{ return STRING; }
\'.\'															{ return CHAR; }
[ \t] ;
\n 																{ yylineno++; }
. 																{ return yytext[0]; }
