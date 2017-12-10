%{
  #include <stdlib.h>
  #include <string.h>
  #include "y.tab.h"
  void debug (char* s);
%}

identifier      [a-zA-Z_][0-9a-zA-Z_]*
number          [0-9]+
comment         (\/\/.*)|("/*"([^*]|\*+[^*/])*\*+"/")
string          \"(\\.|[^"\\])*\"

%option case-insensitive
%option yylineno

%%

"int"           { return INT; }
"stencil"       { return STENCIL; }
"main"          { return MAIN; }
"return"        { return RETURN; }
"void"          { return VOID; }
"if"            { return IF; }
"while"         { return WHILE; }
"else"          { return ELSE; }
"for"           { return FOR; }
"true"          { return TRUE; }
"false"         { return FALSE; }
"const"         { return CONST; }
"printi"        { return PRINTI; }
"printf"        { return PRINTF; }
"#define"		{ return DEFINE_STRING;}
{identifier}    { yylval.string = strdup(yytext);
				//yylval.string = yytext;
				return ID; }
{number}        { yylval.value = atoi(yytext);return NUM; }
{comment}       { }
{string}        { yylval.string = strdup(yytext); return STRING;}
"+"             { return OP_PLUS; }
"++"            { return OP_INC; }
"-"             { return OP_MINUS; }
"--"            { return OP_DEC; }
"*"             { return OP_MULTI; }
"/"             { return OP_DIV; }
"$"             { return OP_STEN; }
"=="            { return OP_EQUAL; }
"="             { return OP_ASSIGN; }
"!="			{ return OP_DIFF;}
"&&"            { return OP_AND; }
"||"            { return OP_OR; }
"!"             { return OP_NOT; }
">"             { return OP_SUP; }
"<"             { return OP_INF; }
">="|"=>"       { return OP_SUP_EQUAL; }
"=<"|"<="       { return OP_INF_EQUAL; }
[()]            { return yytext[0]; }
[{}]            { return yytext[0]; }
"["             { return yytext[0]; }
"]"             { return yytext[0]; }
","             { return yytext[0]; }
";"	            { return yytext[0]; }
\n              { }
[\t ]           { }
.			    { printf("[Lex] Unknown character: %s\n", yytext); }

%%

// Free the memory allocated for Lex when we are done.
void lex_free() {
  yy_delete_buffer(YY_CURRENT_BUFFER);
  free(yy_buffer_stack);
}
