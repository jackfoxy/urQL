# CREATE DATABASE

This command creates a new user-space database accessible to any agent running on the ship. There is no sandboxing implemented.

_NOTE_: Additional features like owner-desk property and GRANT desk permissions are under consideration.
```
<create-database> ::=
  CREATE DATABASE <database>
```

## Example
```
  CREATE DATABASE my-database
```

## API
```
+$  create-database      $:([%create-database name=@tas])
```

## Arguments

**`<database>`**
This is the user-defined name for the new database. It must comply with the Hoon term naming standard.

## Remarks

This command mutates the state of the Obelisk agent.

`CREATE DATABASE` must be executed independently within a script. The script will fail if there are prior commands. Subsequent commands will be ignored.

## Produced Metadata

INSERT `name`, `<timestamp>` into `sys.sys.databases`
Create all `<database>.sys` tables

## Exceptions

database already exists

# CREATE INDEX
This command creates an index over selected column(s) of an existing table.

```
<create-index> ::=
  CREATE [ UNIQUE ] [ NONCLUSTERED | CLUSTERED ] INDEX <index>
    ON [ <db-qualifer> ] <table>
    ( <column> [ ASC | DESC ] [ ,...n ] )
```

## Examples
```
CREATE INDEX ix_vendor-id ON product-vendor (vendor-id);
CREATE UNIQUE INDEX ix_vendor-id2 ON dbo.product-vendor
  (vendor-id DESC, name ASC, address DESC);
CREATE INDEX ix_vendor-id3 ON purchasing..product-vendor (vendor-id);
```

## API

```
+$  create-index
  $:
    %create-index
    name=@t
    object-name=qualified-object                 :: because index can be over table or view
    is-unique=?
    is-clustered=?
    columns=(list ordered-column)
  ==
  ```

## Arguments

**`UNIQUE`**
Specifies that no two rows are permitted to have the same index key value.

**`NONCLUSTERED | CLUSTERED`**
`CLUSTERED` creates an index in which the logical order of the key values determines the physical order of the corresponding rows in a table. A `<table>` or `<view>` can have only one clustered index at a time.

**`<index>`**
User-defined name for the new index. This name must follow the Hoon term naming standard.

**`<table>`**
Name of existing table the index targets.
If not explicitly qualified, defaults to the Obelisk agent's current database and 'dbo' namespace.

**`<column> [ ASC | DESC ] [ ,...n ] `**
List of column names in the target table. This list represents the sort hierarchy and optionally specifies the sort direction for each level. The default sorting is `ASC` (ascending).

## Remarks
This command mutates the state of the Obelisk agent.

Index names cannot start with 'pk-' or 'fk-' as these prefixes are reserved for primary keys and foreign keys respectively.

_NOTE_: Further investigation is required to determine how "clustering" works in Hoon.

## Produced Metadata

INSERT `table name`, `namespace` `index-name`, `NONCLUSTERED | CLUSTERED`, `is-unique`, `<timestamp>` into `<database>.sys.indices`

## Exceptions

index name already exists for table
table does not exist
column does not exist
UNIQUE specified and existing values are not unique for the column(s) specified
index name begins with 'pk-' or 'fk-'

# CREATE NAMESPACE
Namespaces group various database components, including tables and views. When not explicitly specified, namespace designations default to `dbo`.

```
<create-namespace> ::= CREATE NAMESPACE [<database>.]<namespace>
```

## Example
`CREATE NAMESPACE my-namespace`

## API
```
+$  create-namespace     $:([%create-namespace database-name=@t name=@t])
```

## Arguments

**`<namespace>`**
This is a user-defined name for the new namespace. It must adhere to the hoon term naming standard. 

Note: The "sys" namespace is reserved for system use.  

## Remarks
This command mutates the state of the Obelisk agent.

## Produced Metadata

INSERT `name`, `<timestamp>` into `<database>.sys.namespaces`

## Exceptions

namespace already exists

# CREATE PROCEDURE
Procedures are parameterized urQL scripts. 

```
<create-proc> ::=
  CREATE { PROC | PROCEDURE }
      [<db-qualifer>]<procedure>
      [ { #<parameter> <data-type> } ] [ ,...n ]
  AS { <urql command>; | *hoon } [ ;...n ]
```

## Remarks
TBD

Cannot be used to create a database.


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
    PRIMARY KEY [ CLUSTERED | NONCLUSTERED ] ( <column> [ ,... n ] )
    [ { FOREIGN KEY <foreign-key> ( <column> [ ASC | DESC ] [ ,... n ] )
      REFERENCES [ <namespace>. ] <table> ( <column> [ ,... n ] )
        [ ON DELETE { NO ACTION | CASCADE | SET DEFAULT } ]
        [ ON UPDATE { NO ACTION | CASCADE | SET DEFAULT } ] }
      [ ,... n ] ]`
```

## Example
```
CREATE TABLE order-detail
(invoice-nbr @ud, line-item @ud, product-id @ud, special-offer-id @ud, message @t)
PRIMARY KEY CLUSTERED (invoice-nbr, line-item)
FOREIGN KEY fk-special-offer-order-detail (product-id, specialoffer-id)
REFERENCES special-offer (product-id, special-offer-id)
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
  ==
```

## Arguments

**`<table>`**
This is a user-defined name for the new table. It must adhere to the hoon term naming standard.
If not explicitly qualified, it defaults to the Obelisk agent's current database and the 'dbo' namespace..

**`<column> <aura>`**
The list of user-defined column names and associated auras. Names must adhere to the hoon term naming standard.
For more details, refer to [ref-ch02-types](ref-ch02-types.md)

**`[ CLUSTERED | NONCLUSTERED ] ( <column> [ ,... n ]`**
These are column names in the required unique primary index. Defining the index as `NONCLUSTERED` is optional.

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

`PRIMARY KEY` must be unique.

`FOREIGN KEY` constraints ensure data integrity for the data contained in the column or columns. They necessitate that each value in the column exists in the corresponding referenced column or columns in the referenced table. `FOREIGN KEY` constraints can only reference columns that are subject to a `PRIMARY KEY` or `UNIQUE INDEX` constraint in the referenced table.

NOTE: The specific definition of `CLUSTERED` in Hoon, possibly an ordered map, is to be determined during development.

## Produced Metadata

INSERT `table name`, `namespace`, `<timestamp>` INTO `<database>.sys.tables`
INSERT `table name`, `namespace`, `<ordinal>`, `column name`, `aura`, `<timestamp>` INTO `<database>.sys.table-columns`
INSERT `table name`, `namespace`, `delete | update`, `<action>`, `<timestamp>` INTO `<database>.sys.table-ref-integrity`
CREATE INDEX on Primary Key
CREATE INDEX on Foreign Keys

## Exceptions

name within namespace already exists for table
table referenced by FOREIGN KEY does not exist
table column referenced by FOREIGN KEY does not exist
aura mis-match in FOREIGN KEY

# CREATE TRIGGER

A trigger automatically runs when a specified table or view event occurs in the Obelisk agent. It runs a previously defined `<procedure>`.

An `INSTEAD OF` trigger fires before the triggering event can occur and replaces it. Otherwise the procedure runs after the triggering event succedes and all state changed by both the triggering event and trigger `<procedure>` is included in one and the same state change.

Triggering events are `INSERT`, `UPDATE`, and `DELETE` statements on a `<table>` and simple execution in the case of `<view>`.

```
<create-trigger> ::=
  CREATE TRIGGER [ <db-qualifer> ]<trigger>
    ON { <table> | <view> }
    { AFTER | INSTEAD OF }   
      { [ INSERT ] [ , ] [ UPDATE ] [ , ] [ DELETE ] }
  AS <procedure>
  [ ENABLE | DISABLE ]
```

## Remarks
TBD

This command could be used to trigger any database process or agent.

# CREATE TYPE

TBD

`CREATE TYPE <type>`

# CREATE VIEW
A view creates a `<table-set>` whose contents (columns and rows) are defined by a `<transform>`.

The possibility of caching of views is TBD.

```
<create-view> ::=
  CREATE VIEW [ <db-qualifer> ]<view> AS <transform>
```

## API
```
+$  create-view
  $:
    %create-view
    view=qualified-object
    query=transform
  ==
```

## Arguments

**`<view>`**
The user-defined name for the new view, which must adhere to the Hoon term naming standard.

**`<transform>`**
The `<transform>` that produces the output `<table-set>`.

## Remarks
This command mutates the state of the Obelisk agent.

Views are read only.

The final step of the `<transform>` must establish unique column names, whether inherited from prior `<table-set>`s or aliased columns.

Views cannot be defined on foreign ship databases.

## Produced Metadata

INSERT `name`, `<transform>`, `<timestamp>` INTO `<database>.sys.views`
INSERT `name`, `<ordinal>`, `<column>` INTO `<database>.sys.view-columns`

## Exceptions

view already exists
