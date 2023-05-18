# CREATE DATABASE

```
CREATE DATABASE <database-name>
```

Example:
```
<create-database> ::=
  CREATE DATABASE my-database
```

API:
```
+$  create-database      $:([%create-database name=@t])
```

## Remarks

`CREATE DATABASE` must be the only command in a script. The script will fail if there are prior commands. As the first command it will succeed and subsequent commands will be ignored.

## Produced Metadata

## Exceptions

# CREATE INDEX

```
<create-index> ::=
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

API:
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

## Remarks

## Produced Metadata

# Exceptions

# CREATE NAMESPACE

```
<create-namespace> ::=
  CREATE NAMESPACE [<database-name>.]<namespace-name>
```

Example:
`CREATE NAMESPACE my-namespace`

API:
```
+$  create-namespace     $:([%create-namespace database-name=@t name=@t])
```


# CREATE PROCEDURE

```
<create-proc> ::=
  CREATE { PROC | PROCEDURE }
      [<db-qualifer>]<procedure-name>
      [ { #<parameter-name> <data-type> } ] [ ,...n ]
  AS { <urql command>; | *hoon } [ ;...n ]
```

Discussion:
TBD
Cannot be used to create database.


# CREATE TABLE

```
<create-table> ::=
  CREATE TABLE
    [ <db-qualifer> ]<table-name>
    ( { <column-name> <aura> }
      [ ,... n ] )
    PRIMARY KEY [ NONCLUSTERED | CLUSTERED ] ( <column-name> [ ,... n ] )
    [ { FOREIGN KEY <foreign-key-name> ( <column-name> [ ASC | DESC ] [ ,... n ] )
      REFERENCES [ <namespace-name>. ] <table-name> ( <column-name> [ ,... n ]
        [ ON DELETE { NO ACTION | CASCADE } ]
        [ ON UPDATE { NO ACTION | CASCADE } ] }
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

API:
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


# CREATE TRIGGER

```
<create-trigger> ::=
  CREATE TRIGGER [ <db-qualifer> ]<trigger-name>
    ON { <table-name> | <view-name> }
    [ ENABLE | DISABLE ]
```

TBD hoon triggers

Discussion:
Not for initial release.


# CREATE VIEW

```
<create-view> ::=
  CREATE VIEW [ <db-qualifer> ]<view-name> AS <transform>
```

Discussion:
Views are read only.
When a column is derived from an arithmetic expression, a function, or a constant; or when two or more columns may otherwise have the same name, typically because of a JOIN; distinct column names must be assigned in the SELECT statement using AS. Otherwise view columns acquire the same names as the columns in the SELECT statement.

API:
```
+$  create-view
  $:
    %create-view
    view=qualified-object
    query=query
  ==
```
