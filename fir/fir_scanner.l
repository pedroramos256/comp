%option c++ prefix="fir_scanner_" outfile="fir_scanner.cpp"
%option stack noyywrap yylineno 8bit
%{ 
// make relevant includes before including the parser's tab file
#include <string>
#include <sstream>
#include <cdk/ast/sequence_node.h>
#include <cdk/ast/expression_node.h>
#include <cdk/ast/lvalue_node.h>
#include "fir_parser.tab.h"

// output stream for building string literals
static std::ostringstream strlit;

// don't change this
#define yyerror LexerError
%}

SPACE     ([ \t\r]|\n)

%x X_COMMENT
%x X_STRING X_SPECIAL_CHAR
%%
    /* ====================================================================== */
    /* ====[                        Comentarios                         ]==== */
    /* ====================================================================== */

"!!".*$                /* match the whole line (it is ignored) */

"(*"                   yy_push_state(X_COMMENT);
<X_COMMENT>"*)"        yy_pop_state();
<X_COMMENT>.|"\n"      ;  /* ignore inside comments */

    /* ================================================================ */
    /* ====[                      Palavras Chave                  ]==== */
    /* ================================================================ */

"int"                   return tTYPE_INT;
"float"                 return tTYPE_REAL;
"string"                return tTYPE_STRING;
"void"                  return tTYPE_VOID;
[<>]                    return *yytext;

"null"                  return tNULL;

    /* ------------------------------ Ciclos --------------------------- */

"while"                 return tWHILE; 
"do"                    return tDO;
"finally"               return tFINALLY;

    /* ------------------------------ Condicional ---------------------- */

"if"                   return tIF; 
"then"                 return tTHEN;
"else"                 return tELSE;


    /* ------------------------------ Escrita --------------------------- */

"write"                return tWRITE;
"writeln"              return tWRITELN;

    /* ------------------------------ Controlo --------------------------- */

"leave"                 return tLEAVE;
"restart"               return tRESTART;
"return"                return tRETURN;

    /* ------------------------------ Funcoes --------------------------- */

"->"                    return tDEFAULT_VAL;
">>"                    return tEPILOGUE;
[@(){};]                return *yytext;

    /* ------------------------------ Simbolos --------------------------- */

[*?]                    return *yytext;

    /* ------------------------------ Operadores --------------------------- */

"sizeof"                return tSIZEOF;

">="                    return tGE; 
"<="                    return tLE; 
"=="                    return tEQ; 
"!="                    return tNE; 

"~"                     return tNOT;
"&&"                    return tAND;
"||"                    return tOR;

[\[\](),?]       return *yytext;
[-+*/%~<>@=]        return *yytext;

    /* ====================================================================== */
    /* ====[                       Identificadores                      ]==== */
    /* ====================================================================== */

[A-Za-z][A-Za-z0-9_]*         yylval.s = new std::string(yytext); return tIDENTIFIER;

    /* ====================================================================== */
    /* ====[                       Inteiros                              ]==== */
    /* ====================================================================== */

[1-9][0-9]*                   {  
                                try { 
                                  yylval.i = std::stoi(yytext, nullptr, 10);
                                  return tINTEGER;
                                } catch (const std::out_of_range& e) { yyerror("Decimal: out of range.");}
                              }

0[0-7]*	                      { 
                                try { 
                                  yylval.i = std::stoi(yytext, nullptr, 8);
                                  return tINTEGER;
                                } catch (const std::out_of_range& e) { yyerror("Octal: out of range."); }
                              }

0[0-9]+                     yyerror("Invalid Octal number.");

  /* ====================================================================== */
  /* ====[                   Reais                                    ]==== */
  /* ====================================================================== */

([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)([eE][-+]?[0-9]+)? { try { yylval.d = std::stod(yytext, NULL); 
                                                      return tREAL; 
                                                    } catch (const std::out_of_range& e) { yyerror("Real: out of range."); } 
                                                  }

    /* ====================================================================== */
    /* ====[                       Strings                              ]==== */
    /* ====================================================================== */
    
"\'"                            yy_push_state(X_STRING);
<X_STRING>"\'"                  {
                                    yylval.s = new std::string(strlit.str());
                                    strlit.str("");
                                    yy_pop_state();
                                    return tSTRING;
                                }
<X_STRING>"~"                   yy_push_state(X_SPECIAL_CHAR);
<X_STRING>"\n"                  yyerror("String cannot be multi-line");
<X_STRING>.                     strlit << *yytext;
    
<X_SPECIAL_CHAR>"n"             strlit << '\n'; yy_pop_state();             
<X_SPECIAL_CHAR>"t"             strlit << '\t'; yy_pop_state();             
<X_SPECIAL_CHAR>"r"             strlit << '\r'; yy_pop_state();               

    /* O std::string deteta o \0 e por isso ignora a partir dai */
<X_SPECIAL_CHAR>[[:xdigit:]]{1,2} {
                                 strlit << (char)(unsigned char)strtoul(yytext, NULL, 16);
                                 yy_pop_state();
                               }
<X_SPECIAL_CHAR>.                strlit << *yytext; yy_pop_state(); /* isto engloba o caso ~~ e ~' */


  /* ====================================================================== */
  /* ====[                    (outros caracteres)                      ]==== */
  /* ====================================================================== */

{SPACE}                ; /* ignore remaining white space inside the program */
.                      yyerror("Unknown character");

%%
