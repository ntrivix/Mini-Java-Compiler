
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "defs.h"
#include "symtab.h"

#define MAX_UNSIGNED_NUMBER  (1L << TYPE_BIT_SIZE) - 1
#define MIN_INT_NUMBER       (-(1L << (TYPE_BIT_SIZE - 1)))
#define MAX_INT_NUMBER       ((1L << (TYPE_BIT_SIZE - 1)) - 1)

SYMBOL_ENTRY symbol_table[SYMBOL_TABLE_LENGTH];

int first_empty = 0;
extern int line;

// Vraca indeks prvog sledeceg praznog elementa.
int get_next_empty_element(void) {
    if(first_empty < SYMBOL_TABLE_LENGTH)
        return first_empty++;
    else {
        printf("Line: %d : Compiler error! Symbol table overflow!", line);
        exit(EXIT_FAILURE);
    }
}

// Vraca indeks poslednjeg zauzetog elementa.
int get_last_element(void) {
    return first_empty-1;
}

// Ubacuje simbol sa datom oznakom simbola i tipom simbola i vraca indeks ubacenog elementa u tabeli simbola ili -1.
int insert_symbol(char *name, unsigned kind, char* type, int level,int class_id) {
    int index = get_next_empty_element();
    symbol_table[index].name = name;
    symbol_table[index].kind = kind;
    symbol_table[index].type = type;
    symbol_table[index].level = level;
    symbol_table[index].class_id = class_id;
    symbol_table[index].initialized = -1;
    return index;
}

char* parse_method_type(char* str){
  int i=0;
  char* val=malloc(strlen(str));
  while(str[i]!=' '){
    val[i]=str[i];
    i++;
  }
  return val;
}

char* parse_method_name(char* str){
  int i=0;
  int j=0;
  int max=strlen(str);
  char* val=malloc(max);
  while(str[i]!=' ')
    i++;
  while(str[i]==' ')
    i++;
  while(i<max-1){
      val[j]=str[i];
      i++;
      j++;
  }
  return val;
}

// Proverava da li se simbol vec nalazi u tabeli simbola, ako se ne nalazi ubacuje ga, ako se nalazi ispisuje gresku.
// Vraca indeks elementa u tabeli simbola.
int try_to_insert_id(char *name, unsigned kind, char* type, int level,int class_id) { //ovo nije sigurno da radi
    int index;
    if( (index = lookup_id_strict(name, level)) == -1){
            index = insert_symbol(name, kind, type, level,class_id);
        //printf("Ubacujem: %s sa levelom: %d \n",name,level);
	  }
    else {
      if(symbol_table[index].class_id != class_id)
          index = insert_symbol(name, kind, type, level,class_id);
      else
          printf("Line: %d : Redefinition of '%s' \n",line, name);
    }
    return index;
}

// Ubacuje konstantu u tabelu simbola (ako vec ne postoji).
int try_to_insert_constant(char *str, char* type) {
    int index;
    if( (index = lookup_id_strict(str, 0)) == -1 ) {
        // provera opsega za konstante
        long number = atol(str);

	if( number < MIN_INT_NUMBER || number > MAX_INT_NUMBER)
                  printf("Line: %d : constant out of range\n", line);
        index = insert_symbol(str, CONSTANT, type, 0,-1);

    }
	else
		printf("Line: %d : redefinition of '%s' \n",line, str);
    return index;
}

void set_initialized(int index, int value) {
	if(index > -1 && index < SYMBOL_TABLE_LENGTH)
       		symbol_table[index].initialized = value;
}

int is_initialized(int index){
	if(index > -1 && index < SYMBOL_TABLE_LENGTH)
        	return symbol_table[index].initialized;
    	return -1;
}

//Vraca indeks pronadjenog simbola ili vraca -1.
int lookup_global(char* name){
  int i;
  for(i =0 ; i < first_empty; i++) {
      if(strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].level == 0)
          return i;
  }
  return -1;
}


//Vraca pomenljivu
lookup_var_in_class(char* name, int class_id){
  int i;
  for(i = first_empty - 1; i >= 0; i--) {
      if(strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].class_id == class_id)
          return i;
  }
  return -1;
}

//
lookup_var_in_scope(char* name, int class_id, int level){
  int i;
  for(i = first_empty - 1; i >= 0; i--) {
      if(strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].class_id == class_id && symbol_table[i].level == level)
          return i;
  }
  return -1;
}

// Vraca indeks pronadjenog simbola ili vraca -1.
int lookup_id(char *name, unsigned kind, int level) {
    int i;
    for(i = first_empty - 1; i >= 0; i--) {
        if(strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].level <= level && symbol_table[i].kind == kind)
            return i;
	/*printf("For %d\n",i);
	printf("name: %s, table name: %s\n",name,symbol_table[i].name);
	printf("level: %d, table level: %d\n",level,symbol_table[i].level);*/
    }
    return -1;
}

int lookup_id_nokind(char *name, int level) {
    int i;
    for(i = first_empty - 1; i >= 0; i--) {
        if(strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].level <= level)
            return i;
    }
    return -1;
}

int lookup_id_in_class(char* name, int class_id) {
    int i;
    for(i = first_empty - 1; i >= 0; i--) {
        if(strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].class_id == class_id)
            return i;
    }
    return -1;
}

int lookup_id_in_class_var(char* name, int class_id) {
    int i;
    for(i = first_empty - 1; i >= 0; i--) {
        if(strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].class_id == class_id && symbol_table[i].kind == VARIABLE)
            return i;
    }
    return -1;
}

int lookup_id_strict(char *name, int level) {
    int i;
    for(i = first_empty - 1; i >= 0; i--) {
        if((strcmp(symbol_table[i].name, name) == 0) && (symbol_table[i].level == level)){
	    //printf("level: %d,  level iz tabele: %d \n", level, symbol_table[i].level);
            return i;
	}
    }
    return -1;
}

int lookup_id_strict_by_class(char *name, int level, int class_id) {
    int i;
    for(i = first_empty - 1; i >= 0; i--) {
        if((strcmp(symbol_table[i].name, name) == 0) && (symbol_table[i].level == level) && (symbol_table[i].class_id == class_id)){
	    //printf("level: %d,  level iz tabele: %d \n", level, symbol_table[i].level);
            return i;
	}
    }
    return -1;
}

int lookup_class_existance(char* name){
  int i;
  for(i = first_empty - 1; i >= 0; i--) {
      if((strcmp(symbol_table[i].name, name) == 0) && (symbol_table[i].kind == CLASS)){
          return i;
}
  }
  return -1;
}

int lookup_id_strict_kind(char *name, unsigned kind, int level) {
    int i;
    for(i = first_empty - 1; i >= 0; i--) {
        if((strcmp(symbol_table[i].name, name) == 0) && (symbol_table[i].level == level) && (symbol_table[i].kind == kind)){
	    //printf("level: %d,  level iz tabele: %d \n", level, symbol_table[i].level);
            return i;
	}
    }
    return -1;
}

// Vraca indeks pronadjenog simbola (konstante) ili vraca -1.
int lookup_constant(char *name) {
    int i;
    for(i = first_empty - 1; i >= 0; i--) {
        if(strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].kind == CONSTANT)
            return i;
    }
    return -1;
}

int check_primitive_type(char* type) {
	if(strcmp(type, "int") == 0 || strcmp(type, "char") == 0 || strcmp(type, "bool") == 0 || strcmp(type, "string") == 0)
		return 1;
	else
		return -1;

}

char *get_name(int index) {
    if(index > -1 && index < SYMBOL_TABLE_LENGTH)
        return symbol_table[index].name;
    return "?";
}

unsigned get_kind(int index) {
    if(index > -1 && index < SYMBOL_TABLE_LENGTH)
        return symbol_table[index].kind;
    return 0;
}

char* get_type(int index) {
    if(index > -1 && index < SYMBOL_TABLE_LENGTH)
        return symbol_table[index].type;
    return "";
}

void set_attribute(int index, int attribute) {
    if(index > -1 && index < SYMBOL_TABLE_LENGTH)
        symbol_table[index].attribute = attribute;
}

unsigned get_attribute(int index) {
    if(index > -1 && index < SYMBOL_TABLE_LENGTH)
        return symbol_table[index].attribute;
    return NO_ATTRIBUTE;
}

void set_level(int index, int level) {
    if(index > -1 && index < SYMBOL_TABLE_LENGTH)
        symbol_table[index].level = level;
}

int get_level(int index){
    if(index > -1 && index < SYMBOL_TABLE_LENGTH)
        return symbol_table[index].level;
    return NO_LEVEL;
}

void set_class_id(int index, int class_id) {
    if(index > -1 && index < SYMBOL_TABLE_LENGTH)
        symbol_table[index].class_id = class_id;
}

int get_class_id(int index){
    if(index > -1 && index < SYMBOL_TABLE_LENGTH)
        return symbol_table[index].class_id;
    return NO_CLASS_ID;
}

void set_param_type(int index, unsigned number, char* type) {
    if(index > -1 && index < SYMBOL_TABLE_LENGTH) {
        if(symbol_table[index].param_types == 0) {
            symbol_table[index].param_types = malloc(sizeof(char) * PARAM_NUMBER*20);
            int i;
            for(i = 0; i < PARAM_NUMBER; i++)
                symbol_table[index].param_types[i] = "";
        }
        if(number > 0 && number <= PARAM_NUMBER)
            symbol_table[index].param_types[number - 1] = type;
    }
}

char* get_param_type(int index, unsigned number) {
    if(index > -1 && index < SYMBOL_TABLE_LENGTH)
        if(symbol_table[index].param_types && number > 0 && number <= PARAM_NUMBER)
            return symbol_table[index].param_types[number - 1];
    return " ";
}

void set_register_type(int register_index, char* type) {
    if(register_index >= 0 && register_index <= FUNCTION_REGISTER)
        symbol_table[register_index].type = type;
}

// Brise elemente tabele simbola  od pocetnog indeksa do kraja tabele
void clear_symbols(unsigned begin_index) {
    int i;
    if(begin_index >= first_empty) {
        printf("Line: %d : Compiler error! Wrong clear symbols argument\n", line);
        exit(EXIT_FAILURE);
    }
    for(i = begin_index; i < first_empty; i++) {
        if(symbol_table[i].name)
            free(symbol_table[i].name);
        symbol_table[i].name = 0;
        symbol_table[i].kind = 0;
        symbol_table[i].type = "";
        symbol_table[i].attribute = 0;
        if(symbol_table[i].param_types)
            free(symbol_table[i].param_types);
        symbol_table[i].param_types = 0;
    }
    first_empty = begin_index;
}

// Brise sve elemente tabele simbola.
void clear_symtab(void) {
    first_empty = SYMBOL_TABLE_LENGTH - 1;
    clear_symbols(0);
}

// Ispisuje sve elemente tabele simbola.
void print_symtab(void) {
    int i,j;
    printf("\n\nSYMBOL TABLE\n");
    printf("\n         name             kind       type attr p1 p2 p3 p4 p5 p6 p7");
    printf("\n-- ---------------- ---------------- ---- ---- -- -- -- -- --");
    for(i = 0; i < first_empty; i++) {
        printf("\n%2d %-16s %16s %16s %4d %4d %4d ", i,
               symbol_table[i].name,
               symbol_kinds[(int)(logarithm2(symbol_table[i].kind))],
               symbol_table[i].type,
	             symbol_table[i].level,
               symbol_table[i].class_id,
               symbol_table[i].attribute);
        if(symbol_table[i].param_types) {
            for(j = 0; j < PARAM_NUMBER; j++)
                printf("%s ", symbol_table[i].param_types[j]);
        }
        else
            printf(" -");
    }
    printf("\n\n");
}

unsigned logarithm2(unsigned value) {
    unsigned mask = 1;
    int i = 0;
    for(i = 0; i < 32; i++) {
        if(value & mask)
            return i;
        mask <<= 1;
    }
    return 0; // ovo ne bi smelo da se desi; indeksiraj string "NONE"
}

// Inicijalizacija tabele simbola.
void init_symtab(void) {
    clear_symtab();

    int i = 0;
    char s[4];
    for(i = 0; i < 14; i++) {
        sprintf(s, "%%%d", i);
        insert_symbol(strdup(s),  WORKING_REGISTER, NO_TYPE, 0,-1);
    }
}

//===============================================================

int push_array_or_id(char* name, char* type, int class_id, int level){
  int index = -1;
  char* new_type = malloc(strlen(type));
  strcpy(new_type,type);
  if (level > 0 && class_id == -11) return -1;
  if (name[strlen(name)-1] == '[') {
    name[strlen(name)-1] = '\0';
    strcat(new_type,"[]");
  }else if(name[strlen(name)-1] == ']'){
    name[strlen(name)-2] = '\0';
    strcat(new_type,"[]");
  }
  if( (index = lookup_constant(name)) == -1 && (index = lookup_id_strict_by_class(name, level,class_id)) == -1){
    index = insert_symbol(name,   VARIABLE, new_type, level,class_id);
      //printf("Ubacujem: %s sa levelom: %d \n",name,level);
      if(strcmp(new_type, "int") == 0 || strcmp(new_type, "bool") == 0 || strcmp(new_type, "char") == 0) {
        set_initialized(index,1);
      }
  }
  else
    printf("Line: %d : Redefinition of '%s' \n",line, name);
  return index;
}

int register_class(char* name, char* extends_name){
  int ex_class_check = 1;
  if (extends_name != NULL && lookup_class_existance(extends_name) == -1){
      printf("Line: %d: Extended class not existing\n", line);
      ex_class_check = 0;
  }
  if (lookup_global(name) == -1 && ex_class_check){
    int index;
    index = insert_symbol(name, CLASS, "class", 0, -1);
    if (extends_name != NULL){
      symbol_table[index].attribute = lookup_class_existance(extends_name);
    } else
      symbol_table[index].attribute = -1;
    int this_ind = push_array_or_id("this", name, index, 1);    //ubacili this promenljivu za tu klasu i ona je tipa te klase
    set_initialized(this_ind,1);
    return index;
  }else{
    printf("Line: %d: Redefinition of %s\n", line, name);
  }
  return -1;
}

int insert_method(char* name, int class_id, char* function_type, int level){
  int index = -1;
  if (level > 0 && class_id == -11) return index;
  if ((strcmp(function_type,"void") != 0) && (check_type_existance(function_type) == -1)){
    return -1;
  }
  if (check_method_name(name, class_id) == -1){
    index = insert_symbol(name, METHOD, function_type, level, class_id);
  }else{
    printf("Line: %d: Redefinition of %s\n", line, name);
  }
  return index;
}

int check_method_name(char* name, int class_id){
  int i;
  for(i = first_empty - 1; i >= 0; i--) {
      if(strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].level <= get_level(class_id)+1 &&
        (class_id == symbol_table[i].class_id || symbol_table[i].class_id == -1)){
          return i;
        }
  }
  return -1;
}

int check_type_existance(char* name){
  int i;
  if (check_primitive_type(name) == 1) return 1;
  for(i = first_empty - 1; i >= 0; i--) {
      if(strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].kind == CLASS)
      return 1;
  }
  printf("Line: %d: Type %s does not exist\n", line, name);
  return -1;
}

int lookup_global_no_class(char* name){
  int i;
  for(i =0 ; i < first_empty; i++) {                               //NISMO SIGURNI ZA OVO, AKO NE VALJA GRIZ i PEDJA SU KRIVI
      if(strcmp(symbol_table[i].name, name) == 0 && symbol_table[i].level == 0 && symbol_table[i].kind != CLASS)
          return i;
  }
  return -1;
}

int check_if_class_instance(char* name, int class_id){
  int index = -1;
  while(1){
    index = check_if_class_instance_h(name,class_id);
    if (index != -1)
      return index;
    if (symbol_table[class_id].attribute != -1){
      class_id = symbol_table[class_id].attribute;
    } else {
      return -1;
    }
  }
  return -1;
}

int check_if_class_instance_h(char* name, int class_id){
  char* new_name = malloc(strlen(name));
  int class_index;
  int index = -1;
  if (name[strlen(name)-1] == '['){
    strncpy(new_name,name,strlen(name)-1);
    if ((index = lookup_id_in_class(new_name, class_id)) == -1 && (index = lookup_global(new_name)) == -1){
      printf("Line: %d: %s does not exist\n", line, new_name);
    }else{
      if (get_kind(index) == VARIABLE){
        char* our_type = malloc(strlen(get_type(index)));
        our_type = get_type(index);
        if (our_type[strlen(our_type)-1] == ']'){
          char* new_type = malloc(strlen(our_type));
          strncpy(new_type,our_type,strlen(our_type)-2);
          if ((class_index = lookup_class_existance(new_type)) != -1){
            return class_index;
          }else{
            printf("Line: %d: Variable %s is not an array of instances of class\n", line, new_name);
          }
        }else{
          printf("Line: %d: %s is not an array\n",line, new_name );
        }
      }else{
        printf("Line: %d: %s is not a variable\n", line, new_name);
      }
    }
  }
  else{
    strcpy(new_name,name);
    if ((index = lookup_id_in_class(new_name, class_id)) == -1 && (index = lookup_global(new_name)) == -1){
      printf("Line: %d: %s does not exist\n", line, new_name);
    }else {
      if (get_kind(index) == VARIABLE){
        if ((class_index = lookup_class_existance(get_type(index))) != -1){
          return class_index;
        }else{
          printf("Line: %d: Variable %s is not an instance of class\n", line, new_name);
        }
      }else{
        printf("Line: %d: %s is not a variable\n", line, new_name);
      }
    }
  }
  return -1;
}


int check_if_int(char* name, int class_id){
  char* our_name = name;
  int index = -1;
  if (our_name[strlen(our_name)-1] == '['){
    our_name[strlen(our_name)-1] = '\0';

    if ((index = lookup_id_in_class(our_name, class_id)) != -1){
      char* our_type = get_type(index);
      if (our_type[strlen(our_type)-1] == ']'){
        char* new_type = malloc(strlen(our_type));
        strncpy(new_type,our_type,strlen(our_type)-2);
        if (strcmp(new_type,"int") == 0){
          return index;
        }else{
          printf("Line: %d: %s is not an array of integers\n", line, our_name);
        }
      }else{
        printf("Line: %d: %s is not an array\n", line, our_name);
      }
    }else{
      printf("Line: %d: %s does not exist in class %s\n",line, our_name, get_name(class_id));
    }
  }else{
    if ((index = lookup_id_in_class(our_name, class_id)) != -1){
      char* our_type = get_type(index);
      if (strcmp(our_type,"int") == 0){
        return index;
      }else{
        printf("Line: %d: %s is not an integer\n", line, our_name);
      }
    }else{
      printf("Line: %d: %s does not exist in class %s\n",line, our_name, get_name(class_id));
    }
  }

  return index;
}

int check_opperation_for_type(char opp, char* type){
  if (opp == '+'){
    if (strcmp(type, "string") == 0 || strcmp(type, "int") == 0){
      return 1;
    }else{
      return -1;
    }
  }else{
    if (strcmp(type, "int") == 0){
      return 1;
    }else{
      return -1;
    }
  }
  return -1;
}

char* get_designator_type(char* glob_designator, int designator_class_id){
  int index;
  if (glob_designator[strlen(glob_designator)-1] == '['){ //AKO JE ZADNJI CLAN NIZA
    glob_designator[strlen(glob_designator)-1] = '\0'; // MOZDA OVDE PUCA JER NIJE NOVA PROMENLJIVA //odsekli mu [ da dobijemo ime
    if ((index = lookup_var_in_class(glob_designator, designator_class_id)) != -1){
      char* new_type = get_type(index);
      if (new_type[strlen(new_type)-1] == ']' || strcmp("string", new_type) == 0){
        if (strcmp("string", new_type) == 0){
          return "char";
        }else{   //ako nije string vec niz
          new_type[strlen(new_type) - 2] = '\0';
          return new_type;
        }
      }else{
        printf("Line: %d: %s is not an array or string\n", line, get_name(index));
      }
    }else{
      printf("Line: %d: %s does not exist in class %s\n", line, glob_designator, get_name(designator_class_id));
    }
  }else{  // AKO ZADNJI NIJE CLAN NIZA
    if ((index = lookup_var_in_class(glob_designator, designator_class_id)) != -1){
        return get_type(index);
    }else{
       printf("Line: %d: %s does not exist in class %s\n", line, glob_designator, get_name(designator_class_id));

    }
  }
  return NULL;
}
