#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>

char* izbaciNL(char *s){
  char *ps;
  char *sn;
  int pn=0;
  int br=2;
  sn=malloc(strlen(s));
  ps=s;
  while(*(ps+1)!='\0'){
    while(*(ps+br)=='\t'|| *(ps+br)=='\r')
      br++;
    if ((*ps=='\n')&&(*(ps+br)=='\n')){
      ps+=br;
      br=2;
    }
    else{
        sn[pn]=*ps;
        pn++;
        ps++;
        br=2;
    }
  }
  sn[pn]=*ps;
  sn[pn+1]='\0';
  return sn;
}

char* append2(char* a, char*b){
    char* result;
    if(a==NULL)
      a="";
    if(b==NULL)
      b="";
    result = malloc(strlen(a)+strlen(b)+5);
    result = strcat(result, a);
    result = strcat(result, b);
    if (result == "") return "\r\n";
    return result;
}

char* append3(char* a, char*b, char* c){
    char* result;
    if(a==NULL)
      a="";
    if(b==NULL)
      b="";
    if(c==NULL)
      c="";
    result = malloc(strlen(a)+strlen(b)+strlen(c)+5);
    result = strcat(result, a);
    result = strcat(result, b);
    result = strcat(result, c);
    if (result == "") return "\r\n";
    return result;
}

char* append4(char* a, char*b, char* c, char* d){
    char* result;
    if(a==NULL)
      a="";
    if(b==NULL)
      b="";
    if(c==NULL)
      c="";
    if(d==NULL)
      d="";
    result = malloc(strlen(a)+strlen(b)+strlen(c)+strlen(d)+ 5);
    result = strcat(result, a);
    result = strcat(result, b);
    result = strcat(result, c);
    result = strcat(result, d);
    if (result == "") return "\r\n";
    return result;
}

char* append5(char* a, char* b, char* c, char* d, char* e){
    char* result;
    if(a==NULL)
      a="";
    if(b==NULL)
      b="";
    if(c==NULL)
      c="";
    if(d==NULL)
      d="";
    if(e==NULL)
      e="";
    result = malloc(strlen(a)+strlen(b)+strlen(c)+strlen(d)+strlen(e)+ 5);
    result = strcat(result, a);
    result = strcat(result, b);
    result = strcat(result, c);
    result = strcat(result, d);
    result = strcat(result, e);
    if (result == "") return "\r\n";
    return result;
}

char* append6(char* a, char*b, char* c, char* d,char* e, char* f){
    char* result;
    char* q=a;
    char* g=c;
    char* k=f;
    char* j=e;
    char* w=b;
    char* h=d;
    if(a==NULL)
      q="";
    if(b==NULL)
      w="";
    if(c==NULL)
      g="";
    if(d==NULL)
      h="";
    if(e==NULL)
      j="";
    if(f==NULL)
      k="";
    result = malloc(strlen(q)+strlen(w)+strlen(g)+strlen(h)+
    strlen(j)+strlen(k)+ 5);
    result = strcat(result, q);
    result = strcat(result, w);
    result = strcat(result, g);
    result = strcat(result, h);
    result = strcat(result, j);
    result = strcat(result, k);
    if (result == "") return "\r\n";
    return result;
}
