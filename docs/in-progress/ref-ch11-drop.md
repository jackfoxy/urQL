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
