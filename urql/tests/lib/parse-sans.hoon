/-  ast
/+  parse,  *test
|%

::
::  name, as of now
++  test-drop-namespace-03
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace ns1 as of now")
::
::  name, as of date
++  test-drop-namespace-04
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.n as-of=[~ ~2023.12.25..7.15.0..1ef5]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace ns1 as of ~2023.12.25..7.15.0..1ef5")
::
::  name, as of 5 seconds ago
++  test-drop-namespace-05
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.n as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace ns1 as of 5 seconds ago")
::
::  force name as of now
++  test-drop-namespace-06
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force ns1 as of now")
::
::  force name as of date
++  test-drop-namespace-07
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.y as-of=[~ ~2023.12.25..7.15.0..1ef5]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force ns1 as of ~2023.12.25..7.15.0..1ef5")
::
::  force name as of 5 seconds ago
++  test-drop-namespace-08
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='ns1' force=%.y as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force ns1 as of 5 seconds ago")
::
:: db name as of now
++  test-drop-namespace-09
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.n as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace db1.ns1 as of now")
::
:: db name as of date
++  test-drop-namespace-10
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.n as-of=[~ ~2023.12.25..7.15.0..1ef5]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace db1.ns1 as of ~2023.12.25..7.15.0..1ef5")
::
:: db name as of 5 seconds ago
++  test-drop-namespace-11
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.n as-of=[~ [%as-of-offset 5 %seconds]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace db1.ns1 as of 5 seconds ago")
::
:: force db name as of
++  test-drop-namespace-12
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.y as-of=~]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force db1.ns1 as of now")
::
:: force db name as of
++  test-drop-namespace-13
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.y as-of=[~ ~2023.12.25..7.15.0..1ef5]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force db1.ns1 as of ~2023.12.25..7.15.0..1ef5")
::
:: force db name as of
++  test-drop-namespace-14
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db1' name='ns1' force=%.y as-of=[~ [%as-of-offset 15 %minutes]]]]
    !>  (parse:parse(default-database 'other-db') "drop namespace force db1.ns1 as of 15 minutes ago")

    

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
