# Query

```
<query> ::=
[WITH (<query>) AS <alias> [ ,...n ] ]
[ FROM [ <ship-qualifer> ]<table-view> [ [AS] <alias> ]
       [ { { JOIN | LEFT JOIN | RIGHT JOIN | OUTER JOIN }
             [ <ship-qualifer> ]<table-view> [ [AS] <alias> ]
             ON <predicate>
          } [ ...n ]
          | CROSS JOIN
		        [ <ship-qualifer> ]<table-view> [ [AS] <alias> ]
       ]
]
[ { SCALAR <scalar-name> [ AS ] <scalar-function> } [ ...n ] ]
[ WHERE <predicate> ]
[ GROUP BY { <qualified-column> | <column-alias> | <column-ordinal> } [ ,...n ] ]
  [ HAVING <predicate> ]
]
SELECT [ TOP <n> ] [ BOTTOM <n> ] [ DISTINCT ]
  { * | { [<ship-qualifer>]<table-view> | <alias> }.*
      | { <qualified-column> | <constant> } [ [ AS ] <column-alias> ]
      | <scalar-name>
      | <aggregate-name>( { <column> | <scalar-name> } )
  } [ ,...n ]
[ ORDER BY [ { <qualified-column> | <column-alias> | <column-ordinal> }
             [ ASC | DESC ]
           ] [ ,...n ]
]
[ { [ INTO <table> ]
    | [ { UNION
          | COMBINE
          | EXCEPT
          | INTERSECT
          | DIVIDED BY [ WITH REMAINDER ]
        }
        <query>
      ]
  } [ ...n ]
]
[ AS OF { NOW
          | <timestamp>
          | n { SECONDS | MINUTES | HOURS | DAYS | WEEKS | MONTHS | YEARS } AGO
          | <inline-scalar>
        }
]
```
Cross database joins are allowed, but not cross ship joins.

`SELECT ... INTO` targets an existing table not otherwise in the query, and completes the command.

Do not use `ORDER BY` in Common Table Experessions (CTE, WITH clause) or in any query manipulated by set operators prior to the last of the queries, except when `TOP` or `BOTTOM` is specified.

Set operators apply the previous result set to the next query unless otherwise qualified by brackets `{ ... }`.

`AS OF` defaults to `NOW`

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
      { <single-column-query> | ( <value> ,...n ) }
    | expression <inequality operator> { ALL | ANY} ( <single-column-query> )
    | [ NOT ] EXISTS { <column value> | <single-column-query> } }
```
`DISTINCT FROM` is like equals `=` except comparing two `NOT EXISTS` yields false.
`<single-column-query>` is defined in a CTE and must return only one column.

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
`<scalar-query>` is defined in a CTE and must return only one column. The first returned value is accepted and subsequent values ignored.

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
Whitespace is not required between operands and binary-operators, except when the left operand is a numeric literal, in which case whitespace is required.

```
<qualified-column> ::=
[ [ <ship-qualifer> ]<table-view> | <alias> } ].<column-name>
```
