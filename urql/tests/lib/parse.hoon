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
    |.  (parse:parse(current-database 'oTher-db') "cReate\0d\09  namespace my-namespace")
::
:: create database
::
:: tests 1, 3, and extra whitespace characters
++  test-create-database-1
  %+  expect-eq
    !>  ~[[%create-database name='my-database']]
    !>  (parse:parse(current-database 'dummy') "cReate datAbase \0a  my-database ")
::
:: subsequent commands ignored
++  test-create-database-2
  %+  expect-eq
    !>  ~[[%create-database name='my-database']]
    !>  (parse:parse(current-database 'dummy') "cReate datAbase \0a  my-database; cReate namesPace my-db.another-namespace")
::
:: fail when database name is not a term
++  test-create-database-3
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "cReate datAbase  My-database")
::
:: fail when commands are prior to create database
++  test-create-database-4
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "create namespace my-namespace ; cReate datAbase my-database")
::
:: create namespace
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-create-namespace-1
  =/  expected1  [%create-namespace database-name='other-db' name='my-namespace']
  =/  expected2  [%create-namespace database-name='my-db' name='another-namespace']
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'other-db') "cReate\0d\09  namespace my-namespace ; cReate namesPace my-db.another-namespace")
::
:: leading and trailing whitespace characters, end delimiter not required on single
++  test-create-namespace-2
  %+  expect-eq
    !>  ~[[%create-namespace database-name='other-db' name='my-namespace']]
    !>  (parse:parse(current-database 'other-db') "   \09cReate\0d\09  namespace my-namespace ")
::
:: fail when database qualifier is not a term
++  test-create-namespace-3
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "cReate namesPace Bad-face.another-namespace")
::
:: fail when namespace is not a term
++  test-create-namespace-4
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "cReate namesPace my-db.Bad-face")
::
:: drop database
::
:: tests 1, 2, 3, 5, and extra whitespace characters, force db.name, name
++  test-drop-database-1
  =/  expected1  [%drop-database name='name' force=%.n]
  =/  expected2  [%drop-database name='name' force=%.y]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'other-db') "droP  Database  name;droP \0d\09 DataBase FORce  \0a name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, force name
++  test-drop-database-2
  %+  expect-eq
    !>  ~[[%drop-database name='name' force=%.y]]
    !>  (parse:parse(current-database 'other-db') "   \09drOp\0d\09  dAtabaSe\0a force name ")
::
:: fail when database is not a term
++  test-drop-database-3
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP DATABASE nAme")
::
:: drop namespace
::
:: tests 1, 2, 3, 5, and extra whitespace characters, force db.name, name
++  test-drop-namespace-1
  =/  expected1  [%drop-namespace database-name='db' name='name' force=%.n]
  =/  expected2  [%drop-namespace database-name='other-db' name='name' force=%.y]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'other-db') "droP  Namespace  db.name;droP \0d\09 Namespace FORce  \0a name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, force name
++  test-drop-namespace-2
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='other-db' name='name' force=%.y]]
    !>  (parse:parse(current-database 'other-db') "   \09drOp\0d\09  naMespace\0a force name ")
  ::
  :: db.name
++  test-drop-namespace-3
  %+  expect-eq
    !>  ~[[%drop-namespace database-name='db' name='name' force=%.n]]
    !>  (parse:parse(current-database 'other-db') "drop namespace db.name")
::
:: fail when database qualifier is not a term
++  test-drop-namespace-4
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP NAMESPACE Db.name")
::
:: fail when namespace is not a term
++  test-drop-namespace-5
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP NAMESPACE nAme")
::
:: drop table
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-drop-table-1
  =/  expected1  [%drop-table database-name='db' namespace='ns' name='name' force=%.y]
  =/  expected2  [%drop-table database-name='db' namespace='ns' name='name' force=%.n]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'other-db') "droP  table FORce db.ns.name;droP  table  \0a db.ns.name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, force db..name
++  test-drop-table-2
  %+  expect-eq
    !>  ~[[%drop-table database-name='db' namespace='dbo' name='name' force=%.y]]
    !>  (parse:parse(current-database 'other-db') "   \09drop\0d\09  table\0aforce db..name ")
::
:: db..name
++  test-drop-table-3
  %+  expect-eq
    !>  ~[[%drop-table database-name='db' namespace='dbo' name='name' force=%.n]]
    !>  (parse:parse(current-database 'other-db') "drop table db..name")
::
:: force ns.name
++  test-drop-table-4
  %+  expect-eq
    !>  ~[[%drop-table database-name='other-db' namespace='ns' name='name' force=%.y]]
    !>  (parse:parse(current-database 'other-db') "drop table force ns.name")
::
:: ns.name
++  test-drop-table-5
  %+  expect-eq
    !>  ~[[%drop-table database-name='other-db' namespace='ns' name='name' force=%.n]]
    !>  (parse:parse(current-database 'other-db') "drop table ns.name")
::
:: force name
++  test-drop-table-6
  %+  expect-eq
    !>  ~[[%drop-table database-name='other-db' namespace='dbo' name='name' force=%.y]]
    !>  (parse:parse(current-database 'other-db') "DROP table FORCE name")
:: name
++  test-drop-table-7
  %+  expect-eq
   !>  ~[[%drop-table database-name='other-db' namespace='dbo' name='name' force=%.n]]
    !>  (parse:parse(current-database 'other-db') "DROP table name")
::
:: fail when database qualifier is not a term
++  test-drop-table-8
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP table Db.ns.name")

:: fail when namespace qualifier is not a term
++  test-drop-table-9
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP table db.nS.name")
::
:: fail when table name is not a term
++  test-drop-table-10
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP table db.ns.nAme")
::
:: drop view
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-drop-view-1
  =/  expected1  [%drop-view database-name='db' namespace='ns' name='name' force=%.y]
  =/  expected2  [%drop-view database-name='db' namespace='ns' name='name' force=%.n]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'other-db') "droP  View FORce db.ns.name;droP  View  \0a db.ns.name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, force db..name
++  test-drop-view-2
  %+  expect-eq
    !>  ~[[%drop-view database-name='db' namespace='dbo' name='name' force=%.y]]
    !>  (parse:parse(current-database 'other-db') "   \09drop\0d\09  vIew\0aforce db..name ")
  ::
  :: db..name
++  test-drop-view-3
  %+  expect-eq
    !>  ~[[%drop-view database-name='db' namespace='dbo' name='name' force=%.n]]
    !>  (parse:parse(current-database 'other-db') "drop view db..name")
::
:: force ns.name
++  test-drop-view-4
  %+  expect-eq
    !>  ~[[%drop-view database-name='other-db' namespace='ns' name='name' force=%.y]]
    !>  (parse:parse(current-database 'other-db') "drop view force ns.name")
::
:: ns.name
++  test-drop-view-5
  %+  expect-eq
    !>  ~[[%drop-view database-name='other-db' namespace='ns' name='name' force=%.n]]
    !>  (parse:parse(current-database 'other-db') "drop view ns.name")
::
:: force name
++  test-drop-view-6
  %+  expect-eq
    !>  ~[[%drop-view database-name='other-db' namespace='dbo' name='name' force=%.y]]
    !>  (parse:parse(current-database 'other-db') "DROP VIEW FORCE name")
::
:: name
++  test-drop-view-7
  %+  expect-eq
    !>  ~[[%drop-view database-name='other-db' namespace='dbo' name='name' force=%.n]]
    !>  (parse:parse(current-database 'other-db') "DROP VIEW name")
::
:: fail when database qualifier is not a term
++  test-drop-view-8
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP VIEW Db.ns.name")
:: fail when namespace qualifier is not a term
++  test-drop-view-9
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP VIEW db.nS.name")
::
:: fail when view name is not a term
++  test-drop-view-10
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP VIEW db.ns.nAme")
::
:: truncate table
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-truncate-table-1
  =/  expected1  [%truncate-table table=[%qualified-object ship=[~ ~zod] database='db' namespace='ns' name='name']]
  =/  expected2  [%truncate-table table=[%qualified-object ship=[~ ~sampel-palnet] database='db' namespace='dbo' name='name']]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'dummy') " \0atrUncate TAble\0d ~zod.db.ns.name\0a; truncate table ~sampel-palnet.db..name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, db.ns.name
++  test-truncate-table-2
  %+  expect-eq
    !>  ~[[%truncate-table table=[%qualified-object ship=~ database='db' namespace='ns' name='name']]]
    !>  (parse:parse(current-database 'dummy') "   \09truncate\0d\09  TaBle\0a db.ns.name ")
::
:: db..name
++  test-truncate-table-3
  %+  expect-eq
    !>  ~[[%truncate-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='name']]]
    !>  (parse:parse(current-database 'dummy') "truncate table db..name")
::
:: ns.name
++  test-truncate-table-4
  %+  expect-eq
    !>  ~[[%truncate-table table=[%qualified-object ship=~ database='dummy' namespace='ns' name='name']]]
    !>  (parse:parse(current-database 'dummy') "truncate table ns.name")
::
:: name
++  test-truncate-table-5
  %+  expect-eq
   !>  ~[[%truncate-table table=[%qualified-object ship=~ database='dummy' namespace='dbo' name='name']]]
   !>  (parse:parse(current-database 'dummy') "truncate table name")
::
:: fail when database qualifier is not a term
++  test-truncate-table-6
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "truncate table Db.ns.name")

:: fail when namespace qualifier is not a term
++  test-truncate-table-7
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "truncate table db.nS.name")
::
:: fail when view name is not a term
++  test-truncate-table-8
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "truncate table db.ns.nAme")
::
:: fail when view name is not a term
++  test-truncate-table-9
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "truncate table db.ns.nAme")
::
:: fail when ship is invalid
++  test-truncate-table-10
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "truncate table ~shitty-shippp db.ns.nAme")
--
