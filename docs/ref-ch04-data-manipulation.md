# BULK INSERT

TBD


# DELETE
```
<delete> ::=
  DELETE [ FROM ] [ <ship-qualifer> ] <table>
  [ WHERE <predicate> ]
```

Discussion:
Data in the namespace *sys* cannot be deleted.

API:
```
+$  delete
  $:
    %delete
    table=qualified-object
    predicate=(unit predicate)
  ==
```

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated


# INSERT

```
<insert> ::=
  INSERT INTO [ <ship-qualifer> ] <table>
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

Discussion:
The `VALUES` or `<query>` must provide data for all columns in the expected order.
Tables in the namespace *sys* cannot be inserted into.
Cord values are represented in single quotes 'this is a cord'.
Escape single quotes with double backslash thusly `'this is a cor\\'d'`.

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

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated


# TRUNCATE TABLE

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

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated


# UPDATE

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

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated
