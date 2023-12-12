/-  ast
/+  parse,  *test
|%

::
:: alter namespace db.ns db.ns2.table as of now
++  test-alter-namespace-02
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db' source-namespace='ns' object-type=%table target-namespace='ns2' target-name='table' as-of=~]]
    !>  (parse:parse(default-database 'db1') "alter namespace db.ns transfer table db.ns2.table as of now")
::
:: alter namespace db.ns db.ns2.table as of ~2023.12.25..7.15.0..1ef5
++  test-alter-namespace-03
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db' source-namespace='ns' object-type=%table target-namespace='ns2' target-name='table' as-of=[~ ~2023.12.25..7.15.0..1ef5]]]
    !>  (parse:parse(default-database 'db1') "alter namespace db.ns transfer table db.ns2.table as of ~2023.12.25..7.15.0..1ef5")
::
:: alter namespace db.ns db.ns2.table as of 5 days ago
++  test-alter-namespace-04
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db' source-namespace='ns' object-type=%table target-namespace='ns2' target-name='table' as-of=[~ %as-of-offset 5 %days]]]
    !>  (parse:parse(default-database 'db1') "alter namespace db.ns transfer table db.ns2.table as of 5 days ago")
::
:: alter namespace ns table as of now
++  test-alter-namespace-05
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table' as-of=~]]
    !>  (parse:parse(default-database 'db1') "alter namespace ns transfer table table as of now")
::
:: alter namespace ns table as of ~2023.12.25..7.15.0..1ef5
++  test-alter-namespace-06
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table' as-of=[~ ~2023.12.25..7.15.0..1ef5]]]
    !>  (parse:parse(default-database 'db1') "alter namespace ns transfer table table as of ~2023.12.25..7.15.0..1ef5")
::
:: alter namespace ns table as of 5 days ago
++  test-alter-namespace-07
  %+  expect-eq
    !>  ~[[%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table' as-of=[~ %as-of-offset 5 %days]]]
    !>  (parse:parse(default-database 'db1') "alter namespace ns transfer table table as of 5 days ago")
    

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
