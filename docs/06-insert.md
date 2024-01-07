# INSERT

Inserts rows into a `<table-set>`.

```
<insert> ::=
  INSERT INTO <table-set>
    [ ( <column> [ ,...n ] ) ]
    { VALUES (<scalar-expression> [ ,...n ] ) [ ...n ]
      | <transform> }
    [ <as-of-time> ]
```

```
<scalar-expression> ::=
  { <constant>
    | TBD }
```

Currently only constants are supported as `VALUES`.

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
