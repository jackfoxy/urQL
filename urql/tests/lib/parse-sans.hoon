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
::

::  predicate
::
::  re-used components
++  all-columns  [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL']
++  foo
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo'] 'foo' ~] ~ ~]
++  t1-foo
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo' ~] ~ ~]

++  foo2                 [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo2'] 'foo2' ~] ~ ~]
++  t1-foo2              [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo2' ~] ~ ~]
++  foo3                 [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo3'] 'foo3' ~] ~ ~]
++  t1-foo3              [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T1'] 'foo3' ~] ~ ~]
++  foo4                 [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo4'] 'foo4' ~] ~ ~]
++  foo5                 [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo5'] 'foo5' ~] ~ ~]
++  foo6                 [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo6'] 'foo6' ~] ~ ~]
++  foo7                 [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foo7'] 'foo7' ~] ~ ~]
++  bar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'bar'] 'bar' ~] ~ ~]
++  t2-bar
  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'T2'] 'bar' ~] ~ ~]

++  foobar               [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN-OR-CTE' 'foobar'] 'foobar' ~] ~ ~]

++  a1-adoption-email  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A1'] 'adoption-email' ~] ~ ~]
++  a2-adoption-email  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A2'] 'adoption-email' ~] ~ ~]

++  a1-adoption-date  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A1'] 'adoption-date' ~] ~ ~]
++  a2-adoption-date  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A2'] 'adoption-date' ~] ~ ~]

++  a1-name  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A1'] 'name' ~] ~ ~]
++  a2-name  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A2'] 'name' ~] ~ ~]
++  a1-species  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A1'] 'species' ~] ~ ~]
++  a2-species  [[%qualified-column [%qualified-object ~ 'UNKNOWN' 'COLUMN' 'A2'] 'species' ~] ~ ~]

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

::
::  select
::
++  mixed-all
  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='db' namespace='dbo' name='t1'] column='ALL' alias=~] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=[~ 'foobar']] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] [%qualified-object ship=~ database='ALL' namespace='ALL' name='ALL'] [%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='T2'] column='ALL' alias=~]]
++  aggregates
  ~[[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~] [%selected-aggregate aggregate='COUNT' column=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foo'] column='foo' alias=~] alias=[~ 'CountFoo']] [%selected-aggregate aggregate='cOUNT' column=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] alias=~] [%selected-aggregate aggregate='sum' column=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='bar'] column='bar' alias=~] alias=~] [%selected-aggregate aggregate='sum' column=[%qualified-column qualifier=[%qualified-object ship=~ database='UNKNOWN' namespace='COLUMN-OR-CTE' name='foobar'] column='foobar' alias=~] alias=[~ 'foobar']]]

++  test-select-23
  =/  select  "select  foo , COUNT(foo) as CountFoo, cOUNT( bar) ,sum(bar ) , sum( foobar ) as foobar "
::::  =/  my-columns
  %+  expect-eq
::::    !>  [%select [aggregates]]
    !>  ~[[%simple-query ~ [%select top=[~ 10] bottom=[~ 10] distinct=%.y columns=aggregates] ~]]
    !>  (parse:parse(current-database 'db1') select)
--