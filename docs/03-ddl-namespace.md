# CREATE NAMESPACE
Namespaces group various database components, including tables and views. When not explicitly specified, namespace designations default to `dbo`.

```
<create-namespace> ::= 
  CREATE NAMESPACE [<database>.]<namespace> [ <as-of-time> ]
```

## Example
`CREATE NAMESPACE my-namespace`

## API
```
+$  create-namespace 
    database-name=@tas 
    name=@tas
    as-of=(unit @da)
  ==
```

## Arguments

**`<namespace>`**
This is a user-defined name for the new namespace. It must adhere to the hoon term naming standard. 

Note: The "sys" namespace is reserved for system use.

**`<as-of-time>`**
Timestamp of namespace creation. Defaults to NOW (current time). When specified timestamp must be greater than latest system timestamp for the database. 

## Remarks
This command mutates the state of the Obelisk agent.

## Produced Metadata

system timestamp

## Exceptions

"duplicate key: {<key>}" namespace already exists
`<as-of-time>` less than latests system timestamp

# ALTER NAMESPACE
Transfer an existing user `<table>` or `<view>` to another `<namespace>`.

```
<alter-namespace> ::=
  ALTER NAMESPACE [ <database>. ]<namespace>
    TRANSFER { TABLE | VIEW } [ <db-qualifer> ]{ <table> | <view> }
    [ <as-of-time> ]
```

## API
```
+$  alter-namespace
  $:  %alter-namespace
    database-name=@tas
    source-namespace=@tas
    object-type=object-type
    target-namespace=@tas
    target-name=@tas
    as-of=(unit @da)
  ==
```

## Arguments

**`<namespace>`**
Name of the target namespace into which the object is to be transferred. 

**`TABLE | VIEW`**
Indicates the type of the target object.

**`<table> | <view>`**
Name of the object to be transferred to the target namespace.

**`<as-of-time>`**
Timestamp of namespace update. Defaults to NOW (current time). When specified timestamp must be greater than latest system timestamp for the database. 

## Remarks
This command mutates the state of the Obelisk agent.

Objects cannot be transferred in or out of namespace *sys*.

## Produced Metadata
update `<database>.sys.tables`
update `<database>.sys.views`

## Exceptions
namespace does not exist
`<table>` or `<view>` does not exist
`<as-of-time>` less than latests system timestamp

# DROP NAMESPACE
Deletes a `<namespace>` and all its associated objects.

```
<drop-namespace> ::= 
  DROP NAMESPACE [ FORCE ] [ <database>. ]<namespace>
  [ <as-of-time> ]
```

## API
```
+$  drop-namespace
  $:
    %drop-namespace 
    database-name=@tas 
    name=@tas 
    force=?
    as-of=(unit @da)
  ==
```

## Arguments

**`FORCE`**
Optionally, force deletion of `<namespace>`.

**`<namespace>`**
The name of `<namespace>` to delete.

**`<as-of-time>`**
Timestamp of namespace deletion. Defaults to NOW (current time). When specified timestamp must be greater than latest system timestamp for the database. 

## Remarks
This command mutates the state of the Obelisk agent.

Only succeeds when no *populated* `<table>`s are in the namespace, unless `FORCE` is specified, possibly resulting in cascading object drops described in `DROP TABLE`.

The namespaces *dbo* and *sys* cannot be dropped.

## Produced Metadata
DELETE row from `<database>.sys.namespaces`.

## Exceptions
`<namespace>` does not exist.
`<namespace>` has populated tables and FORCE was not specified.
`<as-of-time>` specified and not less than latest system timestamp for database.
