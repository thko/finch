DatabaseDef
	: TableDef
	| TableDef DatabaseDef
	;

TableDef
	: "entity" Identifier "(" FieldDefList ")" ";"
		{ $$ = {name:$2, fields:{}};
                  for (var n = 0; n < $4.length; n++) {
			var name = $4[n].name;
			fields[name] = $4[n];
			delete fields[name].name;
		  }
		}
	;

FieldDefList
	: FieldDef
		{ $$ = [$1]; }
	| FieldDef "," FieldDefList
		{ $$ = [$1].concat($3); }
	| "{" IdentifierList "}" FieldType
		{ $$ = new Array($2.length);
		  for (var n = 0; n < $2.length; n++) {
			$$[n] = jQuery.extend({name:$2[n]}, $4);
		  }
		}
	| "{" IdentifierList "}" FieldType "," FieldDefList
		{ $$ = new Array($2.length);
		  for (var n = 0; n < $2.length; n++) {
			$$[n] = jQuery.extend({name:$2[n]}, $4);
		  }
		  $$ = $$.concat($6);
		}
	;

FieldDef
	: Identifier FieldType
		{ $$ = jQuery.extend({name:$1}, $2); }
	| "&" Identifier
		{ $$ = {name:'ref'+$2, type:'reference', referent:$2}; }
	| Identifier "&" Identifier
		{ $$ = {name:$1, type:'reference', referent:$3}; }
	;

FieldType
	: "int"
		{ $$ = {type:'int'}; }
	| "string" "(" Integer ")"
		{ $$ = {type:'string', size:$3}; }
	| "&" Identifier
		{ $$ = {type:'reference', referent:$2}; }
	;

IdentifierList
	: Identifier
		{ $$ = [$1]; }
	| Identifier "," IdentifierList
		{ $$ = [$1].concat($3); }
	;
