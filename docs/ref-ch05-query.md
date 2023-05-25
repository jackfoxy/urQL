# QUERY

```
<query> ::=
  [ FROM <table-set> [ [AS] <alias> ]
    { JOIN | LEFT JOIN | RIGHT JOIN | OUTER JOIN }
      <table-set> [ [AS] <alias> ]
      ON <predicate>
      [ ...n ]
    | CROSS JOIN <table-set> [ [AS] <alias> ]
  ]
  [ { SCALAR <scalar> [ AS ] <scalar-function> } [ ...n ] ]
  [ WHERE <predicate> ]
  [ GROUP BY { <qualified-column> | <column-alias> | <column-ordinal> } 
             [ ,...n ]
    [ HAVING <predicate> ]
  ]
  SELECT [ TOP <n> ] [ BOTTOM <n> ] [ DISTINCT ]
    { * | { [<ship-qualifer>]<table-view> | <alias> }.*
        | <expression> [ [ AS ] <column-alias> ]
    } [ ,...n ]
  [ ORDER BY 
    {
      { <qualified-column> | <column-alias> | <column-ordinal> } { ASC | DESC }
    }  [ ,...n ]
  ]
```
`JOIN` Inner join returns all matching pairs of rows.
`LEFT JOIN` Left outer join returns all rows from the left table not meeting the join condition long with all matching pairs of rows.
`RIGHT JOIN` Right outer join returns all rows from the right table not meeting the join condition long with all matching pairs of rows.
`OUTER JOIN` Full outer join returns matching pairs of rows as well as all rows from both tables not meeting the join condition.
`CROSS JOIN` Cross join is a cartesian join of two tables.

Cross database joins are allowed, but not cross ship joins.

`HAVING <predicate>` any column reference in the predicate must be one of the grouping columns or be contained in an aggregate function.

`SELECT ... INTO` targets an existing table not otherwise in the query, and completes the command.

Do not use `ORDER BY` in Common Table Expressions (CTE, WITH clause) or in any query manipulated by set operators prior to the last of the queries, except when `TOP` or `BOTTOM` is specified.

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
  { <qualified-column>
    | <constant>
    | <scalar>
	  | <scalar-query>
    | <aggregate-function>( { <column> | <scalar> } )
  }
```
`<scalar-query>` is defined in a CTE and must return only one column. The first returned value is accepted and subsequent values ignored.

```
<aggregate-function> ::=
  { AVG | MAX | MIN | SUM | COUNT | AND | OR | <user-defined> }
```

```
<column> ::=
  { <qualified-column>
    | <column-alias>
    | <constant> }
```

```
<qualified-column> ::=
[ [ <ship-qualifer> ]<table-view> | <alias> ].<column>
```

## API
```
+$  query
  $:
    %query
    from=(unit from)
    scalars=(list scalar-function)
    predicate=(unit predicate)
    group-by=(list grouping-column)
    having=(unit predicate)
    selection=select
    order-by=(list ordering-column)
  ==
```

## Arguments

** **

## Remarks

## Produced Metadata

## Exceptions

