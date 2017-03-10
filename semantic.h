
#ifndef SEMANTIC_H
#define SEMANTIC_H

#include <stdlib.h>
#include <string.h>
#include "defs.h"
#include "symtab.h"


void check_main(void);
int  check_types(int first_index, int second_index);
bool check_argument_type(int function_call_index, int arg_index, int arg_num);
bool check_arguments_number(int function_call_index, int arg_num);

#endif
