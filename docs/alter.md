```
ALTER INDEX [ <db-qualifer> ]{ <index-name> }
ON { <table-name> | <view-name> }
{ REBUILD | DISABLE | RESUME}
```

Discussion:
`RESUME` will rebuild the index if the underlying object is dirty.

### _______________________________

```
ALTER NAMESPACE [ <database-name>. ]<namespace-name>
  TRANSFER { TABLE | VIEW } [ <db-qualifer> ]{ <table-name> | <view-name> }
```

Discussion:
The namespace *sys* cannot be altered, nor can objects be transferred out of it.

### _______________________________


```
ALTER TABLE [ <db-qualifer> ]{ <table-name> }
  { ALTER COLUMN { <column-name> } 
      { <aura> | u(<aura>) [DEFAULT <constant_expression>] } [ ,... n 
    | ADD COLUMN { <column-name> } 
        { <aura> | u(<aura>) [DEFAULT <constant_expression>] } [ ,... n ]
    | DROP COLUMN { <column-name> } [ ,... n ]
    | ADD FOREIGN KEY <foreign-key-name> (<column-name> [ ,... n ])
      REFERENCES [<namespace-name>.]<table-name> ( <column-name> [ ,... n ])
      [ ON DELETE { NO ACTION | CASCADE | SET NULL | SET DEFAULT } ]
      [ ON UPDATE { NO ACTION | CASCADE | SET NULL | SET DEFAULT } ]
      [ ,... n ]
    | DROP FOREIGN KEY <foreign-key-name> [ ,... n ] }
```

Example:
```
ALTER TABLE my-table
DROP FOREIGN KEY fk-1, fk-2
```

### _______________________________


```
ALTER TRIGGER { [ <db-qualifer> ]{ <trigger-name> } | ALL ]
     ON { SERVER | <database.name> | <table-name> | <view-name> }
     [ ENABLE | DISABLE ]
```
TBD

Discussion:
Not for initial release.

### _______________________________


```
ALTER VIEW [ <db-qualifer> ]{ <view-name> }
( { [<alias>.] <column-name> } [ ,...n ] )
AS <select_statement>
```
