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
:: drop 2 foreign keys, extra spaces
++  test-alter-table-7
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' 'fk2' ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') " ALTER  TABLE  mytable  DROP  FOREIGN  KEY  ( fk1,  fk2 )")
::
:: drop 2 foreign keys, no extra spaces
++  test-alter-table-8
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' 'fk2' ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "ALTER TABLE db..mytable DROP FOREIGN KEY (fk1,fk2)")
::
:: drop 1 foreign key
++  test-alter-table-9
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='ns' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "ALTER TABLE ns.mytable DROP FOREIGN KEY (fk1)")
::
:: fail when table name not a term 
++  test-fail-alter-table-10
%-  expect-fail
  |.  (parse:parse(current-database 'db1') "ALTER TABLE ns.myTable DROP FOREIGN KEY (fk1)")
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
++  test-fail-create-database-3
  %-  expect-fail
  |.  (parse:parse(current-database 'dummy') "cReate datAbase  My-database")
::
:: fail when commands are prior to create database
++  test-fail-create-database-4
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
++  test-fail-drop-table-9
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
  =/  expected1  [%insert table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table'] columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~] values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]]]]]
  =/  expected2  [%insert table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table'] columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~] values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]]]]]
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
  =/  expected  [%insert table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table'] columns=~ values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]] ~[[~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]]
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
  =/  expected  [%insert table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table'] columns=~ values=[%data ~[~[[~.t 1.685.221.219] [~.p 28.242.037] [~.p 28.242.037] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.dr 114.450.695.119.985.999.668.576.256] [~.dr 114.450.695.119.985.999.668.576.256] [~.if 3.284.569.946] [~.is 123.543.654.234] [~.f 0] [~.f 1] [~.f 0] [~.f 1] [~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]]
  =/  urql  "insert into db.ns.my-table ".
"values ('cord',~nomryg-nilref,nomryg-nilref,~2020.12.25..7.15.0..1ef5,2020.12.25..7.15.0..1ef5,".
"~d71.h19.m26.s24..9d55, d71.h19.m26.s24..9d55,.195.198.143.90,.0.0.0.0.0.1c.c3c6.8f5a,y,n,Y,N,".
"2.222,2222,195.198.143.900,3.14,-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') urql)
::
:: every column type, spaces on all sides of values, comma inside cord
++  test-insert-4
  =/  expected  [%insert table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table'] columns=~ values=[%data ~[~[[~.t 430.242.426.723] [~.p 28.242.037] [~.p 28.242.037] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.dr 114.450.695.119.985.999.668.576.256] [~.dr 114.450.695.119.985.999.668.576.256] [~.if 3.284.569.946] [~.is 123.543.654.234] [~.f 0] [~.f 1] [~.f 0] [~.f 1] [~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]]
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
::  re-used components
++  foo                  [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN-OR-CTE' 'foo'] 'foo' ~] ~ ~]
++  t1-foo               [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN' 'T1'] 'foo' ~] ~ ~]
++  foo2                 [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN-OR-CTE' 'foo2'] 'foo2' ~] ~ ~]
++  t1-foo2              [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN' 'T1'] 'foo2' ~] ~ ~]
++  foo3                 [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN-OR-CTE' 'foo3'] 'foo3' ~] ~ ~]
++  t1-foo3              [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN' 'T1'] 'foo3' ~] ~ ~]
++  foo4                 [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN-OR-CTE' 'foo4'] 'foo4' ~] ~ ~]
++  foo5                 [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN-OR-CTE' 'foo5'] 'foo5' ~] ~ ~]
++  foo6                 [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN-OR-CTE' 'foo6'] 'foo6' ~] ~ ~]
++  foo7                 [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN-OR-CTE' 'foo7'] 'foo7' ~] ~ ~]
++  bar                  [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN-OR-CTE' 'bar'] 'bar' ~] ~ ~]
++  t2-bar               [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN' 'T2'] 'bar' ~] ~ ~]
++  foobar               [[%qualified-column [%qualified-object ~zod 'UNKNOWN' 'COLUMN-OR-CTE' 'foobar'] 'foobar' ~] ~ ~]
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
++  foobar-gte-foo       [%gte foobar foo]
++  foobar-lte-bar       [%lte foobar bar]
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
::  scalar
::
++  column-foo       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~]
++  column-foo2      [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo2'] column='foo2' alias=~]
++  column-foo3      [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo3'] column='foo3' alias=~]
++  column-bar       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]
++  literal-zod      [value-type=%p value=0]
++  literal-1        [value-type=%ud value=1]
++  naked-coalesce   ~[%coalesce column-bar literal-zod literal-1 column-foo]
++  simple-coalesce  [[%scalar %foobar] naked-coalesce]
++  simple-if-naked  [%if [%eq [literal-1 0 0] literal-1 0 0] %then column-foo %else column-bar %endif]
++  simple-if        [[%scalar %foobar] simple-if-naked]
++  case-predicate   [%when [%eq [literal-1 0 0] literal-1 0 0] %then column-foo]
++  case-datum       [%when column-foo2 %then column-foo]
++  case-coalesce    [%when column-foo3 %then naked-coalesce]
++  case-1           [[%scalar %foobar] [%case column-foo3 ~[case-predicate] %else column-bar %end]]
++  case-2           [[%scalar %foobar] [%case column-foo3 ~[case-datum] %else column-bar %end]]
++  case-3           [[%scalar %foobar] [%case column-foo3 ~[case-datum case-predicate] %else column-bar %end]]
++  case-4           [[%scalar %foobar] [%case column-foo3 ~[case-datum case-predicate] %else simple-if-naked %end]]
++  case-5           [[%scalar %foobar] [%case column-foo3 ~[case-datum case-predicate case-coalesce] %else simple-if-naked %end]]
++  case-aggregate   [[%scalar %foobar] [%case [%qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo3] %foo3 0] [[%when [%qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo2] %foo2 0] %then %aggregate %count %qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo] %foo 0] 0] %else [%aggregate %count %qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo] %foo 0] %end]]
::  coalesce
++  test-scalar-01
  =/  scalar  "SCALAR foobar COALESCE bar,~zod,1,foo"
  %+  expect-eq
    !>  simple-coalesce
    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  coalesce as
++  test-scalar-02
  =/  scalar  "SCALAR foobar AS COALESCE bar,~zod,1,foo"
  %+  expect-eq
    !>  simple-coalesce
    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  simple if
++  test-scalar-03
  =/  scalar  "SCALAR foobar IF 1 = 1 THEN foo ELSE bar ENDIF"
  %+  expect-eq
    !>  simple-if
    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  simple if as
++  test-scalar-04
  =/  scalar  "SCALAR foobar AS IF 1 = 1 THEN foo ELSE bar ENDIF"
  %+  expect-eq
    !>  simple-if
    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  simple case with predicate
++  test-scalar-05
  =/  scalar  "SCALAR foobar CASE foo3 WHEN 1 = 1 THEN foo ELSE bar END"
  %+  expect-eq
    !>  case-1
    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  simple case AS with datum
++  test-scalar-06
  =/  scalar  "SCALAR foobar AS CASE foo3 WHEN foo2 THEN foo ELSE bar END"
  %+  expect-eq
    !>  case-2
    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  simple case, 2 whens
++  test-scalar-07
  =/  scalar  "SCALAR foobar AS CASE foo3 WHEN foo2 THEN foo WHEN 1 = 1 THEN foo ELSE bar END"
  %+  expect-eq
    !>  case-3
    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  2 whens, embedded if for else
++  test-scalar-08
  =/  scalar  "SCALAR foobar AS CASE foo3 ".
" WHEN foo2 THEN foo WHEN 1 = 1 THEN foo ".
" ELSE IF 1 = 1 THEN foo ELSE bar ENDIF END"
  %+  expect-eq
    !>  case-4
    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  3 whens, coalesce, embedded if for else
++  test-scalar-09
  =/  scalar  "SCALAR foobar AS CASE foo3 ".
" WHEN foo2 THEN foo ".
" WHEN 1 = 1 THEN foo ".
" WHEN foo3 THEN COALESCE bar,~zod,1,foo ".
" ELSE IF 1 = 1 THEN foo ELSE bar ENDIF END"
  %+  expect-eq
    !>  case-5
    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  if aggragate
++  test-scalar-10
  =/  scalar  "SCALAR foobar IF count(foo)=1 THEN foo3 else bar ENDIF"
  %+  expect-eq
    !>  [[%scalar %foobar] [%if [%eq [aggregate-count-foo 0 0] literal-1 0 0] %then column-foo3 %else column-bar %endif]]
    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  coalesce aggragate
++  test-scalar-11
  =/  scalar  "SCALAR foobar AS COALESCE count(foo),~zod,1,foo"
  %+  expect-eq
    !>  [[%scalar %foobar] ~[%coalesce aggregate-count-foo literal-zod literal-1 column-foo]]
    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  case aggregate
++  test-scalar-12
  =/  scalar  "SCALAR foobar AS CASE foo3 WHEN foo2 THEN count(foo) ELSE count(foo) END"
  %+  expect-eq
    !>  case-aggregate
    !>  (wonk (parse-scalar:parse [[1 1] scalar]))
::
::  select
::
++  simple-columns  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='x1'] column='x1' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col1' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='table-alias'] column='name' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] column='col2' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='T1'] column='foo' alias=~] [%ud 1] [%p 0] [%t 'cord']]
++  aliased-columns-1  ~[[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='x1'] column='x1' alias=~] %as %foo] [[%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col1' alias=~] %as %foo2] [[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='table-alias'] column='name' alias=~] %as %bar] [[%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] column='col2' alias=~] %as %bar2] [[%ud 1] %as %foobar] [[%p 0] %as 'F1'] [[%t 'cord'] %as 'BAR3']]
++  mixed-all  ~[[%all-columns %qualified-object ship=~ database='db' namespace='dbo' name='t1'] [[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~] %as 125.762.588.864.358] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] %all [%all-columns 'T2']]
++  aggregates  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~] [[%selected-aggregate %aggregate function='COUNT' source=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~]] %as 'CountFoo'] [%selected-aggregate %aggregate function='cOUNT' source=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]] [%selected-aggregate %aggregate function='sum' source=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]] [[%selected-aggregate %aggregate function='sum' source=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]] %as 'foobar']]
::
::  star select top, bottom, distinct, trailing whitespace
++  test-select-01
  =/  select  "select top 10  bottom 10  distinct * "
  %+  expect-eq
    !>  [%select %top 10 %bottom 10 %distinct [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select top, bottom, distinct
++  test-select-02
  =/  select  "select top 10  bottom 10  distinct *"
  %+  expect-eq
    !>  [%select %top 10 %bottom 10 %distinct [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select top bottom
++  test-select-03
  =/  select  "select top 10  bottom 10 *"
  %+  expect-eq
    !>  [%select %top 10 %bottom 10 [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select top, distinct, trailing whitespace
++  test-select-04
  =/  select  "select top 10 distinct   * "
  %+  expect-eq
    !>  [%select %top 10 %distinct [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select top, distinct
++  test-select-05
  =/  select  "select top 10  distinct  *"
  %+  expect-eq
    !>  [%select %top 10 %distinct [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select top, trailing whitespace
++  test-select-06
  =/  select  "select top 10    * "
  %+  expect-eq
    !>  [%select %top 10 [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select top
++  test-select-07
  =/  select  "select top 10    *"
  %+  expect-eq
    !>  [%select %top 10 [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select, trailing whitespace 
++  test-select-08
  =/  select  "select  *       "
  %+  expect-eq
    !>  [%select [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select
++  test-select-09
  =/  select  "select  *"
  %+  expect-eq
    !>  [%select [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select bottom, distinct, trailing whitespace 
++  test-select-10
  =/  select  "select bottom 10  distinct * "
  %+  expect-eq
    !>  [%select %bottom 10 %distinct [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select bottom, distinct
++  test-select-11
  =/  select  "select bottom 10  distinct *"
  %+  expect-eq
    !>  [%select %bottom 10 %distinct [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select bottom, trailing whitespace 
++  test-select-12
  =/  select  "select bottom 10   *  "
  %+  expect-eq
    !>  [%select %bottom 10 [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select bottom
++  test-select-13
  =/  select  "select bottom 10   *"
  %+  expect-eq
    !>  [%select %bottom 10 [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select distinct, trailing whitespace 
++  test-select-14
  =/  select  "select distinct   *   "
  %+  expect-eq
    !>  [%select %distinct [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  star select distinct
++  test-select-15
  =/  select  "select distinct *"
  %+  expect-eq
    !>  [%select %distinct [%all ~]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, distinct, no bottom parameter, trailing whitespace
++  test-fail-select-16
    =/  select  "select top 10  bottom  distinct * "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, distinct, no bottom parameter
++  test-fail-select-17
    =/  select  "select top 10  bottom  distinct *"
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, distinct, no top parameter, trailing whitespace
++  test-fail-select-18
    =/  select  "select top   bottom 10  distinct * "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, distinct, no top parameter
++  test-fail-select-19
    =/  select  "select top   bottom 10  distinct *"
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, no column selection, trailing whitespace
++  test-fail-select-20
    =/  select  "select top 10  bottom 10  "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, no bottom parameter, trailing whitespace
++  test-fail-select-21
    =/  select  "select top 10  bottom   * "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, no bottom parameter
++  test-fail-select-22
    =/  select  "select top 10  bottom   *"
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, no column selection, trailing whitespace
++  test-fail-select-23
    =/  select  "select top 10    "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, distinct, no top parameter, trailing whitespace
++  test-fail-select-24
    =/  select  "select top   distinct  * "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, distinct, no top parameter
++  test-fail-select-25
    =/  select  "select top   distinct  *"
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail no column selection, trailing whitespace
++  test-fail-select-26
    =/  select  "select         "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail bottom, distinct, no bottom parameter, trailing whitespace
++  test-fail-select-27
    =/  select  "select bottom  distinct * "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail bottom, distinct, no bottom parameter
++  test-fail-select-28
    =/  select  "select bottom  distinct *"
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail bottom, no column selection, trailing whitespace
++  test-fail-select-29
    =/  select  "select bottom 10 "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
::  select top, bottom, distinct, simple columns
++  test-select-30
  =/  select  "select top 10  bottom 10  distinct ".
" x1, db.ns.table.col1, table-alias.name, db..table.col2, T1.foo, 1, ~zod, 'cord'"
  %+  expect-eq
    !>  [%select %top 10 %bottom 10 %distinct [simple-columns]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  select top, bottom, distinct, simple columns, trailing space, no internal space
++  test-select-31
  =/  select  "select top 10  bottom 10  distinct x1,db.ns.table.col1,table-alias.name,db..table.col2,T1.foo,1,~zod,'cord' "
  %+  expect-eq
    !>  [%select %top 10 %bottom 10 %distinct [simple-columns]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  aliased format 1 columns
++  test-select-32
  =/  select  "select x1 as foo , db.ns.table.col1 as foo2 , table-alias.name as bar , db..table.col2 as bar2 , 1 as foobar , ~zod as F1 , 'cord' as BAR3 "
  %+  expect-eq
    !>  [%select [aliased-columns-1]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  aliased format 1 columns, no whitespace
++  test-select-33
  =/  select  "select x1 as foo,db.ns.table.col1 as foo2,table-alias.name as bar,db..table.col2 as bar2,1 as foobar,~zod as F1,'cord' as BAR3"
  %+  expect-eq
    !>  [%select [aliased-columns-1]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  mixed all, object all, object alias all, column, aliased column
++  test-select-34
  =/  select  "select db..t1.* , foo as foobar , bar , * , T2.* "
  %+  expect-eq
    !>  [%select [mixed-all]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  mixed all, object all, object alias all, column, aliased column, no whitespace
++  test-select-35
  =/  select  "select db..t1.*,foo as foobar,bar,*,T2.*"
  %+  expect-eq
    !>  [%select [mixed-all]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  mixed aggregates 
++  test-select-36
  =/  select  "select  foo , COUNT(foo) as CountFoo, cOUNT( bar) ,sum(bar ) , sum( foobar ) as foobar "
  %+  expect-eq
    !>  [%select [aggregates]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  mixed aggregates, no whitespace
++  test-select-37
  =/  select  "select  foo,COUNT(foo) as CountFoo,cOUNT( bar),sum(bar ),sum( foobar ) as foobar"
  %+  expect-eq
    !>  [%select [aggregates]]
    !>  (wonk (parse-select:parse [[1 1] select]))

:: for later inclusion in full query
::
:: fail top, bottom, distinct, no column selection
::++  test-fail-select-
::    =/  select  "select top 10  bottom 10  distinct"
::    %-  expect-fail
::    |.  (wonk (parse-select:parse [[1 1] select]))

::
:: fail top, bottom, no column selection
::++  test-fail-select-
::    =/  select  "select top 10  bottom 10"
::    %-  expect-fail
::    |.  (wonk (parse-select:parse [[1 1] select]))

::
:: fail top, no column selection
::++  test-fail-select-
::    =/  select  "select top 10"
::    %-  expect-fail
::    |.  (wonk (parse-select:parse [[1 1] select]))

::
:: fail top, distinct, no column selection
::++  test-fail-select-
::    =/  select  "select top 10  distinct"
::    %-  expect-fail
::    |.  (wonk (parse-select:parse [[1 1] select]))

::
:: fail no column selection
::++  test-fail-select-
::    =/  select  "select"
::    %-  expect-fail
::    |.  (wonk (parse-select:parse [[1 1] select]))

::
:: fail bottom, distinct, no column selection
::++  test-fail-select-
::    =/  select  "select bottom 10 distinct"
::    %-  expect-fail
::    |.  (wonk (parse-select:parse [[1 1] select]))

::
:: fail bottom, no column selection
::++  test-fail-select-
::    =/  select  "select bottom 10"
::    %-  expect-fail
::    |.  (wonk (parse-select:parse [[1 1] select]))

::
:: fail distinct, no column selection
::++  test-fail-select-
::    =/  select  "select distinct"
::    %-  expect-fail
::    |.  (wonk (parse-select:parse [[1 1] select]))

::
:: fail distinct, no column selection, trailing whitespace
::++  test-fail-select-
::    =/  select  "select distinct "
::    %-  expect-fail
::    |.  (wonk (parse-select:parse [[1 1] select]))

::
:: fail top, distinct, no column selection, trailing whitespace
::++  test-fail-select-
::    =/  select  "select top 10  distinct  "
::    %-  expect-fail
::    |.  (wonk (parse-select:parse [[1 1] select]))

::
:: fail top, bottom, distinct, no column selection, trailing whitespace
::++  test-fail-select-
::    =/  select  "select top 10  bottom 10  distinct  "
::    %-  expect-fail
::    |.  (wonk (parse-select:parse [[1 1] select]))

::
:: fail bottom, distinct, no column selection, trailing whitespace
::++  test-fail-select-
::    =/  select  "select bottom 10 distinct "
::    %-  expect-fail
::    |.  (wonk (parse-select:parse [[1 1] select]))

::
::  group and order by
::
++  group-by  [%group-by ~[[%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='T1'] column='foo' alias=~] 3 4]]
++  order-by  [%order-by ~[[%ordering-column [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col' alias=~] is-ascending=%.y] [%ordering-column [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='T1'] column='foo' alias=~] is-ascending=%.n] [%ordering-column 3 is-ascending=%.y] [%ordering-column 4 is-ascending=%.n]]]
::
::  group by
++  test-group-by-01
  =/  select  "group by  db.ns.table.col , T1.foo , 3 , 4 "
  %+  expect-eq
    !>  group-by
    !>  (wonk (parse-group-by:parse [[1 1] select]))
::
::  group by, no whitespace
++  test-group-by-02
  =/  select  "group by db.ns.table.col,T1.foo,3,4"
  %+  expect-eq
    !>  group-by
    !>  (wonk (parse-group-by:parse [[1 1] select]))
::
::  group by
++  test-order-by-01
  =/  select  "order by  db.ns.table.col  asc , T1.foo desc , 3 , 4  desc "
  %+  expect-eq
    !>  order-by
    !>  (wonk (parse-order-by:parse [[1 1] select]))
::
::  group by, no whitespace
++  test-order-by-02
  =/  select  "order by db.ns.table.col asc,T1.foo desc,3,4 desc"
  %+  expect-eq
    !>  order-by
    !>  (wonk (parse-order-by:parse [[1 1] select]))
--