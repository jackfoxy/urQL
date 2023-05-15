# Transform
```
<transform> ::=
  [ WITH [ <common-table-expression> [ ,...n ] ]
         [ <cte-lib> [ AS ] <alias>  [ ,...n ] ]
  ]
  <cmd>
  [ INTO <table>
    | <set-op> [ ( ] <cmd> [ ) ]
  ] [ ...n ]
  [ AS OF { NOW
          | <timestamp>
          | n { SECONDS | MINUTES | HOURS | DAYS | WEEKS | MONTHS | YEARS } AGO
          | <inline-scalar>
          }
  ]
```
```
<cmd> ::=
  <delete>
  | <insert>
  | <merge>
  | <query>
  | <update>
```
```
<set-op> ::=
  UNION
  | EXCEPT
  | INTERSECT
  | DIVIDED BY [ WITH REMAINDER ]
  | PASS-THRU
  | NOP
  | TEE
  | MULTEE
  | WHY 
  | DUBYA 
```
Set operators `UNION`, etc. apply the previous result collection to the next query result or result from `( ... )`.
Left paren `(` can only exist singly, but right paren `)` may be stacked to any depth `...)))`.

`AS OF` defaults to `NOW`
`AS OF <inline-scalar>` inline Scalar function that returns `<timestamp>`.

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated
`AS OF` prior to `<table>` component creation
