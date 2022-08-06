`DROP DATABASE <database-name>`

### _______________________________


`DROP INDEX <index-name>`
`    ON [ <database-name>. | <database-name>.. | <namespace-name>. ] { <table-name> | <view-name> }`

### _______________________________


`DROP TABLE [WARN] [ <database-name>. | <database-name>.. | <namespace-name>. ] { <table-name> }`

Discussion: Cannot drop if used in view. `WARN` prevents dropping if used in a foreign key.

### _______________________________


`DROP TRIGGER`
`     [ <database-name>. | <database-name>.. | <namespace-name>. ] { <trigger-name> }`
`     ON { <table-name> | <view-name> }`


`DROP TYPE <type-name>`

Discussion: Cannot drop if type-name is in use.

### _______________________________


`DROP VIEW [ <database-name>. | <database-name>.. | <namespace-name>. ] <view-name>`

Discussion: Cannot drop if view-name is in use by another view.