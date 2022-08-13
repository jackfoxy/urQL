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
++  test-current-database
    %-  expect-fail
    |.  (parse:parse ['Other-db' "cReate\0d\09  namespace my-namespace"])
::
:: tests 1, 2, 3, 5, and extra whitespace characters
++  test-create-namespace-1
  =/  expected1  [%create-namespace database-name='other-db' name='my-namespace']
  =/  expected2  [%create-namespace database-name='my-db' name='another-namespace']
  %+  expect-eq
    !>  ~[expected1 expected2]
    !>  %-  parse:parse 
    ['other-db' "cReate\0d\09  namespace my-namespace ; cReate namesPace my-db.another-namespace"]
::
:: leading and trailing whitespace characters, end delimiter not required on single
++  test-create-namespace-2
  %+  expect-eq
    !>  ~[[%create-namespace database-name='other-db' name='my-namespace']]
    !>  %-  parse:parse 
    ['other-db' "   \09cReate\0d\09  namespace my-namespace "]  
::
:: fail when database qualifier is not a face
++  test-create-namespace-3
  %-  expect-fail
  |.  (parse:parse ['other-db' "cReate namesPace Bad-face.another-namespace"])
::
:: fail when namespace is not a face
++  test-create-namespace-4
  %-  expect-fail
  |.  (parse:parse ['other-db' "cReate namesPace my-db.Bad-face"])

--
