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
:: current database must be proper face
++  test-current-database
    %-  expect-fail
    |.  (parse:parse ['Other-db' "cReate\0d\09  namespace my-namespace"])
::
:: tests 1, 3, and extra whitespace characters
++  test-create-database-1
  %+  expect-eq
    !>  ~[[%create-database name='my-database']]
    !>  (parse:parse ['dummy' "cReate datAbase \0a  my-database "])
::
:: subsequent commands ignored
++  test-create-database-2
  %+  expect-eq
    !>  ~[[%create-database name='my-database']]
    !>  (parse:parse ['dummy' "cReate datAbase \0a  my-database; cReate namesPace my-db.another-namespace"])
::
:: fail when database name is not a face
++  test-create-database-3
  %-  expect-fail
  |.  (parse:parse ['dummy' "cReate datAbase  My-database"])
::
:: fail when commands are prior to create database
++  test-create-database-4
  %-  expect-fail
  |.  (parse:parse ['dummy' "create namespace my-namespace ; cReate datAbase my-database"])
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-create-namespace-1
  =/  expected1  [%create-namespace database-name='other-db' name='my-namespace']
  =/  expected2  [%create-namespace database-name='my-db' name='another-namespace']
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse 
    ['other-db' "cReate\0d\09  namespace my-namespace ; cReate namesPace my-db.another-namespace"]
::
:: leading and trailing whitespace characters, end delimiter not required on single
++  test-create-namespace-2
  %+  expect-eq
    !>  ~[[%create-namespace database-name='other-db' name='my-namespace']]
    !>  (parse:parse ['other-db' "   \09cReate\0d\09  namespace my-namespace "])
::
:: fail when database qualifier is not a face
++  test-create-namespace-3
  %-  expect-fail
  |.  (parse:parse ['other-db' "cReate namesPace Bad-face.another-namespace"])
::
:: fail when namespace is not a face
++  test-create-namespace-4
  %-  expect-fail
  |.  (parse:parse ['other-db' "cReate namesPace my-db.Bad-face"])
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-drop-view-1
  =/  expected1  [%drop-view database-name='db' namespace='ns' name='name' force=%.y]
  =/  expected2  [%drop-view database-name='db' namespace='ns' name='name' force=%.n]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse 
    ['other-db' "droP  View FORce db.ns.name;droP  View  \0a db.ns.name"]
::
:: leading and trailing whitespace characters, end delimiter not required on single
++  test-drop-view-2
  %+  expect-eq
    !>  ~[[%drop-view database-name='db' namespace='dbo' name='name' force=%.y]]
    !>  (parse:parse ['other-db' "   \09drop\0d\09  vIew\0aforce db..name "])
++  test-drop-view-3
  %+  expect-eq
    !>  ~[[%drop-view database-name='db' namespace='dbo' name='name' force=%.n]]
    !>  (parse:parse ['other-db' "drop view db..name"]) 
++  test-drop-view-4
  %+  expect-eq
    !>  ~[[%drop-view database-name='other-db' namespace='ns' name='name' force=%.y]]
    !>  (parse:parse ['other-db' "drop view force ns.name"])
++  test-drop-view-5
  %+  expect-eq
    !>  ~[[%drop-view database-name='other-db' namespace='ns' name='name' force=%.n]]
    !>  (parse:parse ['other-db' "drop view ns.name"])
++  test-drop-view-6
  %+  expect-eq
    !>  ~[[%drop-view database-name='other-db' namespace='ns' name='name' force=%.y]]
    !>  (parse:parse ['other-db' "drop view force ns.name"])
++  test-drop-view-7
  %+  expect-eq
    !>  ~[[%drop-view database-name='other-db' namespace='ns' name='name' force=%.n]]
    !>  (parse:parse ['other-db' "drop view ns.name"])
++  test-drop-view-8
  %+  expect-eq
    !>  ~[[%drop-view database-name='other-db' namespace='dbo' name='name' force=%.y]]
    !>  (parse:parse ['other-db' "DROP VIEW FORCE name"])
++  test-drop-view-9
  %+  expect-eq
   !>  ~[[%drop-view database-name='other-db' namespace='dbo' name='name' force=%.n]]
    !>  (parse:parse ['other-db' "DROP VIEW name"])
::
:: fail when database qualifier is not a face
++  test-drop-view-10
  %-  expect-fail
  |.  (parse:parse ['other-db' "DROP VIEW Db.ns.name"])

:: fail when namespace qualifier is not a face
++  test-drop-view-11
  %-  expect-fail
  |.  (parse:parse ['other-db' "DROP VIEW db.nS.name"])
::
:: fail when view name is not a face
++  test-drop-view-12
  %-  expect-fail
  |.  (parse:parse ['other-db' "DROP VIEW db.ns.nAme"])
--
