/-  ast
|_  current-database=@t                                      :: (parse:parse(current-database '<db>') "<script>")
::
::  generic urQL command
::
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
::  helper types
::
+$  on-update
  $:
    %on-update
    action=foreign-key-action:ast
    ==
+$  on-delete
  $:
    %on-delete
    action=foreign-key-action:ast
    ==
+$  interim-key  
  $:
    %interim-key
    is-clustered=@t
    columns=(list ordered-column:ast)
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
  ~+
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
++  cook-qualified-3object                                    ::  database.namespace.object-name
  |=  a=*
  ~+
  ?:  ?=([[@ %~] [@ %~] [@ %~]] a)                            :: db.ns.name
    (qualified-object:ast %qualified-object ~ `@t`-<.a `@t`+<-.a `@t`+>-.a)
  ?:  ?=([[@ %~] * [@ %~]] a)                                 :: db..name
    (qualified-object:ast %qualified-object ~ `@t`-<.a 'dbo' `@t`+>-.a)
  ?:  ?=([[@ %~] [@ %~]] a)                                   :: ns.name
    (qualified-object:ast %qualified-object ~ current-database `@t`-<.a `@t`+<.a)
  ?:  ?=([@ %~] a)                                            :: name
    (qualified-object:ast %qualified-object ~ current-database 'dbo' `@t`-.a)
  !!
++  cook-qualified-object                                     ::  @p.database.namespace.object-name
  |=  a=*
  ~+
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


++  cook-column
  |=  a=*
    ?:  ?=([@ @] [a])                   
      (column:ast %column -.a +.a)
    !!
++  cook-ordered-column
  |=  a=*
    ?@  a
      (ordered-column:ast %ordered-column a %asc)
    ?:  ?=([@ @] [a])                   
      (ordered-column:ast %ordered-column -.a +.a)
    !!
++  cook-primary-key
  |=  a=*
    ?@  -.a
      (interim-key %interim-key -.a +.a)
    (interim-key %interim-key %nonclustered a)
++  cook-on-update
  |=  a=*
    ?@  a
      (on-update %on-update a)
    (on-update %on-update %no-action)
++  cook-on-delete
  |=  a=*
    ?@  a
      (on-delete %on-delete a)
    (on-delete %on-delete %no-action)
++  whitespace  ~+  (star ;~(pose gah (just '\09') (just '\0d')))
++  end-or-next-command  ~+  ;~(pose ;~(plug whitespace mic) whitespace mic)
++  parse-face  ~+  ;~(pfix whitespace sym)
++  face-list  ~+  (more com parse-face)
++  qualified-namespace                                       :: database.namespace
  |=  [a=* current-database=@t]
  ~+
  ?:  ?=([@ @] [a])
    a
  [current-database a]
++  parse-qualified-2-name  ~+  ;~(pose ;~(pfix whitespace ;~((glue dot) sym sym)) parse-face)
++  parse-qualified-3  ~+  ;~  pose
  ;~((glue dot) (star sym) (star sym) (star sym))
  ;~(plug (star sym) dot dot (star sym))
  ;~((glue dot) (star sym) (star sym))
  (star sym)
  ==
++  parse-qualified-3object  ~+  (cook cook-qualified-3object ;~(pfix whitespace parse-qualified-3))
++  ordering  ~+  ;~(pfix whitespace ;~(pose (jester 'asc') (jester 'desc')))
++  clustering  ;~(pfix whitespace ;~(pose (jester 'clustered') (jester 'nonclustered')))
++  ordered-column-list  ~+
  ;~(pfix whitespace (ifix [pal par] (more com (cook cook-ordered-column ;~(pose ;~(sfix ;~(plug parse-face ordering) whitespace) ;~(plug parse-face ordering) ;~(sfix parse-face whitespace) parse-face)))))
++  open-paren  ~+  ;~  pose
  ;~(pfix whitespace ;~(sfix pal whitespace))
  ;~(pfix whitespace pal)
  ==
++  close-paren  ~+  ;~  pose
  ;~(pfix whitespace ;~(sfix par whitespace))
  ;~(pfix whitespace par)
  ==
++  parse-ship  ~+  ;~(pfix sig fed:ag)
++  white-ship  ~+  ;~(pose ;~(sfix ;~(pfix whitespace parse-ship) whitespace) ;~(pfix whitespace parse-ship) ;~(sfix parse-ship whitespace) parse-ship)
++  ship-list  ~+  (more com white-ship)
++  parse-qualified-object  ~+  (cook cook-qualified-object ;~(pose ;~((glue dot) parse-ship (star sym) (star sym) (star sym)) ;~((glue dot) parse-ship (star sym) dot dot (star sym)) parse-qualified-3))
++  on-database  ~+  ;~(plug (jester 'database') parse-face)
++  on-namespace  ~+
  ;~(plug (jester 'namespace') (cook |=(a=* (qualified-namespace [a current-database])) parse-qualified-2-name))
++  grant-object  ~+
  ;~(pfix whitespace ;~(pfix (jester 'on') ;~(pfix whitespace ;~(pose on-database on-namespace parse-qualified-3object))))
++  parse-aura  ~+ 
  =/  root-aura  ;~  pose
    (jest '@c')
    (jest '@da')
    (jest '@dr')
    (jest '@d')        
    (jest '@f')
    (jest '@if')
    (jest '@is')
    (jest '@i')        
    (jest '@n')
    (jest '@p')
    (jest '@q')
    (jest '@rh')
    (jest '@rs')
    (jest '@rd')
    (jest '@rq')
    (jest '@r')        
    (jest '@sb')
    (jest '@sd')
    (jest '@sv')
    (jest '@sw')
    (jest '@sx')
    (jest '@s')        
    (jest '@ta')
    (jest '@tas')
    (jest '@t')        
    (jest '@ub')
    (jest '@ud')
    (jest '@uv')
    (jest '@uw')
    (jest '@ux')
    (jest '@u')        
    (jest '@')
    ==
  ;~  pose
    ;~(plug root-aura (shim 'A' 'J'))
    root-aura
  ==
++  column-defintion-list  ~+
  =/  column-definition  ;~  plug
    sym
    ;~(pfix whitespace parse-aura)
    ==  
  (more com (cook cook-column ;~(pose ;~(pfix whitespace ;~(sfix column-definition whitespace)) ;~(sfix column-definition whitespace) ;~(pfix whitespace column-definition) column-definition)))
::

::  =/  prn-less-whitespace  (star ;~(less gah (just '\09') (just '\0d') (just `@`127) (shim 32 256)))
::  =/  prn-less-soz  ;~(less (just `@`39) (just `@`127) (shim 32 256))  
::  =/  cord-literal  ;~(plug soq (star ;~(pose (jest '\\\'') prn-less-soz)) soq)

::
::  parse urQL command
::
++  parse-create-namespace  ;~  sfix
  parse-qualified-2-name
  end-or-next-command
  ==
++  parse-index
  =/  is-unique  ~+  ;~(pfix whitespace (jester 'unique'))
  =/  index-name  ~+  ;~(pfix whitespace (jester 'index') parse-face)
  =/  type-and-name  ;~  pose
    ;~(plug is-unique clustering index-name)
    ;~(plug is-unique index-name)
    ;~(plug clustering index-name)
    index-name
    == 
  ;~  plug
    type-and-name
    ;~(pfix whitespace ;~(pfix (jester 'on') ;~(pfix whitespace parse-qualified-3object)))
    ;~(sfix ordered-column-list end-or-next-command)
  ==
++  parse-drop-database  ;~  sfix
  ;~(pose ;~(plug ;~(pfix whitespace (jester 'force')) ;~(pfix whitespace sym)) ;~(pfix whitespace sym))
  end-or-next-command
  ==
++  parse-drop-index  ;~  sfix
  ;~(pfix whitespace ;~(plug parse-face ;~(pfix whitespace ;~(pfix (jester 'on') ;~(pfix whitespace parse-qualified-3object)))))
  end-or-next-command
  ==
++  parse-drop-namespace  ;~  sfix
  ;~(pose ;~(plug ;~(pfix whitespace (cold %force (jester 'force'))) parse-qualified-2-name) parse-qualified-2-name)
  end-or-next-command
  ==
++  drop-table-or-view  ;~  sfix
  ;~(pose ;~(pfix whitespace ;~(plug (jester 'force') parse-qualified-3object)) parse-qualified-3object)
  end-or-next-command
  ==
++  parse-grant  ;~  plug
  :: permission
  ;~(pfix whitespace ;~(pose (jester 'adminread') (jester 'readonly') (jester 'readwrite')))
  :: grantee
  ;~(pfix whitespace ;~(pfix (jester 'to') ;~(pfix whitespace ;~(pose (jester 'parent') (jester 'siblings') (jester 'moons') (stag %ships ship-list)))))
  ;~(sfix grant-object end-or-next-command)
  ==
++  parse-revoke  ;~  plug
  :: permission
  ;~(pfix whitespace ;~(pose (jester 'adminread') (jester 'readonly') (jester 'readwrite') (jester 'all')))
  :: revokee
  ;~(pfix whitespace ;~(pfix (jester 'from') ;~(pfix whitespace ;~(pose (jester 'parent') (jester 'siblings') (jester 'moons') (jester 'all') (stag %ships ship-list)))))
  ;~(sfix grant-object end-or-next-command)
  ==
++  parse-truncate-table  ;~  sfix
  ;~(pfix whitespace parse-qualified-object)
  end-or-next-command
  ==
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
      
  =/  parse-command  ;~  pose
    (cold %create-database ;~(plug whitespace (jester 'create') whitespace (jester 'database')))
    (cold %create-namespace ;~(plug whitespace (jester 'create') whitespace (jester 'namespace')))
    (cold %create-table ;~(plug whitespace (jester 'create') whitespace (jester 'table')))
    (cold %create-view ;~(plug whitespace (jester 'create') whitespace (jester 'view')))
    (cold %create-index ;~(plug whitespace (jester 'create')))
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
      ~|  "Cannot parse index {<p.q.command-nail>}"   
      =/  index-nail  (parse-index [[1 1] q.q.command-nail])
      =/  parsed  (wonk index-nail)
      =/  next-cursor  
            (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:index-nail])
      ?:  ?=([@ [* *]] [parsed])                              ::"create index ..."
        %=  $                             
          script           q.q.u.+3.q:index-nail
          script-position  next-cursor
          commands         
            [`command-ast`(create-index:ast %create-index -.parsed +<.parsed %.n %.n +>.parsed) commands]
        ==
      ?:  ?=([[@ @] [* *]] [parsed])          
        ?:  =(-<.parsed %unique)                              ::"create unique index ..."
            %=  $                             
              script           q.q.u.+3.q:index-nail
              script-position  next-cursor
              commands         
                [`command-ast`(create-index:ast %create-index ->.parsed +<.parsed %.y %.n +>.parsed) commands]
            ==
        ?:  =(-<.parsed %clustered)                           ::"create clustered index ..."
            %=  $                             
              script           q.q.u.+3.q:index-nail
              script-position  next-cursor
              commands         
                [`command-ast`(create-index:ast %create-index ->.parsed +<.parsed %.n %.y +>.parsed) commands]
            ==
        ?:  =(-<.parsed %nonclustered)                        ::"create nonclustered index ..."
            %=  $                             
              script           q.q.u.+3.q:index-nail
              script-position  next-cursor
              commands         
                [`command-ast`(create-index:ast %create-index ->.parsed +<.parsed %.n %.n +>.parsed) commands]
            ==
        !!
      ?:  ?=([[@ @ @] [* *]] [parsed])
        ?:  =(->-.parsed %clustered)                           ::"create unique clustered index ..."
            %=  $                             
              script           q.q.u.+3.q:index-nail
              script-position  next-cursor
              commands         
                [`command-ast`(create-index:ast %create-index ->+.parsed +<.parsed %.y %.y +>.parsed) commands]
            ==
        ?:  =(->-.parsed %nonclustered)                        ::"create unique nonclustered index ..."
            %=  $                             
              script           q.q.u.+3.q:index-nail
              script-position  next-cursor
              commands         
                [`command-ast`(create-index:ast %create-index ->+.parsed +<.parsed %.y %.n +>.parsed) commands]
            ==
        !!
      !!
    %create-namespace
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
      =/  key-literal  ;~(plug whitespace (jester 'primary') whitespace (jester 'key'))
      =/  foreign-key-literal  ;~(plug whitespace (jester 'foreign') whitespace (jester 'key'))
      =/  foreign-key  
        ;~(pfix foreign-key-literal parse-face ordered-column-list ;~(pfix ;~(plug whitespace (jester 'references')) parse-qualified-2-name face-list))
      =/  parse-on-delete  
        (cook cook-on-delete ;~(pfix ;~(plug whitespace (jester 'on') whitespace (jester 'delete')) ;~(pfix whitespace ;~(pose (jester 'cascade') ;~(plug (jester 'no') whitespace (jester 'action'))))))
      =/  parse-on-update  
       (cook cook-on-update ;~(pfix ;~(plug whitespace (jester 'on') whitespace (jester 'update')) ;~(pfix whitespace ;~(pose (jester 'cascade') ;~(plug (jester 'no') whitespace (jester 'action'))))))
      =/  full-foreign-key  ;~  pose
        ;~(plug foreign-key parse-on-delete parse-on-update) 
        ;~(plug foreign-key parse-on-update parse-on-delete) 
        ;~(plug foreign-key parse-on-delete) 
        ;~(plug foreign-key parse-on-update) 
        foreign-key
        ==
      =/  parse-table  ;~  plug
        :: table name
        ;~(pfix whitespace parse-qualified-3object)
        :: column defintions
        ;~(pfix whitespace (ifix [pal par] column-defintion-list))
        :: primary key
        (cook cook-primary-key ;~(pfix key-literal ;~(pose ;~(plug clustering ordered-column-list) ordered-column-list)))
        :: foreign key
        ;~(pose ;~(plug full-foreign-key end-or-next-command) end-or-next-command)
        ==
      ~|  "Cannot parse table {<p.q.command-nail>}"   
      =/  table-nail  (parse-table [[1 1] q.q.command-nail])
      ~|  "command-nail:  {<command-nail>}"
      ~|  "table-nail:  {<table-nail>}"
      =/  parsed  (wonk table-nail)
      =/  next-cursor  
            (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:table-nail])

      ~|  "parsed:  {<parsed>}"
      =/  yikes  0

      !!
    %create-view
      !!
    %drop-database
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
      =/  drop-table-nail  (drop-table-or-view [[1 1] q.q.command-nail])
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
      =/  drop-view-nail  (drop-table-or-view [[1 1] q.q.command-nail])
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
      ~|  "Cannot parse grant {<p.q.command-nail>}"   
      =/  grant-nail  (parse-grant [[1 1] q.q.command-nail])
      =/  parsed  (wonk grant-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:grant-nail])
      ?:  ?=([@ [@ [@ %~]] [@ @]] [parsed])          ::"grant adminread to ~sampel-palnet on database db"
        %=  $                             
          script           q.q.u.+3.q:grant-nail
          script-position  next-cursor
          commands         
            [`command-ast`(grant:ast %grant -.parsed +<+.parsed +>.parsed) commands]
        ==
      ?:  ?=([@ @ [@ @]] [parsed])                  ::"grant adminread to parent on database db"
        %=  $                             
          script           q.q.u.+3.q:grant-nail
          script-position  next-cursor
          commands         
            [`command-ast`(grant:ast %grant -.parsed +<.parsed +>.parsed) commands]
        ==
      ?:  ?=([@ [@ [@ *]] [@ *]] [parsed])         ::"grant Readwrite to ~zod,~bus,~nec,~sampel-palnet on namespace db.ns"
        %=  $                                       ::"grant adminread to ~zod,~bus,~nec,~sampel-palnet on namespace ns" (ns previously cooked) 
          script           q.q.u.+3.q:grant-nail    ::"grant Readwrite to ~zod,~bus,~nec,~sampel-palnet on db.ns.table"
          script-position  next-cursor
          commands         
            [`command-ast`(grant:ast %grant -.parsed +<+.parsed +>.parsed) commands]
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
      ~|  "Cannot parse revoke {<p.q.command-nail>}"   
      =/  revoke-nail  (parse-revoke [[1 1] q.q.command-nail])
      =/  parsed  (wonk revoke-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:revoke-nail])
      ?:  ?=([@ [@ [@ %~]] [@ @]] [parsed])         ::"revoke adminread from ~sampel-palnet on database db"
        %=  $                             
          script           q.q.u.+3.q:revoke-nail
          script-position  next-cursor
          commands         
            [`command-ast`(revoke:ast %revoke -.parsed +<+.parsed +>.parsed) commands]
        ==
      ?:  ?=([@ @ [@ @]] [parsed])                  ::"revoke adminread from parent on database db"
        %=  $                             
          script           q.q.u.+3.q:revoke-nail
          script-position  next-cursor
          commands         
            [`command-ast`(revoke:ast %revoke -.parsed +<.parsed +>.parsed) commands]
        ==
      ?:  ?=([@ [@ [@ *]] [@ *]] [parsed])          ::"revoke Readwrite from ~zod,~bus,~nec,~sampel-palnet on namespace db.ns"
        %=  $                                       ::"revoke adminread from ~zod,~bus,~nec,~sampel-palnet on namespace ns" (ns previously cooked) 
          script           q.q.u.+3.q:revoke-nail   ::"revoke Readwrite from ~zod,~bus,~nec,~sampel-palnet on db.ns.table"
          script-position  next-cursor
          commands         
            [`command-ast`(revoke:ast %revoke -.parsed +<+.parsed +>.parsed) commands]
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
