/-  ast
/+  parse,  *test
|%

::
:: create table as of simple name
++  test-create-table-08
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~ as-of=~]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1,col2) as of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)

::
:: create table as of ns-qualified name
++  test-create-table-08
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~ as-of=~]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1,col2) as of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)

::
:: create table as of db-qualified name
++  test-create-table-08
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~ as-of=~]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1,col2) as of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)

::
:: create table as of db-ns-qualified name
++  test-create-table-08
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] clustered=%.y pri-indx=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.y]] foreign-keys=~ as-of=~]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1,col2) as of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)

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
