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
++  bar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'bar'] 'bar' ~] ~ ~]
++  all-columns  [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']
++  from-foo
  [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~] joins=~]]
++  literal-10           [[%ud 10] ~ ~]
++  aggregates
  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~] [%selected-aggregate [%aggregate function='count' source=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~]] alias=[~ 'CountFoo']] [%selected-aggregate [%aggregate function='count' source=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]] alias=~] [%selected-aggregate [%aggregate function='sum' source=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]] alias=~] [%selected-aggregate [%aggregate function='sum' source=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]] alias=[~ 'foobar']]]
++  aggregate-count-foobar  [%aggregate function='count' source=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]]
::
::
::  mixed aggregates
++  test-select-23
  =/  select  "select  foo , COUNT(foo) as CountFoo, cOUNT( bar) ,sum(bar ) , sum( foobar ) as foobar "
  %+  expect-eq
    !>  ~[[%simple-query ~ [%scalars ~] ~ [%group-by ~] [%having ~] [%select top=~ bottom=~ distinct=%.n columns=aggregates] ~]]
    !>  (parse:parse(current-database 'db1') select)
::
::  aggregate inequality
++  test-predicate-31
  =/  select  "from foo where  count( foobar )  > 10 select * "
  =/  pred=(tree predicate-component:ast)  [%gt [aggregate-count-foobar ~ ~] literal-10]
  %+  expect-eq
    !>  ~[[%simple-query from-foo [%scalars ~] `pred [%group-by ~] [%having ~] [%select top=~ bottom=~ distinct=%.n columns=~[all-columns]] ~]]
    !>  (parse:parse(current-database 'db1') select)
::
::  aggregate inequality, no whitespace
++  test-predicate-32
  =/  select  "from foo where count(foobar) > 10 select *"
  =/  pred=(tree predicate-component:ast)  [%gt [aggregate-count-foobar ~ ~] literal-10]
  %+  expect-eq
    !>  ~[[%simple-query from-foo [%scalars ~] `pred [%group-by ~] [%having ~] [%select top=~ bottom=~ distinct=%.n columns=~[all-columns]] ~]]
    !>  (parse:parse(current-database 'db1') select)
::
::  aggregate equality
++  test-predicate-33
  =/  select  "from foo where bar = count(foobar) select *"
  =/  pred=(tree predicate-component:ast)  [%eq bar [aggregate-count-foobar ~ ~]]
  %+  expect-eq
    !>  ~[[%simple-query from-foo [%scalars ~] `pred [%group-by ~] [%having ~] [%select top=~ bottom=~ distinct=%.n columns=~[all-columns]] ~]]
    !>  (parse:parse(current-database 'db1') select)
--