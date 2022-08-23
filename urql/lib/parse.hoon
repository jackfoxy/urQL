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
    grant:ast
    revoke:ast
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
    %grant
    %revoke
    %truncate-table
  ==
::
::  get next position in script
::
++  get-next-cursor
  |=  [last-cursor=[@ud @ud] command-hair=[@ud @ud] end-hair=[@ud @ud]]
  ^-  [@ud @ud]
  =/  next-hair  ?:  (gth -.command-hair 1)                   :: if we advanced to next input line
        [(sub (add -.command-hair -.last-cursor) 1) +.command-hair]       ::   add lines and use last column
      [-.command-hair (sub (add +.command-hair +.last-cursor) 1)]         :: else add column positions
  ?:  (gth -.end-hair 1)                                      :: if we advanced to next input line
    [(sub (add -.next-hair -.end-hair) 1) +.end-hair]         ::   add lines and use last column
  [-.next-hair (sub (add +.next-hair +.end-hair) 1)]          :: else add column positions
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
++  cook-qualified-3object 
  |=  a=*
  ?:  ?=([[@ %~] [@ %~] [@ %~]] a)                            :: db.ns.name
    (qualified-object:ast %qualified-object ~ `@t`-<.a `@t`+<-.a `@t`+>-.a)
  ?:  ?=([[@ %~] * [@ %~]] a)                                 :: db..name
    (qualified-object:ast %qualified-object ~ `@t`-<.a 'dbo' `@t`+>-.a)
  ?:  ?=([[@ %~] [@ %~]] a)                                   :: ns.name
    (qualified-object:ast %qualified-object ~ current-database `@t`-<.a `@t`+<.a)
  ?:  ?=([@ %~] a)                                            :: name
    (qualified-object:ast %qualified-object ~ current-database 'dbo' `@t`-.a)
  !!
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
++  qualified-namespace
  |=  [a=* current-database=@t]
  ?:  ?=([@ @] [a])
    a
  [current-database a]
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
  =/  parse-qualified-3object  (cook cook-qualified-3object ;~(pfix whitespace parse-qualified-3))
  =/  parse-table-or-view  ;~  sfix
        ;~(pose ;~(pfix whitespace ;~(plug (jester 'force') parse-qualified-3object)) parse-qualified-3object)
        end-or-next-command
        ==
  =/  parse-ship  ;~(pfix sig fed:ag)
  =/  parse-qualified-object  (cook cook-qualified-object ;~(pose ;~((glue dot) parse-ship (star sym) (star sym) (star sym)) ;~((glue dot) parse-ship (star sym) dot dot (star sym)) parse-qualified-3))
  =/  on-database  ;~(plug (jester 'database') parse-face)
  =/  on-namespace
        ;~(plug (jester 'namespace') (cook |=(a=* (qualified-namespace [a current-database])) parse-qualified-2-name))
  =/  grant-object
        ;~(pfix whitespace ;~(pfix (jester 'on') ;~(pfix whitespace ;~(pose on-database on-namespace parse-qualified-3object))))
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
      (cold %grant ;~(plug whitespace (jester 'grant')))
      (cold %revoke ;~(plug whitespace (jester 'revoke')))
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
      ~|  "Cannot parse name to term in create-namespace {<p.q.command-nail>}"
            =/  create-namespace-nail  (parse-create-namespace [[1 1] q.q.command-nail])
      =/  parsed  (wonk create-namespace-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:create-namespace-nail])
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
      =/  parse-drop-database  ;~  sfix
            ;~(pose ;~(plug ;~(pfix whitespace (jester 'force')) ;~(pfix whitespace sym)) ;~(pfix whitespace sym))
            end-or-next-command
            ==
      ~|  "Cannot parse drop-database {<p.q.command-nail>}"
      =/  drop-database-nail  (parse-drop-database [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-database-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:drop-database-nail])
      ?@  parsed                                              :: name
        %=  $                                      
          script           q.q.u.+3.q:drop-database-nail
          script-position  next-cursor
          commands         [`command-ast`(drop-database:ast %drop-database parsed %.n) commands]
        ==
      ?:  ?=([@ @] parsed)                                    :: force name
        %=  $                                      
          script           q.q.u.+3.q:drop-database-nail
          script-position  next-cursor
          commands         [`command-ast`(drop-database:ast %drop-database +.parsed %.y) commands]
        ==
      !!
    %drop-index
      =/  parse-drop-index  ;~  sfix
        ;~(pfix whitespace ;~(plug parse-face ;~(pfix whitespace ;~(pfix (jester 'on') ;~(pfix whitespace parse-qualified-3object)))))
        end-or-next-command
        ==
      ~|  "Cannot parse drop-index {<p.q.command-nail>}"
      =/  drop-index-nail  (parse-drop-index [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-index-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:drop-index-nail])
      %=  $                                      
        script           q.q.u.+3.q:drop-index-nail
        script-position  next-cursor
        commands         [`command-ast`(drop-index:ast %drop-index -.parsed +.parsed) commands]
      ==
    %drop-namespace
      =/  parse-drop-namespace  ;~  sfix
            ;~(pose ;~(plug ;~(pfix whitespace (cold %force (jester 'force'))) parse-qualified-2-name) parse-qualified-2-name)
            end-or-next-command
            ==
      ~|  "Cannot parse drop-namespace {<p.q.command-nail>}"
      =/  drop-namespace-nail  (parse-drop-namespace [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-namespace-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:drop-namespace-nail])
      ?@  parsed                                              :: name
        %=  $                                      
          script           q.q.u.+3.q:drop-namespace-nail
          script-position  next-cursor
          commands         [`command-ast`(drop-namespace:ast %drop-namespace current-database parsed %.n) commands]
        ==
      ?:  ?=([@ @] parsed)                                    :: force name
        ?:  =(%force -.parsed)                 
          %=  $                                      
            script           q.q.u.+3.q:drop-namespace-nail
            script-position  next-cursor
            commands         [`command-ast`(drop-namespace:ast %drop-namespace current-database +.parsed %.y) commands]
          ==
        %=  $                                                 :: db.name                        
          script           q.q.u.+3.q:drop-namespace-nail
          script-position  next-cursor
          commands         [`command-ast`(drop-namespace:ast %drop-namespace -.parsed +.parsed %.n) commands]
        ==
      ?:  ?=([* [@ @]] parsed)                                :: force db.name
        %=  $                                      
          script           q.q.u.+3.q:drop-namespace-nail
          script-position  next-cursor
          commands         [`command-ast`(drop-namespace:ast %drop-namespace +<.parsed +>.parsed %.y) commands]
        ==
      !!
    %drop-table
      ~|  "Cannot parse drop-table {<p.q.command-nail>}"   
      =/  drop-table-nail  (parse-table-or-view [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-table-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:drop-table-nail])
      ?:  ?=([@ @ @ @ @ @] parsed)                     :: force qualified table name
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table +.parsed %.y) commands]
        ==
      ?:  ?=([@ @ @ @ @] parsed)                              :: qualified table name
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table parsed %.n) commands]
        ==
      !!
    %drop-view
      ~|  "Cannot parse drop-view {<p.q.command-nail>}"   
      =/  drop-view-nail  (parse-table-or-view [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-view-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:drop-view-nail])
      ?:  ?=([@ @ @ @ @ @] parsed)                     :: force qualified view
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view +.parsed %.y) commands]
        ==
      ?:  ?=([@ @ @ @ @] parsed)                              :: qualified view
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view parsed %.n) commands]
        ==
      !!
    %grant
      =/  permission
            ;~(pfix whitespace ;~(pose (jester 'adminread') (jester 'readonly') (jester 'readwrite')))
      =/  grantee
            ;~(pose (jester 'parent') (jester 'siblings') (jester 'moons') (stag %ship parse-ship)) 
      =/  parse-grantee
            ;~(pfix whitespace ;~(pfix (jester 'to') ;~(pfix whitespace grantee)))
      =/  parse-grant  ;~  plug
            permission
            parse-grantee
            ;~(sfix grant-object end-or-next-command)
            ==
      ~|  "Cannot parse grant {<p.q.command-nail>}"   
      =/  grant-nail  (parse-grant [[1 1] q.q.command-nail])
      =/  parsed  (wonk grant-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:grant-nail])
      ?:  ?=([@ [@ @] [@ @]] [parsed])              ::"grant adminread to ~sampel-palnet on database db"
        %=  $                             
          script           q.q.u.+3.q:grant-nail
          script-position  next-cursor
          commands         
            [`command-ast`(grant:ast %grant -.parsed (limo ~[+<+.parsed]) +>.parsed) commands]
        ==
      ?:  ?=([@ @ [@ @]] [parsed])                  ::"grant adminread to parent on database db"
        %=  $                             
          script           q.q.u.+3.q:grant-nail
          script-position  next-cursor
          commands         
            [`command-ast`(grant:ast %grant -.parsed +<.parsed +>.parsed) commands]
        ==
      ?:  ?=([@ [@ @] [@ *]] [parsed])              ::"grant Readwrite to ~sampel-palnet on namespace db.ns"
        %=  $                                       ::"grant adminread to ~sampel-palnet on namespace ns" (ns previously cooked) 
          script           q.q.u.+3.q:grant-nail    ::"grant Readwrite to ~sampel-palnet on db.ns.table"
          script-position  next-cursor
          commands         
            [`command-ast`(grant:ast %grant -.parsed (limo ~[+<+.parsed]) +>.parsed) commands]
        ==
      ?:  ?=([@ @ [@ [@ *]]] [parsed])              ::"grant readonly to siblings on namespace db.ns"
        %=  $                                       ::"grant readwrite to moons on namespace ns" (ns previously cooked) 
          script           q.q.u.+3.q:grant-nail
          script-position  next-cursor
          commands         
            [`command-ast`(grant:ast %grant -.parsed +<.parsed +>.parsed) commands]
        ==
      !!
    %revoke
      =/  revoke-permission
            ;~(pfix whitespace ;~(pose (jester 'adminread') (jester 'readonly') (jester 'readwrite') (jester 'all')))
      =/  revokee
            ;~(pose (jester 'parent') (jester 'siblings') (jester 'moons') (jester 'all') (stag %ship parse-ship)) 
      =/  parse-revokee
            ;~(pfix whitespace ;~(pfix (jester 'from') ;~(pfix whitespace revokee)))
      =/  parse-revoke  ;~  plug
            revoke-permission
            parse-revokee
            ;~(sfix grant-object end-or-next-command)
            ==
      ~|  "Cannot parse revoke {<p.q.command-nail>}"   
      =/  revoke-nail  (parse-revoke [[1 1] q.q.command-nail])
      =/  parsed  (wonk revoke-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:revoke-nail])
      ?:  ?=([@ [@ @] [@ @]] [parsed])              ::"revoke adminread from ~sampel-palnet on database db"
        %=  $                             
          script           q.q.u.+3.q:revoke-nail
          script-position  next-cursor
          commands         
            [`command-ast`(revoke:ast %revoke -.parsed (limo ~[+<+.parsed]) +>.parsed) commands]
        ==
      ?:  ?=([@ @ [@ @]] [parsed])                  ::"revoke adminread from parent on database db"
        %=  $                             
          script           q.q.u.+3.q:revoke-nail
          script-position  next-cursor
          commands         
            [`command-ast`(revoke:ast %revoke -.parsed +<.parsed +>.parsed) commands]
        ==
      ?:  ?=([@ [@ @] [@ *]] [parsed])              ::"revoke Readwrite from ~sampel-palnet on namespace db.ns"
        %=  $                                       ::"revoke adminread from ~sampel-palnet on namespace ns" (ns previously cooked) 
          script           q.q.u.+3.q:revoke-nail   ::"revoke Readwrite from ~sampel-palnet on db.ns.table"
          script-position  next-cursor
          commands         
            [`command-ast`(revoke:ast %revoke -.parsed (limo ~[+<+.parsed]) +>.parsed) commands]
        ==
      ?:  ?=([@ @ [@ [@ *]]] [parsed])              ::"revoke readonly from siblings on namespace db.ns"
        %=  $                                       ::"revoke readwrite from moons on namespace ns" (ns previously cooked) 
          script           q.q.u.+3.q:revoke-nail
          script-position  next-cursor
          commands         
            [`command-ast`(revoke:ast %revoke -.parsed +<.parsed +>.parsed) commands]
        ==
      !!
    %truncate-table
      =/  parse-truncate-table  ;~  sfix
            ;~(pfix whitespace parse-qualified-object)
            end-or-next-command
            ==   
      ~|  "Cannot parse truncate-table {<p.q.command-nail>}"
      =/  truncate-table-nail  (parse-truncate-table [[1 1] q.q.command-nail])
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:truncate-table-nail])
      %=  $
        script           q.q.u.+3.q:truncate-table-nail
        script-position  next-cursor
        commands
          [`command-ast`(truncate-table:ast %truncate-table (wonk truncate-table-nail)) commands]         
      ==
    ==
--
