`ALTER INDEX [ <database-name>. | <database-name>.. | <namespace-name>. ] { <index-name> }` 
`ON [ <database-name>. | <database-name>.. | <namespace-name>. ] { <table-name> | <view-name> }`
`{ REBUILD | DISABLE | RESUME}`

Discussion:
If the `RESUME` will rebuild the index if the underlying object is dirty.

### _______________________________


`ALTER NAMESPACE [ <database-name>. ] <namespace-name>`
`   TRANSFER { TABLE | TRIGGER | VIEW } { <table-name> | <trigger-name> | <view-name> }`

### _______________________________


`ALTER TABLE [ <database-name>. | <database-name>.. | <namespace-name>. ] { <table-name> }`
`     { ALTER COLUMN { <column-name> } { <aura> | u(<aura>) [DEFAULT <constant_expression>] } [ ,... n ]`
`       | ADD COLUMN { <column-name> } { <aura> | u(<aura>) [DEFAULT <constant_expression>] } [ ,... n ]`
`       | DROP COLUMN { <column-name> }`
`       | ADD FOREIGN KEY <foreign-key-name> (<column-name> [ ,... n ])`
`             REFERENCES [<namespace-name>.]<table-name> ( <column-name> [ ,... n ])`
`             [ ON DELETE { NO ACTION | CASCADE | SET NULL | SET DEFAULT } ]`
`             [ ON UPDATE { NO ACTION | CASCADE | SET NULL | SET DEFAULT } ]`
`             [ ,... n ]`
`       | DROP FOREIGN KEY <foreign-key-name> [ ,... n ]`

Example:
`ALTER TABLE my-table`
`DROP FOREIGN KEY fk-1, fk-2`

### _______________________________


`ALTER TRIGGER`
`     [ <database-name>. | <database-name>.. | <namespace-name>. ] { <trigger-name> }`
`     ON { <table-name> | <view-name> }`
TBD

### _______________________________


`ALTER VIEW [ <database-name>. | <database-name>.. | <namespace-name>. ] { <view-name> }`
`( [<alias>.] <column-name> [ ,...n ] )`
`AS <select_statement>`
