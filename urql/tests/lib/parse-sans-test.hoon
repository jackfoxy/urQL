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
:: delete
::
++  col1
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col1'] column='col1' alias=~]
++  col2
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col2'] column='col2' alias=~]
++  col3
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col3'] column='col3' alias=~]
++  col4
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='col4'] column='col4' alias=~]
++  delete-pred
  `[%eq [column-foo ~ ~] [column-bar ~ ~]]
++  cte-t1
  [%cte name='t1' [%query ~ scalars=~ predicate=~ group-by=~ having=~ selection=select-all-columns ~]]
++  cte-foobar
  [%cte name='foobar' [%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foobar'] alias=~] joins=~]] scalars=~ `[%eq [col1 ~ ~] [[value-type=%ud value=2] ~ ~]] group-by=~ having=~ [%select top=~ bottom=~ distinct=%.n columns=~[col3 col4]] ~]]
++  cte-bar
  [%cte name='bar' [%query [~ [%from object=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='bar'] alias=~] joins=~]] scalars=~ `[%eq [col1 ~ ~] [col2 ~ ~]] group-by=~ having=~ [%select top=~ bottom=~ distinct=%.n columns=~[col2]] ~]]
++  foo-table
  [%qualified-object ship=~ database='db1' namespace='dbo' name='foo']
::


++  column-foo       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~]
++  column-bar       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]
++  all-columns         [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']
++  select-all-columns  [%select top=~ bottom=~ distinct=%.n columns=~[all-columns]]
++  foo-table-row       [%query-row ~['col1' 'col2' 'col3']]




:: delete from foo;delete  foo
++  test-delete-01
  =/  expected1  [%transform ctes=~ [[%delete table=foo-table ~] ~ ~]]
  =/  expected2  [%transform ctes=~ [[%delete table=foo-table ~] ~ ~]]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(current-database 'db1') "delete from foo;delete  foo")
::
:: delete with predicate
++  test-delete-02
  =/  expected  [%transform ctes=~ [[%delete table=foo-table delete-pred] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "delete from foo  where foo=bar")
::
:: delete with one cte and predicate
++  test-delete-03
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table delete-pred] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "with (select *) as t1 delete from foo where foo=bar")
::
:: delete with two ctes and predicate
++  test-delete-04
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar] [[%delete table=foo-table delete-pred] ~ ~]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar delete from foo where foo=bar")
::
:: delete with three ctes and predicate
++  test-delete-05
  =/  expected  [%transform ctes=~[cte-t1 cte-foobar cte-bar] [%delete table=foo-table delete-pred] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') "with (select *) as t1, (from foobar where col1=2 select col3, col4) as foobar, (from bar where col1=col2 select col2) as bar delete from foo where foo=bar")
::
:: delete cte with no predicate
++  test-delete-06
  =/  expected  [%transform ctes=~[cte-t1] [[%delete table=foo-table ~] ~ ~]]
  %+  expect-eq
  !>  ~[expected]
  !>  (parse:parse(current-database 'db1') "with (select *) as t1 delete from foo")

++  predicate-bar-eq-bar
  [%eq [[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='tgt'] column='bar' alias=~] ~ ~] [[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='bar' alias=~] ~ ~]]
++  cte-bar-foobar
  [%cte name='T1' %query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ distinct=%.n columns=~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]]] order-by=~]
++  cte-bar-foobar-src
  [%cte name='src' %query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ distinct=%.n columns=~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]]] order-by=~]
++  column-src-foo
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='foo' alias=~]
++  column-src-bar
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='bar' alias=~]
++  column-src-foobar
  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='foobar' alias=~]
++  passthru-tgt
  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'tgt']]
++  passthru-src
  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=[~ 'src']]

++  one-eq-1            [%eq [literal-1 ~ ~] [literal-1 ~ ~]]
++  literal-1           [value-type=%ud value=1]
++  passthru-unaliased  [%table-set object=[%query-row ~['col1' 'col2' 'col3']] alias=~]

::
++  test-merge-01
  =/  query  " WITH (SELECT bar, foobar) as T1 ".
" MERGE INTO dbo.foo AS tgt ".
" USING T1 AS src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED THEN ".
"    UPDATE SET foobar = src.foo "
  =/  expected  
    [%transform ctes=~[cte-bar-foobar] [%merge target-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=[~ 'tgt']] new-table=~ source-table=[%table-set object=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1'] alias=[~ 'src']] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo]]]]] unmatched-by-target=~ unmatched-by-source=~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
::
::
++  test-merge-02
  =/  query  " WITH (SELECT bar, foobar) as T1 ".
" MERGE INTO dbo.foo AS tgt ".
" USING T1 AS src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED THEN ".
"    UPDATE SET foobar = src.foo, ".
"    bar = bar "
  =/  expected  
    [%transform ctes=~[cte-bar-foobar] [%merge target-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=[~ 'tgt']] new-table=~ source-table=[%table-set object=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1'] alias=[~ 'src']] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo] ['bar' column-bar]]]]] unmatched-by-target=~ unmatched-by-source=~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
::
::
++  test-merge-03
  =/  query  "WITH (SELECT bar, foobar) as src ".
" MERGE dbo.foo ".
" USING src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED AND 1 = 1 THEN ".
"    UPDATE SET foobar = src.foobar ".
" WHEN NOT MATCHED THEN ".
"    INSERT (bar, foobar) ".
"    VALUES (src.bar, 99)"
  =/  expected  
    [%transform ctes=~[cte-bar-foobar-src] [%merge target-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~] new-table=~ source-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='src'] alias=~] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=`one-eq-1 matching-profile=[%update ~[['foobar' column-src-foobar]]]]] unmatched-by-target=~[[%matching predicate=~ matching-profile=[%insert ~[['bar' column-src-bar] ['foobar' [value-type=%ud value=99]]]]]] unmatched-by-source=~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
::
:: merge target passthru alias AS
++  test-merge-04
  =/  query  "WITH (SELECT bar, foobar) as T1 ".
" MERGE INTO (col1,col2,col3) AS tgt ".
" USING T1 AS src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED THEN ".
"    UPDATE SET foobar = src.foo "
  =/  expected  
    [%transform ctes=~[cte-bar-foobar] [%merge target-table=passthru-tgt new-table=~ source-table=[%table-set object=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1'] alias=[~ 'src']] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo]]]]] unmatched-by-target=~ unmatched-by-source=~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
::
:: merge target passthru alias
++  test-merge-05
  =/  query  "WITH (SELECT bar, foobar) as T1 ".
" MERGE INTO ( col1, col2 , col3) tgt ".
" USING T1 AS src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED THEN ".
"    UPDATE SET foobar = src.foo "
  =/  expected  
    [%transform ctes=~[cte-bar-foobar] [%merge target-table=passthru-tgt new-table=~ source-table=[%table-set object=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1'] alias=[~ 'src']] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo]]]]] unmatched-by-target=~ unmatched-by-source=~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)

:: merge target passthru unaliased
++  test-merge-06
  =/  query  "WITH (SELECT bar, foobar) as T1 ".
" MERGE INTO (col1, col2 , col3)  ".
" USING T1 AS src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED THEN ".
"    UPDATE SET foobar = src.foo "
  =/  expected
    [%transform ctes=~[cte-bar-foobar] [%merge target-table=passthru-unaliased new-table=~ source-table=[%table-set object=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1'] alias=[~ 'src']] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo]]]]] unmatched-by-target=~ unmatched-by-source=~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
++  test-merge-07
  =/  query  "MERGE dbo.foo ".
" USING (col1, col2 , col3) as src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED AND 1 = 1 THEN ".
"    UPDATE SET foobar = src.foobar ".
" WHEN NOT MATCHED THEN ".
"    INSERT (bar, foobar) ".
"    VALUES (src.bar, 99)"
  =/  expected 
    [%transform ctes=~ [%merge target-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~] new-table=~ source-table=passthru-src predicate=predicate-bar-eq-bar matched=~[[%matching predicate=`one-eq-1 matching-profile=[%update ~[['foobar' column-src-foobar]]]]] unmatched-by-target=~[[%matching predicate=~ matching-profile=[%insert ~[['bar' column-src-bar] ['foobar' [value-type=%ud value=99]]]]]] unmatched-by-source=~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
::
::merge source passthru alias AS
++  test-merge-08
  =/  query  "MERGE dbo.foo ".
" USING (col1, col2 , col3) src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED AND 1 = 1 THEN ".
"    UPDATE SET foobar = src.foobar ".
" WHEN NOT MATCHED THEN ".
"    INSERT (bar, foobar) ".
"    VALUES (src.bar, 99)"
  =/  expected
    [%transform ctes=~ [%merge target-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~] new-table=~ source-table=passthru-src predicate=predicate-bar-eq-bar matched=~[[%matching predicate=`one-eq-1 matching-profile=[%update ~[['foobar' column-src-foobar]]]]] unmatched-by-target=~[[%matching predicate=~ matching-profile=[%insert ~[['bar' column-src-bar] ['foobar' [value-type=%ud value=99]]]]]] unmatched-by-source=~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
::
::merge source passthru alias AS
++  test-merge-09
  =/  query  "MERGE dbo.foo ".
" USING (col1, col2 , col3) ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED AND 1 = 1 THEN ".
"    UPDATE SET foobar = src.foobar ".
" WHEN NOT MATCHED THEN ".
"    INSERT (bar, foobar) ".
"    VALUES (src.bar, 99)"
  =/  expected
    [%transform ctes=~ [%merge target-table=[%table-set object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~] new-table=~ source-table=passthru-unaliased predicate=predicate-bar-eq-bar matched=~[[%matching predicate=`one-eq-1 matching-profile=[%update ~[['foobar' column-src-foobar]]]]] unmatched-by-target=~[[%matching predicate=~ matching-profile=[%insert ~[['bar' column-src-bar] ['foobar' [value-type=%ud value=99]]]]]] unmatched-by-source=~] ~ ~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)


--