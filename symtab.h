
#ifndef SYMTAB_H
#define SYMTAB_H

#define PARAM_NUMBER   10
extern int line;

// Element tabele simbola
typedef struct sym_entry {
    int level;                // na kom nivou je simbol
    char *name;               // ime simbola
    unsigned kind;            // vrsta simbola
    char* type;               // tip vrednosti simbola
    int attribute;            // dodatni attribut
    char**param_types;    // tipovi parametara
    int class_id;             // kojoj klasi pripada
    int initialized;
} SYMBOL_ENTRY;

// Vraca indeks prvog sledeceg praznog elementa.
int  get_next_empty_element(void);

int check_primitive_type(char* type);

int lookup_id_nokind(char *name, int level);

int lookup_id_in_class(char* name, int class_id);

int lookup_id_strict_kind(char *name, unsigned kind, int level);

// Da li je instanca klase ili niza inicijalizovana
int is_initialized(int index);

char* parse_method_name(char* str);

char* parse_method_type(char* str);

// Postavlja vrednost na inicijalizovanu
void set_initialized(int index, int value);

// Vraca indeks poslednjeg zauzetog elementa.
int get_last_element(void);

// Ubacuje simbol sa datom oznakom simbola i tipom simbola i vraca indeks ubacenog elementa u tabeli simbola ili -1.
int  insert_symbol(char *name, unsigned kind, char* type, int level,int class_id);

// Proverava da li se simbol vec nalazi u tabeli simbola, ako se ne nalazi ubacuje ga, ako se nalazi ispisuje gresku.
// Vraca indeks elementa u tabeli simbola.
int  try_to_insert_id(char *name, unsigned kind, char* type, int level,int class_id);

// Ubacuje konstantu u tabelu simbola (ako vec ne postoji).
int  try_to_insert_constant(char *str, char* type);

// Vraca indeks pronadjenog simbola ili vraca -1.
int  lookup_id(char *name, unsigned kind ,int level);

// Vraca indeks pronadjenog simbola ili vraca -1
int lookup_id_strict(char *name, int level);

// Vraca indeks pronadjenog simbola (konstante) ili vraca -1.
int  lookup_constant(char *name);

// set i get metode za polja jednog elementa tabele simbola
char*    get_name(int index);
unsigned get_kind(int index);
char*    get_type(int index);
void     set_attribute(int index, int attribute);
unsigned get_attribute(int index);
void     set_param_type(int index, unsigned number, char* type);
char*    get_param_type(int index, unsigned number);
void     set_register_type(int register_index, char* type);


char* get_designator_type(char* glob_designator, int designator_class_id);

// Brise elemente tabele simbola  od pocetnog indeksa do kraja tabele
void     clear_symbols(unsigned begin_index);

// Brise sve elemente tabele simbola.
void     clear_symtab(void);

// Ispisuje sve elemente tabele simbola.
void     print_symtab(void);
unsigned logarithm2(unsigned value);

// Inicijalizacija tabele simbola.
void     init_symtab(void);

#endif
