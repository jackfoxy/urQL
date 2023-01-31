/-  ast
/+  parse,  *test
::
:: we frequently break the rules of unit and regression tests here
:: by testing more than one thing per result, otherwise there would
:: just be too many tests
::
:: each arm tests one urql command
::
:: common things to test
:: 1) basic command works producing AST object
:: 2) multiple ASTs
:: 3) all keywords are case ambivalent
:: 4) all names follow rules for faces
:: 5) all qualifier combinations work
::
:: -test /=urql=/tests/lib/parse/hoon ~
|%
::


++  aliased-joins-bar-baz
  ~[[%joined-object join=%join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=[~ 'B1']] predicate=`[%eq [[value-type=%ud value=1] ~ ~] [[value-type=%ud value=1] ~ ~]]] [%joined-object join=%left-join object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='baz'] alias=[~ 'b2']] predicate=`[%eq [[value-type=%ud value=1] ~ ~] [[value-type=%ud value=1] ~ ~]]]]
++  aliased-foo-join-bar-baz
  [~ [%from object=[%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=[~ 'f1']] joins=aliased-joins-bar-baz]]
++  aliased-from-foo-join-bar-baz
  [%simple-query [~ [%priori aliased-foo-join-bar-baz ~ ~]] [%select top=[~ 10] bottom=~ distinct=%.y columns=~[[%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']]] ~]


::
::  from foo (aliased) join bar (aliased) left join baz (aliased)
++  test-from-join-09
%+  expect-eq
    !>  ~[aliased-from-foo-join-bar-baz]
    !>  (parse:parse(current-database 'db1') "FROM foo f1 join bar as B1 on 1 = 1 left join baz b2 on 1 = 1 SELECT TOP 10 DISTINCT *")

--