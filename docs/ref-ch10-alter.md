# ALTER INDEX

```
ALTER INDEX [ <db-qualifer> ]{ <index-name> }
ON { <table-name> | <view-name> }
[ ( <column-name> [ ASC | DESC ] [ ,...n ] ) ]
{ REBUILD | DISABLE | RESUME}
```

Discussion:
`RESUME` will rebuild the index if the underlying object is dirty.


# ALTER NAMESPACE

```
ALTER NAMESPACE [ <database-name>. ]<namespace-name>
  TRANSFER { TABLE | VIEW } [ <db-qualifer> ]{ <table-name> | <view-name> }
```

Discussion:
The namespace *sys* cannot be altered, nor can objects be transferred in or out of it.


# ALTER PROCEDURE

```
ALTER { PROC | PROCEDURE }
    [<db-qualifer>]<procedure-name>
    [ { #<parameter-name> <data-type> } ] [ ,...n ]
AS { <urql command>; | *hoon } [ ;...n ]
```

Discussion:
TBD


# ALTER TABLE

```
ALTER TABLE [ <db-qualifer> ]{ <table-name> }
  { ALTER COLUMN ( { <column-name>  <aura> } [ ,... n ] )
    | ADD COLUMN ( { <column-name>  <aura> } [ ,... n ] )
    | DROP COLUMN ( { <column-name> } [ ,... n ] )
    | ADD FOREIGN KEY <foreign-key-name> (<column-name> [ ,... n ])
      REFERENCES [<namespace-name>.]<table-name> (<column-name> [ ,... n ])
      [ ON DELETE { NO ACTION | CASCADE } ]
      [ ON UPDATE { NO ACTION | CASCADE } ]
      [ ,... n ]
    | DROP FOREIGN KEY ( <foreign-key-name> [ ,... n ] } )
```

Example:
```
ALTER TABLE my-table
DROP FOREIGN KEY fk-1, fk-2
```


# ALTER TRIGGER

```
ALTER TRIGGER { [ <db-qualifer> ]{ <trigger-name> } | ALL ]
     ON { SERVER | <database.name> | <table-name> | <view-name> }
     [ ENABLE | DISABLE ]
```

Discussion:
TBD


# ALTER VIEW

```
ALTER VIEW [ <db-qualifer> ]{ <view-name> }
( { [<alias>.] <column-name> } [ ,...n ] )
AS <select_statement>
```
