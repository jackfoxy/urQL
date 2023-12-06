# CREATE DATABASE

Creates a new user-space database accessible to any agent running on the ship. There is no sandboxing implemented.

_To Do NOTE_: Additional features like owner-desk property and GRANT desk permissions are under development.
```
<create-database> ::=
  CREATE DATABASE <database>
    [ AS OF { NOW
            | <timestamp>
            | n { SECONDS | MINUTES | HOURS | DAYS | WEEKS | MONTHS | YEARS } AGO
            | <inline-scalar>
            }
    ]
```

## Example
```
  CREATE DATABASE my-database
```

## API
```
+$  create-database      $:([%create-database name=@tas as-of=(unit @da)])
```

## Arguments

**`<database>`**
The user-defined name for the new database. It must comply with the Hoon term naming standard.

**`AS OF`**
Timestamp of database creation. Defaults to current time. Subsequent DDL and data actions must have timestamps equal to or greater than this timestamp. 

## Remarks

This command mutates the state of the Obelisk agent.

`CREATE DATABASE` must be executed independently within a script. The script will fail if there are prior commands. Subsequent commands will be ignored.

## Produced Metadata

INSERT row into `sys.sys.databases`.

## Example

create-database %db1

## Exceptions

"duplicate key: {<key>}" database already exists

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