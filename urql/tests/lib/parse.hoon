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
:: create index
::
:: tests 1, 2, 3, 5, and extra whitespace characters, create index... db.ns.table, create unique index... db..table
++  test-create-index-1
  =/  expected1  [%create-index name='my-index' object-name=[%qualified-object ship=~ database='db' namespace='ns' name='table'] is-unique=%.n is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n] [%ordered-column column-name='col3' is-ascending=%.y]]]
  =/  expected2  [%create-index name='my-index' object-name=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n] [%ordered-column column-name='col3' is-ascending=%.y]]]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'db1') "CREATe \0d INdEX\09my-index On db.ns.table  ( col1 , col2\0a desc  , col3) \0a;\0a CREATE unIque INDEX my-index ON db..table (col1 , col2 desc, col3 )  ")
::
:: leading whitespace characters, end delimiter, create clustered index... ns.table
++  test-create-index-2
  =/  expected  [%create-index name='my-index' object-name=[%qualified-object ship=~ database='db1' namespace='ns' name='table'] is-unique=%.n is-clustered=%.y columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n] [%ordered-column column-name='col3' is-ascending=%.y]]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "  \0d CREATE clusTered INDEX my-index ON ns.table (col1, col2 desc, col3);")
::
:: create nonclustered index... table (col1 desc, col2 asc, col3)"
++  test-create-index-3
  =/  expected  [%create-index name='my-index' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] is-unique=%.n is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.n] [%ordered-column column-name='col2' is-ascending=%.y] [%ordered-column column-name='col3' is-ascending=%.y]]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "CREATE nonclusTered INDEX my-index ON table (col1 desc, col2 asc, col3)")
::
:: create unique clustered index... table (col1 desc)
++  test-create-index-4
  =/  expected  [%create-index name='my-index' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] is-unique=%.y is-clustered=%.y columns=~[[%ordered-column column-name='col1' is-ascending=%.n]]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "CREATE uniQue clusTered INDEX my-index ON table (col1 desc)")
::
:: create unique nonclustered index... table (col1)
++  test-create-index-5
  =/  expected  [%create-index name='my-index' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y]]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "CREATE uniQue nonclusTered INDEX my-index ON table (col1)")
::
:: fail when database qualifier is not a term
++  test-create-index-6
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "create index my-index ON Db.ns.table (col1)")
::
:: fail when namespace qualifier is not a term
++  test-create-index-7
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "create index my-index ON db.Ns.table (col1)")
::
:: fail when table name is not a term
++  test-create-index-8
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "create index my-index ON db.ns.Table (col1)")
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
:: drop index
::
:: tests 1, 2, 3, 5, and extra whitespace characters, db.ns.name, db..name
++  test-drop-index-1
  =/  expected1  [%drop-index name='my-index' object=[%qualified-object ship=~ database='db' namespace='ns' name='name']]
  =/  expected2  [%drop-index name='my-index' object=[%qualified-object ship=~ database='db' namespace='dbo' name='name']]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'other-db') "droP  inDex my-index On db.ns.name;droP  index my-index oN \0a db..name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, ns.name
++  test-drop-index-2
  %+  expect-eq
    !>  ~[[%drop-index name='my-index' object=[%qualified-object ship=~ database='other-db' namespace='ns' name='name']]]
    !>  (parse:parse(current-database 'other-db') "   \09drop\0d\09  index\0d my-index \0a On ns.name   ")
::
:: :: fail when database qualifier is not a term
++  test-drop-index-3
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP index my-index on Db.ns.name")
::
:: fail when database qualifier is not a term
++  test-drop-index-4
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP index my-index on Db.ns.name")
::
:: fail when namespace qualifier is not a term
++  test-drop-index-5
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP index my-index on db.nS.name")
::
:: fail when index name is not a term
++  test-drop-index-6
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP index my-index on db.ns.nAme")
::
:: fail when index name is qualified with ship
++  test-drop-index-7
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP index my-index on ~zod.db.ns.nAme")
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
  =/  expected1  [%drop-table table=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.y]
  =/  expected2  [%drop-table table=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.n]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'other-db') "droP  table FORce db.ns.name;droP  table  \0a db.ns.name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, force db..name
++  test-drop-table-2
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.y]]
    !>  (parse:parse(current-database 'other-db') "   \09drop\0d\09  table\0aforce db..name ")
::
:: db..name
++  test-drop-table-3
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.n]]
    !>  (parse:parse(current-database 'other-db') "drop table db..name")
::
:: force ns.name
++  test-drop-table-4
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='ns' name='name'] force=%.y]]
    !>  (parse:parse(current-database 'other-db') "drop table force ns.name")
::
:: ns.name
++  test-drop-table-5
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='ns' name='name'] force=%.n]]
    !>  (parse:parse(current-database 'other-db') "drop table ns.name")
::
:: force name
++  test-drop-table-6
  %+  expect-eq
    !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='dbo' name='name'] force=%.y]]
    !>  (parse:parse(current-database 'other-db') "DROP table FORCE name")
::
:: name
++  test-drop-table-7
  %+  expect-eq
   !>  ~[[%drop-table table=[%qualified-object ship=~ database='other-db' namespace='dbo' name='name'] force=%.n]]
    !>  (parse:parse(current-database 'other-db') "DROP table name")
::
:: fail when database qualifier is not a term
++  test-drop-table-8
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP table Db.ns.name")
::
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
:: fail when table name is qualified with ship
++  test-drop-table-11
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP table ~zod.db.ns.name")
::
:: drop view
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-drop-view-1
  =/  expected1  [%drop-view view=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.y]
  =/  expected2  [%drop-view view=[%qualified-object ship=~ database='db' namespace='ns' name='name'] force=%.n]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'other-db') "droP  View FORce db.ns.name;droP  View  \0a db.ns.name")
::
:: leading and trailing whitespace characters, end delimiter not required on single, force db..name
++  test-drop-view-2
  %+  expect-eq
    !>  ~[[%drop-view view=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.y]]
    !>  (parse:parse(current-database 'other-db') "   \09drop\0d\09  vIew\0aforce db..name ")
::
:: db..name
++  test-drop-view-3
  %+  expect-eq
    !>  ~[[%drop-view view=[%qualified-object ship=~ database='db' namespace='dbo' name='name'] force=%.n]]
    !>  (parse:parse(current-database 'other-db') "drop view db..name")
::
:: force ns.name
++  test-drop-view-4
  %+  expect-eq
    !>  ~[[%drop-view view=[%qualified-object ship=~ database='other-db' namespace='ns' name='name'] force=%.y]]
    !>  (parse:parse(current-database 'other-db') "drop view force ns.name")
::
:: ns.name
++  test-drop-view-5
  %+  expect-eq
    !>  ~[[%drop-view view=[%qualified-object ship=~ database='other-db' namespace='ns' name='name'] force=%.n]]
    !>  (parse:parse(current-database 'other-db') "drop view ns.name")
::
:: force name
++  test-drop-view-6
  %+  expect-eq
    !>  ~[[%drop-view view=[%qualified-object ship=~ database='other-db' namespace='dbo' name='name'] force=%.y]]
    !>  (parse:parse(current-database 'other-db') "DROP VIEW FORCE name")
::
:: name
++  test-drop-view-7
  %+  expect-eq
    !>  ~[[%drop-view view=[%qualified-object ship=~ database='other-db' namespace='dbo' name='name'] force=%.n]]
    !>  (parse:parse(current-database 'other-db') "DROP VIEW name")
::
:: fail when database qualifier is not a term
++  test-drop-view-8
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP VIEW Db.ns.name")
::
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
:: fail when view name is qualified with ship
++  test-drop-view-11
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP view ~zod.db.ns.name")
::
:: grant permission
::
:: tests 1, 2, 3, 5, and extra whitespace characters, ship-database, parent-database
++  test-grant-1
  =/  expected1  [%grant permission=%adminread to=~[~sampel-palnet] grant-target=[%database 'db']]
  =/  expected2  [%grant permission=%adminread to=%parent grant-target=[%database 'db']]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'other-db') "grant  adminread\0a tO \0d ~sampel-palnet on\0a database  db;Grant adminRead to paRent on dataBase db")
::
:: leading and trailing whitespace characters, end delimiter not required on single, ship-qualified-ns
++  test-grant-2
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~sampel-palnet] grant-target=[%namespace 'db' 'ns']]]
    !>  (parse:parse(current-database 'db2') "   \09Grant Readwrite   to ~sampel-palnet on namespace db.ns ")
::
:: ship unqualified ns
++  test-grant-3
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~sampel-palnet] grant-target=[%namespace 'db2' 'ns']]]
    !>  (parse:parse(current-database 'db2') "Grant Readwrite to ~sampel-palnet on namespace ns")
::
:: siblings qualified ns
++  test-grant-4
  %+  expect-eq
    !>  ~[[%grant permission=%readonly to=%siblings grant-target=[%namespace 'db' 'ns']]]
    !>  (parse:parse(current-database 'db2') "grant readonly to SIBLINGS on namespace db.ns")
::
:: moons unqualified ns
++  test-grant-5
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=%moons grant-target=[%namespace 'db2' 'ns']]]
    !>  (parse:parse(current-database 'db2') "Grant Readwrite to moonS on namespace ns")
::
:: ship db.ns.table
++  test-grant-6
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~sampel-palnet] grant-target=[%qualified-object ship=~ database='db' namespace='ns' name='table']]]
    !>  (parse:parse(current-database 'db2') "Grant Readwrite to ~sampel-palnet on db.ns.table")
::
:: parent db.ns.table
++  test-grant-7
  %+  expect-eq
    !>  ~[[%grant permission=%adminread to=%parent grant-target=[%qualified-object ship=~ database='db' namespace='ns' name='table']]]
    !>  (parse:parse(current-database 'db2') "grant adminread to parent on db.ns.table")
::
:: ship db..table
++  test-grant-8
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~sampel-palnet] grant-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "Grant Readwrite to ~sampel-palnet on db..table")
::
:: parent on db..table
++  test-grant-9
  %+  expect-eq
    !>  ~[[%grant permission=%adminread to=%parent grant-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "grant adminread to parent on db..table")
::
:: ship table
++  test-grant-10
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~sampel-palnet] grant-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "Grant Readwrite to ~sampel-palnet on table")
::
:: ship list table
++  test-grant-11
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~zod ~bus ~nec ~sampel-palnet] grant-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "grant Readwrite to ~zod,~bus,~nec,~sampel-palnet on table")
::
:: ship list on db..table
++  test-grant-12
  %+  expect-eq
    !>  ~[[%grant permission=%adminread to=~[~zod ~bus ~nec ~sampel-palnet] grant-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "grant adminread to ~zod,~bus,~nec,~sampel-palnet on db..table")
::
:: ship list spaced, table
++  test-grant-13
  %+  expect-eq
    !>  ~[[%grant permission=%readwrite to=~[~zod ~bus ~nec ~sampel-palnet] grant-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "grant Readwrite to  ~zod,\0a~bus ,~nec , ~sampel-palnet on table")
::
:: ship list spaced, on db..table
++  test-grant-14
  %+  expect-eq
    !>  ~[[%grant permission=%adminread to=~[~zod ~bus ~nec ~sampel-palnet] grant-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "grant adminread to ~zod , ~bus, ~nec ,~sampel-palnet on db..table")
::
:: parent table
++  test-grant-15
  %+  expect-eq
    !>  ~[[%grant permission=%adminread to=%parent grant-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "grant adminread to parent on table")
::
:: fail when database qualifier is not a term
++  test-grant-16
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "grant adminread to parent on Db.ns.table")
::
:: fail when namespace qualifier is not a term
++  test-grant-17
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "grant adminread to parent on db.Ns.table")
::
:: fail when table name is not a term
++  test-grant-18
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "grant adminread to parent on Table")
::
:: fail when table name is qualified with ship
++  test-grant-19
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "grant adminread to parent ~zod.db.ns.name")
::
:: revoke permission
::
:: tests 1, 2, 3, 5, and extra whitespace characters, ship-database, parent-database
++  test-revoke-1
  =/  expected1  [%revoke permission=%adminread to=~[~sampel-palnet] revoke-target=[%database 'db']]
  =/  expected2  [%revoke permission=%adminread to=%parent revoke-target=[%database 'db']]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'other-db') "revoke  adminread\0a From \0d ~sampel-palnet on\0a database  db;Revoke adminRead fRom paRent on dataBase db")
::
:: leading and trailing whitespace characters, end delimiter not required on single, ship-qualified-ns
++  test-revoke-2
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite to=~[~sampel-palnet] revoke-target=[%namespace 'db' 'ns']]]
    !>  (parse:parse(current-database 'db2') "   \09ReVoke Readwrite   From ~sampel-palnet on namespace db.ns ")
::
:: ship unqualified ns
++  test-revoke-3
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite to=~[~sampel-palnet] revoke-target=[%namespace 'db2' 'ns']]]
    !>  (parse:parse(current-database 'db2') "Revoke Readwrite from ~sampel-palnet on namespace ns")
::
:: siblings qualified ns
++  test-revoke-4
  %+  expect-eq
    !>  ~[[%revoke permission=%readonly to=%siblings revoke-target=[%namespace 'db' 'ns']]]
    !>  (parse:parse(current-database 'db2') "revoke readonly from SIBLINGS on namespace db.ns")
::
:: moons unqualified ns
++  test-revoke-5
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite to=%moons revoke-target=[%namespace 'db2' 'ns']]]
    !>  (parse:parse(current-database 'db2') "Revoke Readwrite from moonS on namespace ns")
::
:: ship db.ns.table
++  test-revoke-6
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite to=~[~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db' namespace='ns' name='table']]]
    !>  (parse:parse(current-database 'db2') "Revoke Readwrite from ~sampel-palnet on db.ns.table")
::
:: all from all db.ns.table
++  test-revoke-7
  %+  expect-eq
    !>  ~[[%revoke permission=%all from=%all revoke-target=[%qualified-object ship=~ database='db' namespace='ns' name='table']]]
    !>  (parse:parse(current-database 'db2') "revoke all from all on db.ns.table")
::
:: ship db..table
++  test-revoke-8
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite from=~[~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "Revoke Readwrite from ~sampel-palnet on db..table")
::
:: parent on db..table
++  test-revoke-9
  %+  expect-eq
    !>  ~[[%revoke permission=%adminread from=%parent revoke-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "revoke adminread from parent on db..table")
::
:: single ship table
++  test-revoke-10
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite from=~[~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "Revoke Readwrite from ~sampel-palnet on table")
::
:: ship list table
++  test-revoke-11
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite from=~[~zod ~sampel-palnet-sampel-palnet ~nec ~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "Revoke Readwrite from ~zod,~sampel-palnet-sampel-palnet,~nec,~sampel-palnet on table")
::
:: ship list on db..table
++  test-revoke-12
  %+  expect-eq
    !>  ~[[%revoke permission=%adminread from=~[~zod ~bus ~nec ~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "revoke adminread from ~zod,~bus,~nec,~sampel-palnet on db..table")
::
:: ship list spaced, table
++  test-revoke-13
  %+  expect-eq
    !>  ~[[%revoke permission=%readwrite from=~[~zod ~bus ~nec ~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "Revoke Readwrite from  ~zod,\0a~bus ,~nec , ~sampel-palnet on table")
::
:: ship list spaced, on db..table
++  test-revoke-14
  %+  expect-eq
    !>  ~[[%revoke permission=%adminread from=~[~zod ~bus ~nec ~sampel-palnet] revoke-target=[%qualified-object ship=~ database='db' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "revoke adminread from ~zod , ~bus, ~nec ,~sampel-palnet on db..table")
::
:: parent table
++  test-revoke-15
  %+  expect-eq
    !>  ~[[%revoke permission=%adminread from=%parent revoke-target=[%qualified-object ship=~ database='db2' namespace='dbo' name='table']]]
    !>  (parse:parse(current-database 'db2') "revoke adminread from parent on table")
::
:: fail when database qualifier is not a term
++  test-revoke-16
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "revoke adminread from parent on Db.ns.table")
::
:: fail when namespace qualifier is not a term
++  test-revoke-17
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "revoke adminread from parent on db.Ns.table")
::
:: fail when table name is not a term
++  test-revoke-18
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "revoke adminread from parent on Table")
::
:: fail when table name is qualified with ship
++  test-revoke-19
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "revoke adminread from parent on ~zod.db.ns.name")
::
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
::
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
