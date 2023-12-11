# BULK INSERT

TBD


# DELETE

Deletes rows from a `<table-set>`.

```
<delete> ::=
  DELETE [ FROM ] <table-set>
  [ WHERE <predicate> ]
  [ AS OF { NOW
            | <timestamp>
            | n { SECONDS | MINUTES | HOURS | DAYS | WEEKS | MONTHS | YEARS } AGO
            | <inline-scalar>
            }
    ]
```
## API
```
+$  delete
  $:
    %delete
    table=qualified-object
    predicate=(unit predicate)
  ==
```

## Arguments

**`<table-set>`**
The target of the `DELETE` operation.

**`<predicate>`**
Any valid `<predicate>`, including predicates on CTEs.

## Remarks

When `<table-set>` is a `<table>`, the command potentially mutates `<table>` resulting in a state change of the Obelisk agent.

A stand-alone `DELETE` statement can only operate on a `<table>` and produces a `<transform>` of one command step.

Data in the *sys* namespace cannot be deleted.

When `<table-set>` is a virtual table, the command produces an output `<table-set>` which may be consumed as a pass-thru by a subsequent `<transform>` step.

## Produced Metadata

@@ROWCOUNT returns the total number of rows deleted

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated


# INSERT

Inserts rows into a `<table-set>`.

```
<insert> ::=
  INSERT INTO <table-set>
    [ ( <column> [ ,...n ] ) ]
    { VALUES (<scalar-expression> [ ,...n ] ) [ ...n ]
      | <transform> }
    [ AS OF { NOW
            | <timestamp>
            | n { SECONDS | MINUTES | HOURS | DAYS | WEEKS | MONTHS | YEARS } AGO
            | <inline-scalar>
            }
    ]
```

```
<scalar-expression> ::=
  { <constant>
    | <scalar-function>
    | <scalar-query>
    | [ unary-operator ] expression
    | expression <binary-operator> expression }
```

Details of `<scalar-function>` are TBD. Refer to the Functions chapter currently under development.

## API
```
+$  insert
  $:
    %insert
    table=qualified-object
    columns=(unit (list @t))
    values=insert-values
  ==
```

## Arguments

**`<table-set>`**
The target of the `INSERT` operation.

**`<column>` [ ,...n ]**
When present, the column list must account for all column identifiers (names or aliases) in the target once. It determines the order in which update values are applied and the output `<table-set>`'s column order.   

**(`<scalar-expression>` [ ,...n ] ) [ ,...n ]**
Row(s) of literal values to insert into target. Source auras must match target columnwise.

**`<transform>`**
Transform creating source `<table-set>` to insert into target. Source auras must match target columnwise.

## Remarks

When `<table-set>` is a `<table>` the command potentially mutates `<table>`, resulting in a state change of the Obelisk agent.

When `INSERT` operates on a `<table>`, it must be in the terminal (last) step of a `<transform>` or a stand-alone `INSERT`.

Data in the *sys* namespace cannot be inserted into.

When `<table-set>` is a virtual table, the command produces an output `<table-set>` which may be consumed as a pass-thru by a subsequent `<transform>` step.

The `VALUES` or `<query>` must provide data for all columns in the expected order.

Cord values are represented in single quotes `'this is a cord'`. Single quotes within cord values must be escaped with double backslash as `'this is a cor\\'d'`.

If `( <column> [ ,...n ] )` is not specified, the inserted columns must be arranged in the same order as the target `<table-set>`.

When the target `<table-set>` is a `<table>`, the input `<row-type>` must match the `<table>` `<row-type>`.

When target `<table-set>` is not a `<table>` and the input is from a `<transform>` then the target `<table-set>` and `<transform>` `<table-set>` must have the same all-column `<row-type>`. New `<row-type>` sub-types may be introduced.

Note that multiple parentheses enclosed rows of column values are NOT comma separated.

## Produced Metadata

`@@ROWCOUNT` returns the total number of rows inserted

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated
unique key violation
colum misalignment


# TRUNCATE TABLE

Removes all rows in a base table.

```
<truncate-table> ::=
  TRUNCATE TABLE [ <ship-qualifier> ] <table>
  [ AS OF { NOW
            | <timestamp>
            | n { SECONDS | MINUTES | HOURS | DAYS | WEEKS | MONTHS | YEARS } AGO
            | <inline-scalar>
            }
    ]
```

## API
```
+$  truncate-table
  $:
    %truncate-table
    table=qualified-object
  ==
```

## Arguments

**`<table>`**
The target table.

## Remarks

The command potentially mutates `<table>`, resulting in a state change of the Obelisk agent.

Tables in the *sys* namespace cannot be truncated.

## Produced Metadata

none

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated


# UPDATE

Changes content of selected columns in existing rows of a `<table-set>`. 

```
<update> ::=
  UPDATE [ <ship-qualifier> ] <table-set>
    SET { <column> = <scalar-expression> } [ ,...n ]
    [ WHERE <predicate> ]
  [ AS OF { NOW
            | <timestamp>
            | n { SECONDS | MINUTES | HOURS | DAYS | WEEKS | MONTHS | YEARS } AGO
            | <inline-scalar>
            }
    ]
```

## API
```
+$  update
  $:
    %update
    table=qualified-object
    columns=(list @t)
    values=(list value-or-default)
    predicate=(unit predicate)
  ==
```

## Arguments

**`<table-set>`**
The target of the `UPDATE` operation.

**`<column>` = `<scalar-expression>`**
`<column>` is a column name or alias of a target column. `<scalar-expression>` is a valid expression within the statement context.

**`<predicate>`**
Any valid `<predicate>`, including predicates on CTEs.

## Remarks

When `<table-set>` is a `<table>`, the command potentially mutates the data within `<table>`, resulting in a state change of the Obelisk agent.

A stand-alone `UPDATE` statement can only operate on a `<table>`, producing a `<transform>` of one command step with no CTEs.

Data in the *sys* namespace cannot be updated.

When `<table-set>` is a virtual table, the command produces an output `<table-set>` which may be consumed as a pass-thru by a subsequent `<transform>` step.

The `VALUES` or `<query>` must provide data for all columns in the expected order.

Cord values are represented in single quotes 'this is a cord'. Single quotes within cord values must be escaped with double backslash as `'this is a cor\\'d'`.

## Produced Metadata

`@@ROWCOUNT` returns the total number of rows updated

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated
unique key violation
aura mismatch on `SET`
