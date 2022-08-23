```
GRANT { ADMINREAD | READONLY | READWRITE } 
         TO { PARENT | SIBLINGS | MOONS | <@p> [ ,...n ] }
         ON { DATABASE <database-name>
              | NAMESPACE [<database-name>]<namespace-name>
              | [<db-qualifer>]{<view-name> | <table-name> }
```

Example:
`GRANT READONLY TO ~sampel-palnet ON my-namespace`

Discussion:
Grantees `PARENT` and `SIBLINGS` are only valid for moon servers. `MOONS` is only valid for moon parents.
`ADMINREAD` grants read-only access to the servers administration tables and views

### _______________________________


```
REVOKE { ADMINREAD | READONLY | READWRITE | ALL }
  FROM { PARENT | SIBLINGS | MOONS | ALL | <@p> [ ,...n ] }
    <grant-target>
```
