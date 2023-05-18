# BULK INSERT

TBD


# DELETE

Deletes rows from a `<table-set>`.

```
<delete> ::=
  DELETE [ FROM ] <table-set>
  [ WHERE <predicate> ]
```

API:
```
+$  delete
  $:
    %delete
    table=qualified-object
    predicate=(unit predicate)
  ==
```
## Remarks

A stand-alone `DELETE` statement can only operate on a `<table>` and produces a `<transform>` of one command step with no CTEs.

When `<table-set>` is a `<table>` the command potentially mutates `<table>` and if so results in a state change of the Obelisk agent.

Data in the namespace *sys* cannot be deleted.

When `<table-set>` is a virtual table the command produces an output `<table-set>` which may be consumed as a pass-thru by a subsequent `<transform>` step.

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
    { VALUES (<scalar-expression> [ ,...n ] ) [ ,...n ]
      | <query> }
```

```
<scalar-expression> ::=
  { <constant>
    | <scalar-function>
    | <scalar-query>
    | [ unary-operator ] expression
    | expression <binary-operator> expression }
```

TBD see functions chapter, still undergoing design development.

API:
```
+$  insert
  $:
    %insert
    table=qualified-object
    columns=(unit (list @t))
    values=insert-values
  ==
```

## Remarks

A stand-alone `INSERT` statement can only operate on a `<table>` and produces a `<transform>` of one command step with no CTEs.

When `<table-set>` is a `<table>` the command potentially mutates `<table>` and if so results in a state change of the Obelisk agent.

Data in the namespace *sys* cannot be inserted into.

When `<table-set>` is a virtual table the command produces an output `<table-set>` which may be consumed as a pass-thru by a subsequent `<transform>` step.

The `VALUES` or `<query>` must provide data for all columns in the expected order.

Cord values are represented in single quotes 'this is a cord'.
Escape single quotes with double backslash thusly `'this is a cor\\'d'`.

## Produced Metadata

@@ROWCOUNT returns the total number of rows inserted

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated


# TRUNCATE TABLE

Removes all rows in a base table.

```
<truncate-table> ::=
  TRUNCATE TABLE [ <ship-qualifer> ] <table>
```

API:
```
+$  truncate-table
  $:
    %truncate-table
    table=qualified-object
  ==
```
## Remarks

The command potentially mutates `<table>` and if so results in a state change of the Obelisk agent.

Tables in the namespace *sys* cannot be truncated.

## Produced Metadata

none

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated


# UPDATE

Changes content of selected columns in existing rows of a `<table-set>`. 

```
<truncate-table> ::=
  UPDATE [ <ship-qualifer> ] <table>
    SET { <column> = <scalar-expression> } [ ,...n ]
    [ WHERE <predicate> ]
```

API:
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

## Remarks

A stand-alone `UPDATE` statement can only operate on a `<table>` and produces a `<transform>` of one command step with no CTEs.

When `<table-set>` is a `<table>` the command potentially mutates `<table>` and if so results in a state change of the Obelisk agent.

Data in the namespace *sys* cannot be updated.

When `<table-set>` is a virtual table the command produces an output `<table-set>` which may be consumed as a pass-thru by a subsequent `<transform>` step.

The `VALUES` or `<query>` must provide data for all columns in the expected order.

Cord values are represented in single quotes 'this is a cord'.
Escape single quotes with double backslash thusly `'this is a cor\\'d'`.

## Produced Metadata

@@ROWCOUNT returns the total number of rows updated

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated
