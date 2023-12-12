/-  ast
/+  parse,  *test
|%

::
:: tests 1, 2, 3, 5, and extra whitespace characters
:: alter column db.ns.table 3 columns ; alter column db..table 1 column
++  test-alter-table-00
  =/  expected1  [%alter-table table=[%qualified-object ship=~ database='db' namespace='ns' name='table'] alter-columns=~ add-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  =/  expected2  [%alter-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] alter-columns=~ add-columns=~[[%column name='col1' column-type=%t]] drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'db1') " ALtER  TaBLE  db.ns.table  AdD  COlUMN  ( col1  @t ,  col2  @p ,  col3  @ud ) \0a;\0a ALTER TABLE db..table ADD COLUMN (col1 @t) ")
::
:: alter column table 3 columns
++  test-alter-table-01
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER TABLE table ALTER COLUMN (col1 @t, col2 @p, col3 @ud)")
::
:: alter column table 1 column
++  test-alter-table-02
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~[[%column name='col1' column-type=%t]] add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER TABLE table ALTER COLUMN (col1 @t)")
::
:: drop column table 3 columns
++  test-alter-table-03
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=['col1' 'col2' 'col3' ~] add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER TABLE table DROP COLUMN (col1, col2, col3)")
::
:: drop column table 1 column
++  test-alter-table-04
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=['col1' ~] add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER TABLE table DROP COLUMN (col1)")
::
:: add 2 foreign keys, extra spaces and mixed case key words
++  test-alter-table-05
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]] [%foreign-key name='fk2' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table2'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]]] drop-foreign-keys=~ as-of=~]
  =/  urql  "ALTER TABLE table ADD FOREIGN KEY fk  ( col1 , col2  desc )  reFerences  fk-table  ( col19 ,  col20 )  On  dELETE  CAsCADE  oN  UPdATE  CAScADE, fk2  ( col1 ,  col2  desc )  reFerences  fk-table2  ( col19 ,  col20 )  On  dELETE  CAsCADE  oN  UPdATE  CAScADE "
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: drop 2 foreign keys, extra spaces
++  test-alter-table-06
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' 'fk2' ~] as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') " ALTER  TABLE  mytable  DROP  FOREIGN  KEY  ( fk1,  fk2 )")
::
:: drop 2 foreign keys, no extra spaces
++  test-alter-table-07
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db' namespace='dbo' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' 'fk2' ~] as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER TABLE db..mytable DROP FOREIGN KEY (fk1,fk2)")
::
:: drop 1 foreign key
++  test-alter-table-08
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='ns' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' ~] as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "ALTER TABLE ns.mytable DROP FOREIGN KEY (fk1)")



::
::  add column as of now
++  test-alter-table-09
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db' namespace='ns' name='table'] alter-columns=~ add-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
    %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table  db.ns.table  add  column  ( col1  @t ,  col2  @p ,  col3  @ud ) as of now")
::
::  add column as of now
++  test-alter-table-10
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db' namespace='ns' name='table'] alter-columns=~ add-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=[~ ~2023.12.25..7.15.0..1ef5]]
    %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table  db.ns.table  add  column  ( col1  @t ,  col2  @p ,  col3  @ud ) as of ~2023.12.25..7.15.0..1ef5")
::
::  add column as of 1 weeks ago
++  test-alter-table-11
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db' namespace='ns' name='table'] alter-columns=~ add-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=[~ [%as-of-offset 1 %weeks]]]
    %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table  db.ns.table  add  column  ( col1  @t ,  col2  @p ,  col3  @ud ) as of 1 weeks ago")
::
:: alter column as of now
++  test-alter-table-12
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p]] add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table table alter column (col1 @t, col2 @p) as of now")
::
:: alter column as of ~2023.12.25..7.15.0..1ef5
++  test-alter-table-13
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~[[%column name='col1' column-type=%t] [%column name='col2' column-type=%p] [%column name='col3' column-type=%ud]] add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=[~ ~2023.12.25..7.15.0..1ef5]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table table alter column (col1 @t, col2 @p, col3 @ud) as of ~2023.12.25..7.15.0..1ef5")
::
:: alter column as of 5 days ago
++  test-alter-table-14
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~[[%column name='col1' column-type=%t]] add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=~ as-of=[~ %as-of-offset 5 %days]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table table alter column (col1 @t) as of 5 days ago")
::
:: drop column as of now
++  test-alter-table-15
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=['col1' 'col2' ~] add-foreign-keys=~ drop-foreign-keys=~ as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table table drop column (col1, col2) as of now")
::
:: drop column as of ~2023.12.25..7.15.0..1ef5
++  test-alter-table-16
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=['col1' ~] add-foreign-keys=~ drop-foreign-keys=~ as-of=[~ ~2023.12.25..7.15.0..1ef5]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table table drop column (col1) as of ~2023.12.25..7.15.0..1ef5")
::
:: drop column as of 5 days ago
++  test-alter-table-17
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=['col1' 'col2' 'col3' ~] add-foreign-keys=~ drop-foreign-keys=~ as-of=[~ %as-of-offset 5 %days]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter table table drop column (col1, col2, col3) as of 5 days ago")
::
:: add 2 foreign keys as of now
++  test-alter-table-18
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]] [%foreign-key name='fk2' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table2'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]]] drop-foreign-keys=~ as-of=~]
  =/  urql  "alter table table add foreign key fk  ( col1 , col2  desc )  references  fk-table  ( col19 ,  col20 )  on  delete  cascade  on  update  cascade, fk2  ( col1 ,  col2  desc )  references  fk-table2  ( col19 ,  col20 )  on  delete  cascade  on  update  cascade as of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: add 2 foreign keys as of ~2023.12.25..7.15.0..1ef5
++  test-alter-table-19
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]] [%foreign-key name='fk2' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table2'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]]] drop-foreign-keys=~ as-of=[~ ~2023.12.25..7.15.0..1ef5]]
  =/  urql  "alter table table add foreign key fk  ( col1 , col2  desc )  references  fk-table  ( col19 ,  col20 )  on  delete  cascade  on  update  cascade, fk2  ( col1 ,  col2  desc )  references  fk-table2  ( col19 ,  col20 )  on  delete  cascade  on  update  cascade as of ~2023.12.25..7.15.0..1ef5"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: add 2 foreign keys as of 5 days ago
++  test-alter-table-20
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~[[%foreign-key name='fk' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]] [%foreign-key name='fk2' table=[%qualified-object ship=~ database='db1' namespace='dbo' name='table'] columns=~[[%ordered-column name='col1' is-ascending=%.y] [%ordered-column name='col2' is-ascending=%.n]] reference-table=[%qualified-object ship=~ database='db1' namespace='dbo' name='fk-table2'] reference-columns=['col19' 'col20' ~] referential-integrity=~[%delete-cascade %update-cascade]]] drop-foreign-keys=~ as-of=[~ %as-of-offset 5 %days]]
  =/  urql  "alter table table add foreign key fk  ( col1 , col2  desc )  references  fk-table  ( col19 ,  col20 )  on  delete  cascade  on  update  cascade, fk2  ( col1 ,  col2  desc )  references  fk-table2  ( col19 ,  col20 )  on  delete  cascade  on  update  cascade as of 5 days ago"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: drop 2 foreign keys as of now
++  test-alter-table-21
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' 'fk2' ~] as-of=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter  table  mytable  drop  foreign  key  ( fk1,  fk2 ) as of now")
::
:: drop 2 foreign keys as of ~2023.12.25..7.15.0..1ef5
++  test-alter-table-22
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' 'fk2' ~] as-of=[~ ~2023.12.25..7.15.0..1ef5]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter  table  mytable  drop  foreign  key  ( fk1,  fk2 ) as of ~2023.12.25..7.15.0..1ef5")
::
:: drop 2 foreign keys as of 5 days ago
++  test-alter-table-23
  =/  expected  [%alter-table table=[%qualified-object ship=~ database='db1' namespace='dbo' name='mytable'] alter-columns=~ add-columns=~ drop-columns=~ add-foreign-keys=~ drop-foreign-keys=['fk1' 'fk2' ~] as-of=[~ %as-of-offset 5 %days]]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') "alter  table  mytable  drop  foreign  key  ( fk1,  fk2 ) as of 5 days ago")

    

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
