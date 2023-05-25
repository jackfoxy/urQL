# DROP DATABASE
Deletes an existing `<database>` and all associated objects.
```
<drop-database> ::= DROP DATABASE [ FORCE ] <database>
```

## API
```
+$  drop-database        
  $: 
    %drop-database
    name=@tas
    force=?
  ==
```

## Arguments

**`FORCE`**
Optionally, force deletion of a database.

**`<database>`**
The name of the database to delete.

## Remarks
This command mutates the state of the Obelisk agent.

The command only succeeds when no populated tables exist in the database, unless `FORCE` is specified.

## Produced Metadata
DELETE row from `sys.sys.databases`.

## Exceptions
`<database>` does not exist.
`<database>` has populated tables and FORCE was not specified.


# DROP INDEX
Deletes an existing `<index>`.

```
<drop-index> ::= 
  DROP INDEX <index>
    ON [ <db-qualifer> ] { <table> | <view> }
```

## API
```
+$  drop-index
  $:
    %drop-index
    name=@tas
    object=qualified-object
  ==
```

## Arguments

**`<index>`**
The name of the index to delete.

**`<table> | <view>`**
`<table>` or `<view>` with the named index.


## Remarks
This command mutates the state of the Obelisk agent.

Indexes with names that begin with "pk-" cannot be dropped, as these are table primary keys.

This command can be used to delete a `<foreign-key>`.

If `<view>` is shadowing `<table>`, the system attempts to find `<index>` on `<view>` first, then `<table>`.

## Produced Metadata

DELETE FROM `<database>.sys.indices`
DELETE FROM `<database>.sys.table-ref-integrity`

## Exceptions
`<table>` or `<view>` does not exist
`<index>` does not exist on `<table>` or `<view>`.


# DROP NAMESPACE
Deletes a `<namespace>` and all its associated objects.

```
<drop-namespace> ::= 
  DROP NAMESPACE [ FORCE ] [ <database>. ]<namespace>
```

## API
```
+$  drop-namespace
  $:
    %drop-namespace 
    database-name=@tas 
    name=@tas 
    force=?
  ==
```

## Arguments

**`FORCE`**
Optionally, force deletion of `<namespace>`.

**`<namespace>`**
The name of `<namespace>` to delete.

## Remarks
This command mutates the state of the Obelisk agent.

Only succeeds when no *populated* `<table>`s are in the namespace, unless `FORCE` is specified, possibly resulting in cascading object drops described in `DROP TABLE`.

The namespaces *dbo* and *sys* cannot be dropped.

## Produced Metadata
DELETE row from `<database>.sys.namespaces`.

## Exceptions
`<namespace>` does not exist.
`<namespace>` has populated tables and FORCE was not specified.


# DROP TABLE
Deletes a `<table>` and all associated objects

```
<drop-table> ::= DROP TABLE [ FORCE ] [ <db-qualifer> ]{ <table> }
```

## API
```
+$  drop-table
  $:
    %drop-table
    table=qualified-object
    force=?
  ==
```

## Arguments

**`FORCE`**
Optionally, force deletion of a table.

**`<table>`**
Name of `<table>` to delete.

## Remarks
This command mutates the state of the Obelisk agent.

Cannot drop if used in a view or foreign key, unless `FORCE` is specified, resulting in cascading object drops.

Cannot drop when the `<table>` is populated unless `FORCE` is specified.

## Produced Metadata
DELETE from `<database>.sys.tables`.
DELETE from `<database>.sys.views`.
DELETE from `<database>.sys.indices`.

## Exceptions
`<table>` does not exist.
`<table>` is populated and FORCE was not specified.
`<table>` used in `<view>` and FORCE was not specified.
`<table>` used in `<foreign-key>` and FORCE was not specified.

# DROP TRIGGER

TBD

```
<drop-trigger> ::= 
  DROP TRIGGER   [ <db-qualifer> ]{ <trigger> }
    ON { <table> | <view> }
```


# DROP TYPE

TBD

`DROP TYPE <type>`


## Remarks
Cannot drop if type-name is in use.


# DROP VIEW

```
<drop-view> ::= DROP VIEW [ FORCE ] [ <db-qualifer> ]<view>
```


## API
```
+$  drop-view
  $:
    %drop-view
    view=qualified-object
    force=?
  ==
```

## Arguments

**`FORCE`**
Force delete of `<view>`.

**`<view>`**
Name of `<view>` to delete.

## Remarks
This command mutates the state of the Obelisk agent.

Views that are in use in another view cannot be dropped unless `FORCE` is specified, which may result in cascading object drops.

## Produced Metadata
DELETE from `<database>.sys.views`.

## Exceptions
`<view>` does not exist.
`<view>` is in use by other `<view>` and FORCE was not specified.
