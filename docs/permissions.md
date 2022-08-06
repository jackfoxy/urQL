`GRANT { ADMINREAD TO { PARENT | SIBLINGS | MOONS | <@p> [ ,...n ] }` 
`        | READONLY TO { PARENT | SIBLINGS | MOONS | <@p> [ ,...n ] }`
`          ON { <database-name> | [<database-name>.]<namespace-name>`
`               | { [<qualified>.] <view-name> | [<qualified>.] <table-name> }
`        | READWRITE TO { PARENT | SIBLINGS | MOONS }`
`          ON { <database-name> | [<database-name>.]<namespace-name>`
`               | { [<qualified>.] <view-name> | [<qualified>.] <table-name> }
`       }

Example:
`GRANT READONLY TO ~sampel-palnet ON my-namespace`

Discussion:
Grantees `PARENT` and `SIBLINGS` are only valid for moon servers. `MOONS` is only valid for moon parents.
`ADMINREAD` grants read-only access to the servers administration tables and views

### _______________________________


`REVOKE { ADMINREAD | READONLY | READWRITE | ALL }`
`    FROM { PARENT | SIBLINGS | MOONS | <@p> | ALL }`