
#ifndef DEFS_H
#define DEFS_H

#define bool int
#define TRUE  1
#define FALSE 0

#define SYMBOL_TABLE_LENGTH 64

#define NO_ATTRIBUTE -1
#define NO_LEVEL -2
#define NO_CLASS_ID -3

//tipovi podataka (moze ih biti maksimalno 8)
enum { NO_TYPE, INT_TYPE, UNSIGNED_TYPE };

// vrste simbola (moze ih biti maksimalno 32)
enum { CONSTANT = 0x1, WORKING_REGISTER = 0x2, VARIABLE = 0x4, METHOD = 0x8, CLASS=0x10};

static char *symbol_kinds[] = { "CONSTANT","WORKING_REGISTER", "VARIABLE", "METHOD","CLASS" };

//konstante relacionih operatora
enum { LT, GT, LE, GE, EQ, NE };


#define FUNCTION_REGISTER        13
#define TYPE_BIT_SIZE            16
#define CHAR_BUFFER_LENGTH       128

//pomocni makroi za ispis
#define printerror(args...) sprintf(char_buffer, args), yyerror(char_buffer)
#define printwarning(args...) sprintf(char_buffer, args), warning(char_buffer)
extern int yyerror(char *s);
extern void warning(char *s);
extern char char_buffer[CHAR_BUFFER_LENGTH];

#endif
