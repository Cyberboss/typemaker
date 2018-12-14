parser grammar TypemakerParser;

options { tokenVocab=TypemakerLexer; }

compilation_unit: top_level_declaration* EOF;

top_level_declaration: map | var_declaration | proc_declaration | enum | interface | object_declaration | proc_definition;

map: MAP LPAREN RES RPAREN SEMI;

number: INTEGER | REAL | MINUS INTEGER | MINUS REAL;

enum_type: SLASH ENUM SLASH IDENTIFIER;

concrete_path: PATH SLASH CONCRETE;
path_type: concrete_path | PATH;

string_content: CHAR_INSIDE | STRING_INSIDE | MULTI_STRING_INSIDE | MULTI_STRING_QUOTE;
string_body: string_content | EMBED_START expression RBRACE;

string
	: MULTI_STRING_START string_body* MULTI_STRING_CLOSE
	| STRING_START string_body* STRING_CLOSE
	| MULTILINE_VERBATIUM_STRING
	| VERBATIUM_STRING 
	;

dict_type: DICT SLASH nullable_type BSLASH nullable_type;
root_type: enum_type | path_type | interface_type | dict_type | INT | RESOURCE | BOOL | FLOAT | EXCEPTION | STRING;
extended_identifier: IDENTIFIER | IDENTIFIER fully_extended_identifier;
fully_extended_identifier: SLASH extended_identifier;

true_type: root_type | extended_identifier | LIST SLASH nullable_type;
nullable_type: true_type | NULLABLE SLASH true_type;
const_type: true_type | CONST SLASH true_type;
type: const_type | nullable_type;
return_type: nullable_type | VOID | IDENTIFIER;

typed_identifier: type SLASH IDENTIFIER | IDENTIFIER;

var_definition_only: VAR SLASH typed_identifier;
var_definition: var_definition_only | var_definition_only EQUALS expression;
var_definition_statement: var_definition SEMI;
var_declaration: decorator* var_definition_statement;

inc_dec: INC | DEC;

dict_declaration: string EQUALS expression;
dict_declarations: dict_declaration | dict_declaration COMMA dict_declarations;
dict_definition: DICT LPAREN dict_declarations? RPAREN;

list_declarations: expression | expression COMMA list_declarations;
list_definition: LIST LPAREN RPAREN | LIST LPAREN list_declarations RPAREN;

nameof_expression: NAMEOF LPAREN accessed_target RPAREN;

new_type: true_type | accessed_target | DOT;

new_expression
	: NEW new_type
	| NEW new_type argument_list
	| NEW argument_list
	| NEW
	;

input_interior
	: expression COMMA expression COMMA expression
	| expression COMMA expression COMMA expression COMMA expression
	;

input_expression
	: input_start AS nullable_type IN expression
	| input_start AS nullable_type
	| input_start IN expression
	| input_start
	;

input_start: INPUT LPAREN input_interior RPAREN;

accessor
	: nonoptional_accessor
	| QUESTION nonoptional_accessor
	;

nonoptional_accessor
	: DOT	// x.y
	| COLON	// x:y
	;

accessed_target
	: accessed_target accessor IDENTIFIER
	| IDENTIFIER
	;

in_expression: target IN expression;

expression
	: target
	| assignment
	| EXCLAIM expression
	| INVERT expression
	| MINUS expression
	| inc_dec expression
	| expression inc_dec

// BINARY EXPRESSIONS
// NEEDS PRECEDENCE ORDERING

	| expression LSHIFT expression 
	| expression RSHIFT expression
	| expression POW expression
	| expression STAR expression
	| expression SLASH expression
	| expression PLUS expression 
	| expression MINUS expression
	| expression BAND expression
	| expression BOR expression
	| expression XOR expression
	| expression LSHIFT expression
	| expression RSHIFT expression
	| expression LAND expression
	| expression LOR expression
	| expression LESS expression
	| expression GREATER expression
	| expression LESSE expression
	| expression GREATERE expression
	| expression EEQUALS expression
	| expression NEQUALS expression

	| expression QUESTION expression COLON expression
	| new_expression
	| input_expression
	;

invocation
	: call_invocation
	| basic_identifier argument_list
	;

target
	: bracketed_expression
	| fully_extended_identifier
	| list_definition
	| dict_definition
	| nameof_expression	
	| invocation
	| target accessor invocation
	| target accessor IDENTIFIER
	| target LBRACE expression RBRACE	//list access
	| string
	| basic_identifier
	| fully_extended_identifier
	| path_type
	| RES
	| TRUE
	| FALSE
	| INT
	| FLOAT
	| NULL
	;

basic_identifier
	: IDENTIFIER
	| DOTDOT
	| GLOBAL
	| SRC
	| USR
	| DOT
	;

assignment
	: target OEQUALS expression
	| target AEQUALS expression
	| target PEQUALS expression
	| target MEQUALS expression
	| target TEQUALS expression
	| target SEQUALS expression
	| target IEQUALS expression
	| target DEQUALS expression
	| target LEQUALS expression
	| target REQUALS expression
	| target EQUALS expression;

target_var: target | var_definition_only;

argument: expression | semicolonless_identifier_assignment;
arguments: argument | argument COMMA arguments;
argument_list: LPAREN RPAREN | LPAREN arguments* RPAREN;

call_invocation
	: CALL argument_list 
	| CALL LPAREN string RPAREN argument_list 
	| CALL LPAREN expression COMMA expression RPAREN argument_list
	;

in_for: LPAREN target_var IN expression RPAREN;

for_var_def: target_var SEMI | SEMI;
for_condition: expression SEMI | SEMI;
for_statement: semicolonless_statement RPAREN | RPAREN;
standard_for: LPAREN for_var_def for_condition for_statement;

for_type: standard_for | in_for;
for: FOR for_type block;

return_statement: RETURN expression SEMI | RETURN SEMI;

bracketed_expression: LPAREN expression RPAREN;

while_params: WHILE bracketed_expression;
while: while_params block;
do_while: DO block while_params SEMI;

cases: if_start | else;
switch_block: LCURL RCURL | LCURL cases RCURL;
switch: SWITCH bracketed_expression switch_block;

else: ELSE block;
elseif: ELSE if_start;
if_continuation: elseif if_continuation | elseif | else;
if_start: IF bracketed_expression block;
if: if_start if_continuation | if_start;

flow_control: return_statement | while | do_while | for | switch | if;

semicolonless_identifier_assignment: basic_identifier EQUALS expression;
identifier_assignment: semicolonless_identifier_assignment SEMI;
set_assignment_statement: SET identifier_assignment;
set_statement: set_assignment_statement | SET in_expression SEMI;

spawn_block: SPAWN LPAREN number RPAREN block;

try_block: TRY block CATCH LPAREN EXCEPTION SLASH IDENTIFIER RPAREN block;

semicolonless_statement: expression | invocation | BREAK | CONTINUE;
statement: var_definition_statement | set_statement | return_statement | flow_control | try_block | unsafe_block | semicolonless_statement SEMI;
block: statement | LCURL statement+ RCURL;
unsafe_block: UNSAFE block;

implements_statement: IMPLEMENTS IDENTIFIER SEMI;
object_declaration: decorator* fully_extended_identifier declaration_block;

argument_declaration: typed_identifier | typed_identifier EQUALS expression;
argument_declaration_list: argument_declaration | argument_declaration COMMA argument_declaration_list | VARARGS;

proc_arguments: LPAREN RPAREN | LPAREN argument_declaration_list RPAREN;
proc_return_declaration: RDEC return_type;
identifier_or_constructor: SLASH IDENTIFIER | SLASH CONSTRUCTOR;

access_decorator: PUBLIC | PROTECTED;
precedence_decorator: PRECEDENCE LPAREN INTEGER RPAREN;
decorator: access_decorator | SEALED | PARTIAL | READONLY | ABSTRACT | VIRTUAL | FINAL | STATIC | INLINE | EXPLICIT | DECLARE;

proc_type: PROC | VERB;
proc: decorator* fully_extended_identifier? proc_type? identifier_or_constructor proc_arguments proc_return_declaration?;
proc_declaration: proc SEMI;
proc_definition: proc block;

interface_type: SLASH INTERFACE SLASH IDENTIFIER;
interface: interface_type declaration_block;

enum_item: semicolonless_identifier_assignment | IDENTIFIER;
enum_items: enum_item | enum_item COMMA enum_items;
enum_block: LCURL enum_items? RCURL;
enum: enum_type enum_block;

declaration
	: proc_declaration
	| implements_statement
	| set_assignment_statement
	| var_declaration
	| identifier_assignment
	;

declaration_block: LCURL declaration* RCURL;
