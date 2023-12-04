/-  ast
/+  parse,  *test
|%

++  m-cmnt-1
  "/* line1\0a  line2 \0a line3\0a*/"
++  m-cmnt-2
  "\0a/* linea\0a  lineb \0a linec \0a*/"
++  m-cmnt-3
  "\0a/* linea1 \0a lineb2 \0a linec3 \0a*/"

++  vfas-tar  [%selected-value value=[p=~.t q=10.799] alias=~]
++  vhep-hep  [%selected-value value=[p=~.t q=11.565] alias=~]
++  vtar-fas  [%selected-value value=[p=~.t q=12.074] alias=~]
++  va-fas-tar-a  [%selected-value value=[p=~.t q=539.635.488] alias=~]
++  va-hep-hep-a  [%selected-value value=[p=~.t q=539.831.584] alias=~]
++  va-tar-fas-a  [%selected-value value=[p=~.t q=539.961.888] alias=~]

++  s1  ~[vfas-tar vtar-fas vhep-hep va-fas-tar-a va-tar-fas-a va-hep-hep-a]
++  s2  ~[va-hep-hep-a vfas-tar vtar-fas vhep-hep va-fas-tar-a va-tar-fas-a]
++  s3  ~[va-tar-fas-a va-hep-hep-a vfas-tar vtar-fas vhep-hep va-fas-tar-a]

++  s1a  ~[vfas-tar vtar-fas]
++  s2a  ~[va-hep-hep-a vfas-tar vtar-fas]
++  s3a  ~[va-tar-fas-a va-hep-hep-a vfas-tar vtar-fas]

++  q1  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s1] order-by=~]
++  q2  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s2] order-by=~]
++  q3  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s3] order-by=~]
++  q3a  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s3a] order-by=~]

++  q1a  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s1a] order-by=~]
++  q2a  [%query from=~ scalars=~ predicate=~ group-by=~ having=~ selection=[%select top=~ bottom=~ columns=s2a] order-by=~]

++  t1  [%transform ctes=~ set-functions=[q1 ~ ~]]
++  t2  [%transform ctes=~ set-functions=[q2 ~ ~]]
++  t3  [%transform ctes=~ set-functions=[q3 ~ ~]]

++  t1a  [%transform ctes=~ set-functions=[q1a ~ ~]]
++  t2a  [%transform ctes=~ set-functions=[q2a ~ ~]]
++  t3a  [%transform ctes=~ set-functions=[q3a ~ ~]]

++  test-line-cmnt-00
  %+  expect-eq
    !>  ~
    !>  %-  parse:parse(default-database 'other-db')  ~
++  test-line-cmnt-01
  %+  expect-eq
    !>  ~
    !>  %-  parse:parse(default-database 'other-db')  %-  zing  ~["--line cmnt"]
++  test-line-cmnt-02
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=~]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1 \0a--line cmnt")
++  test-line-cmnt-03
  %+  expect-eq
    !>  ~[[%create-namespace database-name='db1' name='ns1' as-of=~]]
    !>  (parse:parse(default-database 'db1') "create namespace ns1 --line cmnt")
++  test-line-cmnt-04
  %+  expect-eq
    !>  ~[t1a t2 t3]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
            %-  limo  
            :~  "select '\2f\2a', '*\2f' --, ' \2f\2a ', ' *\2f ', ' -- '\0a" 
                m-cmnt-1 
                "select ' -- ', '\2f\2a', '*\2f', '--', ' \2f\2a ', ' *\2f '" 
                m-cmnt-2 
                "select ' *\2f ', ' -- ', '\2f\2a', '*\2f', '--', ' \2f\2a '"  
                m-cmnt-3
                ==
++  test-line-cmnt-05
  %+  expect-eq
    !>  ~[t1 t2a t3]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
            %-  limo  
            :~  "select '\2f\2a', '*\2f', '--', ' \2f\2a ', ' *\2f ', ' -- '\0a" 
                m-cmnt-1 
                "select ' -- ', '\2f\2a', '*\2f'--, ' \2f\2a ', ' *\2f '" 
                m-cmnt-2 
                "select ' *\2f ', ' -- ', '\2f\2a', '*\2f', '--', ' \2f\2a '"  
                m-cmnt-3
                ==
++  test-line-cmnt-06
  %+  expect-eq
    !>  ~[t1 t2 t3a]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
            %-  limo  
            :~  "select '\2f\2a', '*\2f', '--', ' \2f\2a ', ' *\2f ', ' -- '\0a" 
                m-cmnt-1 
                "select ' -- ', '\2f\2a', '*\2f', '--', ' \2f\2a ', ' *\2f '" 
                m-cmnt-2 
                "select ' *\2f ', ' -- ', '\2f\2a', '*\2f' --, ' \2f\2a '"  
                m-cmnt-3
                ==
++  test-line-cmnt-07
  %+  expect-eq
    !>  ~[t1a t2a t3a]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
            %-  limo  
            :~  "select '\2f\2a', '*\2f', '--', ' \2f\2a--  ', ' *\2f ', ' -- '\0a" 
                "select ' -- ', '\2f\2a', '*\2f'--, ' \2f\2a ', ' *\2f '" 
                "select ' *\2f '  -- ', '\2f\2a', '*\2f', '--', ' \2f\2a '"
                ==


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
