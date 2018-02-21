%{
// PREPROCESSOR
#include <cstdio>
#include <iostream>
#include <string>

// REQUIRED FLEX METHOD STUBS
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

// THIS NEEDS TO BE HERE I GUESS
void yyerror(const char *s);
%}

// UNION FOR GIVING TYPES TO THE YYSTYPE TOKENS FLEX RETURNS
%union {
	int ival;
	bool bval;
	char sval[32];
}

// ASSOCIATE TOKEN NAMES WITH THOSE TYPES
%token<ival> INT
%token<bval> BOOL
%token<sval> VAR

// OTHER TOKEN DECLARATIONS
%token LPAREN RPAREN
%token PLUS MINUS TIMES DIVIDE
%token LEQ
%token IF THEN ELSE LET EQUAL IN FUN RARROW
%token NEWLINE QUIT

// OPERATOR PRECEDENCE (ASCENDING)
%left LEQ
%left PLUS MINUS
%left TIMES DIVIDE

%nonassoc THEN
%nonassoc ELSE

// TYPING EXPRESSIONS
%type<ival> iexp
%type<bval> bexp

%start calculation
%%
// GRAMMAR
calculation:
      	   | calculation line
;

line: NEWLINE
    | iexp NEWLINE { std::cout << "\tResult: " << $1 << std::endl; }
    | bexp NEWLINE { std::cout << "\tResult: " << $1 << std::endl; }
;

fexp: FUN VAR RARROW bexp					{ }
		| FUN VAR RARROW iexp					{ }

bexp: BOOL												{ $$ = $1; }
    | IF bexp THEN bexp ELSE bexp	{ if ($2) {$$ = $4;} else {$$ = $6;} }
    | iexp LEQ iexp								{ $$ = $1 <= $3; }
		| LPAREN bexp RPAREN					{ $$ = $2; }
		| LET VAR EQUAL bexp IN bexp	{ }
		| LET VAR EQUAL iexp IN bexp	{ }
		| fexp bexp										{ }
    ;

iexp: INT				                  { $$ = $1; }
    | IF bexp THEN iexp ELSE iexp { if ($2) {$$ = $4;} else {$$ = $6;} }
    | iexp PLUS iexp	            { $$ = $1 + $3; }
	  | iexp MINUS iexp	            { $$ = $1 - $3; }
	  | iexp TIMES iexp	            { $$ = $1 * $3; }
    | iexp DIVIDE iexp            { $$ = $1 / $3; }
		| LET VAR EQUAL iexp IN iexp  { }
		| LET VAR EQUAL bexp IN iexp  { }
		| fexp iexp										{ }
	  | LPAREN iexp RPAREN          { $$ = $2; }
;

%%
int main(int argc, char** argv) {

  // bison doesn't like iostreams
	FILE *input = fopen(argv[1], "r");
	if (!input) {
		std::cout << "Error opening file." << std::endl;
		exit(EXIT_FAILURE);
	}
	yyin = input;

  // parse through it all
  do {
    yyparse();
  } while (!feof(yyin));

  exit(EXIT_SUCCESS);
}

void yyerror(const char *s) {
	std::cout << s << std::endl;
	exit(EXIT_FAILURE);
}
