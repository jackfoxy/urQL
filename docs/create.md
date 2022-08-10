`CREATE DATABASE <database-name>`

Example: 
`CREATE DATABASE my-database`

### _______________________________


```
CREATE [ UNIQUE ] [ NONCLUSTERED | CLUSTERED ] INDEX <index-name>
  ON [ <db-qualifer> ]{ <table-name> | <view-name> }
  ( <column-name> [ ASC | DESC ] [ ,...n ] )
```

Examples:
```
CREATE INDEX ix_vendor-id ON product-vendor (vendor-id);
CREATE UNIQUE INDEX ix_vendor-id2 ON dbo.product-vendor 
  (vendor-id DESC, name ASC, address DESC);
CREATE INDEX ix_vendor-id3 ON purchasing..product-vendor (vendor-id);
```

Discussion:
Index name cannot start with 'pk-' as these names are internally reserved for primary keys.
A table or view can only have up to one `CLUSTERED` index, including the primary key for tables.
The `UNIQUE` option is not available for views.

### _______________________________


`CREATE NAMESPACE [<database-name>.]<namespace-name>`

Example: 
`CREATE NAMESPACE my-namespace`

### _______________________________


```
CREATE TABLE
  [ <db-qualifer> ]<table-name>
  ( <column-name> { { <aura> | u( {<aura>) } [DEFAULT <constant_expression>] }
    [ ,... n ] )
  PRIMARY KEY [ NONCLUSTERED | CLUSTERED ] ( <column-name> [ ,... n ] )
  [ { FOREIGN KEY <foreign-key-name> ( <column-name> [ ASC | DESC ] [ ,... n ] )
    REFERENCES [ <namespace-name>. ] <table-name> ( <column-name> [ ,... n ]
      [ ON DELETE { NO ACTION | CASCADE | SET NULL | SET DEFAULT } ]
      [ ON UPDATE { NO ACTION | CASCADE | SET NULL | SET DEFAULT } ] }
    [ ,... n ] ]`
```

Example:
```
CREATE TABLE order-detail
(invoice-nbr @ud, line-item @ud, product-id @ud, special-offer-id @ud, message @t)
PRIMARY KEY CLUSTERED (invoice-nbr, line-item)
FOREIGN KEY fk-special-offer-order-detail (productid, specialofferid)
REFERENCES special-offer (product-id, special-offer-id)
```

Discussion:
`PRIMARY KEY` must be unique.
`SET NULL` only applies to columns defined as `unit`. Columns defined otherwise will be treated as the default `NO ACTION`.
`SET DEFAULT` applies the column's default constant, if available, otherwise the bunt of the aura.

### _______________________________


```
CREATE TRIGGER [ <db-qualifer> ]<trigger-name>
  ON { <table-name> | <view-name> }
  [ ENABLE | DISABLE ]
```
TBD hoon triggers

Discussion:
Not for initial release.

### _______________________________


`CREATE TYPE <type-name>`
TBD

Discussion:
Probably will be available only at server (ship) level, and so shared by all databases.
Possibly part of initial or early release.

### _______________________________


`CREATE VIEW [ <db-qualifer> ]<view-name> AS <query>`

Discussion:
Views are read only.
When a column is derived from an arithmetic expression, a function, or a constant; or when two or more columns may otherwise have the same name, typically because of a join; distinct column names must be assigned in the SELECT statement using AS. Otherwise view columns acquire the same names as the columns in the SELECT statement.
