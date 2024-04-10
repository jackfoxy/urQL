# DDL: Database

## CREATE DATABASE

Creates a new user-space database on the ship.

``
<create-database> ::=
  CREATE DATABASE <database> [ <as-of-time> ]
``

### API
``
+$  create-database
  $:
    %create-database
    name=@tas
    as-of=(unit <as-of>)
  ==
``

### Arguments

**`<database>`**
The user-defined name for the new database. It must comply with the Hoon term naming standard.

**`<as-of-time>`**
Timestamp of database creation. Defaults to `NOW` (current time). Subsequent DDL and data actions must have timestamps greater than this timestamp. 

### Remarks

This command mutates the state of the Obelisk agent. It inserts a row into the view `sys.sys.databases`.

`CREATE DATABASE` must be executed independently within a script. The script will fail if there are prior commands. Subsequent commands will be ignored.

### Produced Metadata

Schema timestamp (labelled 'system time')
Content timestamp (labelled 'data time')

### Exceptions

database name cannot be 'sys'
duplicate key: `<database>`

### Example
``
  CREATE DATABASE my-database
``

## DROP DATABASE

*supported in urQL parser, not yet supported in Obelisk*

Deletes an existing `<database>` and all associated objects.
``
<drop-database> ::= DROP DATABASE [ FORCE ] <database>
``

### API
``
+$  drop-database        
  $: 
    %drop-database
    name=@tas
    force=?
  ==
``

### Arguments

**`FORCE`**
Optionally, force deletion of a database.

**`<database>`**
The name of the database to delete.

## Remarks
This command mutates the state of the Obelisk agent.

The command only succeeds when no populated tables exist in the database, unless `FORCE` is specified. It removes the row from the view `sys.sys.databases`.

## Produced Metadata
Schema timestamp (labelled 'system time')
Content timestamp (labelled 'data time')

## Exceptions
`<database>` does not exist
`<database>` has populated tables and `FORCE` was not specified