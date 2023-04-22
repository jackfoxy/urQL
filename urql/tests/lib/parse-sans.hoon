/-  ast
/+  parse,  *test
|%
::
::
++  foo-table
  [%qualified-object ship=~ database='db1' namespace='dbo' name='foo']
++  one-eq-1
  [%eq [[value-type=%ud value=1] ~ ~] [[value-type=%ud value=1] ~ ~]]
::
::
::    object=[%query-object object=[%query-row <|col1 col2 col3|>]
::
++  foo-table-row  [%query-row ~['col1' 'col2' 'col3']]

++  from-foo-row
  [~ [%from object=[%query-object object=foo-table-row alias=~] joins=~]]

++  from-foo-row-aliased
  [~ [%from object=[%query-object object=foo-table-row alias=[~ 'F1']] joins=~]]

++  simple-from-foo-row
  [%simple-query from-foo-row scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=~ distinct=%.y columns=~[[%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']]] ~]

++  aliased-from-foo-row
  [%simple-query from-foo-row-aliased scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=~ distinct=%.y columns=~[[%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']]] ~]

++  joins-bar
  ~[[%joined-object join=%join object=[%query-object object=[%query-row ~['col1' 'col2' 'col3']] alias=~] predicate=`one-eq-1]]

++  from-foo-join-bar-row
  [~ [%from object=[%query-object object=foo-table alias=~] joins=joins-bar]]

++  simple-from-foo-join-bar-row
  [%simple-query from-foo-join-bar-row scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=~ distinct=%.y columns=~[[%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']]] ~]

++  joins-bar-aliased
  ~[[%joined-object join=%join object=[%query-object object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'b1']] predicate=`one-eq-1]]

++  from-foo-join-bar-row-aliased
  [~ [%from object=[%query-object object=foo-table alias=~] joins=joins-bar-aliased]]

++  simple-from-foo-join-bar-row-aliased
  [%simple-query from-foo-join-bar-row-aliased scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=~ distinct=%.y columns=~[[%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']]] ~]

++  from-foo-row-aliased-join-bar-aliased
  [~ [%from object=[%query-object object=foo-table alias=[~ 'f1']] joins=joins-bar-aliased]]

++  aliased-from-foo-join-bar-row-aliased
  [%simple-query from-foo-row-aliased-join-bar-aliased scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=~ distinct=%.y columns=~[[%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']]] ~]

++  joins-bar-baz
  ~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] predicate=`one-eq-1] [%joined-object join=%left-join object=[%query-object object=[%query-row ~['col1' 'col2' 'col3']] alias=~] predicate=`one-eq-1]]

++  from-foo-join-bar-row-baz
  [~ [%from object=[%query-object object=foo-table-row alias=~] joins=joins-bar-baz]]

++  simple-from-foo-join-bar-row-baz
  [%simple-query from-foo-join-bar-row-baz scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=~ distinct=%.y columns=~[[%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']]] ~]

++  aliased-joins-bar-baz
  ~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=[~ 'B1']] predicate=`one-eq-1] [%joined-object join=%left-join object=[%query-object object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'b2']] predicate=`one-eq-1]]

++  aliased-foo-join-bar-baz
  [~ [%from object=[%query-object object=[%query-row ~['col1']] alias=[~ 'f1']] joins=aliased-joins-bar-baz]]

++  aliased-from-foo-join-bar-row-baz
  [%simple-query aliased-foo-join-bar-baz scalars=~ ~ group-by=~ having=~ [%select top=[~ 10] bottom=~ distinct=%.y columns=~[[%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']]] ~]

::
::  from pass-thru row (un-aliased)
++  test-from-join-10
%+  expect-eq
    !>  ~[simple-from-foo-row]
    !>  (parse:parse(current-database 'db1') "FROM (col1, col2, col3) SELECT TOP 10 DISTINCT *")
::
::  from pass-thru row (aliased)
++  test-from-join-11
%+  expect-eq
    !>  ~[aliased-from-foo-row]
    !>  (parse:parse(current-database 'db1') "FROM (col1, col2, col3) F1 SELECT TOP 10 DISTINCT *")
::
::  from pass-thru row (aliased as)
++  test-from-join-12
%+  expect-eq
    !>  ~[aliased-from-foo-row]
    !>  (parse:parse(current-database 'db1') "FROM (col1, col2, col3) as F1 SELECT TOP 10 DISTINCT *")

::  from foo (un-aliased) join pass-thru (un-aliased)
++  test-from-join-13
%+  expect-eq
    !>  ~[simple-from-foo-join-bar-row]
    !>  (parse:parse(current-database 'db1') "FROM foo join (col1, col2, col3) on 1 = 1 SELECT TOP 10 DISTINCT *")
::
::  from foo (un-aliased) join pass-thru (aliased)
++  test-from-join-14
%+  expect-eq
    !>  ~[simple-from-foo-join-bar-row-aliased]
    !>  (parse:parse(current-database 'db1') "FROM foo join (col1, col2, col3) b1 on 1 = 1 SELECT TOP 10 DISTINCT *")
::
::  from foo (un-aliased) join pass-thru (aliased as)
++  test-from-join-15
%+  expect-eq
    !>  ~[simple-from-foo-join-bar-row-aliased]
    !>  (parse:parse(current-database 'db1') "FROM foo join (col1,col2,col3)  as  b1 on 1 = 1 SELECT TOP 10 DISTINCT *")
::
::  from foo (aliased lower case) join pass-thru (aliased as)
++  test-from-join-16
%+  expect-eq
    !>  ~[aliased-from-foo-join-bar-row-aliased]
    !>  (parse:parse(current-database 'db1') "FROM foo f1 join (col1,col2,col3) b1 on 1 = 1 SELECT TOP 10 DISTINCT *")
::
::  from pass-thru (un-aliased) join bar (un-aliased) left join pass-thru (un-aliased)
++  test-from-join-17
%+  expect-eq
    !>  ~[simple-from-foo-join-bar-row-baz]
    !>  (parse:parse(current-database 'db1') "FROM (col1,col2,col3) join bar on 1 = 1 left join (col1,col2,col3) on 1 = 1 SELECT TOP 10 DISTINCT *")
::
::  from pass-thru single column (aliased) join bar (aliased) left join pass-thru (aliased)
++  test-from-join-18
%+  expect-eq
    !>  ~[aliased-from-foo-join-bar-row-baz]
    !>  (parse:parse(current-database 'db1') "FROM (col1) f1 join bar as B1 on 1 = 1 left join ( col1,col2,col3 ) b2 on 1 = 1 SELECT TOP 10 DISTINCT *")


:: to do: cross join tests and merge

--