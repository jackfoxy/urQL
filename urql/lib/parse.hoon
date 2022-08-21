/-  ast
|_  current-database=@t                                      :: (parse:parse(current-database '<db>') "<script>")
+$  command-ast
  $%
    create-database:ast
    create-index:ast
    create-namespace:ast
    create-table:ast
    create-view:ast
    drop-database:ast
    drop-index:ast
    drop-namespace:ast
    drop-table:ast
    drop-view:ast
    truncate-table:ast
  ==
+$  command
  $%
    %create-database
    %create-index
    %create-namespace
    %create-table
    %create-view
    %drop-database
    %drop-index
    %drop-namespace
    %drop-table
    %drop-view
    %truncate-table
  ==
::
::  parser rules and helpers
::
++  jester                                                    ::  match a cord, case agnostic, thanks ~tinnus-napbus
  |=  daf=@t
  |=  tub=nail
  =+  fad=daf
  |-  ^-  (like @t)
  ?:  =(`@`0 daf)
    [p=p.tub q=[~ u=[p=fad q=tub]]]
  =+  n=(end 3 daf)
  ?.  ?&  ?=(^ q.tub)  
          ?|  =(n i.q.tub)
              &((lte 97 n) (gte 122 n) =((sub n 32) i.q.tub))
              &((lte 65 n) (gte 90 n) =((add 32 n) i.q.tub))
          ==
      ==
    (fail tub)
  $(p.tub (lust i.q.tub p.tub), q.tub t.q.tub, daf (rsh 3 daf))
++  cook-qualified-object 
  |=  a=*
  ?:  ?=([@ [@ %~] [@ %~] [@ %~]] a)                          :: ~firsub.db.ns.name
    (qualified-object:ast %qualified-object ``@p`-.a `@t`+<-.a `@t`+>-<.a `@t`+>+<.a)
  ?:  ?=([@ [@ %~] * [@ %~]] a)                               ::~firsub..ns.name
    (qualified-object:ast %qualified-object ``@p`-.a `@t`+<-.a 'dbo' `@t`+>+<.a)
  ?:  ?=([[@ %~] [@ %~] [@ %~]] a)                            :: db.ns.name
    (qualified-object:ast %qualified-object ~ `@t`-<.a `@t`+<-.a `@t`+>-.a)
  ?:  ?=([[@ %~] * [@ %~]] a)                                 :: db..name
    (qualified-object:ast %qualified-object ~ `@t`-<.a 'dbo' `@t`+>-.a)
  ?:  ?=([[@ %~] [@ %~]] a)                                   :: ns.name
    (qualified-object:ast %qualified-object ~ current-database `@t`-<.a `@t`+<.a)
  ?:  ?=([@ %~] a)                                            :: name
    (qualified-object:ast %qualified-object ~ current-database 'dbo' `@t`-.a)
  !!
::
::  parse urQL script
::
++  parse
  |=  script=tape
  ~|  'Input script is empty.'
  ?>  !=((lent script) 0)
  ^-  (list command-ast)
  =/  commands  `(list command-ast)`~
  =/  script-position  [1 1]
  ::
  :: parser rules
  ::
  =/  whitespace  (star ;~(pose gah (just '\09') (just '\0d')))
  =/  end-or-next-command  ;~(pose ;~(plug whitespace mic) whitespace mic)
  =/  parse-face  ;~(pfix whitespace sym)
  =/  parse-qualified-2-name  ;~(pose ;~(pfix whitespace ;~((glue dot) sym sym)) parse-face)
  =/  parse-qualified-3  ;~  pose
          ;~((glue dot) (star sym) (star sym) (star sym))
          ;~(plug (star sym) dot dot (star sym))
          ;~((glue dot) (star sym) (star sym))
          (star sym)
        ==
  =/  parse-qualified-3-name  ;~(pfix whitespace parse-qualified-3)
  =/  parse-force-or-3-name  ;~(pose ;~(pfix whitespace (jester 'force')) parse-qualified-3-name)
  =/  parse-ship  ;~(pfix sig fed:ag)
  =/  parse-qualified-object  (cook cook-qualified-object ;~(pose ;~((glue dot) parse-ship (star sym) (star sym) (star sym)) ;~((glue dot) parse-ship (star sym) dot dot (star sym)) parse-qualified-3))
  =/  parse-force-qualified-name  ;~  sfix 
        ;~(pose ;~(plug parse-force-or-3-name parse-qualified-3-name) parse-qualified-3-name) 
        end-or-next-command
        ==
  =/  parse-command  ;~  pose
      (cold %create-database ;~(plug whitespace (jester 'create') whitespace (jester 'database')))
      (cold %create-index ;~(plug whitespace (jester 'create') whitespace (jester 'index')))
      (cold %create-namespace ;~(plug whitespace (jester 'create') whitespace (jester 'namespace')))
      (cold %create-table ;~(plug whitespace (jester 'create') whitespace (jester 'table')))
      (cold %create-view ;~(plug whitespace (jester 'create') whitespace (jester 'view')))
      (cold %drop-database ;~(plug whitespace (jester 'drop') whitespace (jester 'database')))
      (cold %drop-index ;~(plug whitespace (jester 'drop') whitespace (jester 'index')))
      (cold %drop-namespace ;~(plug whitespace (jester 'drop') whitespace (jester 'namespace')))
      (cold %drop-table ;~(plug whitespace (jester 'drop') whitespace (jester 'table')))
      (cold %drop-view ;~(plug whitespace (jester 'drop') whitespace (jester 'view')))
      (cold %truncate-table ;~(plug whitespace (jester 'truncate') whitespace (jester 'table')))
::      (cold  ;~(plug whitespace (jester '') whitespace (jester '')))
      ==
  ~|  'Current database name is not a proper term'
  =/  dummy  (scan (trip current-database) sym)
  :: main loop
  ::
  |-
  ?:  =(~ script)                  ::  https://github.com/urbit/arvo/issues/1024
    (flop commands)
  ~|  "Error parsing command keyword: {<script-position>}"
  =/  command-nail  u.+3:q.+3:(parse-command [script-position script])
  ?-  `command`p.command-nail
    %create-database
      ~|  'Create database must be only statement in script'
      ?>  =((lent commands) 0)  
      %=  $                         
        script  ""
        commands  
          [`command-ast`(create-database:ast %create-database p.u.+3:q.+3:(parse-face [[1 1] q.q.command-nail])) commands]
      ==
    %create-index
      !!
    %create-namespace
      =/  parse-create-namespace  ;~  sfix
            parse-qualified-2-name
            end-or-next-command
            ==
      ~|  "Cannot parse name to face in create-namespace {<p.q.command-nail>}"
            =/  create-namespace-nail  (parse-create-namespace [[1 1] q.q.command-nail])
      =/  parsed  (wonk create-namespace-nail)
      =/  cursor  p.q.u.+3:q.+3:create-namespace-nail
      =/  next-cursor  ?:  (gth -.cursor -.script-position)   :: if we advanced to next input line
            [(add -.cursor -.script-position) +.cursor]       ::   add lines and use nail cursor column
          [-.cursor (add +.cursor +.script-position)]         :: else add column positions
      ?@  parsed
        %=  $                                      
          script           q.q.u.+3.q:create-namespace-nail
          script-position  next-cursor
          commands         [`command-ast`(create-namespace:ast %create-namespace current-database parsed) commands]
        ==
      %=  $                                      
        script           q.q.u.+3.q:create-namespace-nail
        script-position  next-cursor
        commands         [`command-ast`(create-namespace:ast %create-namespace -.parsed +.parsed) commands]
      ==
    %create-table
      !!
    %create-view
      !!
    %drop-database
      !!
    %drop-index
      !!
    %drop-namespace
      !!
    %drop-table
      ~|  "Cannot parse drop-table {<p.q.command-nail>}"   
      =/  drop-table-nail  (parse-force-qualified-name [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-table-nail)
      =/  cursor  p.q.u.+3:q.+3:drop-table-nail
      =/  next-cursor  ?:  (gth -.cursor -.script-position)   :: if we advanced to next input line
            [(add -.cursor -.script-position) +.cursor]       ::   add lines and use nail cursor column
          [-.cursor (add +.cursor +.script-position)]         :: else add column positions
      ?:  ?=([@ [[@ %~] [@ %~] [@ %~]]] parsed)               :: "drop table force db.ns.name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table i.+<.parsed i.+>-.parsed i.+>+.parsed %.y) commands]
        ==
      ?:  ?=([@ [[@ %~] @ [@ %~]]] parsed)                  :: "drop table force db..name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table i.+<.parsed 'dbo' +>+<.parsed %.y) commands]
        ==
      ?:  ?=([@ [[@ %~] [@ %~]]] parsed)                      :: "drop table force ns.name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table current-database i.+<.parsed +>-.parsed %.y) commands]
        ==
      ?:  ?=([@ [@ %~]] parsed)                               :: "drop table force name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table current-database 'dbo' +<.parsed %.y) commands]
        ==
      ?:  ?=([[[@ %~] [@ %~] [@ %~]] %~] parsed)              :: "drop table db.ns.name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table i.-<.parsed i.->-.parsed i.->+.parsed %.n) commands]
        ==
      ?:  ?=([[[@ %~] @ [@ %~]] %~] parsed)                 :: "drop table db..name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table i.-<.parsed 'dbo' ->+<.parsed %.n) commands]
        ==
      ?:  ?=([[[@ %~] [@ %~]] %~] parsed)                     :: "drop table ns.name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table current-database i.-<.parsed ->-.parsed %.n) commands]
        ==
      ?:  ?=([[@ %~] %~] parsed)                              :: "drop table name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table current-database 'dbo' -<.parsed %.n) commands]
        ==
      !!
    %drop-view
      ~|  "Cannot parse drop-view {<p.q.command-nail>}"   
      =/  drop-view-nail  (parse-force-qualified-name [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-view-nail)
      =/  cursor  p.q.u.+3:q.+3:drop-view-nail
      =/  next-cursor  ?:  (gth -.cursor -.script-position)   :: if we advanced to next input line
            [(add -.cursor -.script-position) +.cursor]       ::   add lines and use nail cursor column
          [-.cursor (add +.cursor +.script-position)]         :: else add column positions
      ?:  ?=([@ [[@ %~] [@ %~] [@ %~]]] parsed)               :: "drop view force db.ns.name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view i.+<.parsed i.+>-.parsed i.+>+.parsed %.y) commands]
        ==
      ?:  ?=([@ [[@ %~] @ [@ %~]]] parsed)                  :: "drop view force db..name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view i.+<.parsed 'dbo' +>+<.parsed %.y) commands]
        ==
      ?:  ?=([@ [[@ %~] [@ %~]]] parsed)                      :: "drop view force ns.name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view current-database i.+<.parsed +>-.parsed %.y) commands]
        ==
      ?:  ?=([@ [@ %~]] parsed)                               :: "drop view force name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view current-database 'dbo' +<.parsed %.y) commands]
        ==
      ?:  ?=([[[@ %~] [@ %~] [@ %~]] %~] parsed)              :: "drop view db.ns.name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view i.-<.parsed i.->-.parsed i.->+.parsed %.n) commands]
        ==
      ?:  ?=([[[@ %~] @ [@ %~]] %~] parsed)                 :: "drop view db..name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view i.-<.parsed 'dbo' ->+<.parsed %.n) commands]
        ==
      ?:  ?=([[[@ %~] [@ %~]] %~] parsed)                     :: "drop view ns.name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view current-database i.-<.parsed ->-.parsed %.n) commands]
        ==
      ?:  ?=([[@ %~] %~] parsed)                              :: "drop view name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view current-database 'dbo' -<.parsed %.n) commands]
        ==
      !!
    %truncate-table
      =/  parse-truncate-table  ;~  sfix
            ;~(pfix whitespace parse-qualified-object)
            end-or-next-command
            ==   
      ~|  "Cannot parse truncate-table {<p.q.command-nail>}"
      =/  truncate-table-nail  (parse-truncate-table [[1 1] q.q.command-nail])
      =/  cursor  p.-.truncate-table-nail
      =/  next-cursor  ?:  (gth -.cursor -.script-position)   :: if we advanced to next input line
            [(add -.cursor -.script-position) +.cursor]       ::   add lines and use nail cursor column
          [-.cursor (add +.cursor +.script-position)]         :: else add column positions
      %=  $
        script           q.q.u.+3.q:truncate-table-nail
        script-position  next-cursor
        commands
          [`command-ast`(truncate-table:ast %truncate-table (wonk truncate-table-nail)) commands]         
      ==
    ==
--
