/-  ast
/+  parse,  *test
|%
::
::
::
:: merge
::
++  literal-1        [value-type=%ud value=1]
++  one-eq-1  [%eq [literal-1 ~ ~] [literal-1 ~ ~]]
++  predicate-bar-eq-bar  [%eq [[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='tgt'] column='bar' alias=~] ~ ~] [[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='bar' alias=~] ~ ~]]
++  cte-bar-foobar  [%cte name='T1' %simple-query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ distinct=%.n columns=~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]]] order-by=~]
++  cte-bar-foobar-src  [%cte name='src' %simple-query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ distinct=%.n columns=~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~]]] order-by=~]
++  column-src-foo  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='foo' alias=~]
++  column-src-bar  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='bar' alias=~]
++  column-src-foobar  [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN' name='src'] column='foobar' alias=~]
++  column-bar       [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~]
::
::
++  test-merge-01
  =/  query  "MERGE INTO dbo.foo AS tgt ".
" WITH (SELECT bar, foobar) as T1 ".
" USING T1 AS src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED THEN ".
"    UPDATE SET foobar = src.foo "
  =/  expected=merge:ast  [%merge target-table=[~ [%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=[~ 'tgt']]] new-table=~ source-table=[~ [%query-object object=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1'] alias=[~ 'src']]] ctes=~[cte-bar-foobar] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo]]]]] unmatched-by-target=~ unmatched-by-source=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
::
::
++  test-merge-02
  =/  query  "MERGE INTO dbo.foo AS tgt ".
" WITH (SELECT bar, foobar) as T1 ".
" USING T1 AS src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED THEN ".
"    UPDATE SET foobar = src.foo, ".
"    bar = bar "
  =/  expected=merge:ast  [%merge target-table=[~ [%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=[~ 'tgt']]] new-table=~ source-table=[~ [%query-object object=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T1'] alias=[~ 'src']]] ctes=~[cte-bar-foobar] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=~ matching-profile=[%update ~[['foobar' column-src-foo] ['bar' column-bar]]]]] unmatched-by-target=~ unmatched-by-source=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)
::
::
++  test-merge-03
  =/  query  "MERGE dbo.foo ".
" WITH (SELECT bar, foobar) as src ".
" USING src ".
" ON (tgt.bar = src.bar) ".
" WHEN MATCHED AND 1 = 1 THEN ".
"    UPDATE SET foobar = src.foobar ".
" WHEN NOT MATCHED THEN ".
"    INSERT (bar, foobar) ".
"    VALUES (src.bar, 99)"
  =/  expected=merge:ast  [%merge target-table=[~ [%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='foo'] alias=~]] new-table=~ source-table=[~ [%query-object object=[%qualified-object ship=~ database='db1' namespace='dbo' name='src'] alias=~]] ctes=~[cte-bar-foobar-src] predicate=predicate-bar-eq-bar matched=~[[%matching predicate=`one-eq-1 matching-profile=[%update ~[['foobar' column-src-foobar]]]]] unmatched-by-target=~[[%matching predicate=~ matching-profile=[%insert ~[['bar' column-src-bar] ['foobar' [value-type=%ud value=99]]]]]] unmatched-by-source=~]
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(current-database 'db1') query)

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
