/-  ast
|_  current-database=@t                                      :: (parse:parse(current-database '<db>') "<script>")
::
::  generic urQL command
::
+$  command-ast
  $%
    alter-index:ast
    alter-namespace:ast
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
    insert:ast
    revoke:ast
    truncate-table:ast
  ==
+$  command
  $%
    %alter-index
    %alter-namespace
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
    %insert
    %revoke
    %truncate-table
  ==
::
::  helper types
::
+$  interim-key  
  $:
    %interim-key
    is-clustered=?
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
++  crub-no-text                                              :: crub:so without text parsing
  ~+
  ;~  pose
    (cook |=(det=date `dime`[%da (year det)]) when:so)
  ::
    %+  cook
      |=  [a=(list [p=?(%d %h %m %s) q=@]) b=(list @)]
      =+  rop=`tarp`[0 0 0 0 b]
      |-  ^-  dime
      ?~  a
        [%dr (yule rop)]
      ?-  p.i.a
        %d  $(a t.a, d.rop (add q.i.a d.rop))
        %h  $(a t.a, h.rop (add q.i.a h.rop))
        %m  $(a t.a, m.rop (add q.i.a m.rop))
        %s  $(a t.a, s.rop (add q.i.a s.rop))
      ==
    ;~  plug
      %+  most
        dot
      ;~  pose
        ;~(pfix (just 'd') (stag %d dim:ag))
        ;~(pfix (just 'h') (stag %h dim:ag))
        ;~(pfix (just 'm') (stag %m dim:ag))
        ;~(pfix (just 's') (stag %s dim:ag))
      ==
      ;~(pose ;~(pfix ;~(plug dot dot) (most dot qix:ab)) (easy ~))
    ==
  ::
    (stag %p fed:ag)
  ==
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
++  cook-qualified-2object                                    ::  namespace.object-name
  |=  a=*
  ~+
  ?@  a
    (qualified-object:ast %qualified-object ~ current-database 'dbo' a)
  (qualified-object:ast %qualified-object ~ current-database -.a +.a)
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
      (ordered-column:ast %ordered-column a %.y)
    ?:  ?=([@ @] [a])
      ?:  =(+.a %asc)                  
        (ordered-column:ast %ordered-column -.a %.y)
      (ordered-column:ast %ordered-column -.a %.n)
    !!
++  cook-primary-key
  |=  a=*
  ?@  -.a
    ?:  =(-.a 'clustered')  (interim-key %interim-key %.y +.a)  (interim-key %interim-key %.n +.a)
  (interim-key %interim-key %.n a)
++  cook-referential-integrity
  |=  a=*
  ?:  ?=([[@ @] @ @] [a])                                    :: <type> cascade, <type> cascade          
    ?:  =(%delete -<.a)
      ?:  =(%update +<.a) 
        ~[%delete-cascade %update-cascade]
      !!
    ?:  =(%update -<.a)
      ?:  =(%delete +<.a) 
        ~[%delete-cascade %update-cascade]
      !!
    !!
  ?:  ?=([@ @] [a])                                           :: <type> cascade
    ?:  =(-.a %delete)  [%delete-cascade ~]  [%update-cascade ~]
  ?:  ?=([[@ @] @ @ [@ %~] @] [a])                            :: <type> cascade, <type> no action
    ?:  =(-<.a %delete)  [%delete-cascade ~]  [%update-cascade ~]
  ?:  ?=([[@ @ [@ %~] @] @ @] [a])                                :: <type> no action, <type> cascade
    ?:  =(+<.a %delete)  [%delete-cascade ~]  [%update-cascade ~]
  ?:  ?=([@ [@ %~]] a)                                        :: <type> no action
    ~
  ?:  ?=([[@ @ [@ %~] @] @ @ [@ %~] @] a)                             :: <type> no action, <type> no action
    ~
  !! 
++  cook-foreign-key
  |=  a=*
  ~+
  ?:  ?=([[@ * * [@ @] *] *] [a])    :: foreign key ns.table ... references fk-table ... on action on action  
    (foreign-key:ast %foreign-key -<.a ->-.a ->+<-.a ->+<+.a ->+>.a +.a)
  ?:  ?=([[@ [[@ @ @] %~] @ [@ %~]] *] [a])    :: foreign key table ... references fk-table ... on action on action  
    (foreign-key:ast %foreign-key -<.a ->-.a ->+<-.a 'dbo' ->+.a +.a)
  !!
++  cook-numbers
  |=  a=(list @t)
  ~+
  =/  parser  ;~  pose
    (stag %ud (full dem:ag))                                             :: formatted @ud
    (stag %ud (full dim:ag))                                             :: unformatted @ud, no leading 0s
    (stag %ub (full bay:ag))                                             :: formatted @ub, no leading 0s
    (stag %ux ;~(pfix (jest '0x') (full hex:ag)))                        :: formatted @ux
    (full tash:so)                                                       :: @sd or @sx
    (stag %rs (full royl-rs:so))                                         :: @rs
    (stag %rd (full royl-rd:so))                                         :: @rd
    (stag %uw (full wiz:ag))                                             :: formatted @uw base-64 unsigned
    ==
  =/  parsed  (parser [[1 1] a])
  (wonk parsed)
++  column-value  ~+  ;~  pose
  (cold [%default %default] (jester 'default'))
  cord-literal
  ;~(pose ;~(pfix sig crub-no-text) crub-no-text)       :: @da, @dr, @p
  (stag %is ;~(pfix (just '.') bip:ag))                 :: @is
  (stag %if ;~(pfix (just '.') lip:ag))                 :: @if
  (stag %f ;~(pose (cold & (jester 'y')) (cold | (jester 'n'))))  :: @if
  (cook cook-numbers prn-less-com-par)                  :: all numeric parsers
  ==
++  clean-column-value  ~+  ;~  pose
  ;~(pfix whitespace ;~(sfix column-value whitespace))
  ;~(pfix whitespace column-value)
  ;~(sfix column-value whitespace)
  column-value
  ==
++  whitespace  ~+  (star ;~(pose gah (just '\09') (just '\0d')))
++  end-or-next-command  ~+  ;~(pose ;~(plug whitespace mic) whitespace mic)
++  parse-face  ~+  ;~(pfix whitespace sym)
++  face-list  ~+  ;~(pfix whitespace (ifix [pal par] (more com ;~(pose ;~(sfix parse-face whitespace) parse-face))))
++  qualified-namespace  ~+                                       :: database.namespace
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
++  clustering  ~+  ;~(pfix whitespace ;~(pose (jester 'clustered') (jester 'nonclustered')))
++  ordered-column-list  ~+
  ;~(pfix whitespace (ifix [pal par] (more com (cook cook-ordered-column ;~(pose ;~(sfix ;~(plug parse-face ordering) whitespace) ;~(plug parse-face ordering) ;~(sfix parse-face whitespace) parse-face)))))
++  parse-ship  ~+  ;~(pfix sig fed:ag)
++  ship-list  ~+  (more com ;~(pose ;~(sfix ;~(pfix whitespace parse-ship) whitespace) ;~(pfix whitespace parse-ship) ;~(sfix parse-ship whitespace) parse-ship))
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
++  prn-less-soz  ~+  ;~(less (just `@`39) (just `@`127) (shim 32 256))  
++  cord-literal  ~+  
  (cook |=(a=(list @t) [%t (crip a)]) (ifix [soq soq] (star ;~(pose (cold '\'' (jest '\\\'')) prn-less-soz))))
++  prn-less-com-par  ~+  ;~  pose
  ;~(pfix whitespace (star ;~(less (just ',') (just ')') (just `@`127) gah (just '\09') (just '\0d') (shim 32 256))))
  (star ;~(less (just ',') (just ')') (just `@`127) (shim 32 256)))
  ==
++  build-foreign-keys
  |=  a=[table=qualified-object:ast f-keys=(list *)]
  =/  f-keys  +.a
  =/  foreign-keys  `(list foreign-key:ast)`~
  |-
  ?:  =(~ f-keys)
    foreign-keys 
  ?@  -<.f-keys
    %=  $                                                       :: foreign key table must be in same DB as table  
      foreign-keys  [(foreign-key:ast %foreign-key -<.f-keys -.a ->-.f-keys (qualified-object:ast %qualified-object ~ ->+<.a ->+<+>+<.f-keys ->+<+>+>.f-keys) ->+>.f-keys ~) foreign-keys]
      f-keys        +.f-keys
    ==
  %=  $                                                       :: foreign key table must be in same DB as table  
    foreign-keys  [(foreign-key:ast %foreign-key -<-.f-keys -.a -<+<.f-keys (qualified-object:ast %qualified-object ~ ->+<.a -<+>->+>-.f-keys -<+>->+>+.f-keys) -<+>+.f-keys ->.f-keys) foreign-keys]
    f-keys        +.f-keys
  ==
++  foreign-key
  ;~(pfix ;~(plug whitespace (jester 'foreign') whitespace (jester 'key')) ;~(plug parse-face ordered-column-list ;~(pfix ;~(plug whitespace (jester 'references')) ;~(plug (cook cook-qualified-2object parse-qualified-2-name) face-list))))
++  referential-integrity  ;~  plug 
  ;~(pfix ;~(plug whitespace (jester 'on') whitespace) ;~(pose (jester 'update') (jester 'delete')))
  ;~(pfix whitespace ;~(pose (jester 'cascade') ;~(plug (jester 'no') whitespace (jester 'action'))))
  ==
++  full-foreign-key  ;~  pose
  ;~(plug foreign-key (cook cook-referential-integrity ;~(plug referential-integrity referential-integrity)))
  ;~(plug foreign-key (cook cook-referential-integrity ;~(plug referential-integrity referential-integrity)))
  ;~(plug foreign-key (cook cook-referential-integrity referential-integrity))
  ;~(plug foreign-key (cook cook-referential-integrity referential-integrity))
  foreign-key
  ==
::
::  parse urQL command
::
++  parse-alter-index
  =/  columns  ;~(sfix ordered-column-list end-or-next-command)
  =/  action  ;~(pfix whitespace ;~(pose (jester 'rebuild') (jester 'disable') (jester 'resume')))
  ;~  plug
    ;~(pfix whitespace parse-qualified-3object)
    ;~(pfix whitespace ;~(pfix (jester 'on') ;~(pfix whitespace parse-qualified-3object)))
    ;~(sfix ;~(pose ;~(plug columns action) columns action) end-or-next-command)
  ==
++  parse-alter-namespace  ;~  plug
  (cook |=(a=* (qualified-namespace [a current-database])) parse-qualified-2-name)
  ;~(pfix ;~(plug whitespace (jester 'transfer')) ;~(pfix whitespace ;~(pose (jester 'table') (jester 'view'))))
  ;~(sfix ;~(pfix whitespace parse-qualified-3object) end-or-next-command)
  ==
++  parse-create-namespace  ;~  sfix
  parse-qualified-2-name
  end-or-next-command
  ==
++  parse-create-index
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
++  parse-create-table  ;~  plug
  :: table name
  ;~(pfix whitespace parse-qualified-3object)
  :: column defintions
  ;~(pfix whitespace (ifix [pal par] column-defintion-list))
  :: primary key
  (cook cook-primary-key ;~(pfix ;~(plug whitespace (jester 'primary') whitespace (jester 'key')) ;~(pose ;~(plug clustering ordered-column-list) ordered-column-list)))
  :: foreign keys
  ;~(sfix (more com full-foreign-key) end-or-next-command)
  ==
++  parse-insert  ;~  plug 
  ;~(pfix whitespace parse-qualified-object)
  ;~(pose ;~(plug face-list ;~(pfix whitespace (jester 'values'))) ;~(pfix whitespace (jester 'values')))
  ;~(pfix whitespace (more whitespace (ifix [pal par] (more com clean-column-value))))  :: column-value-list
  end-or-next-command
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
  ^-  (list command-ast)
  =/  commands  `(list command-ast)`~
  =/  script-position  [1 1]
  =/  parse-command  ;~  pose
    (cold %alter-index ;~(plug whitespace (jester 'alter') whitespace (jester 'index')))
    (cold %alter-namespace ;~(plug whitespace (jester 'alter') whitespace (jester 'namespace')))
    (cold %create-database ;~(plug whitespace (jester 'create') whitespace (jester 'database')))
    (cold %create-namespace ;~(plug whitespace (jester 'create') whitespace (jester 'namespace')))
    (cold %create-table ;~(plug whitespace (jester 'create') whitespace (jester 'table')))
    (cold %create-view ;~(plug whitespace (jester 'create') whitespace (jester 'view')))
    (cold %create-index ;~(plug whitespace (jester 'create')))  :: must be last of creates
    (cold %drop-database ;~(plug whitespace (jester 'drop') whitespace (jester 'database')))
    (cold %drop-index ;~(plug whitespace (jester 'drop') whitespace (jester 'index')))
    (cold %drop-namespace ;~(plug whitespace (jester 'drop') whitespace (jester 'namespace')))
    (cold %drop-table ;~(plug whitespace (jester 'drop') whitespace (jester 'table')))
    (cold %drop-view ;~(plug whitespace (jester 'drop') whitespace (jester 'view')))
    (cold %grant ;~(plug whitespace (jester 'grant')))
    (cold %insert ;~(plug whitespace (jester 'insert') whitespace (jester 'into')))
    (cold %revoke ;~(plug whitespace (jester 'revoke')))
    (cold %truncate-table ;~(plug whitespace (jester 'truncate') whitespace (jester 'table')))
    ==
  ~|  'Current database name is not a proper term'
  =/  dummy  (scan (trip current-database) sym)
  :: main loop
  ::
  |-
  ?:  =(~ script)                  ::  https://github.com/urbit/arvo/issues/1024
    (flop commands)
  =/  check-empty  u.+3:q.+3:(whitespace [[1 1] script])
  ?:  =(0 (lent q.q:check-empty))                             :: trailing whitespace after last end-command (;)
    (flop commands)
  ~|  "Error parsing command keyword: {<script-position>}"
  =/  command-nail  u.+3:q.+3:(parse-command [script-position script])
  ?-  `command`p.command-nail
    %alter-index
      ~|  "Cannot parse index {<p.q.command-nail>}"   
      =/  index-nail  (parse-alter-index [[1 1] q.q.command-nail])
      =/  parsed  (wonk index-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:index-nail])
      ?:  ?=([[@ @ @ @ @] [@ @ @ @ @] * @] [parsed])          ::"alter index columns action"
        %=  $                             
          script           q.q.u.+3.q:index-nail
          script-position  next-cursor
          commands         
            [`command-ast`(alter-index:ast %alter-index -.parsed +<.parsed +>-.parsed +>+.parsed) commands]
        ==
      ::
      :: mysterious bug, if only 1 column in list and no action it fails
      ?:  ?=([[@ @ @ @ @] [@ @ @ @ @] *] [parsed])            ::"alter index columns"
        %=  $                             
          script           q.q.u.+3.q:index-nail
          script-position  next-cursor
          commands         
            [`command-ast`(alter-index:ast %alter-index -.parsed +<.parsed +>.parsed %rebuild) commands]
        ==
      ::
      :: also bug, tried changing ast def to (unit (list ordered-column)) and other hacks...wtf
      ?:  ?=([[@ @ @ @ @] [@ @ @ @ @] @] [parsed])                           ::"alter index action"
          %=  $                             
            script           q.q.u.+3.q:index-nail
            script-position  next-cursor
            commands         
              [`command-ast`(alter-index:ast %alter-index -.parsed +<.parsed ~ +>.parsed) commands]
          ==
      !!
    %alter-namespace
      ~|  "Cannot parse namespace {<p.q.command-nail>}"   
      =/  namespace-nail  (parse-alter-namespace [[1 1] q.q.command-nail])
      =/  parsed  (wonk namespace-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:namespace-nail])
      %=  $                             
        script           q.q.u.+3.q:namespace-nail
        script-position  next-cursor
        commands         
          [`command-ast`(alter-namespace:ast %alter-namespace -<.parsed ->.parsed +<.parsed +>+>+<.parsed +>+>+>.parsed) commands]
      ==
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
      =/  index-nail  (parse-create-index [[1 1] q.q.command-nail])
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
      ~|  "Cannot parse table {<p.q.command-nail>}"   
      =/  table-nail  (parse-create-table [[1 1] q.q.command-nail])
      =/  parsed  (wonk table-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:table-nail])
      =/  qualified-table  -.parsed
      =/  table-columns  +<.parsed
      =/  key  +>-.parsed
      =/  key-name  (crip (weld (weld "ix-primary-" (trip +>+<.qualified-table)) (weld "-" (trip +>+>.qualified-table))))
      =/  primary-key  (create-index:ast %create-index key-name qualified-table %.y +<.key +>.key)
      =/  foreign-keys  (build-foreign-keys [qualified-table +>+.parsed])
      %=  $
        script           q.q.u.+3.q:table-nail
        script-position  next-cursor
        commands         
          [`command-ast`(create-table:ast %create-table qualified-table table-columns primary-key foreign-keys) commands]
      ==
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
    %insert
      ~|  "Cannot parse insert {<p.q.command-nail>}"   
      =/  insert-nail  (parse-insert [[1 1] q.q.command-nail])
      =/  parsed  (wonk insert-nail)
      =/  next-cursor  
        (get-next-cursor [script-position +<.command-nail p.q.u.+3:q.+3:insert-nail])
      ?:  ?=([[@ @ @ @ @] @ *] [parsed])          ::"insert rows"
        %=  $                             
          script           q.q.u.+3.q:insert-nail
          script-position  next-cursor
          commands         
            [`command-ast`(insert:ast %insert -.parsed ~ (insert-values:ast %expressions +>-.parsed)) commands]
        ==
      ?:  ?=([[@ @ @ @ @] [* @] *] [parsed])          ::"insert column names rows"
        %=  $                             
          script           q.q.u.+3.q:insert-nail
          script-position  next-cursor
          commands         
            [`command-ast`(insert:ast %insert -.parsed `+<-.parsed (insert-values:ast %expressions +>-.parsed)) commands]
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
