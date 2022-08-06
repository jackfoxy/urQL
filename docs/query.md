\<query> ::=
`[WITH <alias> AS ( <query> ) [, <alias> AS ( <query> ) ] [ ,...n ] ]`
`FROM { <table-view> [ <alias> ]`
`         [ { JOIN | LEFT JOIN | RIGHT JOIN | OUTER JOIN }`
`           <table-view> [ <alias> ]`
`           ON <predicate>`
`         ]
`     } [ ,...n ]`
`[ WHERE <predicate> ]`
`SELECT { [ { <table-view>. | <alias> }. ] *`
`         | { <column-expression> | <column-alias> } [ ,...n ]`
`[ GROUP BY { <column-expression> | <column-alias> } [ ,...n ] ]`
`[ HAVING <predicate> ]`
`[ INTO <new-table> ]`
`[ ORDER BY { <column-expression> | <column-alias> } [ ,...n ] ]`
`[ { UNION | UNION ALL | EXCEPT | INTERSECT } <query> ] [ ...n ]`

`<table-view> ::=`
`[ <database-name>.<namespace-name> | <database-name>.. | <namespace-name>. ]`
`{ <view-name> | <table-name> }`

`<column-expression> ::=`
{ [ { <alias>. | <qualified-or-not-table-or-view-name>. } ] <column-name>`
` | <constant> | <expression> }

`<predicate> ::=`
`{ <column-expression> | <column-alias> }`
`{ { = | <> | <= | =< | < | >= | => | > |  }`
`  { <column-expression> | <column-alias> } }`
`| [ NOT ] IN ( <constant> [ ,...n ] | <query-single-column-result> )`
`| [ NOT ] BETWEEN { <column-expression> | <column-alias> }` 
`  AND { <column-expression> | <column-alias> }`
`[ { AND | OR } [ ,...n ] ]`

`<expression> ::=`
`IF <predicate> THEN <column-expression> ENDIF`
`| CASE <column-expression>`
`  WHEN { <predicate> | <column-expression> } THEN <column-expression> [ ...n ]`
`  [ ELSE <column-expression> ]`
`  END`
`| COALESCE ( <column-expression> [ ,...n ] )`
`| native hoon (stretch goal)`

Discussion:
Set operators apply the previous result set to the next query unless otherwise qualified by parentheses.
`ORDER BY` is not allowed in Common Table Experessions (CTE, WITH clause) or in any query joined by set operators except for the last of the queries.
`SELECT INTO` targets an existing table not otherwise in the query.
`COALESCE` returns the first `<column-expression>` in the list that does not evaluate to `~` (in the case of unit) or not in the selected `<column-expression>` due to `LEFT` or `RIGHT JOIN`.
If a `CASE WHEN` expression is a `<predicate>`, the expected boolean (or loobean) logic applies. If it is a <column-expression> atom value 0 is treated as false and any other value as true (not loobean).