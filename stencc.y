%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "symbol.h"
  #include "quad.h"
  #include "quad_list.h"
  #include "operator.h"
  #include "array_dimension.h"
  #include "assembly_generator.h"
  //#define DEBUG


  void debug(char*);
  void yyerror(char*);
  int yylex();
  void lex_free();
  struct symbol* symbol_list = NULL;
  struct quad* quad_list = NULL;
  FILE* yyin;
  int err = 0;

%}

%union {
  char* string;
  int value;
  struct {
    struct symbol* result;
    struct quad* code;
    struct quad_list* true_list;
    struct quad_list* false_list;
    struct array_dimension* dimension;
  }codegen;
}

%type <codegen> expression affectation statement define define_list
%type <codegen> statement_list declaration programme declaration_affectation
%type <codegen> mark condition control_structure array_declare array mark_array_load mark_array_write array_next
%token <string> ID STRING
%token <value> NUM
%token INT STENCIL MAIN RETURN VOID
%token IF WHILE ELSE FOR TRUE FALSE
%token CONST PRINTI PRINTF
%token OP_PLUS OP_INC OP_MINUS OP_DEC OP_DIFF
%token OP_STEN OP_EQUAL OP_ASSIGN OP_AND
%token OP_OR OP_NOT DEFINE_STRING
%token OP_MULTI OP_DIV OP_SUP OP_INF OP_SUP_EQUAL OP_INF_EQUAL

%left OP_OR
%left OP_AND
%left OP_NOT
%left OP_PLUS
%left OP_MINUS
%left OP_MULTI
%left OP_DIV


%%

/**
 * @I. axiom
 */

axiom:
    programme{
      //Axiom de la grammaire
      quad_list = $1.code;

      debug("Match !\n");
      return 0;
    }
  ;

programme:
    define_list INT MAIN '(' ')' '{' statement_list '}'{
      //détection du main
      debug("programme");
      //$$.code = $6.code;
      $$.code = $7.code;
      struct quad* last_quad = quad_last($7.code);
      //test d'analyse sémantique
      if(last_quad->operator != E_RETURN){
        //le programme doit se terminer par un return
        printf("ERROR: main function must finish with a return statement\n");
        exit(1);
      }
    }
  ;
/**
 * @II. define
 */

//déclaration de plusieurs define
define_list:
  define define_list{

  }
  |{

  }
// les define de génère pas de code
// mais une entrée dans la TdS
define:
  DEFINE_STRING ID NUM{
    struct symbol* result = symbol_lookup(symbol_list, $2);
      if(result == NULL){
        result = symbol_add(&symbol_list, $2);
        result->is_define = true;
        result->is_initialised = true;
        result->isconstant = true;
        result->value = $3;
      }else{
        printf("ERROR: define already declared  -> %s",$2);
        exit(1);
      }
      free($2);
  }
  |
  DEFINE_STRING ID {
    struct symbol* result = symbol_lookup(symbol_list, $2);
      if(result == NULL){
        result = symbol_add(&symbol_list, $2);
        result->is_define = true;
      }else{
        printf("ERROR: define already declared  -> %s",$2);
        exit(1);
      }
      free($2);
  }

/**
 * @III. statement_list
 */
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
      //une déclaration de génère pas de code
      debug("declaration");
    }
  |
  affectation ';' {
    debug("affectation");
    $$.code = $1.code;
    debug("affectation");
  }
  |
  declaration_affectation ';'{
    debug("declare & affect");
    $$.code = $1.code;
  }
  |
  expression ';' {
      $$.code = $1.code;
      debug("expression");
  }
  |
  control_structure {
      $$.code = $1.code;
      debug("control_structure");
  }
  |
  PRINTI '(' expression ')' ';' {
      //la variable affiché est dans un nouveau temporaire
      $$.result = $3.result;
      struct quad* code = quad_gen(E_PRINTI,$$.result,NULL,NULL);
      $$.code = quad_add($3.code,code);
      debug("printi expr");
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
  RETURN expression ';' {
    $$.code = quad_gen(E_RETURN,$2.result,NULL,NULL);
    debug("return expression");
  }
  ;

declaration:
   INT ID {
    struct symbol* result = symbol_lookup(symbol_list, $2);
      debug("INT ID");
      if(result == NULL){
        result = symbol_add(&symbol_list, $2);
      }else{
        printf("ERROR: already declared variable -> %s",$2);
        exit(1);
      }
      result->is_never_used = true;
      $$.result = result;
      $$.code = NULL;
      free($2);
   }
   |
   INT ID array_declare {
      //voir IV. Array
      debug("INT ID [...]");
      int array_size = 0;
      struct array_dimension* parcours;
      struct symbol* result = symbol_lookup(symbol_list, $2);
      if(result == NULL){
        result = symbol_add(&symbol_list, $2);
      }else{
        printf("ERROR: already declared variable -> %s\n",$2);
        exit(1);
      }
      result->is_array = true;
      //association des dimensions du tableaux avec son entrée dans la TdS
      result->array_dimension = $3.dimension;
      parcours = $3.dimension;
      //calcul du nombre total d'octets du tableau
      array_size = parcours->size->value;
      parcours = parcours ->next_dimension;
      while(parcours != NULL){
        array_size = array_size * parcours->size->value;
        parcours = parcours->next_dimension;
      }
      array_size*=4;//*4 car un int est sur 4 octets
      result->value = array_size;//taille dans le champs value pour allocation en assembleur
      $$.result = NULL;
      $$.code = NULL;
      free($2);
   }
  ;

/**
 * @IV. array
 */

 //la taille d'un tableau est forcément indiquer avec des valeurs constantes
array_declare:
   '[' NUM ']' array_declare {
    debug("array_declare [NUM]");
    $$.dimension = malloc(sizeof(struct array_dimension));
    struct symbol* size = symbol_newtemp_init(&symbol_list,$2);
    $$.dimension->size = size;
    $$.dimension->next_dimension = $4.dimension;
  }
  |
  '[' ID ']' array_declare {
      debug("[ID] array_declare");
      $$.dimension = malloc(sizeof(struct array_dimension));
      struct symbol* result = symbol_lookup(symbol_list, $2);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s\n",$2);
        exit(1);
      }
      if(result->isconstant == true){
        if(result->is_initialised == false){
          printf("ERROR: array declaration using define with no value -> %s\n",$2);
          exit(1);
        }else{
          $$.dimension->size = result;
          $$.dimension->next_dimension = $4.dimension;
        }
      }else{
        printf("ERROR: array declaration using a not constant value -> %s\n",$2);
        exit(1);
      }
      free($2);
   }
  | '[' NUM ']' {
    //dernière dimension du tableau: int tab[?][?]...[?][ici];
    debug("[NUM]");
    $$.dimension = malloc(sizeof(struct array_dimension));
    struct symbol* size = symbol_newtemp_init(&symbol_list,$2);
    $$.dimension->size = size;
  }
  | '[' ID ']' {
      //dernière dimension du tableau: int tab[?][?]...[?][ici];
      debug("[ID]");
      $$.dimension = malloc(sizeof(struct array_dimension));
      struct symbol* result = symbol_lookup(symbol_list, $2);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s\n",$2);
        exit(1);
      }
      if(result->isconstant == true){
        if(result->is_initialised == false){
          printf("ERROR: array declaration using define with no value -> %s\n",$2);
          exit(1);
        }else{
          $$.dimension->size = result;
        }
      }else{
        printf("ERROR: array declaration using a not constant value -> %s\n",$2);
        exit(1);
      }
      free($2);

  }
//règle utiliser pour les accès en écriture ou lecture dans le tableau
array:
    //on ne genère pas les mêmes quad pour la première dimension du tableau
    expression ']' '[' array_next {
    debug( "expr ] [ array_next");
    $$.code = quad_add($1.code,$4.code);
    $$.true_list = $4.true_list;
    //on indique la valeur à multiplier aux quads suivants
    $4.true_list->elt->arg1 = $1.result;
    $$.result = $4.result;//calcul d'offset
  }
  |
  expression ']'{
    //pour les tableaux à une dimension
    debug("expr ] ");
    $$.result = $1.result;
    $$.code = $1.code;//calcul d'offset
  }
  ;
array_next:
    //permet de faire (offset_precedant)*dimension_actuel + valeur
    //le premier off_set est vide et est complété dans array
    //les dimension_actuel sont remplie plus tard grâce à des quad_list (par convention true_list)

    array_next '[' expression ']'{
    debug("[ expr ] [ array_next");
    struct symbol* result_mult = symbol_newtemp(&symbol_list);
    struct symbol* result_plus = symbol_newtemp(&symbol_list);
    struct quad* code = quad_add($1.code,$3.code);
    //on va devoir compléter ce quad plus tard
    struct quad* multi = quad_gen(E_MULT,result_mult,$1.result,NULL);
    struct quad* plus = quad_gen(E_PLUS,result_plus,$3.result,result_mult);
    struct quad_list* array_list = quad_list_new(multi);
    array_list = quad_list_concat($1.true_list,array_list);
    code = quad_add(code,multi);
    code = quad_add(code,plus);
    $$.true_list = array_list;
    $$.code = code;
    $$.result = result_plus;//calcul d'offset
  }
  |
   expression ']' {
    debug("expr ] ");
    struct symbol* result_mult = symbol_newtemp(&symbol_list);
    struct symbol* result_plus = symbol_newtemp(&symbol_list);
    struct quad* code = $1.code;
    struct quad* multi = quad_gen(E_MULT,result_mult,NULL,NULL);
    struct quad* plus = quad_gen(E_PLUS,result_plus,$1.result,result_mult);
    struct quad_list* array_list = quad_list_new(multi);
    code = quad_add(code,multi);
    code = quad_add(code,plus);
    $$.true_list = array_list;
    $$.code = code;
    $$.result = result_plus;//calcul d'offset
  }
  ;

mark_array_load:
  {
    struct symbol* result_mult = symbol_newtemp(&symbol_list); //offset total
    struct symbol* result_addr = symbol_newtemp(&symbol_list);  // addr
    struct symbol* result_tab = symbol_newtemp(&symbol_list); //valeur à addr
    //mult_size = arg1 = taille de la case mémoire arg2: offset (complété plus tard)
    //taille de la case mémoire = 4 octets
    struct quad* mult_size = quad_gen(E_MULT,result_mult,symbol_newtemp_init(&symbol_list,4),NULL);
    struct quad* addr = quad_gen(E_PLUS,result_addr,result_mult,NULL);
    struct quad* tab = quad_gen(E_TAB_LOAD,result_tab,result_addr,NULL);
    $$.result = result_tab;//la valeur dans la case mémoire
    $$.code = quad_add(mult_size,addr);
    $$.code = quad_add($$.code,tab);
  }
  ;
mark_array_write:
  {
    struct symbol* result_mult = symbol_newtemp(&symbol_list); //offset total
    struct symbol* result_addr = symbol_newtemp(&symbol_list);  // addr
    //mult_size = arg1 = taille de la case mémoire arg2: offset (complété plus tard)
    //taille de la case mémoire = 4 octets
    struct quad* mult_size = quad_gen(E_MULT,result_mult,symbol_newtemp_init(&symbol_list,4),NULL);
    struct quad* addr = quad_gen(E_PLUS,result_addr,result_mult,NULL);
    $$.result = result_addr;//l'adresse où l'ont doit écrire
    $$.code = quad_add(mult_size,addr);
  }
  ;
/**
 * @V. affectation
 */
affectation:
    ID OP_ASSIGN expression {
      struct symbol* result = symbol_lookup(symbol_list, $1);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s\n",$1);
        exit(1);
      }
      if(result->is_array){
        printf("ERROR: try to modify a array -> %s\n",$1);
        exit(1);
      }
      if(result->isconstant){
        printf("ERROR: try to modify a constant  -> %s\n",$1);
        exit(1);
      }
      result->is_initialised = true;
      $$.result = result;
      struct quad* quad = quad_gen(E_ASSIGN,result,$3.result,NULL);
      struct quad* code = quad_add($3.code,quad);
      $$.code = code;
      debug("ID = expr");
      free($1);
    }
    |
    ID '['array mark_array_write OP_ASSIGN expression {
      //voir IV. array
      struct symbol* result = symbol_lookup(symbol_list, $1);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s\n",$1);
        exit(1);
      }
      if(result->is_array == false){
        printf("ERROR: %s is not a array\n",$1);
        exit(1);
      }
      $4.code->arg2 = $3.result;//donner le calcul de l'offset (va être multiplier par 4)
      $4.code->next->arg2 = result;//donner le nom du tableau pour le calcul de l'offset
      struct quad* quad = quad_gen(E_TAB_WRITE,$6.result,$4.result,NULL);
      struct quad* code = quad_add($3.code,$4.code);
      //complète les quads de calcul d'offset avec les dimensions du tableau
      quad_list_array_complete($3.true_list,result->array_dimension);
      code = quad_add(code,$6.code);
      code = quad_add(code,quad);
      $$.code = code;
      debug("ID [...] = expr");
      free($1);
    }
    | ID OP_INC {
      struct symbol* result = symbol_lookup(symbol_list, $1);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s\n",$1);
        exit(1);
      }
      if(result->is_array == true){
        printf("ERROR: can't do ++ to a array");
        exit(1);
      }
      if(result->isconstant){
        printf("ERROR: try to modify a constant  -> %s\n",$1);
        exit(1);
      }
      if(result->is_initialised == false){
        printf("WARNING: using uninitialized variable -> %s\n",$1);
      }
      $$.result = result;
      struct symbol* temp = symbol_newtemp_init(&symbol_list,1);
      struct quad* quad = quad_gen(E_PLUS,result,result,temp);
      $$.code = quad;
      free($1);
    }
    | ID OP_DEC {
      struct symbol* result = symbol_lookup(symbol_list, $1);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s\n",$1);
        exit(1);
      }
      if(result->is_array == true){
        printf("ERROR: can't do -- to a array");
        exit(1);
      }
      if(result->isconstant){
        printf("ERROR: try to modify a constant  -> %s\n",$1);
        exit(1);
      }
      if(result->is_initialised == false){
        printf("WARNING: using uninitialized variable -> %s\n",$1);
      }
      $$.result = result;
      struct symbol* temp = symbol_newtemp_init(&symbol_list,1);
      struct quad* quad = quad_gen(E_MINUS,result,result,temp);
      $$.code = quad;
      free($1);
    }
    ;
/**
 * @VI. declaration_affectation
 */
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
      result->is_initialised = true;
      $$.result = result;
      struct quad* quad = quad_gen(E_ASSIGN,result,$4.result,NULL);
      struct quad* code = quad_add($4.code,quad);
      $$.code = code;
      free($2);

    }
    |
    CONST INT ID OP_ASSIGN expression {
      debug("CONST INT ID = expr");
      struct symbol* result = symbol_lookup(symbol_list, $3);
      if(result == NULL){
        result = symbol_add(&symbol_list,$3);
        result->isconstant = true;
      }else{
        printf("ERROR: already declared variable -> %s\n",$3);
        exit(1);
      }
      result->is_initialised = true;
      result->is_never_used = true;
      $$.result = result;
      struct quad* quad = quad_gen(E_ASSIGN,result,$5.result,NULL);
      struct quad* code = quad_add($5.code,quad);
      $$.code = code;
      free($3);
    }
    ;
/**
 * @VII. expression
 */
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
      debug("- expr");
      struct symbol* result = symbol_newtemp(&symbol_list);
      struct symbol * temp  = symbol_newtemp_init(&symbol_list,0);
      $$.result = result;
      struct quad* quad = quad_gen(E_MINUS,result,temp,$2.result);
      struct quad* code = quad_add($2.code,quad);
      $$.code = code;
    }
    |
    expression OP_MULTI expression {
      debug("expr * expr");
      struct symbol* result = symbol_newtemp(&symbol_list);
      $$.result = result;
      struct quad* quad = quad_gen(E_MULT,result,$1.result,$3.result);
      struct quad* code = quad_add($1.code,$3.code);
      code = quad_add(code,quad);
      $$.code = code;
    }
    |
    expression OP_DIV expression {
      debug("expr / expr");
      struct symbol* result = symbol_newtemp(&symbol_list);
      $$.result = result;
      struct quad* quad = quad_gen(E_DIV,result,$1.result,$3.result);
      struct quad* code = quad_add($1.code,$3.code);
      code = quad_add(code,quad);
      $$.code = code;
    }
    |
    '(' expression ')'{
      debug("(  expr ) ");
      $$.result = $2.result;
      $$.code = $2.code;
    }
    |
    ID {
      struct symbol* result = symbol_lookup(symbol_list, $1);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s\n",$1);
        exit(1);
      }
      if(result->is_define == true){
        if(result->is_initialised == false){
          printf("ERROR: using define with no value -> %s\n",$1);
          exit(1);
        }
      }
      else if(result->is_initialised == false){
        printf("WARNING: using uninitialized variable -> %s\n",$1);
      }
      result->is_never_used = false;
      $$.result = result;
      $$.code = NULL;
      debug("ID");
      free($1);

    }
    |
    ID '['array mark_array_load {
      //voir IV. array
      struct symbol* result = symbol_lookup(symbol_list, $1);
      if(result == NULL){
        printf("ERROR: undeclared variable -> %s\n",$1);
        exit(1);
      }
      if(result->is_array == false){
        printf("ERROR: %s is not a array\n",$1);
        exit(1);
      }
      $4.code->arg2 = $3.result;
      $4.code->next->arg2 = result;
      struct quad* code = quad_add($3.code,$4.code);
      quad_list_array_complete($3.true_list,result->array_dimension);
      $$.code = code;
      $$.result = $4.result;
      debug("ID [...]");
      free($1);

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


/**
 * @VIII. structures de contrôle
 */
mark:
  //marqueur pour les else, for et while
  {
    $$.code = quad_gen(E_GOTO,NULL,NULL,NULL);
    $$.false_list = quad_list_new($$.code);
    $$.true_list = $$.false_list;
  }
  ;


control_structure:
    IF '(' condition ')' '{' statement_list '}' {
      debug("if (condition) {statement_list}");
      //permet de gérer le cas où la statement_list est vide
      //actuellement inutile avec cette grammaire car statement_list dérive toujours en au moins un element
      struct quad* last_condition = quad_last($3.code);
      struct quad* last_statement;
      struct symbol* where_true = symbol_newtemp_init(&symbol_list,last_condition->number+1);
      struct symbol* where_false;
      quad_list_complete($3.true_list,where_true);
      $$.code = quad_add($3.code,$6.code);
      //permet de gérer le cas où la statement_list est vide
      //actuellement inutile avec cette grammaire car statement_list dérive toujours en au moins un element
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
      //voir IF '(' condition ')' '{' statement_list '}'
      //mark permet de créer le goto pour sortir du if sans exécuté le code du else
      debug("if (condition) {statement_list} else { statement_list}");
      struct quad* last_condition = quad_last($3.code);
      struct quad* code;
      struct quad* last_statement;
      struct symbol* where_true = symbol_newtemp_init(&symbol_list,last_condition->number+1);
      struct symbol* where_false;
      //$3.false_list = quad_list_concat($3.false_list,$10.false_list);
      quad_list_complete($3.false_list,symbol_newtemp_init(&symbol_list,$10.code->number+1));
      quad_list_complete($3.true_list,where_true);
      code = quad_add($3.code,$6.code);
      code = quad_add(code,$10.code);
      code = quad_add(code,$11.code);
      $$.code  = code;
      if($11.code != NULL){
        last_statement = quad_last($11.code);
      }else{
        last_statement = $10.code;
      }
      where_false = symbol_newtemp_init(&symbol_list,last_statement->number + 1);
      quad_list_complete($10.false_list,where_false);
    }
    |
    WHILE '(' condition ')' '{' statement_list mark '}' {
      //mark permet d'avoir le goto pour retourner dans la condition
      debug("while (condition) {statement_list}");
      struct quad* last_condition = quad_last($3.code);
      struct quad* code;
      struct quad* last_statement;
      struct symbol* where_true = symbol_newtemp_init(&symbol_list,last_condition->number+1);
      struct symbol* where_false;
      struct symbol* where_begin = symbol_newtemp_init(&symbol_list,$3.code->number);
      quad_list_complete($7.true_list,where_begin);
      quad_list_complete($3.true_list,where_true);
      $3.code->need_label = true;//pour l'assembleur
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
    FOR '('affectation ';' condition ';' affectation mark ')' '{' statement_list mark'}' {
      //1er  mark: permet de passer de l'affection de fin d'itération au test de condition
      //2ème mark: permet de jump de la dernière instruction de la boucle à l'affectation de fin de boucle
      debug("for (affectation; condition; affectation){ statement_list } ");
      //concaténation du code
      struct quad* code = quad_add($3.code,$5.code);
      code = quad_add(code,$7.code);
      code = quad_add(code,$8.code);
      code = quad_add(code,$11.code);
      code = quad_add(code,$12.code);
      //pour l'assembleur
      $5.code->need_label = true;
      $7.code->need_label = true;
      //remplir les quad_list
      struct symbol* where_false =  symbol_newtemp_init(&symbol_list,$12.code->number + 1);
      struct symbol* where_true =  symbol_newtemp_init(&symbol_list,$8.code->number + 1);
      struct symbol* where_begin_condition = symbol_newtemp_init(&symbol_list,$5.code->number);
      struct symbol* where_incr = symbol_newtemp_init(&symbol_list,$7.code->number);
      quad_list_complete($5.true_list,where_true);
      quad_list_complete($5.false_list,where_false);
      quad_list_complete($8.true_list,where_begin_condition);
      quad_list_complete($12.true_list,where_incr);
      $$.code = code;
    }
    ;
/**
 * @IIX. condition
 */
condition:
    expression OP_EQUAL expression {
      debug("elt == elt");
      struct quad* codeTrue = quad_gen(E_EQUAL,NULL,$1.result,$3.result); //if ( a == b) goto ?
      struct quad* codeFalse = quad_gen(E_GOTO,NULL,NULL,NULL); // goto ?
      struct quad* code = quad_add(codeTrue,codeFalse);
      $$.code = code;
      $$.true_list = quad_list_new(codeTrue);
      $$.false_list = quad_list_new(codeFalse);
    }
    |
    expression OP_SUP expression {
      debug("elt > elt");
      struct quad* codeTrue = quad_gen(E_SUPERIOR,NULL,$1.result,$3.result);
      struct quad* codeFalse = quad_gen(E_GOTO,NULL,NULL,NULL);
      struct quad* code = quad_add(codeTrue,codeFalse);
      $$.code = code;
      $$.true_list = quad_list_new(codeTrue);
      $$.false_list = quad_list_new(codeFalse);
    }
    |
    expression OP_INF expression {
      debug("elt < elt");
      struct quad* codeTrue = quad_gen(E_INFERIOR,NULL,$1.result,$3.result);
      struct quad* codeFalse = quad_gen(E_GOTO,NULL,NULL,NULL);
      struct quad* code = quad_add(codeTrue,codeFalse);
      $$.code = code;
      $$.true_list = quad_list_new(codeTrue);
      $$.false_list = quad_list_new(codeFalse);
    }
    |
    expression OP_SUP_EQUAL expression {
      debug("elt >= elt");
      struct quad* codeTrue = quad_gen(E_SUPEQUAL,NULL,$1.result,$3.result);
      struct quad* codeFalse = quad_gen(E_GOTO,NULL,NULL,NULL);
      struct quad* code = quad_add(codeTrue,codeFalse);
      $$.code = code;
      $$.true_list = quad_list_new(codeTrue);
      $$.false_list = quad_list_new(codeFalse);
    }
    |
    expression OP_DIFF expression {
      debug("elt != elt");
      struct quad* codeTrue = quad_gen(E_DIFFERENT,NULL,$1.result,$3.result);
      struct quad* codeFalse = quad_gen(E_GOTO,NULL,NULL,NULL);
      struct quad* code = quad_add(codeTrue,codeFalse);
      $$.code = code;
      $$.true_list = quad_list_new(codeTrue);
      $$.false_list = quad_list_new(codeFalse);
    }
    |
    expression OP_INF_EQUAL expression {
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
      debug("true");
    }
    |
    FALSE {
      $$.code = quad_gen(E_GOTO,NULL,NULL,NULL);
      $$.false_list = quad_list_new($$.code);
      debug("false");
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
    extern int yylineno;
    err = 1;
    fprintf(stderr, "[Yacc] error near line %d : %s\n", yylineno, s);
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

    if (err == 0) {
        #ifdef DEBUG
        printf("-----------------\nSymbol table:\n");
        symbol_print(symbol_list);
        printf("-----------------\nQuad list:\n");
        quad_print(quad_list);
        #endif

        //generation code assembleur
        generator(symbol_list, quad_list);
    }
    struct symbol* parcours = symbol_list;
    while(parcours != NULL){
      if(parcours->is_never_used == true){
        printf("WARNING: %s is never used\n",parcours->identifier);
      }
      parcours = parcours->next;
    }


    // Be clean.
    lex_free();
    quad_free(quad_list);
    symbol_free(symbol_list);
    return 0;
}
