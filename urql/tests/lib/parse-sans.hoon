/-  ast
/+  parse,  *test
|%

::
:: insert
::
:: tests 1, 2, 3, 5, and extra whitespace characters, db.ns.table, db..table, colum list, two value rows, one value row, no space around ; delimeter
:: NOTE: the parser does not check:
::       1) validity of columns re parent table
::       2) match column count to values count
::       3) enforce consistent value counts across rows
++  test-insert-00
  =/  expected1  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table']
                columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~]
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]]]]
                as-of=~
            ==
        ~
        ~
  =/  expected2  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='dbo' name='my-table']
                columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~]
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]]]]
                as-of=~
            ==
        ~
        ~
  =/  urql1  " iNsert  iNto  db.ns.my-table  ".
"( col1 ,  col2 ,  col3 ,  col4 ,  col5 ,  col6 ,  col7 ,  col8 ,  col9 )".
" Values  ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
"  (Default,.195.198.143.90, 195.198.143.900)"
  =/  urql2  "insert into db..my-table ".
"(col1, col2, col3, col4, col5, col6, col7, col8, col9)".
"valueS ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)"
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  (parse:parse(default-database 'other-db') (weld urql1 (weld ";" urql2)))
::
:: no columns, 3 rows
++  test-insert-01
  =/  expected  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table']
                columns=~
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]] ~[[~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]
                as-of=~
            ==
        ~
        ~
  =/  urql  "insert into my-table ".
"values ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
" (default,.195.198.143.90, 195.198.143.900)".
" (2.222,2222,195.198.143.900,.3.14,.-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: no columns, 3 rows, as of now
++  test-insert-02
  =/  expected  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table']
                columns=~
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]] ~[[~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]
                as-of=~
            ==
        ~
        ~
  =/  urql  "insert into my-table ".
"values ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
" (default,.195.198.143.90, 195.198.143.900)".
" (2.222,2222,195.198.143.900,.3.14,.-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)".
" as of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: no columns, 3 rows, as of ~2023.12.25..7.15.0..1ef5
++  test-insert-03
  =/  expected  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table']
                columns=~
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]] ~[[~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]
                as-of=[~ ~2023.12.25..7.15.0..1ef5]
            ==
        ~
        ~
  =/  urql  "insert into my-table ".
"values ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
" (default,.195.198.143.90, 195.198.143.900)".
" (2.222,2222,195.198.143.900,.3.14,.-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)".
" as of ~2023.12.25..7.15.0..1ef5"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: no columns, 3 rows, as of 5 days ago
++  test-insert-04
  =/  expected  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db1' namespace='dbo' name='my-table']
                columns=~
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]] ~[[~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]
                as-of=[~ %as-of-offset 5 %days]
            ==
        ~
        ~
  =/  urql  "insert into my-table ".
"values ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
" (default,.195.198.143.90, 195.198.143.900)".
" (2.222,2222,195.198.143.900,.3.14,.-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)".
" as of 5 days ago"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: no columns, 3 rows, as of now
++  test-insert-05
  =/  expected
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table']
                columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~]
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]]]]
                as-of=~
            ==
        ~
        ~
  =/  urql  "insert  into  db.ns.my-table ".
"(col1, col2, col3, col4, col5, col6, col7, col8, col9 )".
" values  ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
"  (default,.195.198.143.90, 195.198.143.900) as of now"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'other-db') urql)
::
:: no columns, 3 rows, as of now
++  test-insert-06
  =/  expected
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table']
                columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~]
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]]]]
                as-of=[~ ~2023.12.25..7.15.0..1ef5]
            ==
        ~
        ~
  =/  urql  "insert  into  db.ns.my-table ".
"(col1, col2, col3, col4, col5, col6, col7, col8, col9 )".
" values  ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
"  (default,.195.198.143.90, 195.198.143.900) as of ~2023.12.25..7.15.0..1ef5"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'other-db') urql)
::
:: no columns, 3 rows, as of offset
++  test-insert-07
  =/  expected
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table']
                columns=`['col1' 'col2' 'col3' 'col4' 'col5' 'col6' 'col7' 'col8' 'col9' ~]
                values=[%data ~[~[[~.t 1.685.221.219] [~.rs 1.078.523.331] [~.sd 39] [~.ud 20] [~.rs 1.078.523.331] [~.p 28.242.037] [~.rs 3.226.006.979] [~.t 430.158.540.643] [~.sd 6]] ~[[~.default 32.770.348.699.510.116] [~.if 3.284.569.946] [~.ud 195.198.143.900]]]]
                as-of=[~ %as-of-offset 5 %days]
            ==
        ~
        ~
  =/  urql  "insert  into  db.ns.my-table ".
"(col1, col2, col3, col4, col5, col6, col7, col8, col9 )".
" values  ('cord',.3.14,-20,20,.3.14,~nomryg-nilref,.-3.14, 'cor\\'d', --3)".
"  (default,.195.198.143.90, 195.198.143.900) as of 5 days ago"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'other-db') urql)
::
:: every column type, no spaces around values
++  test-insert-08
  =/  expected  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table']
                columns=~
                values=[%data ~[~[[~.t 1.685.221.219] [~.p 28.242.037] [~.p 28.242.037] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.dr 114.450.695.119.985.999.668.576.256] [~.dr 114.450.695.119.985.999.668.576.256] [~.if 3.284.569.946] [~.is 123.543.654.234] [~.f 0] [~.f 1] [~.f 0] [~.f 1] [~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]
                as-of=~
            ==
        ~
        ~
  =/  urql  "insert into db.ns.my-table ".
"values ('cord',~nomryg-nilref,nomryg-nilref,~2020.12.25..7.15.0..1ef5,2020.12.25..7.15.0..1ef5,".
"~d71.h19.m26.s24..9d55, d71.h19.m26.s24..9d55,.195.198.143.90,.0.0.0.0.0.1c.c3c6.8f5a,y,n,Y,N,".
"2.222,2222,195.198.143.900,.3.14,.-3.14,~3.14,~-3.14,0x12.6401,10.1011,-20,--20,e2O.l4Xpm,pm.l4e2O.l4Xpm)"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
::
:: every column type, spaces on all sides of values, comma inside cord
++  test-insert-09
  =/  expected  
    :+  %transform
        ctes=~
        :+  :*  %insert
                table=[%qualified-object ship=~ database='db' namespace='ns' name='my-table']
                columns=~
                values=[%data ~[~[[~.t 430.242.426.723] [~.p 28.242.037] [~.p 28.242.037] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.da 170.141.184.504.830.774.788.415.618.594.688.204.800] [~.dr 114.450.695.119.985.999.668.576.256] [~.dr 114.450.695.119.985.999.668.576.256] [~.if 3.284.569.946] [~.is 123.543.654.234] [~.f 0] [~.f 1] [~.f 0] [~.f 1] [~.ud 2.222] [~.ud 2.222] [~.ud 195.198.143.900] [~.rs 1.078.523.331] [~.rs 3.226.006.979] [~.rd 4.614.253.070.214.989.087] [~.rd 13.837.625.107.069.764.895] [~.ux 1.205.249] [~.ub 43] [~.sd 39] [~.sd 40] [~.uw 61.764.130.813.526] [~.uw 1.870.418.170.505.042.572.886]]]]
                as-of=~
            ==
        ~
        ~
  =/  urql  "insert into db.ns.my-table ".
"values ( 'cor,d' , ~nomryg-nilref , nomryg-nilref , ~2020.12.25..7.15.0..1ef5 , 2020.12.25..7.15.0..1ef5 , ".
"~d71.h19.m26.s24..9d55 ,  d71.h19.m26.s24..9d55 , .195.198.143.90 , .0.0.0.0.0.1c.c3c6.8f5a , y , n , Y , N , ".
"2.222 , 2222 , 195.198.143.900 , .3.14 , .-3.14 , ~3.14 , ~-3.14 , 0x12.6401 , 10.1011 , -20 , --20 , e2O.l4Xpm , pm.l4e2O.l4Xpm )"
  %+  expect-eq
    !>  ~[expected]
    !>  (parse:parse(default-database 'db1') urql)
    

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
