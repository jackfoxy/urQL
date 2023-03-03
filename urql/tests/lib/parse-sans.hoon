/-  ast
/+  parse,  *test
|%
::
:: delete
::
++  column-foo       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~]
++  column-bar       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]
++  all-columns  [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']

++  col1
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col1'] column='col1' alias=~]
++  col2
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col2'] column='col2' alias=~]
++  col3
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col3'] column='col3' alias=~]
++  col4
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col4'] column='col4' alias=~]
++  delete-pred
  `[%eq [column-foo ~ ~] [column-bar ~ ~]]
++  cte-t1
  [%cte name='t1' [%simple-query ~ [%scalars ~] ~ [%group-by ~] [%having ~] [%select top=~ bottom=~ distinct=%.n columns=~[all-columns]] ~]]
++  cte-foobar
  [%cte name='foobar' [%simple-query [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foobar'] alias=~] joins=~]] [%scalars ~] `[%eq [col1 ~ ~] [[value-type=%ud value=2] ~ ~]] [%group-by ~] [%having ~] [%select top=~ bottom=~ distinct=%.n columns=~[col3 col4]] ~]]
++  cte-bar
  [%cte name='bar' [%simple-query [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] joins=~]] [%scalars ~] `[%eq [col1 ~ ~] [col2 ~ ~]] [%group-by ~] [%having ~] [%select top=~ bottom=~ distinct=%.n columns=~[col2]] ~]]
::
:: delete from foo;delete  foo
++  test-delete-01
  =/  expected1  [[%delete table=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] ~ ~]]
  =/  expected2  [[%delete table=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] ~ ~]]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'db1') "delete from foo;delete  foo")
::
:: delete with predicate
++  test-delete-02
  =/  expected  [%delete table=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] ~ delete-pred]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "delete from foo  where foo=bar")
::
:: delete with one cte and predicate
++  test-delete-03
  =/  expected  [%delete table=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] ~[cte-t1] delete-pred]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "delete from foo with (select *) as t1 where foo=bar")
::
:: delete with two ctes and predicate
++  test-delete-04
  =/  expected  [%delete table=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] ~[cte-t1 cte-foobar] delete-pred]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "delete from foo with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar where foo=bar")
::
:: delete with three ctes and predicate
++  test-delete-05
  =/  expected  [%delete table=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] ~[cte-t1 cte-foobar cte-bar] delete-pred]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "delete from foo with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar where foo=bar")
::
:: fail delete cte with no predicate
++  test-fail-delete-06
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "delete from foo with (select *) as t1")
--