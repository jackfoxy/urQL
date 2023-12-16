/-  ast
/+  parse,  *test
|%

++  column-foo       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~]
++  column-bar       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]
++  all-columns  [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']
++  select-all-columns  [%select top=~ bottom=~ columns=~[all-columns]]
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
  [%cte name='t1' [%query ~ scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns ~]]
++  cte-foobar
  [%cte name='foobar' [%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foobar'] alias=~] joins=~]] scalars=~ `[%eq [col1 ~ ~] [[value-type=%ud value=2] ~ ~]] group-by=~ having=~ [%select top=~ bottom=~ columns=~[col3 col4]] ~]]
++  cte-bar
  [%cte name='bar' [%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] joins=~]] scalars=~ `[%eq [col1 ~ ~] [col2 ~ ~]] group-by=~ having=~ [%select top=~ bottom=~ columns=~[col2]] ~]]
++  foo-table
  [%qualified-object ship=~ database='db1' namespace='dbo' name='foo']
::@@@@@@@@@@@@@@@@@@@@@@@@@

::
:: delete from foo;delete  foo
++  test-delete-00
  =/  expected1  [%transform ctes=~ [[%delete table=foo-table ~ ~] ~ ~]]
  =/  expected2  [%transform ctes=~ [[%delete table=foo-table ~ ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') "delete from foo;delete  foo")
::
:: delete from foo as of now;delete foo as of now
++  test-delete-01
  =/  expected1  [%transform ctes=~ [[%delete table=foo-table ~ ~] ~ ~]]
  =/  expected2  [%transform ctes=~ [[%delete table=foo-table ~ ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') "delete from foo as of now;delete  foo as of now")
::
:: delete from foo as of ~2023.12.25..7.15.0..1ef5;delete foo as of ~2023.12.25..7.15.0..1ef5
++  test-delete-02
  =/  expected1  [%transform ctes=~ [[%delete table=foo-table ~ [~ ~2023.12.25..7.15.0..1ef5]] ~ ~]]
  =/  expected2  [%transform ctes=~ [[%delete table=foo-table ~ [~ ~2023.12.25..7.15.0..1ef5]] ~ ~]]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') "delete from foo as of 2023.12.25..7.15.0..1ef5;delete  foo as of ~2023.12.25..7.15.0..1ef5")
::
:: delete from foo as of 5 seconds ago;delete foo as of 5 seconds ago
++  test-delete-03
  =/  expected1  [%transform ctes=~ [[%delete table=foo-table ~ [~ [%as-of-offset 5 %seconds]]] ~ ~]]
  =/  expected2  [%transform ctes=~ [[%delete table=foo-table ~ [~ [%as-of-offset 4 %seconds]]] ~ ~]]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') "delete from foo as of 5 seconds ago;delete  foo as of 4 seconds ago")
::
:: delete with predicate as
++  test-delete-04
  =/  expected  [%transform ctes=~ [[%delete table=foo-table delete-pred ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "delete from foo  where foo=bar")
::
:: delete with predicate of now
++  test-delete-05
  =/  expected  [%transform ctes=~ [[%delete table=foo-table delete-pred ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "delete from foo where foo=bar as of now")
::
:: delete with predicate of ~2023.12.25..7.15.0..1ef5
++  test-delete-06
  =/  expected  [%transform ctes=~ [[%delete table=foo-table delete-pred [~ ~2023.12.25..7.15.0..1ef5]] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "delete from foo where foo=bar as of ~2023.12.25..7.15.0..1ef5")
::
:: delete with predicate of 5 seconds ago
++  test-delete-07
  =/  expected  [%transform ctes=~ [[%delete table=foo-table delete-pred [~ [%as-of-offset 5 %seconds]]] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "delete from foo where foo=bar as of 5 seconds ago")
::
:: delete with one cte and predicate
++  test-delete-08
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table delete-pred ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo where foo=bar")
::
:: delete with one cte and predicate as of now
++  test-delete-09
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table delete-pred ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo where foo=bar as of now")
::
:: delete with one cte and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-delete-10
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table delete-pred [~ ~2023.12.25..7.15.0..1ef5]] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo where foo=bar as of ~2023.12.25..7.15.0..1ef5")
::
:: delete with one cte and predicate as of 5 seconds ago
++  test-delete-11
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table delete-pred [~ [%as-of-offset 5 %seconds]]] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo where foo=bar as of 5 seconds ago")
::
:: delete with two ctes and predicate
++  test-delete-12
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar] [[%delete table=foo-table delete-pred ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar delete from foo where foo=bar")
::
:: delete with two ctes and predicate as of now
++  test-delete-13
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar] [[%delete table=foo-table delete-pred ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar delete from foo where foo=bar as of now")
::
:: delete with two ctes and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-delete-14
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar] [[%delete table=foo-table delete-pred [~ ~2023.12.25..7.15.0..1ef5]] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar delete from foo where foo=bar as of ~2023.12.25..7.15.0..1ef5")
::
:: delete with two ctes and predicate as of 5 seconds ago
++  test-delete-15
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar] [[%delete table=foo-table delete-pred [~ [%as-of-offset 5 %seconds]]] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar delete from foo where foo=bar as of 5 seconds ago")
::
:: delete with three ctes and predicate
++  test-delete-16
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar cte-bar] [%delete table=foo-table delete-pred ~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar delete from foo where foo=bar")
::
:: delete with three ctes and predicate as of now
++  test-delete-17
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar cte-bar] [%delete table=foo-table delete-pred ~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar delete from foo where foo=bar as of now")
::
:: delete with three ctes and predicate as of ~2023.12.25..7.15.0..1ef5
++  test-delete-18
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar cte-bar] [%delete table=foo-table delete-pred [~ ~2023.12.25..7.15.0..1ef5]] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar delete from foo where foo=bar as of ~2023.12.25..7.15.0..1ef5")
::
:: delete with three ctes and predicate as of 5 seconds ago
++  test-delete-19
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar cte-bar] [%delete table=foo-table delete-pred [~ [%as-of-offset 5 %seconds]]] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar delete from foo where foo=bar as of 5 seconds ago")

::
:: delete cte with no predicate
++  test-delete-20
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table ~ ~] ~ ~]]
  %+  expect-eq
  !>  ~[expected]
  !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo")
::
:: delete cte with no predicate as of now
++  test-delete-21
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table ~ ~] ~ ~]]
  %+  expect-eq
  !>  ~[expected]
  !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo as of now")
::
:: delete cte with no predicate as of ~2023.12.25..7.15.0..1ef5
++  test-delete-22
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table ~ [~ ~2023.12.25..7.15.0..1ef5]] ~ ~]]
  %+  expect-eq
  !>  ~[expected]
  !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo as of ~2023.12.25..7.15.0..1ef5")
::
:: delete cte with no predicate as of 5 seconds ago
++  test-delete-23
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table ~ [~ [%as-of-offset 5 %seconds]]] ~ ~]]
  %+  expect-eq
  !>  ~[expected]
  !>  (parse:parse(default-database 'db1') "with (select *) as t1 delete from foo as of 5 seconds ago")


::@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
::
:: expected/actual match
::++  test-predicate-26
::  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
::    " WHERE foobar >=foo And foobar<=bar ".
::    " and T1.foo2 = ~zod ".
::    " SELECT *"
::  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
::  =/  pred=(tree predicate-component:ast)      and-and
::  =/  expected=simple-query:ast
::    [%simple-query [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] scalars=~ `pred group-by=~ having=~ select-all-columns ~]
::  %+  expect-eq
::    !>  ~[expected]
::    !>  (parse:parse(current-database 'db1') query)


--
