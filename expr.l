%{
  #include <stdlib.h>
  #include <string.h>
  #include "y.tab.h"
%}

identifier      [a-zA-Z_][0-9a-zA-Z_]*
number          [0-9]+

%%

"int"           { return INT; }
"stencil"       { return STENCIL; }
"main"          { return MAIN; }
"return"        { return RETURN; }
"if"            { return IF; }
"while"         { return WHILE; }
"do"            { return DO; }
"else"          { return ELSE; }
"for"           { return FOR; }
"true"          { return TRUE; }
"false"         { return FALSE; }
"define"        { return DEFINE; }
{identifier}    { return ID; }
{number}        { return NUM; }

%%

// Free the memory allocated for Lex when we are done.
void lex_free() {
  yy_delete_buffer(YY_CURRENT_BUFFER);
  free(yy_buffer_stack);
}
