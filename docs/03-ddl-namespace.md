# CREATE NAMESPACE
Namespaces group various database components, including tables and views. When not explicitly specified, namespace designations default to `dbo`.

```
<create-namespace> ::= 
  CREATE NAMESPACE [<database>.]<namespace>
   [ AS OF { NOW
            | <timestamp>
            | n { SECONDS | MINUTES | HOURS | DAYS | WEEKS | MONTHS | YEARS } AGO
            | <inline-scalar>
            }
    ]
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

**`AS OF`**
Timestamp of namespace creation. Defaults to current time. When specified timestamp must be equal to or greater than latest system timestamp for the database. 

## Remarks
This command mutates the state of the Obelisk agent.

## Produced Metadata

system timestamp

## Exceptions

"duplicate key: {<key>}" namespace already exists
AS OF less than latests system timestamp

# ALTER NAMESPACE
Transfer an existing user `<table>` or `<view>` to another `<namespace>`.

```
<alter-namespace> ::=
  ALTER NAMESPACE [ <database>. ]<namespace>
    TRANSFER { TABLE | VIEW } [ <db-qualifer> ]{ <table> | <view> }
    [ AS OF { NOW
            | <timestamp>
            | n { SECONDS | MINUTES | HOURS | DAYS | WEEKS | MONTHS | YEARS } AGO
            | <inline-scalar>
            }
    ]
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

**`AS OF`**
Timestamp of namespace update. Defaults to current time. When specified timestamp must be equal to or greater than latest system timestamp for the database. 

## Remarks
This command mutates the state of the Obelisk agent.

Objects cannot be transferred in or out of namespace *sys*.

## Produced Metadata
update `<database>.sys.tables`
update `<database>.sys.views`

## Exceptions
namespace does not exist
`<table>` or `<view>` does not exist
AS OF less than latests system timestamp

# DROP NAMESPACE
Deletes a `<namespace>` and all its associated objects.

```
<drop-namespace> ::= 
  DROP NAMESPACE [ FORCE ] [ <database>. ]<namespace>
  [ AS OF { NOW
            | <timestamp>
            | n { SECONDS | MINUTES | HOURS | DAYS | WEEKS | MONTHS | YEARS } AGO
            | <inline-scalar>
            }
    ]
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

**`AS OF`**
Timestamp of namespace deletion. Defaults to current time. When specified timestamp must be equal to or greater than latest system timestamp for the database. 

## Remarks
This command mutates the state of the Obelisk agent.

Only succeeds when no *populated* `<table>`s are in the namespace, unless `FORCE` is specified, possibly resulting in cascading object drops described in `DROP TABLE`.

The namespaces *dbo* and *sys* cannot be dropped.

## Produced Metadata
DELETE row from `<database>.sys.namespaces`.

## Exceptions
`<namespace>` does not exist.
`<namespace>` has populated tables and FORCE was not specified.
`AS OF` specified and not less than latest system timestamp for database.
