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

`<cte-lib>` pre-built library of `<common-table-expression>`, TBD.

`INTO <table>` inserts resulting `<table-set>` into `<table>`. Prior `<cmd>` is terminal.

`AS OF` defaults to `NOW`.
`AS OF <inline-scalar>` inline Scalar function that returns `<timestamp>`.

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
```
Set operators `UNION`, etc. apply the previous result collection to the next query result or result from nested queries `( ... )`.
Left paren `(` can only exist singly, but right paren `)` may be stacked to any depth `...)))`.

```
<cmd> ::=
  <delete>
  | <insert>
  | <merge>
  | <query>
  | <update>
```


```
<set-functions> ::=
  <cmd> | <set-op>
```

API:
```
+$  transform
  $:
  %transform
  ctes=(list <common-table-expression>)
  (tree <set-functions>)
  ==
```

## Arguments

** **

## Remarks

## Produced Metadata

## Exceptions
`<table>` does not exist
`GRANT` permission on `<table>` violated
`AS OF` prior to `<table>` component creation
