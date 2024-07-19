%option noyywrap
%option yylineno

%{
    #include <iostream>
    #include <string>
    #include "../parser/parser.tab.h"
%}

%%

"//".* { /* Ignore. */ }
"Accept" { yylval.sval = strdup(yytext); return KW_ACCEPT; }
"Error" { yylval.sval = strdup(yytext); return KW_ERROR; }
"0-9" { return NUM_RANGE; }
"a-z" { return CHAR_RANGE_L; }
"A-Z" { return CHAR_RANGE_U; }
"->" { yylval.sval = strdup(yytext); return ARROW; }
(":"|";"|"("|")") { yylval.cval = strdup(yytext)[0]; return yytext[0]; }
\'.\' { yylval.cval = strdup(yytext)[1]; return SYMBOL; }
[_a-zA-Z0-9]+ { yylval.sval = strdup(yytext); return ID; }
[\n\t ]+ { /* Ignore. */ }
<<EOF>> { return END; }
\' { /* Ignore. */ }

. { std::cout << "Unrecognized token: " << yytext << std::endl; }

%%