# CREATE DATABASE

Creates a new user-space database available to any agent running on the ship. There is no sand-boxing.

TO DO: consider adding an owner-desk property and GRANT desk permissions.
```
CREATE DATABASE <database>
```

## Example
```
<create-database> ::=
  CREATE DATABASE my-database
```

## API
```
+$  create-database      $:([%create-database name=@tas])
```

## Arguments

**`<database>`**
User-defined name for the new database. Must follow the hoon term naming standard.

## Remarks

The command results in a state change of the Obelisk agent.

`CREATE DATABASE` must be the only command in a script. 
The script will fail if there are prior commands. 
As the first command it will succeed and subsequent commands will be ignored.

## Produced Metadata

INSERT `name`, `<timestamp>` into `sys.sys.databases`
Creates all `<database>.sys` tables.

## Exceptions

database already exists

# CREATE INDEX
Creates an index over selected column(s) on an existing table.

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

**`<index>`**
User-defined name for the new index. Must follow the hoon term naming standard.

**`<table>`**
Name of existing table the index targets.
If not explicitly qualified defaults to the Obelisk agent's current database and 'dbo' namespace.

**`<column> [ ASC | DESC ] [ ,...n ] `**
List of column names in the target table, representing the sort hierarchy, and optionally sort direction for each level, defaulting to `ASC`, ascending.

## Remarks
The command results in a state change of the Obelisk agent.

Index name cannot start with 'pk-' as these names are internally reserved for primary keys.
Index name cannot start with 'fk-' as these names are internally reserved for primary keys.

TO DO: investigate hoon ordered maps to determine what exactly "clustered" means in hoon. It may be that multiple clustering indices are possibley, freaking out most DBAs.

## Produced Metadata

INSERT `table name`, `namespace` `index-name`, `NONCLUSTERED | CLUSTERED`, `is-unique`, `<timestamp>` into `<database>.sys.indices`

## Exceptions

index name already exists for table
table does not exist
column does not exist
UNIQUE specified and existing values are not unique for the column(s) specified
index name begins with 'pk-' or 'fk-'

# CREATE NAMESPACE
Namespaces provide a means of grouping database components including tables and views.
When not otherwise specified namepace designations default to `dbo`.

```
<create-namespace> ::=
  CREATE NAMESPACE [<database>.]<namespace>
```

## Example
`CREATE NAMESPACE my-namespace`

## API
```
+$  create-namespace     $:([%create-namespace database-name=@t name=@t])
```

## Arguments

**`<namespace>`**
User-defined name for the new index. Must follow the hoon term naming standard.
The namespace "sys" is reserved for system use. 

## Remarks
The command results in a state change of the Obelisk agent.

## Produced Metadata

INSERT `name`, `<timestamp>` into `<database>.sys.namespaces`

## Exceptions

namespace already exists

# CREATE PROCEDURE
Procedures are urQL scripts that accept parameters. 

```
<create-proc> ::=
  CREATE { PROC | PROCEDURE }
      [<db-qualifer>]<procedure>
      [ { #<parameter> <data-type> } ] [ ,...n ]
  AS { <urql command>; | *hoon } [ ;...n ]
```

## Remarks
TBD
Cannot be used to create database.


# CREATE TABLE
Tables are the only means of indexed persistent `<table-sets>`s.
Any update to `<table>` contents results the Obelisk agent changeing state.

TO DO: any reason to specify foreign key name (see CREATE INDEX).
```
<create-table> ::=
  CREATE TABLE
    [ <db-qualifer> ]<table>
    ( { <column> <aura> }
      [ ,... n ] )
    PRIMARY KEY [ NONCLUSTERED | CLUSTERED ] ( <column> [ ,... n ] )
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
    primary-key=create-index
    foreign-keys=(list foreign-key)
  ==
```

## Arguments

**`<table>`**
User-defined name for the new table. Must follow the hoon term naming standard.
If not explicitly qualified defaults to the Obelisk agent's current database and 'dbo' namespace.

**`<column> <aura>`**
List of user-define column names and associated auras. Names must follow the hoon term naming standard.
See [ref-ch02-types](ref-ch02-types.md)

**`[ NONCLUSTERED | CLUSTERED ] ( <column> [ ,... n ]`**
Columns in the required unique primary index. Defining the index as `CLUSTERED` is optional.

**`<foreign-key> ( <column> [ ASC | DESC ] [ ,... n ]`**
User-defined name for `<foreign-key>`. Must follow the hoon term naming standard.
List of columns in the table for association with a foreign table along with sort ordering. Default is `ASC` ascending.

**`<table> ( <column> [ ,... n ]`**
Referenced foreign `<table>` and columns. Count and associated column auras must match the specified columns from the new `<table>`.

**`ON DELETE { NO ACTION | CASCADE | SET DEFAULT }`**
Specifies an action on the rows in the table if those rows have a referential relationship and the referenced row is deleted from the foreign table.

* NO ACTION (default)

The Obelisk agent raises an error and the delete action on the row in the parent foreign table is aborted.

* CASCADE

Corresponding rows are deleted from the referencing table when that row is deleted from the parent foreign table.

* SET DEFAULT

All the values that make up the foreign key are set to their bunt values when the corresponding row in the parent foreign table is deleted.
The Obelisk agent raises an error if the parent table has no entry with bunt values.

**`ON UPDATE { NO ACTION | CASCADE | SET DEFAULT }`**
Specifies an action on the rows in the table if those rows have a referential relationship and the referenced row is deleted from the foreign table.

* NO ACTION (default)

The Database Engine raises an error, and the update action on the row in the parent table is aborted.

* CASCADE

Corresponding rows are updated in the referencing table when that row is updated in the parent table.

* SET DEFAULT

All the values that make up the foreign key are set to their bunt values when the corresponding row in the parent table is updated. 
The Obelisk agent raises an error if the parent table has no entry with bunt values.

## Remarks
The command results in a state change of the Obelisk agent.

`PRIMARY KEY` is unique.

TO DO: What constitutes `CLUSTERED` in hoon? An ordered map? This will shake-out during development.

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

Trigger events are INSERT, UPDATE, or DELETE statements on a `<table>`.
The trigger event for a `<view>` is simple execution.

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
could be used to trigger any database process or agent
`{ [ INSERT ] [ , ] [ UPDATE ] [ , ] [ DELETE ] }` does not apply to views.


# CREATE VIEW
A view creates a `<table-set>` whose contents (columns and rows) are defined by a `<transform>`.

Potential caching of views is TBD.

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
User-defined name for the new view. Must follow the hoon term naming standard.

**`<transform>`**
`<transform>` producing the output `<table-set>`.

## Remarks
The command results in a state change of the Obelisk agent.

Views are read only.
The last step of the `<transform>` must establish unique column names, whether inherited from prior `<table-set>`s or aliased columns.

## Produced Metadata

INSERT `name`, `<transform>`, `<timestamp>` into `<database>.sys.views`
INSERT `name`, `<ordinal>`, `<column>` into `<database>.sys.view-columns`

## Exceptions

view already exists
