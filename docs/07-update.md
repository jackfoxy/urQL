# UPDATE
(currently supported in urQL parser, not yet supported in Obelisk)

Changes content of selected columns in existing rows of a `<table-set>`. 

```
<update> ::=
  UPDATE [ <ship-qualifier> ] <table-set>
    SET { <column> = <scalar-expression> } [ ,...n ]
    [ WHERE <predicate> ]
  [ <as-of-time> ]
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