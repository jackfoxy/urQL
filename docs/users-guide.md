# SYSTEM VIEWS

Views on database schema metadata available in every database.

## sys.sys.databases

Only available in database "sys".

This is the only query in Obelisk that is not idempotent. This is because dropping a database results in clearing all references to that database on the server.

### Columns

**database @tas** Database name.

**sys-agent @tas** Agent responsible for the latest database schema state.

**sys-tmsp @da** Timestamp of latest database schema state.

**data-ship @p** Ship making the latest database user data state

**data-agent @tas** Agent responsible for the latest user data state.

**data-tmsp @da** Timestamp of latest user data state.

### Default Ordering

database, sys-tmsp, data-tmsp

## sys.namespaces

Available in every database except "sys".

### Columns

**namespace @tas** Namespace name.

**tmsp @da** Namespace creation timestamp.

### Default Ordering

tmsp, namespace

## sys.tables

### Columns

**namespace @tas** Namespace of table.

**name @tas** Table name.

**ship @p** Ship making the latest table state change.

**agent @tas** Agent responsible for the latest table state change.

**tmsp @da** Timestamp of latest table state change.

**row-count @ud** Count of rows in table.

**key-ordinal @ud** Ordinal of column in primary key.

**key @tas** Column in primary key.

**key-ascending @f** Indicates whether the column in the primary key is ascending or descending

### Default Ordering

namespace, name, key-ordinal

## sys.columns

### Columns

**namespace @tas**  Namespace of the table.

**name @tas** Table name.

**col-ordinal @ud** Ordinal of column in table's canonical ordering.

**col-name @tas** Name of column.

**col-type @ta** Aura type of column.

### Default Ordering

namespace, name, col-ordinal

## sys.sys-log

This view records the times and events effecting the current state of the database schema.
DROPs are not recorded.

### Columns

**tmsp @da** Timestamp of database schema change of state.

**agent @tas** Agent responsible for the state change.

**component @tas** (To do: 2 columns, component and namespace along with view rewrite)

**name @tas** Added or altered component.

### Default Ordering

tmsp descending, component, name

## sys.data-log

This view records the times and events effecting the current state of the database data.

### Columns

**tmsp @da**  Timestamp of table data change of state.

**ship @p** Ship making the state change.

**agent @tas** Agent responsible for the state change.

**namespace @tas** Table namespace.

**table @tas** Table name.

### Default Ordering

tmsp descending, namespace, table

## sys.view-cache

To do: list caches & populated/not populated

### Columns

**namespace @tas**  Namespace of the view.

**name @tas** View name.

...
