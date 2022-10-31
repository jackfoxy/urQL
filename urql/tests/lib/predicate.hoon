/+  parse,  *test
|%
::  predicate
::
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
++  king-and                 [%and [second-and] last-or]::
::  complext predicate
++  test-predicate-34
  =/  predicate  " A1.adoption-email = A2.adoption-email  ".
  "  AND     A1.adoption-date = A2.adoption-date  ".
  "  AND    foo = bar  ".
  "  AND ((A1.name = A2.name AND A1.species > A2.species) ".
  "       OR ".
  "       (A1.name > A2.name AND A1.species = A2.species) ".
  "       OR ".
  "      (A1.name > A2.name AND A1.species > A2.species) ".
  "     ) "
  %+  expect-eq
    !>  [%and [%and [%and [%eq a1-adoption-email a2-adoption-email] [%eq a1-adoption-date a2-adoption-date]] [%eq foo bar]] [%or [%or [%and [%eq a1-name a2-name] [%gt a1-species a2-species]] [%and [%gt a1-name a2-name] [%eq a1-species a2-species]]] [%and [%gt a1-name a2-name] [%gt a1-species a2-species]]]]
    !>  (wonk (parse-predicate:parse [[1 1] predicate]))
--