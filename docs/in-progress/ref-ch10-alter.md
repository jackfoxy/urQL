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

# ALTER PROCEDURE

TBD

```
<alter-proc> ::=
  ALTER { PROC | PROCEDURE }
    [<db-qualifer>]<procedure>
    [ { #<parameter> <data-type> } ] [ ,...n ]
  AS { <urql command>; | *hoon } [ ;...n ]
```

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