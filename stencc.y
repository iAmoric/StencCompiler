%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "symbol.h"
  #include "quad.h"
  #include "quad_list.h"
  #include "operator.h"
  #include "assembly_generator.h"
  //#define DEBUG


  void debug(char*);
  void yyerror(char*);
  int yylex();
  void lex_free();
  struct symbol* symbol_list = NULL;
  struct quad* quad_list = NULL;
  FILE* yyin;
%}
%union {
  char* string;
  int value;
  struct {
    struct symbol* result;
    struct quad* code;
    struct quad_list* true_list;
    struct quad_list* false_list;
  }codegen;
}
%type <codegen> expression affectation statement 
%type <codegen> statement_list declaration programme declaration_affectation
%type <codegen> mark element condition control_structure
%token <string> ID STRING
%token <value> NUM
%token INT STENCIL MAIN RETURN VOID
%token IF WHILE ELSE FOR TRUE FALSE
%token CONST PRINTI PRINTF
%token OP_PLUS OP_INC OP_MINUS OP_DEC
%token OP_STEN OP_EQUAL OP_ASSIGN OP_AND
%token OP_OR OP_NOT
%token OP_MULTI OP_DIV OP_SUP OP_INF OP_SUP_EQUAL OP_INF_EQUAL

%left OP_OR
%left OP_AND
%left OP_NOT
%left OP_PLUS
%left OP_MINUS
%left OP_MULTI
%left OP_DIV


%%

axiom:
    programme{
      quad_list = $1.code;
      printf("Match !!!\n");
      return 0;
    }
  ;

programme:
    INT MAIN '(' ')' '{' statement_list '}'{
      debug("programme");
      $$.code = $6.code;
    }
  ;

statement_list:
  statement statement_list {
    $$.code = quad_add($1.code,$2.code);
    debug("statement");
  }
  |
  statement {
    $$.code = $1.code;
    debug("statement");
  }
  ;

statement:
  declaration ';' {
    debug("declaration");
    }
  |
  affectation ';' {
    $$.code = $1.code;
    debug("affectation");
  }
  |
  declaration_affectation ';'{
    printf("statement: declare affect\n");
    $$.code = $1.code;
  }
  |
  expression ';' {
      $$.code = $1.code;
      debug("expression");
  }
  |
  control_structure {

      debug("control_structure");
  }
  |
  PRINTI '(' NUM ')' ';' {
      struct symbol* result = symbol_newtemp(&symbol_list);
      result->isconstant = true;
      result->value = $3;
      $$.result = result;
      $$.code = quad_gen(E_PRINTI,result,NULL,NULL);
      debug("printi num");
  }
  |
  PRINTI '(' ID ')' ';' {
      struct symbol* result = symbol_lookup(symbol_list, $3);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s\n",$3);
        exit(1);
      }
      $$.result = result;
      struct quad* quad = quad_gen(E_PRINTI,result,NULL,NULL);
      $$.code = quad;
      debug("printi id");
  }
  |
  PRINTF '(' STRING ')' ';' {
      struct symbol* result = symbol_newtemp(&symbol_list);
      result->isconstant = true;
      result->string = $3;
      $$.result = result;
      $$.code = quad_gen(E_PRINTF,result,NULL,NULL);;
      debug("printf");
  }
  |
  RETURN NUM ';' {
    struct symbol* result = symbol_newtemp(&symbol_list);
    result->isconstant = true;
    result->value = $2;
    $$.result = result;
    $$.code = quad_gen(E_RETURN,result,NULL,NULL);
      debug("return");
  }
  ;

declaration:
   INT ID {
    struct symbol* result = symbol_lookup(symbol_list, $2);
      if(result == NULL){
        result = symbol_add(&symbol_list, $2);
      }else{
        printf("ERROR: already declared variable -> %s",$2);
        exit(1);
      }
      $$.result = result;
      $$.code = NULL;
   }
   |
   CONST INT ID {
    struct symbol* result = symbol_lookup(symbol_list, $3);
      if(result == NULL){
        result = symbol_add(&symbol_list, $3);
      }else{
        printf("ERROR: already declared variable -> %s",$3);
        exit(1);
      }
      $$.result = result;
      $$.code = NULL;
   }
  ;

affectation:
    ID OP_ASSIGN expression {
      struct symbol* result = symbol_lookup(symbol_list, $1);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s\n",$1);
        exit(1);
      }
      $$.result = result;
      struct quad* quad = quad_gen(E_ASSIGN,result,$3.result,NULL);
      struct quad* code = quad_add($3.code,quad);
      $$.code = code;
      debug("ID = expr");
    }

    ;

declaration_affectation:
    INT ID OP_ASSIGN expression {
      debug("INT ID = expr");
      struct symbol* result = symbol_lookup(symbol_list, $2);
      if(result == NULL){
        result = symbol_add(&symbol_list,$2);
      }else{
        printf("ERROR: already declared variable -> %s\n",$2);
        exit(1);
      }
      $$.result = result;
      struct quad* quad = quad_gen(E_ASSIGN,result,$4.result,NULL);
      struct quad* code = quad_add($4.code,quad);
      $$.code = code;
      debug("int ID = expr");
    }
    ;
expression:
    expression OP_PLUS expression {
      struct symbol* result = symbol_newtemp(&symbol_list);
      $$.result = result;

      struct quad* quad = quad_gen(E_PLUS,result,$1.result,$3.result);
      struct quad* code = quad_add($1.code,$3.code);
      code = quad_add(code,quad);
      $$.code = code;
      debug("expr + expr");
    }
    |
    expression OP_MINUS expression {
      struct symbol* result = symbol_newtemp(&symbol_list);
      $$.result = result;
      struct quad* quad = quad_gen(E_MINUS,result,$1.result,$3.result);
      struct quad* code = quad_add($1.code,$3.code);
      code = quad_add(code,quad);
      $$.code = code;
      debug(" expr - expr");
    }
    |
    OP_MINUS expression {

    }
    |
    expression OP_MULTI expression {
      struct symbol* result = symbol_newtemp(&symbol_list);
      $$.result = result;
      struct quad* quad = quad_gen(E_MULT,result,$1.result,$3.result);
      struct quad* code = quad_add($1.code,$3.code);
      code = quad_add(code,quad);
      $$.code = code;
    }
    |
    expression OP_DIV expression {
      struct symbol* result = symbol_newtemp(&symbol_list);
      $$.result = result;
      struct quad* quad = quad_gen(E_DIV,result,$1.result,$3.result);
      struct quad* code = quad_add($1.code,$3.code);
      code = quad_add(code,quad);
      $$.code = code;
    }
    |
    '(' expression ')'{
      $$.result = $2.result;
      $$.code = $2.code;
    }
    |
    ID {
      struct symbol* result = symbol_lookup(symbol_list, $1);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s\n",$1);
      } 
      $$.result = result;
      $$.code = NULL;
      debug("ID");
    }
    |
    NUM {
      struct symbol* result = symbol_newtemp(&symbol_list);
      result->isconstant = true;
      result->value = $1;
      $$.result = result;
      $$.code = NULL;
      debug("NUM");
    }
;

mark:
  {
    $$.code = quad_gen(E_GOTO,NULL,NULL,NULL);
    $$.false_list = quad_list_new($$.code);
    $$.true_list = quad_list_new($$.code);
  }
  ;


control_structure:
    IF '(' condition ')' '{' statement_list '}' {
      debug("if (condition) {statement_list}");
      struct quad* last_condition = quad_last($3.code);
      struct quad* last_statement;
      struct symbol* where_true = symbol_newtemp_init(&symbol_list,last_condition->number+1);
      struct symbol* where_false;
      quad_list_complete($3.true_list,where_true);
      $$.code = quad_add($3.code,$6.code);
      if($6.code != NULL){
        last_statement = quad_last($6.code); 
      }else{
        last_statement = quad_last($3.code);
      }
      where_false = symbol_newtemp_init(&symbol_list,last_statement->number + 1);
      quad_list_complete($3.false_list,where_false);
    }
    |
    IF '(' condition ')' '{' statement_list '}' ELSE '{' mark statement_list '}'{
      debug("if (condition) {statement_list} else { statement_list}");
      struct quad* last_condition = quad_last($3.code);
      struct quad* code;
      struct quad* last_statement;
      struct symbol* where_true = symbol_newtemp_init(&symbol_list,last_condition->number+1);
      struct symbol* where_false;
      $3.false_list = quad_list_concat($3.false_list,$10.false_list);
      quad_list_complete($3.true_list,where_true);
      code = quad_add($3.code,$6.code);
      code = quad_add(code,$10.code);
      code = quad_add(code,$11.code);
      $$.code  = code;
      if($11.code != NULL){
        last_statement = $11.code; 
      }else{
        last_statement = $10.code;
      }
      where_false = symbol_newtemp_init(&symbol_list,last_statement->number + 1);
      quad_list_complete($3.false_list,where_false);
    }
    |
    WHILE '(' condition ')' '{' statement_list mark '}' {
      debug("while (condition) {statement_list}");
      struct quad* last_condition = quad_last($3.code);
      struct quad* code;
      struct quad* last_statement;
      struct symbol* where_true = symbol_newtemp_init(&symbol_list,last_condition->number+1);
      struct symbol* where_false;
      struct symbol* where_begin = symbol_newtemp_init(&symbol_list,$3.code->number);
      quad_list_complete($7.true_list,where_begin);
      quad_list_complete($3.true_list,where_true);
      code = quad_add($3.code,$6.code);
      code = quad_add(code,$7.code);
      $$.code  = code;
      //dernière instruction a faire dans la boucle
      if($6.code != NULL){
        last_statement = quad_last($6.code); 
      }else{
        last_statement = $7.code;
      }
      where_false = symbol_newtemp_init(&symbol_list,last_statement->number + 1);
      quad_list_complete($3.false_list,where_false);
    }
    |
    FOR '('  ')' '{' statement_list '}' {

    }
    ;


element:
  ID {
      struct symbol* result = symbol_lookup(symbol_list, $1);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s\n",$1);
      }
      $$.result = result;
      $$.code = NULL;
      debug("ID");
  }
  |
  NUM {
     $$.result = symbol_newtemp_init(&symbol_list,$1);
  }

condition:
    element OP_EQUAL element {
      debug("elt == elt");
      struct quad* codeTrue = quad_gen(E_EQUAL,NULL,$1.result,$3.result);
      struct quad* codeFalse = quad_gen(E_GOTO,NULL,NULL,NULL);
      struct quad* code = quad_add(codeTrue,codeFalse);
      $$.code = code;
      $$.true_list = quad_list_new(codeTrue);
      $$.false_list = quad_list_new(codeFalse);
    }
    |
    element OP_SUP element {
      debug("elt > elt");
      struct quad* codeTrue = quad_gen(E_SUPERIOR,NULL,$1.result,$3.result);
      struct quad* codeFalse = quad_gen(E_GOTO,NULL,NULL,NULL);
      struct quad* code = quad_add(codeTrue,codeFalse);
      $$.code = code;
      $$.true_list = quad_list_new(codeTrue);
      $$.false_list = quad_list_new(codeFalse);
    }
    |
    element OP_INF element {
      debug("elt < elt");
      struct quad* codeTrue = quad_gen(E_INFERIOR,NULL,$1.result,$3.result);
      struct quad* codeFalse = quad_gen(E_GOTO,NULL,NULL,NULL);
      struct quad* code = quad_add(codeTrue,codeFalse);
      $$.code = code;
      $$.true_list = quad_list_new(codeTrue);
      $$.false_list = quad_list_new(codeFalse);
    }
    |
    element OP_SUP_EQUAL element {
      debug("elt >= elt");
      struct quad* codeTrue = quad_gen(E_SUPEQUAL,NULL,$1.result,$3.result);
      struct quad* codeFalse = quad_gen(E_GOTO,NULL,NULL,NULL);
      struct quad* code = quad_add(codeTrue,codeFalse);
      $$.code = code;
      $$.true_list = quad_list_new(codeTrue);
      $$.false_list = quad_list_new(codeFalse);
    }
    |
    element OP_INF_EQUAL element {
      debug("elt <= elt");
      struct quad* codeTrue = quad_gen(E_INFEQUAL,NULL,$1.result,$3.result);
      struct quad* codeFalse = quad_gen(E_GOTO,NULL,NULL,NULL);
      struct quad* code = quad_add(codeTrue,codeFalse);
      $$.code = code;
      $$.true_list = quad_list_new(codeTrue);
      $$.false_list = quad_list_new(codeFalse);
    }
    |
    TRUE {
      $$.code = quad_gen(E_GOTO,NULL,NULL,NULL);
      $$.true_list = quad_list_new($$.code);
    }
    |
    FALSE {
      $$.code = quad_gen(E_GOTO,NULL,NULL,NULL);
      $$.false_list = quad_list_new($$.code);
    }
    |
    condition OP_OR condition {
      debug("condition || condition");
      $$.true_list = quad_list_concat($1.true_list,$3.true_list);
      $$.false_list = $3.false_list;
      struct symbol* where_to_go = symbol_newtemp(&symbol_list);
      where_to_go->isconstant = true;
      where_to_go->value = $3.code->number;
      quad_list_complete($1.false_list,where_to_go);
      $$.code = quad_add($1.code,$3.code);
    }
    |
    condition OP_AND condition {
      debug("condition && condition");
      $$.false_list = quad_list_concat($1.false_list,$3.false_list);
      struct symbol* where_to_go = symbol_newtemp(&symbol_list);
      where_to_go->isconstant = true;
      where_to_go->value = $3.code->number;
      quad_list_complete($1.true_list,where_to_go);
      $$.true_list = $3.true_list;
      $$.code = quad_add($1.code,$3.code);
    }
    |
    OP_NOT condition {
      debug("!condition");
      $$.true_list = $2.false_list;
      $$.false_list = $2.true_list;
      $$.code = $2.code;
    }
    |
    '(' condition ')' {
      debug("( condition ) ");
      $$.true_list = $2.true_list;
      $$.false_list = $2.false_list;
      $$.code = $2.code;
    }
    ;

%%

void yyerror (char *s) {
    fprintf(stderr, "[Yacc] error: %s\n", s);
}

void debug (char* s){
    #ifdef DEBUG
    fprintf(stderr, "[Yacc] ");
    fprintf(stderr, "%s\n",s);
    #endif
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "error with arguments\n");
        exit(1);
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        fprintf(stderr, "unable to open file %s\n", argv[1]);
        exit(1);
    }

    yyparse();
    printf("-----------------\nSymbol table:\n");
    symbol_print(symbol_list);
    printf("-----------------\nQuad list:\n");
    quad_print(quad_list);

    //generation code assembleur
    generator(symbol_list, quad_list);

    // Be clean.
    lex_free();
    return 0;
}
