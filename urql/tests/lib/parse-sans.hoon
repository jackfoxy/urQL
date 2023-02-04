/-  ast
/+  parse,  *test
::
:: we frequently break the rules of unit and regression tests here
:: by testing more than one thing per result, otherwise there would
:: just be too many tests
::
:: each arm tests one urql command
::
:: common things to test
:: 1) basic command works producing AST object
:: 2) multiple ASTs
:: 3) all keywords are case ambivalent
:: 4) all names follow rules for faces
:: 5) all qualifier combinations work
::
:: -test /=urql=/tests/lib/parse/hoon ~
|%
::  re-used components
++  all-columns  [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']
++  group-by  [%group-by ~[[%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='T1'] column='foo' alias=~] 3 4]]
++  order-by  [%order-by ~[[%ordering-column [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col' alias=~] is-ascending=%.y] [%ordering-column [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='T1'] column='foo' alias=~] is-ascending=%.n] [%ordering-column 3 is-ascending=%.y] [%ordering-column 4 is-ascending=%.n]]]
++  from-foo  [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~] joins=~]]
++  t1-foo
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo' ~] ~ ~]
++  t2-bar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T2'] 'bar' ~] ~ ~]
::
::  group by
++  test-group-by-01
  =/  select  "from foo group by  db.ns.table.col , T1.foo , 3 , 4 select *"
  %+  expect-eq
    !>  ~[[%simple-query from-foo group-by [%scalars ~] ~ [%select top=~ bottom=~ distinct=%.n columns=~[all-columns]] ~]]
    !>  (parse:parse(current-database 'db1') select)

++  test-group-by-02
  =/  pred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  select  "from foo group by db.ns.table.col,T1.foo,3,4 where T1.foo = T2.bar select *"
  %+  expect-eq
    !>  ~[[%simple-query from-foo group-by [%scalars ~] `pred [%select top=~ bottom=~ distinct=%.n columns=~[all-columns]] ~]]
    !>  (parse:parse(current-database 'db1') select)
--