# DELETE
```
DELETE [ FROM ] [ <ship-qualifer> ]<table-name>
[ WITH (<query>) AS <alias> [ ,...n ] ]
[ WHERE <predicate> ]
```

Discussion:
Data in the namespace *sys* cannot be deleted.


# INSERT

```
INSERT INTO [ <ship-qualifer> ]<table-name>
  [ ( <column-name> [ ,...n ] ) ]
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


# MERGE

```
MERGE [ INTO ] [ <ship-qualifer> ]<target-table-name> [ [ AS ] <alias> ]
[ WITH (<query>) AS <alias> [ ,...n ] ]
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
  UPDATE { SET <column-name> = <scalar-expression> }  [ ...n ]
```

```
<merge-not-matched> ::=
  INSERT [ ( <column-name> [ ,...n ] ) ]
    VALUES ( <scalar-expression> [ ,...n ] )
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
UPDATE [ <ship-qualifer> ]<table-name>
SET { <column-name> = <scalar-expression> } [ ,...n ]
[ WITH (<query>) AS <alias> [ ,...n ] ]
[ WHERE <predicate> ]
```

Discussion:
Tables in the namespace *sys* cannot be updated.
