`DROP DATABASE [ FORCE ] <database-name>`

Discussion:  
Only succeeds when no *populated* tables exist in it unless `FORCE` is specified.

### _______________________________

```
DROP INDEX <index-name>
  ON [ <db-qualifer> ] { <table-name> | <view-name> }
```

Discussion:
Cannot drop indices whose names begin with "pk-", as these are table primary keys.

### _______________________________


`DROP NAMESPACE [ FORCE ] [ <database-name>. ]<namespace-name>`

Discussion:
Only succeeds when no tables or views are in the namespace, unless `FORCE` is specified, possibly resulting in cascading object drops described in `DROP TABLE`.

Cannot drop namespaces *dbo* and *sys*.

### _______________________________


`DROP TABLE [ FORCE ] [ <db-qualifer> ] { <table-name> }`

Discussion: 
Cannot drop if used in a view or foreign key, unless `FORCE` is specified, resulting in cascading object drops. 

### _______________________________


```
DROP TRIGGER
  [ <db-qualifer> ] { <trigger-name> }
  ON { <table-name> | <view-name> }
```

### _______________________________


`DROP TYPE <type-name>`
TBD

Discussion: 
Cannot drop if type-name is in use.


### _______________________________


`DROP VIEW [ FORCE ] [ <db-qualifer> ] <view-name>`

Discussion: Cannot drop if used in another view, unless `FORCE` is specified, resulting in cascading object drops.