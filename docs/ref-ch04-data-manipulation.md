# DELETE
```
[ WITH (<query>) AS <alias> [ ,...n ] ]
DELETE [ FROM ] [ <ship-qualifer> ]<table-name>
[ WHERE <predicate>
```

Discussion:
Data in the namespace *sys* cannot be deleted.


# INSERT

```
INSERT INTO [ <ship-qualifer> ]<table-name>
  [ ( <column-name> [ ,...n ] ) ]
  { VALUES ( { DEFAULT | <scalar-expression> } [ ,...n ] ) [ ,...n ]
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
`DEFAULT` is the bunt of the column type.
Cord values are represented in single quotes 'this is a cord'.
Escape single quotes with double backslash thusly `'this is a cor\\'d'`.


# MERGE

```
[ WITH (<query>) AS <alias> [ ,...n ] ]
MERGE [ INTO ] [ <ship-qualifer> ]<target-table-name> [ [ AS ] <alias> ]
USING [ <ship-qualifer> ]<table-source-name> [ [ AS ] <alias> ]
  ON <predicate>
  [ WHEN MATCHED [ AND <predicate> ]
    THEN <merge-matched> ] [ ...n ]
  [ WHEN NOT MATCHED [ BY TARGET ] [ AND <predicate> ]
    THEN <merge-not-matched> ]
  [ WHEN NOT MATCHED BY SOURCE [ AND <predicate> ]
    THEN <merge-matched> ] [ ...n ]
```

```
<merge-matched> ::=
  UPDATE { SET <column-name> = <scalar-expression> | DELETE }  [ ...n ]
```

```
<merge-not-matched> ::=
  INSERT [ ( <column-name> [ ,...n ] ) ]
    VALUES ( { DEFAULT | ~ | <scalar-expression> } [ ,...n ] )
```

Discussion:
Cross ship merges not allowed.
The discussion of `INSERT` also applies when not matched by target.
In the case of multiple `WHEN MATCHED` or `WHEN NOT MATCHED` and overlapping predicates, the cases are processed in order, so the last successful case will take precedence.
Tables in the namespace *sys* cannot be merged into.


# TRUNCATE TABLE

`TRUNCATE TABLE [ <ship-qualifer> ]<table-name>`

Discussion:
Tables in the namespace *sys* cannot be truncated.


# UPDATE

```
[WITH (<query>) AS <alias> [ ,...n ] ]
UPDATE [ FROM ] [ <ship-qualifer> ]<table-name>
SET { <column-name> = { <scalar-expression> | DEFAULT | ~ }
[ WHERE <predicate> ]
```

Discussion:
`DEFAULT` available only when column has a default defined.
`~` available only when column defined as `u(aura}`.
Tables in the namespace *sys* cannot be updated.
