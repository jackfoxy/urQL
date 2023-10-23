# SYSTEM VIEWS

Views on database schema metadata available in every database.

## sys.sys.databases

Only available in database "sys".

### Columns

**database @tas** Database name.

**sys-agent @tas** Agent making latest database schema state.

**sys-tmsp @da** Timestamp of latest database schema state.

**data-ship @p** Ship making latest database user data state

**data-agent @tas** Agent making latest user data state.

**data-tmsp @da** Timestamp of latest user data state.

### Default Ordering

database, sys-tmsp, data-tmsp

## sys.namespaces

Available in every database except "sys".

### Columns

**namespace @tas** Namespace name.

**tmsp @da** Namespace creation timestamp.

### Default Ordering

namespace

## sys.tables

### Columns

**namespace @tas** Namespace of table.

**name @tas** Table name.

**ship @p** Ship making latest table state change.

**agent @tas** Agent making latest table state change.

**tmsp @da** Timestamp of latest table state change.

**row-count @ud** Count of rows in table.

**clustered @f** Primary key of table is clustered or look-up.

**key-ordinal @ud** Ordinal of column in primary key.

**key @tas** Column in primary key.

**key-ascending @f** Column in primary key is ascending or descending

**col-ordinal @ud** Ordinal of column in table's canonical ordering.

**col-name @tas** Name of column.

**col-type @tas** Aura type of column.

### Default Ordering

namespace, name, key-ordinal, col-ordinal

## sys.columns

### Columns

**namespace @tas**  Namespace of table.

**name @tas** Table name.

**col-ordinal @ud** Ordinal of column in table's canonical ordering.

**col-name @tas** Name of column.

**col-type @tas** Aura type of column.

### Default Ordering

namespace, name, col-ordinal

## sys.sys-log

### Columns

**tmsp @da** Timestamp of database schema change of state.

**agent @tas** Agent making state change.

**component @tas** To do: 2 columns, component and namespace along with view rewrite

**name @tas** Added or altered component.

### Default Ordering

tmsp descending, component, name

## sys.data-log

### Columns

**tmsp @da**  Timestamp of table data change of state.

**ship @p** Ship making state change.

**agent @tas** Agent making state change.

**namespace @tas** Table namespace.

**table @tas** Table name.

### Default Ordering

tmsp descending, namespace, table
