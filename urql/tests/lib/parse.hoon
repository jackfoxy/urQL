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
++  test-fail-current-database
    %-  expect-fail
    |.  (parse:parse(current-database 'oTher-db') "cReate\0d\09  namespace my-namespace")
::
:: alter index
::
:: tests 1, 2, 3, 5, and extra whitespace characters, alter index... db.ns.index db.ns.table columns action; alter index db..index db..table one column
++  test-alter-index-1
  =/  expected1  [%alter-index name=[%qualified-object ship=~ database='db' namespace='ns' name='my-index'] object=[%qualified-object ship=~ database='db' namespace='ns' name='table'] columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n] [%ordered-column column-name='col3' is-ascending=%.y]] action=%disable]
  =/  expected2  [%alter-index name=[%qualified-object ship=~ database='db' namespace='dbo' name='my-index'] object=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] columns=~[[%ordered-column column-name='col1' is-ascending=%.y]] action=%rebuild]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'db1') "aLter \0d INdEX\09db.ns.my-index On db.ns.table  ( col1  asc , col2\0a desc  , col3) \0a dIsable \0a;\0a aLter \0d INdEX\09db..my-index On db..table  ( col1  asc ) \0a \0a rEBuild ")
::
:: alter index 1 column without action
++  test-alter-index-2
  =/  expected  [%alter-index name=[%qualified-object ship=~ database='db' namespace='ns' name='my-index'] object=[%qualified-object ship=~ database='db' namespace='ns' name='table'] columns=~[[%ordered-column column-name='col1' is-ascending=%.y]] action=%rebuild]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "ALTER INDEX db.ns.my-index ON db.ns.table (col1)")
::
:: leading whitespace characters, end delimiter, alter ns.index ns.table columns no action
++  test-alter-index-3
  =/  expected  [%alter-index name=[%qualified-object ship=~ database='db1' namespace='ns' name='my-index'] object=[%qualified-object ship=~ database='db1' namespace='ns' name='table'] columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n] [%ordered-column column-name='col3' is-ascending=%.y]] action=%rebuild]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "  \0d alter INDEX ns.my-index ON ns.table (col1, col2 desc, col3 asc);")
::
:: alter index table no columns, action only
++  test-alter-index-4
  =/  expected  [%alter-index name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-index'] object=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~ action=%resume]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "ALTER INDEX my-index ON table RESUME")
::
:: fail when namespace qualifier is not a term
++  test-fail-alter-index-5
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "alter index my-index ON db.Ns.table (col1, col2) resume")
::
:: fail when table name is not a term
++  test-fail-alter-index-6
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "alter index my-index ON db.ns.Table (col1, col2) resume")
::
::
:: alter namespace
::
:: tests 1, 2, 3, 5, and extra whitespace characters, alter namespace db.ns db.ns2.table ; ns db..table
++  test-alter-namespace-1
  =/  expected1  [%alter-namespace database-name='db' source-namespace='ns' object-type=%table target-namespace='ns2' target-name='table']
  =/  expected2  [%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table']
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'db1') " ALtER NAmESPACE   db.ns   TRANsFER   TaBLE  db.ns2.table \0a;\0a ALTER NAMESPACE ns TRANSFER TABLE db..table ")
::
:: alter namespace  ns table
++  test-alter-namespace-2
  =/  expected  [%alter-namespace database-name='db1' source-namespace='ns' object-type=%table target-namespace='dbo' target-name='table']  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "ALTER NAMESPACE ns TRANSFER TABLE table ")
::
:: fail when namespace qualifier is not a term
++  test-fail-alter-namespace-3
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "ALTER NAMESPACE db.nS TRANSFER TABLE db.ns2.table")
::
:: fail when table name is not a term
++  test-fail-alter-namespace-4
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "ALTER NAMESPACE db.ns TRANSFER TABLE db.ns2.tAble")
::
::
:: alter table
::
:: tests 1, 2, 3, 5, and extra whitespace characters 
:: alter column db.ns.table 3 columns ; alter column db..table 1 column
++  test-alter-table-1
  =/  expected1  [%alter-table table=[%qualified-object ship=~ database='db' namespace='ns' name='table'] alter-columns=~ add-columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~]
  =/  expected2  [%alter-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] alter-columns=~ add-columns=~[[%column name='col1' column-type='@t']] drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'db1') " ALtER  TaBLE  db.ns.table  AdD  COlUMN  ( col1  @t ,  col2  @p ,  col3  @ud ) \0a;\0a ALTER TABLE db..table ADD COLUMN (col1 @t) ")
::
:: alter column table 3 columns
++  test-alter-table-2
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "ALTER TABLE table ALTER COLUMN (col1 @t, col2 @p, col3 @ud)")
::
:: alter column table 1 column
++  test-alter-table-3
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~[[%column name='col1' column-type='@t']] add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "ALTER TABLE table ALTER COLUMN (col1 @t)")
::
:: drop column table 3 columns
++  test-alter-table-4
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=['col1' 'col2' 'col3' ~] add-foreign-keys=~ drop-foreign-keys=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "ALTER TABLE table DROP COLUMN (col1, col2, col3)")
::
:: drop column table 1 column
++  test-alter-table-5
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=['col1' ~] add-foreign-keys=~ drop-foreign-keys=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "ALTER TABLE table DROP COLUMN (col1)")
::
:: add 2 foreign keys, extra spaces and mixed case key words
++  test-alter-table-6
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]] [%foreign-key name='fk2' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table2'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]]] drop-foreign-keys=~]
  =/  urql  "ALTER TABLE table ADD FOREIGN KEY fk  ( col1 , col2  desc )  reFerences  fk-table  ( col19 ,  col20 )  On  dELETE  CAsCADE  oN  UPdATE  CAScADE, fk2  ( col1 ,  col2  desc )  reFerences  fk-table2  ( col19 ,  col20 )  On  dELETE  CAsCADE  oN  UPdATE  CAScADE "
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') urql)
::
:: 
::++  test-alter-table-
::  =/  expected  
::  %+  expect-eq
::    !>  ~[expected]
::    !>  (parse:parse(current-database 'db1') "")
::
:: 
::++  test-alter-table-
::  =/  expected  
::  %+  expect-eq
::    !>  ~[expected]
::    !>  (parse:parse(current-database 'db1') "")
::
:: 
::++  test-alter-table-
::  =/  expected  
::  %+  expect-eq
::    !>  ~[expected]
::    !>  (parse:parse(current-database 'db1') "")

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
++  test-fail-create-index-6
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "create index my-index ON Db.ns.table (col1)")
::
:: fail when namespace qualifier is not a term
++  test-fail-create-index-7
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "create index my-index ON db.Ns.table (col1)")
::
:: fail when table name is not a term
++  test-fail-create-index-8
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
++  test-fail-create-namespace-3
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "cReate namesPace Bad-face.another-namespace")
::
:: fail when namespace is not a term
++  test-fail-create-namespace-4
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "cReate namesPace my-db.Bad-face")
::
:: create table
::
:: tests 1, 2, 3, 5, and extra whitespace characters, db.ns.table clustered on delete cascade on update cascade; db..table nonclustered on update cascade on delete cascade
++  test-create-table-1
  =/  expected1  [%create-table table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-ns-my-table' object-name=[%qualified-object ship=~ database='db' namespace='ns' name='my-table'] is-unique=%.y is-clustered=%.y columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.y]]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table'] columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db' namespace='dbo' name='fk-table'] reference-columns=~['col19' 'col20'] referential-integrity=~[%delete-cascade %update-cascade]]]]
  =/  expected2  [%create-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.y]]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db' namespace='dbo' name='fk-table'] reference-columns=~['col19' 'col20'] referential-integrity=~[%delete-cascade %update-cascade]]]]
  =/  urql1  "crEate  taBle  db.ns.my-table  ( col1  @t ,  col2  @p ,  col3  @ud )  pRimary  kEy  clusTered  ( col1 ,  col2 )  foReign  KeY  fk  ( col1 ,  col2  desc )  reFerences  fk-table  ( col19 ,  col20 )  On  dELETE  CAsCADE  oN  UPdATE  CAScADE "
  =/  urql2  "crEate  taBle  db..my-table  ( col1  @t ,  col2  @p ,  col3  @ud )  pRimary  kEy  nonclusTered  ( col1 ,  col2 )  foReign  KeY  fk  ( col1 ,  col2  desc )  reFerences  fk-table  ( col19 ,  col20 )  On  UPdATE  CAsCADE  oN  dELETE  CAScADE "
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'db1') (weld urql1 (weld "\0a;\0a" urql2)))
::
:: leading whitespace characters, whitespace after end delimiter, create nonclustered table... table ... references  ns.fk-table  on update no action on delete no action
++  test-create-table-2
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.y]]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='ns' name='fk-table'] reference-columns=~['col19' 'col20'] referential-integrity=~]]]
  =/  urql2  "  \0acreate table my-table (col1 @t,col2 @p,col3 @ud) primary key nonclustered (col1, col2) foreign key fk (col1,col2 desc) reFerences ns.fk-table (col19, col20) on update no action on delete no action; "
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') urql2)
::
:: create table... table ... references  ns.fk-table  on update no action on delete cascade
++  test-create-table-3
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.y]]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='ns' name='fk-table'] reference-columns=~['col19' 'col20'] referential-integrity=~[%delete-cascade]]]]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1, col2) foreign key fk (col1,col2 desc) reFerences ns.fk-table (col19, col20) on update no action on delete cascade"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') urql)
::
:: create table... table ... references fk-table on update cascade on delete no action
++  test-create-table-4
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.y]]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=~['col19' 'col20'] referential-integrity=~[%update-cascade]]]]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1, col2) foreign key fk (col1,col2 desc) reFerences fk-table (col19, col20) on update cascade on delete no action"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') urql)
::
:: create table... table ... single column indices... references fk-table on update cascade
++  test-create-table-5
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y]]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column column-name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=~['col20'] referential-integrity=~[%update-cascade]]]]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1) foreign key fk (col2 desc) reFerences fk-table (col20) on update cascade"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') urql)
::
:: create table... table ... single column indices... references fk-table
++  test-create-table-6
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y]]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column column-name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=~['col20'] referential-integrity=~]]]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1) foreign key fk (col2 desc) reFerences fk-table (col20) "
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') urql)
::
:: create table...  no foreign key
++  test-create-table-7
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.y]]] foreign-keys=~]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1,col2)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') urql)
::
:: create table...  2 foreign keys
++  test-create-table-8
  =/  expected  [%create-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%column name='col1' column-type='@t'] [%column name='col2' column-type='@p'] [%column name='col3' column-type='@ud']] primary-key=[%create-index name='ix-primary-dbo-my-table' object-name=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] is-unique=%.y is-clustered=%.n columns=~[[%ordered-column column-name='col1' is-ascending=%.y]]] foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column column-name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=['col20' ~] referential-integrity=~] [%foreign-key name='fk2' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~[[%ordered-column column-name='col1' is-ascending=%.y] [%ordered-column column-name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table2'] reference-columns=['col19' 'col20' ~] referential-integrity=~]]]
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1) foreign key fk (col2 desc) reFerences fk-table (col20), fk2 (col1, col2 desc) reFerences fk-table2 (col19, col20)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') urql) 
::
:: fail when database qualifier on foreign key table db.ns.fk-table
++  test-fail-create-table-9
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1) foreign key fk (col2 desc) reFerences db.ns.fk-table (col20) "
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') urql)
::
:: fail when database qualifier on foreign key table db..fk-table
++  test-fail-create-table-10
  =/  urql  "create table my-table (col1 @t,col2 @p,col3 @ud) primary key (col1) foreign key fk (col2 desc) reFerences db..fk-table (col20) "
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') urql)
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
++  test-fail-drop-database-3
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
++  test-fail-drop-index-3
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP index my-index on Db.ns.name")
::
:: fail when database qualifier is not a term
++  test-fail-drop-index-4
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP index my-index on Db.ns.name")
::
:: fail when namespace qualifier is not a term
++  test-fail-drop-index-5
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP index my-index on db.nS.name")
::
:: fail when index name is not a term
++  test-fail-drop-index-6
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP index my-index on db.ns.nAme")
::
:: fail when index name is qualified with ship
++  test-fail-drop-index-7
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
++  test-fail-drop-namespace-4
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP NAMESPACE Db.name")
::
:: fail when namespace is not a term
++  test-fail-drop-namespace-5
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
++  test-fail-drop-table-8
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP table Db.ns.name")
::
:: fail when namespace qualifier is not a term
++  test-drop-table-9
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP table db.nS.name")
::
:: fail when table name is not a term
++  test-fail-drop-table-10
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP table db.ns.nAme")
::
:: fail when table name is qualified with ship
++  test-fail-drop-table-11
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
++  test-fail-drop-view-8
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP VIEW Db.ns.name")
::
:: fail when namespace qualifier is not a term
++  test-fail-drop-view-9
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP VIEW db.nS.name")
::
:: fail when view name is not a term
++  test-fail-drop-view-10
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "DROP VIEW db.ns.nAme")
::
:: fail when view name is qualified with ship
++  test-fail-drop-view-11
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
++  test-fail-grant-16
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "grant adminread to parent on Db.ns.table")
::
:: fail when namespace qualifier is not a term
++  test-fail-grant-17
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "grant adminread to parent on db.Ns.table")
::
:: fail when table name is not a term
++  test-fail-grant-18
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "grant adminread to parent on Table")
::
:: fail when table name is qualified with ship
++  test-fail-grant-19
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "grant adminread to parent ~zod.db.ns.name")
::
:: insert
::
:: tests 1, 2, 3, 5, and extra whitespace characters, db.ns.table, db..table, colum list, two value rows, one value row, no space around ; delimeter
:: NOTE: the parser does not check:
::       1) validity of columns re parent table
::       2) match column count to values count
::       3) enforce consistent value counts across rows
++  test-insert-1
  =/  expected1  [%insert table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table'] columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~] values=[%expressions ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]]]]]
  =/  expected2  [%insert table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~] values=[%expressions ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]]]]]
  =/  urql1  " iNsert  iNto  db.ns.my-table  ".
"( col1 ,  col2 ,  col3 ,  col4 ,  col5 ,  col6 ,  col7 ,  col8 ,  col9 )".
" Values  ('cord',3.14,-20,20,3.14,~nomryg-nilref,-3.14, 'cor\\'d', --3)".
"  (Default,.195.198.143.90, 195.198.143.900)"
  =/  urql2  "insert into db..my-table ".
"(col1, col2, col3, col4, col5, col6, col7, col8, col9)".
"valueS ('cord',3.14,-20,20,3.14,~nomryg-nilref,-3.14, 'cor\\'d', --3)"
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'other-db') (weld urql1 (weld ";" urql2)))
::
:: table, no columns, 3 rows
++  test-insert-2
  =/  expected  [%insert table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~ values=[%expressions ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]] ~[[~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]]
  =/  urql  "insert into my-table ".
"values ('cord',3.14,-20,20,3.14,~nomryg-nilref,-3.14, 'cor\\'d', --3)".
" (default,.195.198.143.90, 195.198.143.900)".
" (2.222,2222,195.198.143.900,3.14,-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') urql)
::
:: every column type, no spaces around values
++  test-insert-3
  =/  expected  [%insert table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table'] columns=~ values=[%expressions ~[~[[~.t 1.685.221.219] [~.p 28.242.037] [~.p 28.242.037] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.dr 114.450.695.119.985.999.668.576.256] [~.dr 114.450.695.119.985.999.668.576.256] [~.if 3.284.569.946] [~.is 123.543.654.234] [~.f 0] [~.f 1] [~.f 0] [~.f 1] [~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]]
  =/  urql  "insert into db.ns.my-table ".
"values ('cord',~nomryg-nilref,nomryg-nilref,~2020.12.25..7.15.0..1ef5,2020.12.25..7.15.0..1ef5,".
"~d71.h19.m26.s24..9d55, d71.h19.m26.s24..9d55,.195.198.143.90,.0.0.0.0.0.1c.c3c6.8f5a,y,n,Y,N,".
"2.222,2222,195.198.143.900,3.14,-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') urql)
::
:: every column type, no spaces on all sides of values, comma inside cord
++  test-insert-4
  =/  expected  [%insert table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table'] columns=~ values=[%expressions ~[~[[~.t 430.242.426.723] [~.p 28.242.037] [~.p 28.242.037] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.dr 114.450.695.119.985.999.668.576.256] [~.dr 114.450.695.119.985.999.668.576.256] [~.if 3.284.569.946] [~.is 123.543.654.234] [~.f 0] [~.f 1] [~.f 0] [~.f 1] [~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]]
  =/  urql  "insert into db.ns.my-table ".
"values ( 'cor,d' , ~nomryg-nilref , nomryg-nilref , ~2020.12.25..7.15.0..1ef5 , 2020.12.25..7.15.0..1ef5 , ".
"~d71.h19.m26.s24..9d55 ,  d71.h19.m26.s24..9d55 , .195.198.143.90 , .0.0.0.0.0.1c.c3c6.8f5a , y , n , Y , N , ".
"2.222 , 2222 , 195.198.143.900 , 3.14 , -3.14 , ~3.14 , ~-3.14 , 0x12.6401 , 10.1011 , -20 , --20 , e2O.l4Xpm , pm.l4e2O.l4Xpm )"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') urql)
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
++  test-fail-revoke-16
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "revoke adminread from parent on Db.ns.table")
::
:: fail when namespace qualifier is not a term
++  test-fail-revoke-17
  %-  expect-fail
  |.  (parse:parse(current-database 'db2') "revoke adminread from parent on db.Ns.table")
::
:: fail when table name is not a term
++  test-fail-revoke-18
  %-  expect-fail
  |.  (parse:parse(current-database 'other-db') "revoke adminread from parent on Table")
::
:: fail when table name is qualified with ship
++  test-fail-revoke-19
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
++  test-fail-truncate-table-6
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "truncate table Db.ns.name")
::
:: fail when namespace qualifier is not a term
++  test-fail-truncate-table-7
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "truncate table db.nS.name")
::
:: fail when view name is not a term
++  test-fail-truncate-table-8
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "truncate table db.ns.nAme")
::
:: fail when view name is not a term
++  test-fail-truncate-table-9
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "truncate table db.ns.nAme")
::
:: fail when ship is invalid
++  test-fail-truncate-table-10
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "truncate table ~shitty-shippp db.ns.nAme")
--
