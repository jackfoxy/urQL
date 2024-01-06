# CREATE TABLE
`<table>`s are the only means of indexed persistent `<table-sets>`s in Obelisk.
Any update to `<table>` contents results in a state change of the Obelisk agent.

_NOTE_: Further investigation is needed to understand if there's a reason to specify foreign key names (see CREATE INDEX).

```
<create-table> ::=
  CREATE TABLE
    [ <db-qualifer> ]<table>
    ( <column> <aura>
      [ ,... n ] )
    PRIMARY KEY [ CLUSTERED | LOOK-UP ] ( <column> [ ,... n ] )
    [ { FOREIGN KEY <foreign-key> ( <column> [ ASC | DESC ] [ ,... n ] )
      REFERENCES [ <namespace>. ] <table> ( <column> [ ,... n ] )
        [ ON DELETE { NO ACTION | CASCADE | SET DEFAULT } ]
        [ ON UPDATE { NO ACTION | CASCADE | SET DEFAULT } ] }
      [ ,... n ] ]
    [ <as-of-time> ]
```

## API
```
+$  create-table
  $:
    %create-table
    table=qualified-object
    columns=(list column)
    clustered=?
    pri-indx=(list ordered-column)
    foreign-keys=(list foreign-key)
    as-of=(unit @da)
  ==
```

## Arguments

**`<table>`**
This is a user-defined name for the new table. It must adhere to the hoon term naming standard.
If not explicitly qualified, it defaults to the Obelisk agent's current database and the 'dbo' namespace..

**`<column> <aura>`**
The list of user-defined column names and associated auras. Names must adhere to the hoon term naming standard.
For more details, refer to [ref-ch02-types](ref-ch02-types.md)

**`[ CLUSTERED | LOOK-UP ] ( <column> [ ,... n ]`**
These are column names in the required unique primary index. Defining the index as `LOOK-UP` is optional.

**`<foreign-key> ( <column> [ ASC | DESC ] [ ,... n ]`**
This is a user-defined name for `<foreign-key>`. It must adhere to the hoon term naming standard.
This list comprises column names in the table for association with a foreign table along with sort ordering. Default is `ASC` (ascending).

**`<table> ( <column> [ ,... n ]`**
Referenced foreign `<table>` and columns. Count and associated column auras must match the specified columns from the new `<table>` and comprise a `UNIQUE` index on the referenced foreign `<table>`.

**`ON DELETE { NO ACTION | CASCADE | SET DEFAULT }`**
This argument specifies the action to be taken on the rows in the table that have a referential relationship when the referenced row is deleted from the foreign table.

* NO ACTION (default)

The Obelisk agent raises an error and the delete action on the row in the parent foreign table is aborted.

* CASCADE

Corresponding rows are deleted from the referencing table when that row is deleted from the parent foreign table.

* SET DEFAULT

All the values that make up the foreign key in the referencing row(s) are set to their bunt (default) values when the corresponding row in the parent foreign table is deleted.

The Obelisk agent raises an error if the parent foreign table has no entry with bunt values.

**`ON UPDATE { NO ACTION | CASCADE | SET DEFAULT }`**

This argument specifies the action to be taken on the rows in the table that have a referential relationship when the referenced row is updated in the foreign table.

* NO ACTION (default)

The Database Engine raises an error and the update action on the row in the parent table is aborted.

* CASCADE

Corresponding rows are updated in the referencing table when that row is updated in the parent table.

* SET DEFAULT

All the values that make up the foreign key in the referencing row(s) are set to their bunt (default) values when the corresponding row in the parent foreign table is updated. 

The Obelisk agent raises an error if the parent foreign table has no entry with bunt values.

**`<as-of-time>`**
Timestamp of table creation. Defaults to NOW (current time). When specified timestamp must be greater than system timestamp for the database. 

## Remarks
This command mutates the state of the Obelisk agent.

`PRIMARY KEY` must be unique.

`FOREIGN KEY` constraints ensure data integrity for the data contained in the column or columns. They necessitate that each value in the column exists in the corresponding referenced column or columns in the referenced table. `FOREIGN KEY` constraints can only reference columns that are subject to a `PRIMARY KEY` or `UNIQUE INDEX` constraint in the referenced table.

NOTE: The specific definition of `CLUSTERED` in Hoon, possibly an ordered map, is to be determined during development.

## Produced Metadata

## Exceptions

name within namespace already exists for table
table referenced by FOREIGN KEY does not exist
table column referenced by FOREIGN KEY does not exist
aura mis-match in FOREIGN KEY
`<as-of-time>` timestamp prior to database creation

## Example
```
CREATE TABLE order-detail
(invoice-nbr @ud, line-item @ud, product-id @ud, special-offer-id @ud, message @t)
PRIMARY KEY CLUSTERED (invoice-nbr, line-item)
FOREIGN KEY fk-special-offer-order-detail (product-id, specialoffer-id)
REFERENCES special-offer (product-id, special-offer-id)
```

# ALTER TABLE
Modify the columns and/or `<foreign-key>`s of an existing `<table>`.
(Available in the urQL parser. Not currently implemented in the Obelisk DB engine.)

```
<alter-> ::=
  ALTER TABLE [ <db-qualifer> ]{ <table> }
    { ADD COLUMN ( <column>  <aura> [ ,... n ] )
      | ALTER COLUMN ( <column>  <aura> [ ,... n ] )
      | DROP COLUMN ( <column> [ ,... n ] )
      | ADD FOREIGN KEY <foreign-key> (<column> [ ,... n ])
        REFERENCES [<namespace>.]<table> (<column> [ ,... n ])
        [ ON DELETE { NO ACTION | CASCADE } ]
        [ ON UPDATE { NO ACTION | CASCADE } ]
        [ ,... n ]
      | DROP FOREIGN KEY ( <foreign-key> [ ,... n ] } )
    [ <as-of-time> ]
```

Example:
```
ALTER TABLE my-table
DROP FOREIGN KEY fk-1, fk-2
```

## API
```
+$  alter-table
  $:
    %alter-table
    table=qualified-object
    alter-columns=(list column)
    add-columns=(list column)
    drop-columns=(list @tas)
    add-foreign-keys=(list foreign-key)
    drop-foreign-keys=(list @tas)
    as-of=(unit @da)
  ==
```

## Arguments

**`<table>`**
Name of `<table>` to alter.

**`ADD | ALTER COLUMN ( <column> <aura> [ ,... n ] )`**
Denotes a list of user-defined column names and associated auras. `ALTER` is used to change the aura of an existing column.

Names must follow the Hoon term naming standard. See [ref-ch02-types](ref-ch02-types.md)

**`DROP COLUMN ( <column> [ ,... n ] )`**
Denotes a list of existing column names to delete from the `<table>` structure.

**`[ NONCLUSTERED | CLUSTERED ] ( <column> [ ,... n ]`**
These are column names in the required unique primary index. Defining the index as `CLUSTERED` is optional.

**`ADD | DROP`**
The action is to add or drop a foreign key.

**`<foreign-key> ( <column> [ ASC | DESC ] [ ,... n ]`**
This is a user-defined name for `<foreign-key>`. It must adhere to the hoon term naming standard.
This list comprises column names in the table for association with a foreign table along with sort ordering. Default is `ASC` (ascending).

**`<table> ( <column> [ ,... n ]`**
Referenced foreign `<table>` and columns. Count and associated column auras must match the specified columns from the new `<table>` and comprise a `UNIQUE` index on the referenced foreign `<table>`.

**`ON DELETE { NO ACTION | CASCADE | SET DEFAULT }`**
This argument specifies the action to be taken on the rows in the table that have a referential relationship when the referenced row is deleted from the foreign table.

* NO ACTION (default)

The Obelisk agent raises an error and the delete action on the row in the parent foreign table is aborted.

* CASCADE

Corresponding rows are deleted from the referencing table when that row is deleted from the parent foreign table.

* SET DEFAULT

All the values that make up the foreign key in the referencing row(s) are set to their bunt (default) values when the corresponding row in the parent foreign table is deleted.

The Obelisk agent raises an error if the parent foreign table has no entry with bunt values.

**`ON UPDATE { NO ACTION | CASCADE | SET DEFAULT }`**
This argument specifies the action to be taken on the rows in the table that have a referential relationship when the referenced row is updated in the foreign table.

* NO ACTION (default)

The Database Engine raises an error and the update action on the row in the parent table is aborted.

* CASCADE

Corresponding rows are updated in the referencing table when that row is updated in the parent table.

* SET DEFAULT

All the values that make up the foreign key in the referencing row(s) are set to their bunt (default) values when the corresponding row in the parent foreign table is updated. 

The Obelisk agent raises an error if the parent foreign table has no entry with bunt values.

**`<as-of-time>`**
Timestamp of table aleration. Defaults to NOW (current time). When specified timestamp must be greater than latest database system timestamp and greater than the latest data timestamp for the table. 

## Remarks
This command mutates the state of the Obelisk agent.

`FOREIGN KEY` constraints ensure data integrity for the data contained in the column or columns. They necessitate that each value in the column exists in the corresponding referenced column or columns in the referenced table. `FOREIGN KEY` constraints can only reference columns that are subject to a `PRIMARY KEY` or `UNIQUE INDEX` constraint in the referenced table.

## Produced Metadata
update `<database>.sys.table-columns`
update `<database>.sys.table-columns`
update  `<database>.sys.table-ref-integrity`

## Exceptions
alter a column that does not exist
add a column that does exist
drop a column that does not exist
table referenced by FOREIGN KEY does not exist
table column referenced by FOREIGN KEY does not exist
aura mis-match in FOREIGN KEY
`<as-of-time>` timestamp prior to latest system timestamp for table


# DROP TABLE
Deletes a `<table>` and all associated objects

```
<drop-table> ::= 
  DROP TABLE [ FORCE ] [ <db-qualifer> ]{ <table> }
    [ <as-of-time> ]
```

## API
```
+$  drop-table
  $:
    %drop-table
    table=qualified-object
    force=?
    as-of=(unit @da)
  ==
```

## Arguments

**`FORCE`**
Optionally, force deletion of a table.

**`<table>`**
Name of `<table>` to delete.

**`<as-of-time>`**
Timestamp of table deletion. Defaults to NOW (current time). When specified timestamp must be greater than latest database system timestamp and greater than the latest data timestamp for the table. 

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
`<as-of-time>` `<timestamp>` prior to latest system timestamp `<timestamp>`.
