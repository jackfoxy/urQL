```
<query> ::=
[WITH (<query>) AS <alias> [ ,...n ] ]
FROM [ <ship-qualifer> ]<table-view> [ [AS] <alias> ]
       [ { { JOIN | LEFT JOIN | RIGHT JOIN | OUTER JOIN [ALL] }
              [ <ship-qualifer> ]<table-view> [ [AS] <alias> ]
              ON <predicate> 
          } [ ,...n ]
          | CROSS JOIN
       ]
[ WHERE <predicate> ]
SELECT [ TOP <n> | BOTTOM <n> ] [ DISTINCT ]
  { * 
    | {
        { [<ship-qualifer>]<table-view> | <alias> }.*
        | { <qualified-column> | <constant> } [ [ AS ] <column-alias> ]
        | <column-alias> = { <qualified-column> | <constant> }
      } [ ,...n ]
  }
[ SCALAR [ [ AS ] { [^..^]<column-name> | [^..^]<column-alias> | <ordinal> } ]
  { <expression> | (TBD) *hoon }
]
[ GROUP BY { <column> | <column-ordinal>  } [ ,...n ]
  [ HAVING <predicate> ]
  [ AGGREGATE [ [ AS ] { [^..^]<column-name> | [^..^]<column-alias> | <ordinal> } ]
    { <expression> | (TBD) *hoon }
  ]
]
[ INTO <new-table> ]
[ ORDER BY { <column> | <column-ordinal>  } [ ,...n ] ]
[ { UNION 
    | COMBINE 
    | EXCEPT 
    | INTERSECT 
    | DIVIDED BY [ WITH REMAINDER ] 
```

```
<qualified-column> ::= 
```
[ [ <ship-qualifer> ]<table-view> | <alias> } ].<column>
```
<predicate> ::= 
  { [ NOT ] <predicate> | ( <simple-predicate> ) }
  [ { { AND | OR } [ NOT ] { <predicate> | ( <simple-predicate> ) }
      [ ...n ]
  ]
```

```
<simple-predicate> ::=
  { expression <binary-operator> expression
    | expression [ NOT ] BETWEEN expression [ AND ] expression
    | expression IS [ NOT ] DISTINCT FROM expression
    | expression [ NOT ] IN
      { <cte-one-column-query> | ( <value> ,...n ) }
    | expression <inequality-operator> { ALL | ANY} ( <cte-one-column-query> )
    | [ NOT ] EXISTS { <column-value> | <cte-one-column-query> } }
```

```
<expression> ::=
  {
    constant
    | <column-value>
    | <scalar-function>
  }
```

```
<binary-operator> ::=
  { = | <> | != | > | >= | !> | < | <= | !< }
```

```
`<column> ::=
  { [ { <alias>. | <table-view>. } ]<column-name>
    | <constant> 
    | <column-alias> }
```

```
<scalar-function> ::=
  IF <predicate> THEN <expression> ELSE <expression> ENDIF
  | CASE <expression>`
    WHEN { <predicate> | <expression> } THEN <expression> [ ...n ]
    [ ELSE <expression> ]
    END
  | COALESCE ( <expression> [ ,...n ] )
  | native hoon (stretch goal)
```

Discussion:
Not shown in diagrams, parentheses distinguish order of operations for binary conjunctions `AND` and `OR`.

Set operators apply the previous result set to the next query unless otherwise qualified by parentheses.

`ORDER BY` is not recommended in Common Table Experessions (CTE, WITH clause) or in any query joined by set operators prior to the last of the queries, except when `TOP` or `BOTTOM` is specified.

`SELECT INTO` targets an existing table not otherwise in the query.

`COALESCE` returns the first `<expression>` in the list that does not evaluate to `~` (in the case of unit) or not in the selected `<expression>` due to `LEFT` or `RIGHT JOIN`.

If a `CASE WHEN` expression is a `<predicate>`, the expected boolean (or loobean) logic applies. If it is a <expression> atom value 0 is treated as false and any other value as true (not loobean).

Cross database joins are allowed, but not cross ship joins.

`DISTINCT FROM` is like equals, `=`, except comparing two nulls will yield false.
