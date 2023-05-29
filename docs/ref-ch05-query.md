# QUERY
The `<query>` statement provides a means to create `<table-set>`s derived from persisted and/or cached `<table-set>`s and/or constants. Data rows can be joined based on predicates, specific columns can be selected, and the resulting rows can be filtered by predicate.

The full syntax involves complex manipulations at the row level through scalar functions, data aggregation across preliminary rows via aggregate functions, filtering by aggregation, and row ordering.

NOTE: scalar and aggregate functions are currently under development and not available. Also, these are subject to change.

```
<query> ::=
  [ FROM <table-set> [ [AS] <alias> ]
    {
      { JOIN | LEFT JOIN | RIGHT JOIN | OUTER JOIN }
        <table-set> [ [AS] <alias> ]
        ON <predicate>
    } [ ...n ]
    | CROSS JOIN <table-set> [ [AS] <alias> ]
  ]
  [ { SCALAR <scalar> [ AS ] <scalar-function> } [ ...n ] ]
  [ WHERE <predicate> ]
  [ GROUP BY { <qualified-column> 
               | <column-alias> 
               | <column-ordinal> } [ ,...n ]
    [ HAVING <predicate> ]
  ]
  SELECT [ TOP <n> ] [ BOTTOM <n> ]
    { * | { [<ship-qualifer>]<table-view> | <alias> }.*
        | <expression> [ [ AS ] <column-alias> ]
    } [ ,...n ]
  [ ORDER BY 
    {
      { <qualified-column> | <column-alias> | <column-ordinal> } { ASC | DESC }
    }  [ ,...n ]
  ]
```
`JOIN` is an inner join returning all matching pairs of rows.

`LEFT JOIN` is a left outer join returning all rows from the left table not meeting the join condition, along with all matching pairs of rows.

`RIGHT JOIN` is a right outer join returning all rows from the right table not meeting the join condition, along with all matching pairs of rows.

`OUTER JOIN` is a full outer join returning matching pairs of rows, as well as all rows from both tables not meeting the join condition.

`CROSS JOIN` is a cartesian join of two tables.

Cross database joins are permitted, but not cross ship joins.

`HAVING <predicate>` filters aggregated rows returned from the `<query>`. The column references in the predicate must be either one of the grouping columns or be contained in an aggregate function.

Avoid using `ORDER BY` in CTEs or in any query prior to the last step in a `<transform>`, unless required by `TOP` or `BOTTOM` specified in the `SELECT` statement or, in the case of CTEs, it is used in an `<expression>` expecting a scalar result.

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
        { <scalar-query> | ( <value> ,...n ) }
    | expression <inequality-operator> 
        { ALL | ANY} { ( <scalar-query> ) | ( <value> ,...n ) }
    | expression [ NOT ] BETWEEN expression [ AND ] expression
    | [ NOT ] EXISTS { <column value> | <scalar-query> } }
```

When applied to a column `EXISTS` tests whether the returned `<row-type>` includes the required column. In the case of `<scalar-query>`, it tests whether a CTE returns any rows.

`[ NOT ] EQUIV` is a binary operator, similar to (not) equals `<>`, `=`. However, comparing two `NOT EXISTS` yields true.

`<scalar-query>` is a CTE that selects for one column. Depending on whether the operator expects a set or a value, it operates on the entire result set or on the first row returned, respectively. If the CTE is not ordered, results may be unpredictable.

```
<binary-operator> ::=
  { = | <> | != | > | >= | !> | < | <= | !< | EQUIV | NOT EQUIV}
```
Whitespace is not required between operands and binary-operators, except when the left operand is a numeric literal, in which case whitespace is required.

`<inequality-operator>` is any `<binary-operator>` other than equality and `EQUIV`.

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
If a `CASE` expression uses `<predicate>`, the expected boolean (or loobean) logic applies. If it uses `<expression>` `@`0 is treated as false and any other value as true (not loobean). (NOTE: This is preliminary design subject to change.)

`COALESCE` returns the first `<expression>` in the list that exists. Non-existence occurs when a selected `<expression>` value is not returned due to an outer join not matching or `<scalar-query>` not returning rows.

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
`<scalar-query>` is a CTE that returns only one column. The first returned value is accepted and subsequent values ignored. Ordering the CTE may be required for predictable results.

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
[ [ <ship-qualifer> ]<table-view> | <alias> ].<column-name>
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

**`<table-set> [ [AS] <alias> ]`**
Any valid `<table-set>`.

`<alias>` allows short-hand reference to the `<table-set>` in the `SELECT` clause and subsequent `<predicates>`. 

**`{ <qualified-column> | <column-alias> | <column-ordinal> }`**

Used to select columns for ordering and grouping. `<column-ordinal>`s are 1-based.

**`[ TOP <n> ] [ BOTTOM <n> ]`**

`SELECT` only the first and/or last `n` rows returned by the rest of the query. If the result set is less than `n`, the entire set of rows is returned.

`TOP` and `BOTTOM` require the presence of an `ORDER BY` clause.

## Remarks

The `SELECT` clause may choose columns from a single CTE, in which case the `FROM` clause is absent. It may also choose only constants and `SCALAR` functions on constants, in which case it returns a result set of one row.

The simplest possible query is `SELECT 0`.

`<query>` alone does not change the Obelisk agent state.

## Produced Metadata

`@@ROWCOUNT` returns the total number of rows returned.

## Exceptions

Provided `<query>` attempts execution (i.e., syntax and internal consistency checks pass), the only exceptions possible are performance-related, such as timeouts and memory constraints.
