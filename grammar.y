DatabaseDef
  : TableDef ";"
	| TableDef DatabaseDef
	;

TableDef
	: "entity" Identifier "(" FieldDefList ")" ";"
	;

FieldDefList
	: FieldDef
	| FieldDef "," FieldDefList
	| "&" Identifier
	| "&" Identifier "," FieldDefList
	| "{" IdentifierList "}" FieldType
	| "{" IdentifierList "}" FieldType "," FieldDefList
	;

FieldDef
	: Identifier FieldType
	;

FieldType
	: "int"
	| "string" "(" Integer ")"
	| "fixstring" "(" Integer ")"
	| "&" Identifier
	;
