/-  ast
/+  parse,  *test
|%
::
:: update
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
++  cte-t1
  [%cte name='t1' [%simple-query ~ [%scalars ~] ~ [%group-by ~] [%having ~] [%select top=~ bottom=~ distinct=%.n columns=~[all-columns]] ~]]
++  cte-foobar
  [%cte name='foobar' [%simple-query [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foobar'] alias=~] joins=~]] [%scalars ~] `[%eq [col1 ~ ~] [[value-type=%ud value=2] ~ ~]] [%group-by ~] [%having ~] [%select top=~ bottom=~ distinct=%.n columns=~[col3 col4]] ~]]
++  cte-bar
  [%cte name='bar' [%simple-query [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] joins=~]] [%scalars ~] `[%eq [col1 ~ ~] [col2 ~ ~]] [%group-by ~] [%having ~] [%select top=~ bottom=~ distinct=%.n columns=~[col2]] ~]]
++  foo-table  
  [%qualified-object ship=~ database='db1' namespace='dbo' name='foo']



++  one-eq-1  [%eq [[value-type=%ud value=1] ~ ~] [[value-type=%ud value=1] ~ ~]]
++  update-pred
  [%and one-eq-1 [%eq [col2 ~ ~] [[value-type=%ud value=4] ~ ~]]]
::
:: update one column, no predicate
++  test-update-01
  %+  expect-eq
    !>  ~[[%update table=foo-table columns=~['col1'] values=~[[value-type=%t value='hello']] ~ predicate=~]]
    !>  (parse:parse(current-database 'db1') "update foo set col1='hello'")
::
:: update two columns, no predicate
++  test-update-02
  %+  expect-eq
    !>  ~[[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] ~ predicate=~]]
    !>  (parse:parse(current-database 'db1') "update foo set col1=col2, col3 = 'hello'")
::
:: update two columns, with predicate
++  test-update-03
  %+  expect-eq
    !>  ~[[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] ~ predicate=`update-pred]]
    !>  (parse:parse(current-database 'db1') "update foo set col1=col2, col3 = 'hello' where 1 = 1 and col2 = 4")

::
:: update with one cte and predicate
++  test-update-04
  %+  expect-eq
    !>  ~[[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] ~[cte-t1] predicate=`update-pred]]
    !>  (parse:parse(current-database 'db1') "update foo set col1=col2, col3 = 'hello' with (select *) as t1 where 1 = 1 and col2 = 4")
::
:: update with three ctes and predicate
++  test-update-05
  %+  expect-eq
    !>  ~[[%update table=foo-table columns=~['col3' 'col1'] values=~[[value-type=%t value='hello'] col2] ~[cte-t1 cte-foobar cte-bar] predicate=`update-pred]]
    !>  (parse:parse(current-database 'db1') "update foo set col1=col2, col3 = 'hello' with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar where 1 = 1 and col2 = 4")
::
:: fail update cte with no predicate
++  test-fail-update-06
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "update foo set col1=col2, col3 = 'hello' with (select *) as t1")

--