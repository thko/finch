%lex
%%

\s+                     /* skip whitespace */
[0-9]+("."[0-9]+)?\b    return 'Integer'
";"                     return ';'
","                     return ','
"{"                     return '{'
"}"                     return '}'
"("                     return '('
")"                     return ')'
"&"                     return '&'
"entity"                return 'entity'
"int"                   return 'int'
"string"                return 'string'
[a-zA-Z_][a-zA-Z0-9_]*  return 'Identifier'
<<EOF>>                 return 'Eof'
.                       return 'Invalid'

/lex

%start Body
%%


Body

  : DatabaseDef Eof
    { return $1; }
  ;

DatabaseDef

  : TableDef
    { $$ = $1; }

  | TableDef DatabaseDef
    { $$ = jQuery.extend($1, $2); }
  ;

TableDef

  : "entity" Identifier "(" FieldDefList ")" ";"
    { $$ = {};
      $$[$2] = jQuery.extend($4, {__pk__:{type:'int'}});
    }

  | "entity" Identifier "(" ")" ";"
    { $$ = {};
      $$[$2] = {__pk__:{type:'int'}};
    }
  ;

FieldDefList

  : FieldDef
    { $$ = $1; }

  | FieldDef "," FieldDefList
    { $$ = jQuery.extend($1, $3); }

  | "{" IdentifierList "}" FieldType
    { $$ = {}
      for (var n = 0; n < $2.length; n++) {
        $$[$2[n]] = $4;
      }
      $$ = jQuery.extend($$, $6);
    }

  | "{" IdentifierList "}" FieldType "," FieldDefList
    { $$ = {};
      for (var n = 0; n < $2.length; n++) {
        $$[$2[n]] = $4;
      }
      $$ = jQuery.extend($$, $6);
    }
  ;

FieldDef

  : Identifier FieldType
    { $$ = {};
      $$[$1] = $2;
    }

  | "&" Identifier
    { $$ = {};
      $$['__ref__'+$2] = {type:'reference', referent:$2}; }

  | Identifier "&" Identifier
    { $$ = {};
      $$[$1] = {type:'reference', referent:$3};
    }
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
