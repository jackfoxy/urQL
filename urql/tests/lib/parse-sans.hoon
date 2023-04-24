/-  ast
/+  parse,  *test
|%
::
::
++  all-columns  [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']
++  select-all-columns  [%select top=~ bottom=~ distinct=%.n columns=~[all-columns]]
++  foo
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo'] 'foo' ~] ~ ~]
++  bar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'bar'] 'bar' ~] ~ ~]
++  t1-foo
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo' ~] ~ ~]
++  t2-bar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T2'] 'bar' ~] ~ ~]
++  t1-foo2
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo2' ~] ~ ~]
++  foobar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foobar'] 'foobar' ~] ~ ~]

++  t1-foo2-eq-zod       [%eq t1-foo2 [[%p 0] ~ ~]]
++  foobar-lte-bar       [%lte foobar bar]
++  foobar-gte-foo       [%gte foobar foo]
++  and-fb-gte-f--fb-lte-b   [%and foobar-gte-foo foobar-lte-bar]
++  and-and                  [%and and-fb-gte-f--fb-lte-b t1-foo2-eq-zod]
::
::
::    object=[%query-object object=[%query-row <|col1 col2 col3|>]
::

++  foo-alias-y  [%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=[~ 'y']]
++  bar-alias-x  [%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=[~ 'x']]

++  foo-unaliased  [%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~]
++  bar-unaliased  [%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~]

++  passthru-row-y  [%query-object object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'y']]
++  passthru-row-x  [%query-object object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'x']]

++  passthru-unaliased  [%query-object object=[%query-row ~['col1' 'col2' 'col3']] alias=~]

::
::  from foo as (aliased) cross join bar (aliased)
++  test-from-join-19
%+  expect-eq
 =/  expected  [%simple-query from=[~ [%from object=foo-alias-y joins=~[[%joined-object join=%cross-join object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~]
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "FROM foo as y cross join bar x SELECT *")
::
::  from foo (aliased) cross join bar as (aliased)
++  test-from-join-20
%+  expect-eq
 =/  expected  [%simple-query from=[~ [%from object=foo-alias-y joins=~[[%joined-object join=%cross-join object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~]
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "FROM foo y cross join bar as x SELECT *")
::
::  from foo cross join bar
++  test-from-join-21
%+  expect-eq
 =/  expected  [%simple-query from=[~ [%from object=foo-unaliased joins=~[[%joined-object join=%cross-join object=bar-unaliased predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~]
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "FROM foo cross join bar SELECT *")
::
::  from pass-thru as (aliased) cross join bar (aliased)
++  test-from-join-22
%+  expect-eq
 =/  expected  [%simple-query from=[~ [%from object=passthru-row-y joins=~[[%joined-object join=%cross-join object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~]
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "FROM (col1, col2, col3) as y cross join bar x SELECT *")
::
::  from pass-thru (aliased) cross join bar as (aliased)
++  test-from-join-23
%+  expect-eq
 =/  expected  [%simple-query from=[~ [%from object=passthru-row-y joins=~[[%joined-object join=%cross-join object=bar-alias-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~]
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "FROM (col1,col2,col3) y cross join bar as x SELECT *")
::
::  from foo as (aliased) cross join pass-thru  (aliased)
++  test-from-join-24
%+  expect-eq
=/  expected  [%simple-query from=[~ [%from object=foo-alias-y joins=~[[%joined-object join=%cross-join object=passthru-row-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~]
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "FROM foo as y cross join (col1,col2,col3) x SELECT *")
::
::  from foo (aliased) cross join pass-thru  as (aliased)
++  test-from-join-25
%+  expect-eq
=/  expected  [%simple-query from=[~ [%from object=foo-alias-y joins=~[[%joined-object join=%cross-join object=passthru-row-x predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~]
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "FROM foo y cross join (col1,col2,col3) as x SELECT *")
::
::  from pass-thru cross join pass-thru
++  test-from-join-26
%+  expect-eq
=/  expected  [%simple-query from=[~ [%from object=passthru-unaliased joins=~[[%joined-object join=%cross-join object=passthru-unaliased predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~]
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "FROM (col1,col2,col3) cross join (col1,col2,col3) SELECT *")
::
::  from foo (aliased) cross join pass-thru
++  test-from-join-27
%+  expect-eq
=/  expected  [%simple-query from=[~ [%from object=foo-alias-y joins=~[[%joined-object join=%cross-join object=passthru-unaliased predicate=~]]]] scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns order-by=~]
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "FROM foo y cross join (col1,col2,col3) SELECT *")


::
:: fail joins with cross join
++  test-fail-from-join-28
    =/  select  "FROM foo y join foo cross join (col1,col2,col3) SELECT *"
    %-  expect-fail
    |.  (parse:parse(current-database 'db1') select)
    ::
:: fail joins with cross join
++  test-fail-from-join-29
    =/  select  "FROM foo y cross join bar join bar  SELECT *"
    %-  expect-fail
    |.  (parse:parse(current-database 'db1') select)
:: fail multiple cross join
++  test-fail-from-join-30
    =/  select  "FROM foo y cross join (col1,col2,col3) cross join foobar  SELECT *"
    %-  expect-fail
    |.  (parse:parse(current-database 'db1') select)



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
