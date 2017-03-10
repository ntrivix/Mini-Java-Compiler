
#include <stdio.h>
#include "semantic.h"

extern char char_buffer[CHAR_BUFFER_LENGTH];
extern int line;

// Proverava da li se ime main nalazi u tabeli simbola ili ne,
// i da li je njen tip 'int'.
void check_main() {
    int index;
    if((index = lookup_id_strict_kind("main", METHOD, 0)) == -1)
        printf("No main!\n");
    else
      if(strcmp(get_type(index),"void") != 0)
          printf("Return type of 'main' is not void\n");
}
// Proverava da li su isti tipovi elemenata tabele simbola.
bool check_types(int first_index, int second_index) {
    char* t1 = get_type(first_index);
    char* t2 = get_type(second_index);
    if(strcmp(t1, t2))
        return TRUE;
    else
        return FALSE;
}

// Proverava da li n-ti argument po tipu odgovara n-tom parametru funkcije
bool check_argument_type(int function_call_index, int arg_index, int arg_num) {
    if(get_param_type(function_call_index, arg_num) == get_type(arg_index))
        return TRUE;
    printf("incompatible type for argument %d in '%s'", arg_num, get_name(function_call_index));
    return FALSE;
}

// Proverava da li broj argumenata poziva funkcije
// odgovara broju parametara funkcije
bool check_arguments_number(int function_call_index, int arg_num) {
    if(get_attribute(function_call_index) == arg_num)
        return TRUE;
    printf("wrong number of arguments to function '%s'", get_name(function_call_index));
    return FALSE;
}
