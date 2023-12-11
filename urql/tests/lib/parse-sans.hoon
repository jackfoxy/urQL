/-  ast
/+  parse,  *test
|%

:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-drop-table-00
  =/  expected1  [%drop-table table=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.y as-of=~]
  =/  expected2  [%drop-table table=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.n as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'other-db') "droP  table FORce db.ns.name;droP  table  \0a db.ns.name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, force db..name
++  test-drop-table-01
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "   \09drop\0d\09  table\0aforce db..name ")
::
:: db..name
++  test-drop-table-02
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop table db..name")
::
:: force ns.name
++  test-drop-table-03
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='ns' name='name'] force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop table force ns.name")
::
:: ns.name
++  test-drop-table-04
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='ns' name='name'] force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop table ns.name")
::
:: force name
++  test-drop-table-05
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='dbo' name='name'] force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "DROP table FORCE name")
::
:: name
++  test-drop-table-06
  %+  expect-eq
   !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='dbo' name='name'] force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "DROP table name")


:: force db.ns.name as of now
++  test-drop-table-07
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop table force db.ns.name as of now")
:: force db..name as of date
++  test-drop-table-08
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.y as-of=[~ ~2023.12.25..7.15.0..1ef5]]]
    !>  (parse:parse(default-database 'other-db') "drop table force db..name as of ~2023.12.25..7.15.0..1ef5")
:: force ns.name as of weeks ago
++  test-drop-table-09
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='ns' name='name'] force=%.y as-of=[~ [%as-of-offset 10 %weeks]]]]
    !>  (parse:parse(default-database 'other-db') "drop table force ns.name as of 10 weeks ago")

:: name as of now
++  test-drop-table-10
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop table db.ns.name as of now")
:: db..name as of date
++  test-drop-table-11
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.n as-of=[~ ~2023.12.25..7.15.0..1ef5]]]
    !>  (parse:parse(default-database 'other-db') "drop table db..name as of ~2023.12.25..7.15.0..1ef5")
:: name as of weeks ago
++  test-drop-table-12
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='dbo' name='name'] force=%.n as-of=[~ [%as-of-offset 10 %weeks]]]]
    !>  (parse:parse(default-database 'other-db') "drop table name as of 10 weeks ago")
    

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
