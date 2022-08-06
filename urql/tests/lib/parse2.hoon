/+  parse, *test
|%
++  test-blah
  ;:  weld
    %+  expect-eq
    !>  %.y
    !>  %.y
    ::
    %+  expect-eq
    !>  %.y
    !>  %.y
::  watch rsync -zr --delete ~/GitRepos/urQL/urql/* ~/urbit/zod/urql