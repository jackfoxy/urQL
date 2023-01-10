/-  ast
/+  parse,  *test
|%
::  predicate
::
::  re-used components
++  foo
  `(tree predicate-component:ast)`[[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo'] 'foo' ~] ~ ~]
++  t1-foo      
  `(tree predicate-component:ast)`[[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo' ~] ~ ~]

++  foo2                 [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo2'] 'foo2' ~] ~ ~]
++  t1-foo2              [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo2' ~] ~ ~]
++  foo3                 [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo3'] 'foo3' ~] ~ ~]
++  t1-foo3              [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo3' ~] ~ ~]
++  foo4                 [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo4'] 'foo4' ~] ~ ~]
++  foo5                 [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo5'] 'foo5' ~] ~ ~]
++  foo6                 [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo6'] 'foo6' ~] ~ ~]
++  foo7                 [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo7'] 'foo7' ~] ~ ~]
++  bar
  `(tree predicate-component:ast)`[[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'bar'] 'bar' ~] ~ ~]
++  t2-bar      
  `(tree predicate-component:ast)`[[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T2'] 'bar' ~] ~ ~]

++  foobar               [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foobar'] 'foobar' ~] ~ ~]

++  a1-adoption-email  [[%qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN' 'A1'] 'adoption-email' 0] 0 0]
++  a2-adoption-email  [[%qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN' 'A2'] 'adoption-email' 0] 0 0]

++  a1-adoption-date  [[%qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN' 'A1'] 'adoption-date' 0] 0 0]
++  a2-adoption-date  [[%qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN' 'A2'] 'adoption-date' 0] 0 0]

++  a1-name  [[%qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN' 'A1'] 'name' 0] 0 0]
++  a2-name  [[%qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN' 'A2'] 'name' 0] 0 0]
++  a1-species  [[%qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN' 'A1'] 'species' 0] 0 0]
++  a2-species  [[%qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN' 'A2'] 'species' 0] 0 0]

++  value-literal-list   [[%value-literal-list %ud '3;2;1'] ~ ~]
++  aggregate-count-foo  [%aggregate %count %qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo] %foo 0]
++  literal-10           [[%ud 10] 0 0]
::
::  re-used simple predicates
++  foobar-gte-foo       `(tree predicate-component:ast)`[%gte foobar foo]
++  foobar-lte-bar       `(tree predicate-component:ast)`[%lte foobar bar]
++  foo-eq-1             [%eq foo [[%ud 1] ~ ~]]
++  t1-foo-gt-foo2       [%gt t1-foo foo2]
++  t2-bar-in-list       [%in t2-bar value-literal-list]
++  t1-foo2-eq-zod       [%eq t1-foo2 [[%p 0] ~ ~]]
++  t1-foo3-lt-any-list  [%lt t1-foo3 [%any value-literal-list ~]]
::
::  re-used predicates with conjunctions
++  and-fb-gte-f--fb-lte-b   [%and foobar-gte-foo foobar-lte-bar]
++  and-fb-gte-f--t1f2-eq-z  [%and foobar-gte-foo t1-foo2-eq-zod]
++  and-f-eq-1--t1f3-lt-any  [%and foo-eq-1 t1-foo3-lt-any-list]
++  and-and                  [%and and-fb-gte-f--fb-lte-b t1-foo2-eq-zod]
++  and-and-or               [%or and-and t2-bar-in-list]
++  and-and-or-and           [%or and-and and-fb-gte-f--t1f2-eq-z]
++  and-and-or-and-or-and    [%or and-and-or-and and-f-eq-1--t1f3-lt-any]
::
::  predicates with conjunctions and nesting
++  and-fb-gt-f--fb-lt-b     [%and [%gt foobar foo] [%lt foobar bar]]
++  and-t1f-gt-f2--t2b-in-l  [%and t1-foo-gt-foo2 t2-bar-in-list]
++  or2                      [%and [%and t1-foo3-lt-any-list t1-foo2-eq-zod] foo-eq-1]
++  or3                      [%and [%eq foo3 foo4] [%eq foo5 foo6]]
++  big-or                   [%or [%or [%or and-t1f-gt-f2--t2b-in-l or2] or3] [%eq foo4 foo5]]
++  big-and                  [%and and-fb-gt-f--fb-lt-b big-or]
++  a-a-l-a-o-l-a-a-r-o-r-a-l-o-r-a  
                             [%and big-and [%eq foo6 foo7]]
++  first-or                 [%or [%gt foobar foo] [%lt foobar bar]]
++  last-or                  [%or t1-foo3-lt-any-list [%and t1-foo2-eq-zod foo-eq-1]]
++  first-and                [%and first-or t1-foo-gt-foo2]
++  second-and               [%and first-and t2-bar-in-list]
++  king-and                 [%and [second-and] last-or]
::
::  test binary operators, varying spacing
++  test-predicate-01
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  expected=simple-query:ast  [%simple-query [~ [%priori [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] ~ ~]] [%select top=~ bottom=~ distinct=%.n columns=~[%all]] ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
++  test-predicate-02
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo<>bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%neq foo bar]
  =/  expected=simple-query:ast  [%simple-query [~ [%priori [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] ~ ~]] [%select top=~ bottom=~ distinct=%.n columns=~[%all]] ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
++  test-predicate-03
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo!= bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%neq foo bar]
  =/  expected=simple-query:ast  [%simple-query [~ [%priori [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] ~ ~]] [%select top=~ bottom=~ distinct=%.n columns=~[%all]] ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
++  test-predicate-04
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo >bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%gt foo bar]
  =/  expected=simple-query:ast  [%simple-query [~ [%priori [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] ~ ~]] [%select top=~ bottom=~ distinct=%.n columns=~[%all]] ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
++  test-predicate-05
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo <bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%lt foo bar]
  =/  expected=simple-query:ast  [%simple-query [~ [%priori [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] ~ ~]] [%select top=~ bottom=~ distinct=%.n columns=~[%all]] ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
++  test-predicate-06
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo>= bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%gte foo bar]
  =/  expected=simple-query:ast  [%simple-query [~ [%priori [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] ~ ~]] [%select top=~ bottom=~ distinct=%.n columns=~[%all]] ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
++  test-predicate-07
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo!< bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%gte foo bar]
  =/  expected=simple-query:ast  [%simple-query [~ [%priori [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] ~ ~]] [%select top=~ bottom=~ distinct=%.n columns=~[%all]] ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
++  test-predicate-08
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo <= bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%lte foo bar]
  =/  expected=simple-query:ast  [%simple-query [~ [%priori [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] ~ ~]] [%select top=~ bottom=~ distinct=%.n columns=~[%all]] ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
++  test-predicate-09
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON foo !> bar SELECT *"
  =/  pred=(tree predicate-component:ast)  [%lte foo bar]
  =/  expected=simple-query:ast  [%simple-query [~ [%priori [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`pred]]]] ~ ~]] [%select top=~ bottom=~ distinct=%.n columns=~[%all]] ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
::
::  remaining simple predicates, varying spacing and keywork casing
++  test-predicate-10
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
   " WHERE foobar  Not  Between foo  And bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%not [%between foobar-gte-foo foobar-lte-bar] ~]
  =/  expected=simple-query:ast  
    [%simple-query [~ [%priori [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] ~ `pred]] [%select top=~ bottom=~ distinct=%.n columns=~[%all]] ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
++  test-predicate-11
  =/  query  "FROM adoptions AS T1 JOIN adoptions AS T2 ON T1.foo = T2.bar ".
   " WHERE foobar  Not  Between foo   bar ".
    " SELECT *"
  =/  joinpred=(tree predicate-component:ast)  [%eq t1-foo t2-bar]
  =/  pred=(tree predicate-component:ast)      [%not [%between foobar-gte-foo foobar-lte-bar] ~]
  =/  expected=simple-query:ast  
    [%simple-query [~ [%priori [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T1']] joins=~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='adoptions'] alias=[~ 'T2']] predicate=`joinpred]]]] ~ `pred]] [%select top=~ bottom=~ distinct=%.n columns=~[%all]] ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)

--