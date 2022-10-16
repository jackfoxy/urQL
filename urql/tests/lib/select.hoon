/+  parse,  *test
|%
::
::  select
::
++  simple-columns  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='x1'] column='x1' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col1' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='table-alias'] column='name' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] column='col2' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='T1'] column='foo' alias=~] [%ud 1] [%p 0] [%t 'cord']]
++  aliased-columns-1  ~[[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='x1'] column='x1' alias=~] %as %foo] [[%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='ns' name='table'] column='col1' alias=~] %as %foo2] [[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='table-alias'] column='name' alias=~] %as %bar] [[%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='dbo' name='table'] column='col2' alias=~] %as %bar2] [[%ud 1] %as %foobar] [[%p 0] %as 'F1'] [[%t 'cord'] %as 'BAR3']]
++  mixed-all  ~[[%all-columns %qualified-object ship=~ database='db' namespace='dbo' name='t1'] [[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~] %as 125.762.588.864.358] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] %all [%all-columns 'T2']]
++  aggregates  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~] [[%selected-aggregate 'COUNT' [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~]] %as 'CountFoo'] [%selected-aggregate 'cOUNT' [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]] [%selected-aggregate 'sum' [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]] [[%selected-aggregate 'sum' [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]] %as 'foobar']]
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
:: fail top, bottom, distinct, no column selection, trailing whitespace
++  test-fail-select-16
    =/  select  "select top 10  bottom 10  distinct  "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, distinct, no bottom parameter, trailing whitespace
++  test-fail-select-17
    =/  select  "select top 10  bottom  distinct * "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, distinct, no bottom parameter
++  test-fail-select-18
    =/  select  "select top 10  bottom  distinct *"
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, distinct, no top parameter, trailing whitespace
++  test-fail-select-19
    =/  select  "select top   bottom 10  distinct * "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, distinct, no top parameter
++  test-fail-select-20
    =/  select  "select top   bottom 10  distinct *"
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, no column selection, trailing whitespace
++  test-fail-select-21
    =/  select  "select top 10  bottom 10  "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, no bottom parameter, trailing whitespace
++  test-fail-select-22
    =/  select  "select top 10  bottom   * "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, bottom, no bottom parameter
++  test-fail-select-23
    =/  select  "select top 10  bottom   *"
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, no column selection, trailing whitespace
++  test-fail-select-24
    =/  select  "select top 10    "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, distinct, no column selection, trailing whitespace
++  test-fail-select-25
    =/  select  "select top 10  distinct  "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, distinct, no top parameter, trailing whitespace
++  test-fail-select-26
    =/  select  "select top   distinct  * "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail top, distinct, no top parameter
++  test-fail-select-27
    =/  select  "select top   distinct  *"
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail no column selection, trailing whitespace
++  test-fail-select-28
    =/  select  "select         "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail bottom, distinct, no column selection, trailing whitespace
++  test-fail-select-29
    =/  select  "select bottom 10 distinct "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail bottom, distinct, no bottom parameter, trailing whitespace
++  test-fail-select-30
    =/  select  "select bottom  distinct * "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail bottom, distinct, no bottom parameter
++  test-fail-select-31
    =/  select  "select bottom  distinct *"
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail bottom, no column selection, trailing whitespace
++  test-fail-select-32
    =/  select  "select bottom 10 "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
:: fail distinct, no column selection, trailing whitespace
++  test-fail-select-33
    =/  select  "select distinct "
    %-  expect-fail
    |.  (wonk (parse-select:parse [[1 1] select]))
::
::  select top, bottom, distinct, simple columns
++  test-select-34
  =/  select  "select top 10  bottom 10  distinct ".
" x1, db.ns.table.col1, table-alias.name, db..table.col2, T1.foo, 1, ~zod, 'cord'"
  %+  expect-eq
    !>  [%select %top 10 %bottom 10 %distinct [simple-columns]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  select top, bottom, distinct, simple columns, trailing space, no internal space
++  test-select-35
  =/  select  "select top 10  bottom 10  distinct x1,db.ns.table.col1,table-alias.name,db..table.col2,T1.foo,1,~zod,'cord' "
  %+  expect-eq
    !>  [%select %top 10 %bottom 10 %distinct [simple-columns]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  aliased format 1 columns
++  test-select-36
  =/  select  "select x1 as foo , db.ns.table.col1 as foo2 , table-alias.name as bar , db..table.col2 as bar2 , 1 as foobar , ~zod as F1 , 'cord' as BAR3 "
  %+  expect-eq
    !>  [%select [aliased-columns-1]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  aliased format 1 columns, no whitespace
++  test-select-37
  =/  select  "select x1 as foo,db.ns.table.col1 as foo2,table-alias.name as bar,db..table.col2 as bar2,1 as foobar,~zod as F1,'cord' as BAR3"
  %+  expect-eq
    !>  [%select [aliased-columns-1]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  mixed all, object all, object alias all, column, aliased column
++  test-select-38
  =/  select  "select db..t1.* , foo as foobar , bar , * , T2.* "
  %+  expect-eq
    !>  [%select [mixed-all]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  mixed all, object all, object alias all, column, aliased column, no whitespace
++  test-select-39
  =/  select  "select db..t1.*,foo as foobar,bar,*,T2.*"
  %+  expect-eq
    !>  [%select [mixed-all]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  mixed aggregates 
++  test-select-40
  =/  select  "select  foo , COUNT(foo) as CountFoo, cOUNT( bar) ,sum(bar ) , sum( foobar ) as foobar "
  %+  expect-eq
    !>  [%select [aggregates]]
    !>  (wonk (parse-select:parse [[1 1] select]))
::
::  mixed aggregates, no whitespace
++  test-select-41
  =/  select  "select  foo,COUNT(foo) as CountFoo,cOUNT( bar),sum(bar ),sum( foobar ) as foobar"
  %+  expect-eq
    !>  [%select [aggregates]]
    !>  (wonk (parse-select:parse [[1 1] select]))
--

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
