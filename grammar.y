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
{

var constructDependencies = function(db) {
    var dependencies = {};
    for (var entity in db) {
        dependencies[entity] = [];
        for (var field in db[entity]) {
            field = db[entity][field];
            if (field.type == 'reference'
                && dependencies[entity].indexOf(field.referent) == -1)
            {
                dependencies[entity].push(field.referent);
            }
        }
    }
    return dependencies;
}

// topologically sort a dependency graph
// returns an array of nodes, independent nodes first
// this is similar to the implementation in The AWK Programming Language
var tsort = function(graph) {
    // copy the graph because we're going to fuck it up
    graph = jQuery.extend({}, graph);

    var sorted = [];
    var independent = [];
    for (var node in graph) {
        if (graph[node].length == 0) {
            independent.push(node);
            delete graph[node];
        }
    }

    while (independent.length > 0) {
        var node = independent.shift();
        sorted.push(node);
        for (var dependent in graph) {
            var i = 0;
            while (i < graph[dependent].length) {
                if (graph[dependent][i] == node) {
                    graph[dependent].splice(i,1);
                } else {
                    i++;
                }
            }
            if (graph[dependent].length == 0) {
                independent.push(dependent);
                delete graph[dependent];
            }
        }
    }

    for (var node in graph) {
        if (graph[node].length > 0) {
            return "cycle! "+node+" to "+graph[node];
        }
    }

    return sorted;
}

var struct2sql = function(db, entity) {
    var fieldlist = [];
    for (var fieldname in db[entity]) {
        var field = db[entity][fieldname];
        var sqlfield = fieldname+' '+field.type;
        if ('size' in field) {
            sqlfield += '('+field.size+')';
        }
        if ('referent' in field) {
            sqlfield += ' FOREIGN KEY REFERENCES '+field.referent+'.pk';
        }
        fieldlist.push(sqlfield);
    }
    return 'CREATE TABLE '+entity+' ('+fieldlist.join('<br>, ')+');';
}

var output = "";
var log = function(msg) {output += msg + "<br><br>"};

var db = $1;
var dep = constructDependencies(db);
//return dep;

// for now, let's assume that there are no cycles in the dependency graph...
var sorted = tsort(dep);
for (var n = 0; n < sorted.length; n++)
    log(struct2sql(db, sorted[n]));

return output;

} // end of Body definition
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
