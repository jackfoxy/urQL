# ALTER INDEX
Modifies the structure of an existing `<index>` on a user `<table>` or `<view>`.

```
<alter-index> ::=
  ALTER [ UNIQUE ] [ NONCLUSTERED | CLUSTERED ] INDEX [ <db-qualifer> ]<index>
    ON { <table> | <view> }
    [ ( <column> [ ASC | DESC ] [ ,...n ] ) ]
    { DISABLE | RESUME}
```

## API
```
+$  alter-index
  $:
    %alter-index
    name=qualified-object
    object=qualified-object
    columns=(list ordered-column)
    action=index-action
  ==
```

## Arguments

**`UNIQUE`**
Specifies that no two rows are permitted to have the same index key value.

**`NONCLUSTERED | CLUSTERED`**
`CLUSTERED` creates an index in which the logical order of the key values determines the physical order of the corresponding rows in a table. A `<table>` or `<view>` can have only one clustered index at a time.

**`[ <db-qualifer> ]<index>`**
Specifies the target index.

**`<table> | <view>`**
Name of the underlying object of the index.

**`<column> [ ASC | DESC ] [ ,...n ] `**
List of column names in the target table. This list represents the sort hierarchy and optionally specifies the sort direction for each level. The default sorting is `ASC` (ascending).

**`DISABLE | RESUME`**
Used to disable an active index or resume a disabled index.

## Remarks
This command mutates the state of the Obelisk agent.

Cannot alter primary key and foreign key indices.

`RESUME` will rebuild the index if the underlying object is dirty.

Note: Further investigation into hoon ordered maps is needed to determine what exactly "clustered" means in hoon.

## Produced Metadata
update `<database>.sys.indices`

## Exceptions
index name does not exist for table
table does not exist
column does not exist
UNIQUE specified and existing values are not unique for the column(s) specified

# ALTER NAMESPACE
Transfer an existing user `<table>` or `<view>` to another `<namespace>`.

```
<alter-namespace> ::=
  ALTER NAMESPACE [ <database>. ]<namespace>
    TRANSFER { TABLE | VIEW } [ <db-qualifer> ]{ <table> | <view> }
```

## API
```
+$  alter-namespace
  $:
    %alter-namespace
    database-name=@tas
    source-namespace=@tas
    object-type=object-type
    target-namespace=@tas
    target-name=@tas
  ==
```

## Arguments

**`<namespace>`**
Name of the target namespace into which the object is to be transferred. 

**`TABLE | VIEW`**
Indicates the type of the target object.

**`<table> | <view>`**
Name of the object to be transferred to the target namespace..

## Remarks
This command mutates the state of the Obelisk agent.

Objects cannot be transferred in or out of namespace *sys*.

## Produced Metadata
update `<database>.sys.tables`
update `<database>.sys.views`

## Exceptions
namespace does not exist
`<table>` or `<view>` does not exist

# ALTER PROCEDURE

TBD

```
<alter-proc> ::=
  ALTER { PROC | PROCEDURE }
    [<db-qualifer>]<procedure>
    [ { #<parameter> <data-type> } ] [ ,...n ]
  AS { <urql command>; | *hoon } [ ;...n ]
```


# ALTER TABLE
Modify the columns and/or `<foreign-key>`s of an existing `<table>`.

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

# ALTER TRIGGER

TBD

```
<alter-trigger> ::=
  ALTER TRIGGER { [ <db-qualifer> ]{ <trigger> } | ALL }
     ON { SERVER | <database.name> | <table> | <view> }
     [ ENABLE | DISABLE ]
```

# ALTER VIEW
Alter the structure of an existing `<view>`.

```
<alter-view> ::=
  ALTER VIEW [ <db-qualifer> ]{ <view> }
    ( { [<alias>.] <column> } [ ,...n ] )
  AS <select_statement>
```

## API
```
+$  alter-view
  $:
    %alter-view
    view=qualified-object
    transform
  ==
```

## Arguments

**`<view>`**
Specifies the name of the view to alter.

**`<transform>`**
Refers to the `<transform>` producing the output `<table-set>`.

## Remarks
This command mutates the state of the Obelisk agent.

## Produced Metadata
UPDATE `<database>.sys.views`
UPDATE `<database>.sys.view-columns`

## Exceptions
view does not exist.