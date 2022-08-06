DELETE

`DISABLE TRIGGER { [ <namespace-name>. ] <trigger-name> [ ,...n ] | ALL }`
` ON { <database-name> | SERVER }`

### _______________________________


`ENABLE TRIGGER { [ <namespace-name>. ] <trigger-name> [ ,...n ] | ALL }`
` ON { <database-name> | SERVER }`

### _______________________________


`INSERT INTO [ <database-name>.<namespace-name> | <database-name>.. | <namespace-name>. ] <table-name>`
`    [ ( <column-name> [ ,...n ] ) ]`
`    { VALUES ( { DEFAULT | ~ | expression } [ ,...n ] ) [ ,...n ]` 
`      | <query>`  
`    }`

Discussion:
If a column list is provided columns defines as `u(*)` or defined with a default my be omitted. Otherwise the `VALUES` or `<query>` must provide data for all columns in the expected order.

### _______________________________


UPDATE

MERGE

### _______________________________


`TRUNCATE TABLE`
`  [ <database-name>.<namespace-name>. | <database-name>.. | <namespace-name>. ]`
`  <trigger-name>`