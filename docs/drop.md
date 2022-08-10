`DROP DATABASE [WARN] <database-name>`

Discussion:  
`WARN` prevents dropping if *populated* tables exist in database.

### _______________________________

```
DROP INDEX <index-name>
  ON [ <db-qualifer> ] { <table-name> | <view-name> }
```

Discussion:
Cannot drop indices whose names begin with "pk-", as these are table primary keys.

### _______________________________


`DROP NAMESPACE [ <database-name>. ]<namespace-name>`

Discussion:
Only succeeds when no tables or views are in the namespace.
Cannot drop namespaces *dbo* and *sys*.

### _______________________________


`DROP TABLE [WARN] [ <db-qualifer> ] { <table-name> }`

Discussion: 
Cannot drop if used in view. 
`WARN` prevents dropping if used in a foreign key.

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


`DROP VIEW [ <db-qualifer> ] <view-name>`

Discussion: Cannot drop if view is in use by another view.
