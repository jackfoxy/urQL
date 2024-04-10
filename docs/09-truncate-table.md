# TRUNCATE TABLE

Removes all rows in a base table.

``
<truncate-table> ::=
  TRUNCATE TABLE [ <ship-qualifier> ] <table>
  [ <as-of-time> ]
``

### API
``
+$  truncate-table
  $:
    %truncate-table
    table=qualified-object
    as-of=(unit as-of)
  ==
``

### Arguments

**`<table>`**
The target table.

**`<as-of-time>`**
*as-of-time not currently supported in urQL parser or in Obelisk*
Timestamp of table creation. Defaults to `NOW` (current time). When specified, the timestamp must be greater than both the latest database schema and content timestamps.

### Remarks

The command potentially mutates `<table>`, resulting in a state change of the Obelisk agent.

Tables in the *sys* namespace cannot be truncated.

### Produced Metadata

Row count (when table was populated)
Content timestamp (labelled 'data time')

### Exceptions

truncate table state change after query in script
database `<database>` does not exist
truncate table `<table>` as-of data time out of order
truncate table `<table>` as-of schema time out of order
table `<namespace>`.`<table>` does not exist
`GRANT` permission on `<table>` violated
