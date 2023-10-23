# CREATE INDEX
This command creates an index over selected column(s) of an existing table.

```
<create-index> ::=
  CREATE [ UNIQUE ] [ LOOK-UP | CLUSTERED ] INDEX <index>
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

**`LOOK-UP | CLUSTERED`**
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

## Example

INSERT `table name`, `namespace` `index-name`, `LOOK-UP | CLUSTERED`, `is-unique`, `<timestamp>` into `<database>.sys.indices`

## Exceptions

index name already exists for table
table does not exist
column does not exist
UNIQUE specified and existing values are not unique for the column(s) specified
index name begins with 'pk-' or 'fk-'

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

## Examples

INSERT `name`, `<transform>`, `<timestamp>` INTO `<database>.sys.views`
INSERT `name`, `<ordinal>`, `<column>` INTO `<database>.sys.view-columns`

## Exceptions

view already exists
