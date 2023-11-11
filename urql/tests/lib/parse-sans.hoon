/-  ast
/+  parse,  *test
|%

++  m-cmnt-1
  "/* line1\0a  line2 \0a line3\0a*/"
++  m-cmnt-2
  "/* linea\0a  lineb \0a linec */"
++  m-cmnt-3
  "/* linea1\0a  lineb2 \0a linec3 */"

++  test-multiline-cmnt-00
  =/  expected1  [%create-namespace database-name='other-db' name='ns1' as-of=~]
  =/  expected2  [%create-namespace database-name='db1' name='db1-ns1' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
                %-  limo  :~  m-cmnt-1 
                              "cReate" 
                              m-cmnt-2 
                              "  namespace ns1\0a" 
                              " ; \0a" 
                              "cReate namesPace db1.db1-ns1\0a" 
                              m-cmnt-3
                              ==

++  test-multiline-cmnt-01
  =/  expected1  [%create-namespace database-name='other-db' name='ns1' as-of=~]
  =/  expected2  [%create-namespace database-name='db1' name='db1-ns1' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
                %-  limo  :~  "cReate\0a" 
                              m-cmnt-1 
                              "  namespace ns1\0a" 
                              m-cmnt-2 
                              " ; \0a" 
                              m-cmnt-3 
                              "cReate namesPace db1.db1-ns1\0a"
                              ==

++  test-multiline-cmnt-02
  =/  expected1  [%create-namespace database-name='other-db' name='ns1' as-of=~]
  =/  expected2  [%create-namespace database-name='db1' name='db1-ns1' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
                %-  limo  :~  m-cmnt-1 
                              "\0acReate\0a" 
                              "  namespace ns1\0a" 
                              m-cmnt-2 
                              m-cmnt-3 
                              " ; \0a" 
                              "cReate namesPace db1.db1-ns1\0a"
                              ==

++  test-multiline-cmnt-03
  =/  expected1  [%create-namespace database-name='other-db' name='ns1' as-of=~]
  =/  expected2  [%create-namespace database-name='db1' name='db1-ns1' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
                %-  limo  :~  "cReate\0a" 
                              "  namespace ns1\0a" 
                              m-cmnt-1 
                              " ; \0a" 
                              m-cmnt-2 
                              "cReate namesPace db1.db1-ns1\0a" 
                              m-cmnt-3
                              ==

++  test-multiline-cmnt-04
  =/  expected1  [%create-namespace database-name='other-db' name='ns1' as-of=~]
  =/  expected2  [%create-namespace database-name='db1' name='db1-ns1' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
                %-  limo  :~  "cReate\0a" 
                              "  namespace ns1" 
                              m-cmnt-1 
                              " ; " 
                              m-cmnt-2 
                              "cReate namesPace db1.db1-ns1" 
                              m-cmnt-3
                              ==


++  test-multiline-cmnt-005
  =/  expected1  [%create-namespace database-name='other-db' name='ns1' as-of=~]
  =/  expected2  [%create-namespace database-name='db1' name='db1-ns1' as-of=~]
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse(default-database 'other-db') 
            %-  zing 
                %-  limo  :~  "select '\2f\2a', '*\2f', '--', ' \2f\2a ', ' *\2f ', ' -- '" 
                              m-cmnt-1 
                              "select ' -- ', '\2f\2a', '*\2f', '--', ' \2f\2a ', ' *\2f '" 
                              m-cmnt-2 
                              "select ' *\2f ', ' -- ', '\2f\2a', '*\2f', '--', ' \2f\2a '"  
                              m-cmnt-3
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
