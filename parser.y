%{
    #include <stdio.h>
    #include <string.h>
    #include "defs.h"
    #include "translator.c"
    #include "symtab.h"
    #include "semantic.h"

    #define YYSTYPE char*

    int yyparse(void);
    int yylex(void);
    int yyerror(char *s);


    int class_id = -1;
    int designator_class_id = -1;
    extern int line;
    int level = 0;
    char* type;
    extern FILE * yyin;
    int error_count = 0;
    FILE *fp;
    int function_index = -1;
    char* function_type;
    char* glob_designator = NULL;
    int par_num = 0;
    char* ex_type = NULL;
    int if_or_while = 0;
    int arg_num = 0;
    int function_call_index = -1;
    int glob_designator_id=-1;
    char* to_assign_type=NULL;
    int to_assign_id=-1;
    int return_called=0;
%}

%token _TYPE
%token _IF
%token _ELSE
%token _RETURN
%token _ID
%token _INT_NUMBER
%token _UNSIGNED_NUMBER
%token _LPAREN
%token _RPAREN
%token _COMMA
%token _LBRACKET
%token _RBRACKET
%token _ASSIGN
%token _SEMICOLON
%token _PLUS
%token _MINUS
%token _TIMES
%token _DIV
%token _MOD
%token _RELOP
%token _INCLUDE
%token _CHAR
%token _REAL
%token _STRING
%token _VOJD
%token _WHILE
%token _SCANF
%token _APERSANT
%token _PRINTF
%token _ARRAY_VALUE
%token _SWITCH
%token _COLON
%token _BREAK
%token _RSQUARE_BRACKET
%token _AND
%token _OR
%token _NOT
%token _NOTB
%token _ORB
%token _PLUS_PLUS
%token _MINUS_MINUS
%token _PROGRAM
%token _NEW
%token _READ
%token _CLASS
%token _CONST
%token _EXTENDS
%token _FALSE
%token _TRUE
%token _DOT
%token _POINT_ID
%token _LSQUARE_BRACKET
%token _NULL
%token _START_METHOD_DECL

%%
program
    : _PROGRAM _ID {
      insert_symbol("eol", METHOD, "char", 0, -1);
      set_attribute(0, 0);

      insert_symbol("ord", METHOD, "int", 0, -1);
      set_param_type(1, 1, "char");
      set_attribute(1, 1);

      insert_symbol("chr", METHOD, "char", 0, -1);
      set_param_type(2, 1, "int");
      set_attribute(2, 1);

      insert_symbol("len", METHOD, "int", 0, -1);
      set_param_type(3, 1, "string");
      set_attribute(3, 1);
    }
      allDeclarations _LBRACKET methodDeclarations _RBRACKET {
    check_main();  print_symtab();}
    ;

allDeclarations
    : allDeclarations allDeclaration
    |
    ;


allDeclaration
    : classDeclaration {}
    | varDeclaration {}
    | constDeclaration {}
    ;

varDeclarations
    : varDeclarations  varDeclaration
    | { }
    ;


varDeclaration
    : type{
      if (check_type_existance($1) == 1) type = $1;
      else {
        printf("Line: %d: Type does not exist", line);
        type = "";
      }
    }
      var_enumeration _SEMICOLON
    ;

classVarDeclarationsAndMethods
    : varDeclarations varDeclaration methodDeclarations
    |
    ;

constDeclaration
    : _CONST type {type = $2; if(check_primitive_type($2) == -1) printf("Line: %d : Invalid constant type!\n", line); } clist _SEMICOLON
    ;

clist
    : _ID _ASSIGN constvalue {if(strcmp(type, $3) != 0) printf("Line: %d : Invalid assignment!\n", line);
				try_to_insert_constant($1, type);}
    | clist _COMMA _ID _ASSIGN constvalue {if(strcmp(type, $5) != 0) printf("Line: %d : Invalid assignment!\n", line);
						try_to_insert_constant($3, type);}
    ;

type
    : _TYPE
    | _ID
    ;

classDeclaration
    : _CLASS _ID _EXTENDS _ID {
      class_id = register_class($2, $4);
      if (class_id != -1) level = 1 ;
      else class_id = -11;
    }
    _LBRACKET varDeclarations methodDeclarations
    _RBRACKET {
      class_id = -1;
      level = 0;
    }
    | _CLASS _ID _LBRACKET {
      class_id = register_class($2, NULL);
      if (class_id != -1) level = 1 ;
      else class_id = -11;
    }
    varDeclarations methodDeclarations  _RBRACKET {
      class_id = -1;
      level = 0;
    }
    ;

methodDeclarations
    : _START_METHOD_DECL{
      function_index = insert_method(parse_method_name($1), class_id, parse_method_type($1), level);
		  level++;
	  }
    formParams {
      set_attribute(function_index, par_num);
      par_num=0;
    }
    _RPAREN  varDeclarations _LBRACKET statements _RBRACKET {
      level--;
      if(strcmp(get_type(function_index),"void") != 0 && return_called <=0)
        printf("Line: %d: Method does not have a return call\n",line);
      if (function_index != -1)
        if (function_index != get_last_element() )
          clear_symbols(function_index+1);
      function_index = -1;
      return_called=0;
    }
    methodDeclarations
    |
    ;

formParams
    : arguments
    |
    ;

arguments
    :   type arrayOrId {
      if (function_index != -1){
        if (check_type_existance($1) == 1){
          int index;
          index = push_array_or_id($2, $1, class_id, level);
          set_initialized(index,1);
          par_num++;
          set_param_type(function_index, par_num, get_type(index));
        }else{ // ne valja nam type argumenta pa brisemo sve prethodne i metodu
          clear_symbols(function_index);
          function_index = -1;     //OOOOOOOOVOOOOOOOOO DOOOOOOOOOBROOOOOOO TESTIRATIIIIIIIIIII
        }
      }
	  }
    |   arguments _COMMA type arrayOrId {
      if (function_index != -1){
        if (check_type_existance($3) == 1){
          int index;
          index = push_array_or_id($4, $3, class_id, level);
          set_initialized(index,1);
          par_num++;
          set_param_type(function_index, par_num, get_type(index));
        }else{ // ne valja nam type argumenta pa brisemo sve prethodne i metodu
          clear_symbols(function_index);
          function_index = -1;     //OOOOOOOOVOOOOOOOOO DOOOOOOOOOBROOOOOOO TESTIRATIIIIIIIIIII
        }
      }
    }
    ;

methodType
    : type
    | _VOJD
    ;

var_enumeration
    : var_enumeration _COMMA arrayOrId {
      if (strcmp(type, "") != 0)
        push_array_or_id($3, type, class_id, level);

	   }
    | arrayOrId {
      if (strcmp(type, "") != 0)
        push_array_or_id($1, type, class_id, level);
	  }
    ;

arrayOrId
    : _ID {$$ = $1;}
    | _ARRAY_VALUE _RSQUARE_BRACKET {$$ = strcat($1, $2);}
    ;

designator
    : _ID {
      glob_designator = $1;
      designator_class_id = class_id;
      if((glob_designator_id=lookup_id_in_class_var(glob_designator,class_id))==-1)
        if((glob_designator_id=lookup_id(glob_designator,VARIABLE,0)) !=-1 || (glob_designator_id=lookup_id(glob_designator,METHOD,0)) !=-1){
          designator_class_id=-1;
        }
    }
      designatorExt
    | _ARRAY_VALUE {
      glob_designator = $1;
      designator_class_id = class_id;
      if((glob_designator_id=lookup_id_in_class_var(glob_designator,class_id)) == -1)
        if((glob_designator_id=lookup_id(glob_designator,VARIABLE,0)) != -1 || (glob_designator_id=lookup_id(glob_designator,METHOD,0)) !=-1){
          designator_class_id = -1;
        }
    }
      expression _RSQUARE_BRACKET designatorExt
    ;

designatorExt
    : _POINT_ID{
      int index;
      int glob_designator_index;
      //printf("Id: %d\n",glob_designator_id);
      if(glob_designator_id != -1){
        if ((index = check_if_class_instance(glob_designator, get_class_id(glob_designator_id))) != -1){
          glob_designator_index = lookup_var_in_class(glob_designator, designator_class_id);
          if(is_initialized(glob_designator_index) == -1) {
            printf("Line: %d: %s is not initialized!\n", line, glob_designator);
          }
          glob_designator = $1 + 1;
          designator_class_id = index;
        }
      }
      else{
        printf("Line: %d: %s does not exist\n",line, glob_designator);
        designator_class_id=-1;
      }
    }
    | _LSQUARE_BRACKET expression _RSQUARE_BRACKET{
      strcat(glob_designator,"[");
    }
    | designatorExt _POINT_ID{
      int index;
      int glob_designator_index;
      if ((index = check_if_class_instance(glob_designator, designator_class_id)) != -1){
        glob_designator_index = lookup_var_in_class(glob_designator, designator_class_id);
        if(is_initialized(glob_designator_index) == -1) {
          printf("Line: %d: %s is not initialized!\n", line, glob_designator);
        }
        glob_designator = $2 + 1;
        designator_class_id = index;
        //printf("glob_designator: %s\n",glob_designator);
      }
    }
    | designatorExt _LSQUARE_BRACKET expression _RSQUARE_BRACKET {
      strcat(glob_designator,"[");
    }
    |
    ;

statement
    : designator {to_assign_type = glob_designator; to_assign_id = designator_class_id;}_ASSIGN
      expression _SEMICOLON {
      //printf("What id is it: %d\n",to_assign_id);
      char* designator_type= get_designator_type(to_assign_type,to_assign_id);
      //printf("Type 1: %s vs Type 2: *%s*\n",designator_type,$4);
      if(designator_type!=NULL){
        if(get_kind(lookup_var_in_class(to_assign_type,to_assign_id)) == VARIABLE) {
          char *new = malloc(5);
          new=strncpy(new,$4,4);
          if(strcmp(new,"new ")==0){
            if(strcmp(designator_type,$4+4)!=0){
              printf("Line: %d: Wrong assignment type\n",line);
            }
            else set_initialized(lookup_var_in_class(to_assign_type,to_assign_id), 1);
          }
          else{
            if(strcmp(designator_type,"int") != 0 && strcmp(designator_type,"char") != 0 && strcmp(designator_type,"bool") != 0){
              if(strcmp(designator_type, $4) != 0 && strcmp($4,"null") != 0){
                if(strcmp(designator_type,"char[]")!=0 || strcmp($4,"string")!=0)
                  printf("Line: %d: Wrong assignment type!\n", line);
                else set_initialized(lookup_var_in_class(to_assign_type,to_assign_id), 1);
              }
              else set_initialized(lookup_var_in_class(to_assign_type,to_assign_id), 1);
            }
            else{
              if(strcmp(designator_type, $4) != 0)
                  printf("Line: %d: Wrong assignment type!\n", line);
              else set_initialized(lookup_var_in_class(to_assign_type,to_assign_id), 1);
            }
          }
        }else {
          printf("Line: %d: Can not assign a value to a method!\n", line);
        }
      }
    }
    | designator {
        char* designator_type = get_designator_type(glob_designator,designator_class_id);
        int index;
        if(designator_type != NULL) {
          if(get_kind(index = lookup_var_in_class(glob_designator, designator_class_id)) == METHOD){
            function_call_index = index;
          } else
            printf("Line: %d: %s is not a method!\n", line, glob_designator);
        }
    }
     _LPAREN actParams {arg_num = 0;} _RPAREN _SEMICOLON

    | designator _PLUS_PLUS _SEMICOLON {
      int index;
      char* designator_type = get_designator_type(glob_designator,designator_class_id);
      if(get_kind(index = lookup_var_in_class(glob_designator, designator_class_id)) == VARIABLE){
        if(strcmp(designator_type, "int") == 0) {
          if(is_initialized(index) == -1)
            printf("Line: %d: %s is not initialized!\n", line, glob_designator);
        }else {
          printf("Line: %d: %s is not an integer!\n", line, glob_designator);
        }
      }else {
        printf("Line: %d: %s is not a variable!\n", line, glob_designator);
      }
    }

    | designator _MINUS_MINUS _SEMICOLON {
      int index;
      char* designator_type = get_designator_type(glob_designator,designator_class_id);
      if(get_kind(index = lookup_var_in_class(glob_designator, designator_class_id)) == VARIABLE){
        if(strcmp(designator_type, "int") == 0) {
          if(is_initialized(index) == -1)
            printf("Line: %d: %s is not initialized!\n", line, glob_designator);
        }else {
          printf("Line: %d: %s is not an integer!\n", line, glob_designator);
        }
      }else {
        printf("Line: %d: %s is not a variable!\n", line, glob_designator);
      }
    }
    | _IF _LPAREN condition _RPAREN {if_or_while++; } statement {if_or_while--; } //resen
    | _IF _LPAREN condition _RPAREN {if_or_while++; } statement _ELSE statement {if_or_while--; } //resen
    | _WHILE _LPAREN condition _RPAREN {if_or_while++; } statement {if_or_while--; } //resen
    | _BREAK {
        if(if_or_while <= 0) {
          printf("Line: %d: Break can not be placed here!\n", line);
        }
      }
     _SEMICOLON
    | _RETURN _SEMICOLON {
      if(strcmp("void", get_type(function_index)) != 0){
        printf("Line: %d: Function has to return %s\n",line, get_type(function_index));
      }
    }
    | _RETURN expression
      {
        if(strcmp(get_type(function_index), $2) != 0) {
          if(strcmp(get_type(function_index), "void") == 0)
            printf("Line: %d: Function does not have a return type\n", line);
          else
            printf("Line: %d: Function has to return %s \n", line, get_type(function_index));

        }
        return_called++;
      }
      _SEMICOLON
    | _READ _LPAREN designator{
      char* designator_type = get_designator_type(glob_designator,designator_class_id);
      if(get_kind(lookup_var_in_class(glob_designator, designator_class_id)) != VARIABLE) {
        printf("Line: %d: A value cannot be assigned to a method\n", line);
      }
    } _RPAREN _SEMICOLON
    | _PRINTF _LPAREN expression {
      if (check_primitive_type($3) == -1){
        printf("Line: %d: Only primitive types can be printed\n", line);
      }
    } _RPAREN _SEMICOLON
    | _PRINTF _LPAREN expression{
      if (check_primitive_type($3) == -1)
        printf("Line: %d: Only primitive types can be printed\n", line);
      } _COMMA _INT_NUMBER _RPAREN _SEMICOLON
    | _LBRACKET {level++;}
      statements _RBRACKET {level--;}
    ;

statements
    : statements statement
    |
    ;

condition
    : conditionTerm  orConditionTerms
    ;

orConditionTerms
    : _OR conditionTerm
    | orConditionTerms _OR conditionTerm
    |
    ;

conditionTerm
    : conditionFactor andConditionFactors
    ;


andConditionFactors
    : _AND conditionFactor
    | andConditionFactors _AND conditionFactor
    |
    ;

conditionFactor
    : expression {
        if(strcmp($1,"bool")!=0){
          printf("Line: %d: Expression is not a boolean type\n",line);
        }
    }
    | expression _RELOP expression{
      if(strcmp($1,$3)!=0){
        printf("Line: %d: Types not compatible\n",line);
      }
    }
    ;


expression
    : _MINUS term addopTerms {
      if($3[0]!=' ')
        if(strcmp($2,$3+1)==0){
          if($3[0]=='+'){
            if(strcmp($2,"int")!=0 && strcmp($2,"string")!=0)
              printf("Line: %d: Not integers or strings\n",line);
          }
          else{
            if(strcmp($2,"int")!=0)
              printf("Line: %d: Not integers\n",line);
          }
        }
        else{
          printf("Line: %d: Types not compatible\n",line);
        }
      $$=$2;
    }
    | term addopTerms {
      //printf("Usli smo u expression, $1(term): %s  $2(addopTerms):  %s\n", $1, $2);
      if($2[0]!=' ')
        if(strcmp($1,$2+1)==0){
          if($2[0]=='+'){
            if(strcmp($1,"int")!=0 && strcmp($1,"string")!=0)
              printf("Line: %d: Not integers or strings\n",line);
          }
          else{
            if(strcmp($1,"int")!=0)
              printf("Line: %d: Not integers\n",line);
          }
        }
        else{
          printf("Line: %d: Types not compatible\n",line);
        }
        //printf("Ne izadje bre\n");
      $$=$1;
      //printf("Line: %d: Jel stvarno %s\n",line,$1);
    }
    ;

term
    : factor mulopFactors {
      //printf("Usli smo u term, $1(factor): %s  $2(mulopFactor):  *%s*\n", $1, $2);
      if($2[0]!=' ')
        if(strcmp($1,$2)==0){
          if(strcmp($1,"int")!=0)
            printf("Line: %d: Not integers\n",line);
        }
        else{
          printf("Line: %d: Types not compatible\n",line);
        }
        //printf("Ovaj %s u termu prodje\n",$1);
      $$=$1;
    }
    ;

mulopFactors
    : mulop factor {$$=$2;}
    | mulopFactors mulop factor {
      if(strcmp($1,$3)==0){
        if(strcmp($1,"int")!=0)
          printf("Line: %d: All operands should be integers\n",line);
      }
      else{
        printf("Line: %d: Types not compatible\n",line);
      }
      $$=$3;
    }
    | {$$=" ";}
    ;

mulop
    : _DIV
    | _MOD
    | _TIMES
    ;

addop
    : _PLUS
    | _MINUS
    ;


addopTerms
    : addop term {$$=strcat($1,$2);}
    | addopTerms addop term {
      //printf("wdlfhgfehgowefhi\n");
      if(strcmp($1,$3)!=0){
        if(strcmp($2,"+")==0){
          if(strcmp($1,"int")!=0 && strcmp($1,"string")!=0)
            printf("Line: %d: Not integers or strings\n",line);
        }else{
          if(strcmp($1,"int")!=0)
            printf("Line: %d: Not integers\n",line);
        }
      }
      else{
        printf("Line: %d: Types not compatible\n",line);
      }
      $$=strcat($1,$3);
    }
    | {$$=" ";}
    ;


factor
    : designator {
        char* designator_type;
        designator_type = get_designator_type(glob_designator, designator_class_id);
        if(designator_type != NULL) {
          if(get_kind(lookup_var_in_class(glob_designator, designator_class_id)) == VARIABLE) {
            if(is_initialized(lookup_var_in_class(glob_designator, designator_class_id)) == -1) {
              printf("Line: %d: %s is not initialized\n",line,glob_designator);
            }
            $$=designator_type;
          } else {
            if (glob_designator[strlen(glob_designator)-1] == '[')
              glob_designator[strlen(glob_designator)-1] = '\0';
            printf("Line: %d: %s is not a variable!\n", line, glob_designator);
          }
        }

    }
    | designator {
        int index;
        //printf("Trivicev bug :  glob_designator: %s     designator_class_id: %d\n",glob_designator, designator_class_id);
        char* designator_type = get_designator_type(glob_designator, designator_class_id);
        //printf("Line: %d: tip pre %s\n",line,designator_type);
        if(designator_type != NULL) {
          if(get_kind(index = lookup_var_in_class(glob_designator, designator_class_id)) == METHOD) {
            $1=designator_type;
            //printf("Line: %d: tip %s\n",line,designator_type);
            function_call_index = index;
          } else {
            if (glob_designator[strlen(glob_designator)-1] == '[')
              glob_designator[strlen(glob_designator)-1] = '\0';
            printf("Line: %d: %s is not a method!\n", line, glob_designator);
          }
        }

    }
    _LPAREN actParams{arg_num = 0;}  _RPAREN { $$=$1;}
    | num { $$=$1;
    }
    | _NEW type {
      //printf("Line %d $2: %s\n", line, $2);
      $$ = malloc(100);
      strcat($$, "new ");
      //printf("WTF\n");
      strcat($$, $2);
      //printf("Ispisujem nesto\n");

      //printf("Line %d $$: %s\n", line, $$);
    }
    | _NEW _TYPE {
      $$ = malloc(100);
      strcat($$, "new ");
      //printf("WTF\n");
      strcat($$, $2);
    }
      _LSQUARE_BRACKET expression _RSQUARE_BRACKET
    | _NEW _ARRAY_VALUE {
          char* type=malloc(strlen($2)+1);
          type[strlen($2)]=']';
          $$ = malloc(100);
          strcat($$, "new ");
          strcat($$,type);
      }
      expression {}
      _RSQUARE_BRACKET
    | _LPAREN expression _RPAREN {$$=$2;}
    ;

num
    : _INT_NUMBER      {$$ = "int";}
    | _UNSIGNED_NUMBER {$$ = "int";}
    | _CHAR            {$$ = "char";}
    | _STRING          {$$ = "string";}
    | _NULL            {$$ = "null";}
    ;

constvalue
    : num
    | _FALSE {$$ = "bool";}
    | _TRUE  {$$ = "bool";}
    ;


actParams
      :{char* arg = malloc(2);
        arg[0]=1;
        arg[1]=function_call_index;
        $$=arg;
      }
      expression {
        char* tip= malloc(100);
        tip = $1;
        char* param_type = get_param_type($$[1], $$[0]);
      //printf("FUNCTION CALL INDEX1: %d\n", $$[1]);
      //printf("Expected type(%d): %s and current type: %s\n",$$[0],get_param_type($$[1],$$[0]),$2);
      if(strcmp(param_type,"int") != 0 && strcmp(param_type,"char") != 0 && strcmp(param_type,"bool") != 0){
        if(strcmp(param_type, $2) != 0 && strcmp($2,"null") != 0) {
          printf("Line: %d: Incorrect argument type!\n", line);
        }
      }
      else{
        if(strcmp(param_type, $2) != 0) {
          printf("Line: %d: Incorrect argument type!\n", line);
        }
      }

    }
    | actParams _COMMA expression {
      char* arg = malloc(2);
      arg[0]=$1[0]+1;
      arg[1]=$1[1];
      $$=arg;
      char* tip=$3;
      char* param_type=get_param_type($$[1], $$[0]);
      //printf("FUNCTION CALL INDEX2: %d\n", $$[1]);
      //printf("Expected type(%d): %s and current type: %s\n",$$[0],get_param_type($$[1],$$[0]),$3);
      if(strcmp(param_type,"int") != 0 && strcmp(param_type,"char") != 0 && strcmp(param_type,"bool") != 0){
        if(strcmp(param_type, $3) != 0 && strcmp($3,"null") != 0){
          printf("Line: %d: Incorrect argument type!\n", line);
        }
      }
      else{
        if(strcmp(param_type, $3) != 0) {
          printf("Line: %d: Incorrect argument type!\n", line);
        }
      }
    }
    |
    ;


%%

int yyerror(char *s) {
    fprintf(stderr, "\nERROR (%d): %s", line, s);
    error_count++;
    return 0;
}

int main(int argc, char *argv[]) {
    yyin = fopen(argv[1], "r");
    yyparse();
    return error_count;
}
