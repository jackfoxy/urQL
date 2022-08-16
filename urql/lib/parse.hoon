/-  ast
|%
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
  ==
::
::  turn an atom into upper case cord
::  (this has got to be super inefficient, but it was easy)
++  trip-cuss-crip
  |=  target=@
  ^-  @t
  (crip (cuss (trip `@t`target)))
::
::  match a cord, case agnostic
::
++  jester
  |=  daf=@t
  |=  tub=nail
  =+  fad=daf
  |-  ^-  (like @t)
  ?:  =(`@`0 daf)
    [p=p.tub q=[~ u=[p=fad q=tub]]]
  ?:  |(?=(~ q.tub) !=((trip-cuss-crip (end 3 daf)) (trip-cuss-crip i.q.tub)))
    (fail tub)
  $(p.tub (lust i.q.tub p.tub), q.tub t.q.tub, daf (rsh 3 daf))
::
::  the main event
::
++  parse
  |=  [current-database=@t script=tape]
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
                              ;~(plug (star sym) dot dot (star sym))
                              ;~((glue dot) (star sym) (star sym) (star sym))
                              ;~((glue dot) (star sym) (star sym))
                              (star sym)
                            ==
  =/  parse-qualified-3-name  ;~(pfix whitespace parse-qualified-3)
  =/  parse-force-or-3-name  ;~(pose ;~(pfix whitespace (jester 'force')) parse-qualified-3-name)
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
::      (cold  ;~(plug whitespace (jester '') whitespace (jester '')))
      ==
  ~|  'Current database name is not a proper face'
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
      ~|  "Cannot parse name to face in create-namespace {<p.q.command-nail>}"   
      =/  qualified-name-nail  u.+3:q.+3:(parse-qualified-2-name [[1 1] q.q.command-nail])
      =/  namespace-ast  ?@  p.qualified-name-nail
        (create-namespace:ast %create-namespace current-database p.qualified-name-nail)
      (create-namespace:ast %create-namespace -:p.qualified-name-nail +:p.qualified-name-nail)
      =/  last-nail  (end-or-next-command q:qualified-name-nail)
      ?:  (gth -.p:last-nail -.p.q.command-nail)   :: if we advanced to next input line
        %=  $
          script           q.q.u.+3.q:last-nail    :: then use the current position
          script-position  [p.p.q.+3.+3.q:last-nail q.p.q.+3.+3.q:last-nail]
          commands         [`command-ast`namespace-ast commands]
        ==
      %=  $                                      
        script           q.q.u.+3.q:last-nail      :: else add starting column to current column position
        script-position  [p.p.q.command-nail (add q.p.q.command-nail q.p.q.+3.+3.q.last-nail)]
        commands         [`command-ast`namespace-ast commands]
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
      !!
    %drop-view
      =/  parse-drop-view  ;~  sfix 
            ;~(pose ;~(plug parse-force-or-3-name parse-qualified-3-name) parse-qualified-3-name) 
            end-or-next-command
            ==
      ~|  "Cannot parse drop-view {<p.q.command-nail>}"   
      =/  drop-view-nail  (parse-drop-view [[1 1] q.q.command-nail])
      =/  parsed  p.u.+3:q.+3:drop-view-nail
      =/  cursor  p.q.u.+3:q.+3:drop-view-nail
      =/  next-cursor  ?:  (gth -.cursor -.script-position)   :: if we advanced to next input line
            cursor
          [-.cursor (add +.cursor +.script-position)]
::
:: "drop view force db.ns.name"
      ?:  ?=([@ [[@ %~] [@ %~] [@ %~]]] parsed)
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view i.+<.parsed i.+>-.parsed i.+>+.parsed %.y) commands]
        ==
::
:: "drop view force db..name"
      ?:  ?=([@ [[@ %~] @ @ [@ %~]]] parsed)
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view i.+<.parsed 'dbo' +>+>-.parsed %.y) commands]
        ==
::
:: "drop view force ns.name"
      ?:  ?=([@ [[@ %~] [@ %~]]] parsed)
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view current-database i.+<.parsed +>-.parsed %.y) commands]
        ==
::
:: "drop view force name"
      ?:  ?=([@ [@ %~]] parsed)
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view current-database 'dbo' +<.parsed %.y) commands]
        ==
::
:: "drop view db.ns.name"
      ?:  ?=([[[@ %~] [@ %~] [@ %~]] %~] parsed)
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view i.-<.parsed i.->-.parsed i.->+.parsed %.n) commands]
        ==
::
:: "drop view db..name"
      ?:  ?=([[[@ %~] @ @ [@ %~]] %~] parsed)
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view i.-<.parsed 'dbo' ->+>-.parsed %.n) commands]
        ==
::
:: "drop view ns.name"
      ?:  ?=([[[@ %~] [@ %~]] %~] parsed)
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view current-database i.-<.parsed ->-.parsed %.n) commands]
        ==
::
:: "drop view name"
      ?:  ?=([[@ %~] %~] parsed)
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view current-database 'dbo' -<.parsed %.n) commands]
        ==
      !!
    ==
--
