
# Query

```
<query> ::=
[WITH (<query>) AS <alias> [ ,...n ] ]
[ { ]
FROM [ <ship-qualifer> ]<table-view> [ [AS] <alias> ]
       [ { { JOIN | LEFT JOIN | RIGHT JOIN | OUTER JOIN [ALL] }
              [ <ship-qualifer> ]<table-view> [ [AS] <alias> ]
              ON <predicate> 
          } [ ...n ]
          | CROSS JOIN
		      [ <ship-qualifer> ]<table-view> [ [AS] <alias> ]
       ]
[ { SCALAR <scalar-name> [ AS ] <scalar-function> } [ ...n ] ]       
[ WHERE <predicate> ]
SELECT [ TOP <n> ] [ BOTTOM <n> ] [ DISTINCT ]
  { * | { { [<ship-qualifer>]<table-view> | <alias> }.*
          | { <qualified-column> | <constant> } [ [ AS ] <column-alias> ]
          | <scalar-name>
          | <aggregate-name>( { <column> | <scalar-name> } )
         } [ ,...n ]
  }
[ GROUP BY { <qualified-column> | <column-alias> | <column-ordinal> } [ ,...n ] 
  [ HAVING <predicate> ] ]
[ ORDER BY { { <qualified-column> | <column-alias> | <column-ordinal> } 
               [ ASC | DESC ] } [ ,...n ] ]
[ INTO <table> ]
[ { UNION 
    | COMBINE 
    | EXCEPT 
    | INTERSECT 
    | DIVIDED BY [ WITH REMAINDER ] 
  }
  <query> ] [ } ] [ ...n ]
[ AS OF { Now
          | <timestamp>
          | n { SECONDS | MINUTES | HOURS | DAYS | WEEKS | MONTHS | YEARS } AGO
          | <inline-scalar>
        } ]
```
Cross database joins are allowed, but not cross ship joins.

`SELECT ... INTO` targets an existing table not otherwise in the query.

Do not use `ORDER BY` in Common Table Experessions (CTE, WITH clause) or in any query manipulated by set operators prior to the last of the queries, except when `TOP` or `BOTTOM` is specified.

Set operators apply the previous result set to the next query unless otherwise qualified by brackets `{ ... }`.

```
<predicate> ::= 
  { [ NOT ] <predicate> |  [ ( ] <simple-predicate> [ ) ] }
  [ { { AND | OR } [ NOT ] { <predicate> |  [ ( ] <simple-predicate> [ ) ] }
      [ ...n ]
  ]
```

```
<simple-predicate> ::=
  { expression <binary-operator> expression
    | expression [ NOT ] BETWEEN expression [ AND ] expression
    | expression IS [ NOT ] DISTINCT FROM expression
    | expression [ NOT ] IN
      { <cte one column query> | ( <value> ,...n ) }
    | expression <inequality operator> { ALL | ANY} ( <cte one column query> )
    | [ NOT ] EXISTS { <column value> | <cte one column query> } }
```
`DISTINCT FROM` is like equals `=` except comparing two `NOT EXISTS` yields false.

```
<scalar-function> ::=
  IF <predicate> THEN { <expression> | <scalar-function> } 
                 ELSE { <expression> | <scalar-function> } ENDIF
  | CASE <expression>
    WHEN { <expression> | <predicate> } 
	  THEN { <expression> | <scalar-function> } [ ...n ]
    [ ELSE { <expression> | <scalar-function> } ]
    END
  | COALESCE ( <expression> [ ,...n ] )
  | BEGIN <arithmetic on expressions and scalar functions> END
  | *hoon (TBD)
```
If a `CASE` expression uses `<predicate>`, the expected boolean (or loobean) logic applies. 
If it uses `<expression>` `@`0 is treated as false and any other value as true (not loobean).

`COALESCE` returns the first `<expression>` in the list that exists where not existing occurs when selected `<expression>` value is not returned due to `LEFT` or `RIGHT JOIN` not matching.

```
<expression> ::=
  { <column>
    | <scalar-function>
	| <scalar-query>
    | <aggregate-name>( { <column> | <scalar-name> } )
  }
```

```
<column> ::=
  { [ <qualified-column>
    | <column-alias>
    | <constant> }
```

```
<binary-operator> ::=
  { = | <> | != | > | >= | !> | < | <= | !< }
```

```
<qualified-column> ::= 
[ [ <ship-qualifer> ]<table-view> | <alias> } ].<column-name>
```
