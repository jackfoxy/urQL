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
        | { <qualified-column>
            | <constant> }
            | <scalar-name>
            | <scalar-query>
            | <aggregate-function>( { <column> | <scalar-name> } )
          } [ [ AS ] <column-alias> ]
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
`JOIN` Inner join returns all matching pairs of rows.
`LEFT JOIN` Left outer join returns all rows from the left table not meeting the join condition long with all matching pairs of rows. Missing columns from the right table are `NULL` filled.
`RIGHT JOIN` Right outer join returns all rows from the right table not meeting the join condition long with all matching pairs of rows. Missing columns from the left table are `NULL` filled.
`OUTER JOIN` Full outer join returns all rows from both tables not meeting the join condition long with all matching pairs of rows. Missing columns are `NULL` filled.
`CROSS JOIN` Cross join is a cartesian join of two tables.

Cross database joins are allowed, but not cross ship joins.

`HAVING <predicate>` any column reference in the predicate must be one of the grouping columns or be contained in an aggregate function.

`SELECT ... INTO` targets an existing table not otherwise in the query, and completes the command.

Do not use `ORDER BY` in Common Table Expressions (CTE, WITH clause) or in any query manipulated by set operators prior to the last of the queries, except when `TOP` or `BOTTOM` is specified.

Collection operators `UNION`, etc. apply the previous result collection to the next query result unless otherwise qualified by brackets `{ ... }`.

`AS OF` defaults to `NOW`
`AS OF <inline-scalar>` Scalar function written inline that returns `<timestamp>`.

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
    | expression [ NOT ] EQUIV expression
    | expression [ NOT ] IN
      { <single-column-query> | ( <value> ,...n ) }
    | expression <inequality operator> { ALL | ANY} ( <single-column-query> )
    | expression [ NOT ] BETWEEN expression [ AND ] expression
    | [ NOT ] EXISTS { <column value> | <single-column-query> } }
```
Since nullable table columns are not allowed, `NOT EXISTS` can only yield `true` on the column of an outer join that is not in a returned row or a `<scalar-query>` that returns nothing. `NULL` is a marker for this case.

`[ NOT ] EQUIV` is a binary operator like [ NOT ] equals `<>`, `=` except comparing two `NOT EXISTS` yields true.

`<single-column-query>` is defined in a CTE and must return only one column.

```
<binary-operator> ::=
  { = | <> | != | > | >= | !> | < | <= | !< }
```
Whitespace is not required between operands and binary-operators, except when the left operand is a numeric literal, in which case whitespace is required.

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
  | <arithmetic>
  | <bitwise>
  | <predicate>
  | <boolean>
  | <scalar>
```
If a `CASE` expression uses `<predicate>`, the expected boolean (or loobean) logic applies.
If it uses `<expression>` `@`0 is treated as false and any other value as true (not loobean).

`COALESCE` returns the first `<expression>` in the list that exists where not existing occurs when selected `<expression>` value is not returned due to `LEFT` or `RIGHT JOIN` not matching.

See CH 8 Functions for full documentation on Scalars.

```
<expression> ::=
  { <column>
    | <scalar-function>
	  | <scalar-query>
    | <aggregate-function>( { <column> | <scalar-name> } )
  }
```
`<scalar-query>` is defined in a CTE and must return only one column. The first returned value is accepted and subsequent values ignored.

```
<aggregate-function> ::=
  { AVG | MAX | MIN | SUM | COUNT | AND | OR | <user-defined> }
```

```
<column> ::=
  { [ <qualified-column>
    | <column-alias>
    | <constant> }
```

```
<qualified-column> ::=
[ [ <ship-qualifer> ]<table-view> | <alias> } ].<column-name>
```
