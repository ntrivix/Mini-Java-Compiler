%{
    #include <string.h>
    #include "y.tab.h"

    #define YYSTYPE char*

    extern YYSTYPE yylval;
    int line = 1;
%}

letter                      [a-zA-Z]
digit                       [0-9]

%%

[ \t\r]+                                            {   /* skip */    }
"."{letter}({letter}|{digit}|"_")*  { yylval = strdup(yytext); return _POINT_ID;}
{letter}({letter}|{digit}|"_")*"[" { yylval = strdup(yytext); return _ARRAY_VALUE;}

"eol"                       { yylval = strdup(yytext);  return _CHAR;     }
"switch"                    { yylval = strdup(yytext); return _SWITCH; }
"void"                      {yylval = strdup(yytext);  return _VOJD;}
"while"                     { yylval = strdup(yytext); return _WHILE; }
"break"                     { yylval = strdup(yytext); return _BREAK; }
"null"                       { yylval = strdup(yytext);  return _NULL;     }
"print"                    { yylval = strdup(yytext); return _PRINTF; }
"program"                   { yylval = strdup(yytext); return _PROGRAM;}
"class"                     { yylval = strdup(yytext); return _CLASS; }
"const"                     { yylval = strdup(yytext); return _CONST; }
"new"                       { yylval = strdup(yytext); return _NEW; }
"read"                      { yylval = strdup(yytext); return _READ;}
"extends"                   { yylval = strdup(yytext); return _EXTENDS; }
"false"                     { yylval = strdup(yytext); return _FALSE; }
"true"                      { yylval = strdup(yytext); return _TRUE; }
"if"                        {  yylval = strdup(yytext);  return _IF;       }
"else"                      {  yylval = strdup(yytext); return _ELSE;     }
"return"                    {  yylval = strdup(yytext); return _RETURN;   }

("int"|"void"|"char"|"bool"|"string"|({letter}({letter}|{digit}|"_")*))(" ")+({letter}({letter}|{digit}|"_")*)"("   { yylval = strdup(yytext); return _START_METHOD_DECL;}
"("                         {yylval = strdup(yytext);   return _LPAREN;     }
")"                         {yylval = strdup(yytext);    return _RPAREN;}
"["                         {yylval = strdup(yytext); return _LSQUARE_BRACKET; }
"]"                         {yylval = strdup(yytext); return _RSQUARE_BRACKET; }

"."                         { yylval = strdup(yytext); return _DOT; }

"string"                       { yylval = strdup(yytext);  return _TYPE;     }
"bool"                       { yylval = strdup(yytext);  return _TYPE;     }
"int"                       { yylval = strdup(yytext);  return _TYPE;     }
"unsigned"                  {  yylval = strdup(yytext); return _TYPE;     }
"char"                      {  yylval = strdup(yytext); return _TYPE;   }
"double"                      {  yylval = strdup(yytext); return _TYPE;   }
"float"                      {  yylval = strdup(yytext); return _TYPE;   }


"'"."'"                     { yylval = strdup(yytext);  return _CHAR;  }
digit*(.digit*)?            { yylval = strdup(yytext);  return _REAL;  }

{letter}({letter}|{digit}|"_")* {  yylval = strdup(yytext);  return _ID;       }

{digit}{1,5}[uU]            {   yylval = strdup(yytext); return _UNSIGNED_NUMBER;   }
{digit}{1,5}           {  yylval = strdup(yytext);  return _INT_NUMBER;        }

"~"                          {yylval = strdup(yytext); return _NOTB;}
"&&"                        {yylval = strdup(yytext); return _AND;}
"||"                        {yylval = strdup(yytext); return _OR;}
"|"                        {yylval = strdup(yytext); return _ORB;}
"&"                         {yylval = strdup(yytext); return _APERSANT; }
"\""[^\"]*"\""                {yylval = strdup(yytext); return _STRING; }
","                         {yylval = strdup(yytext);   return _COMMA;      }
":"                         {yylval = strdup(yytext); return _COLON;      }
"{"                         { yylval = strdup(yytext);  return _LBRACKET;   }
"}"                         { yylval = strdup(yytext);  return _RBRACKET;   }
"="                         {yylval = strdup(yytext);   return _ASSIGN;     }
";"                         {yylval = strdup(yytext);    return _SEMICOLON;  }
"++"                        { yylval = strdup(yytext); return _PLUS_PLUS; }
"--"                        { yylval = strdup(yytext); return _MINUS_MINUS; }
"+"                         {yylval = strdup(yytext);   return _PLUS;       }
"-"                         {yylval = strdup(yytext);   return _MINUS;      }
"*"                         {yylval = strdup(yytext);   return _TIMES;      }
"/"                         {yylval = strdup(yytext);   return _DIV;        }
"%"                         {yylval = strdup(yytext);   return _MOD;        }
"<"                         {yylval = strdup(yytext);   return _RELOP;      }
">"                         {yylval = strdup(yytext);   return _RELOP;      }
"<="                        {yylval = strdup(yytext);   return _RELOP;      }
">="                        {yylval = strdup(yytext);   return _RELOP;      }
"=="                        {yylval = strdup(yytext);   return _RELOP;      }
"!="                        {yylval = strdup(yytext);   return _RELOP;      }
"!"                         {yylval = strdup(yytext); return _NOT; }


""

"#include <"(.*)">"            {yylval = strdup(yytext);   return _INCLUDE;    }

"/*"                        {
                                int in_comment = 1;
                                char c;
                                while(in_comment) {
                                    c = input();
                                    if(c == '*') {
                                        char ch = input();
                                        if(ch == '/') in_comment = 0;
                                        else unput(ch);
                                    }
                                    else if(c == '\n') line++;
                                    else if(c == EOF) {
                                        printf("\nERROR (%d): Unterminated comment", line);
                                        in_comment = 0;
                                    }
                                }
                            }

\/\/.*                      {   /* skip */   }

"\n"                        {   line++;    }
.                           { yylval = strdup(yytext);  printf("\nLEXICAL ERROR on character %d (line %d)\n", yytext[0], line);   }

%%

int yywrap() {
    return 1;
}
