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
    insert:ast
    revoke:ast
    truncate-table:ast
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
::
::  parser rules and helpers
::
++  end-or-next-command  ~+  ;~(pose ;~(plug whitespace mic) whitespace mic)
++  build-foreign-keys                                        ::  foreign keys in create table
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
++  open-paren  ~+  ;~  pose
  ;~(pfix whitespace ;~(sfix pal whitespace))
  ;~(pfix whitespace pal)
  ==
++  close-paren  ~+  ;~  pose
  ;~(pfix whitespace ;~(sfix par whitespace))
  ;~(pfix whitespace par)
  ==
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
++  foreign-key  ~+  
  ;~(pfix ;~(plug whitespace (jester 'foreign') whitespace (jester 'key')) ;~(plug parse-face ordered-column-list ;~(pfix ;~(plug whitespace (jester 'references')) ;~(plug (cook cook-qualified-2object parse-qualified-2-name) face-list))))
++  referential-integrity  ~+  ;~  plug 
  ;~(pfix ;~(plug whitespace (jester 'on') whitespace) ;~(pose (jester 'update') (jester 'delete')))
  ;~(pfix whitespace ;~(pose (jester 'cascade') ;~(plug (jester 'no') whitespace (jester 'action'))))
  ==
++  full-foreign-key  ~+  ;~  pose
  ;~(plug foreign-key (cook cook-referential-integrity ;~(plug referential-integrity referential-integrity)))
  ;~(plug foreign-key (cook cook-referential-integrity ;~(plug referential-integrity referential-integrity)))
  ;~(plug foreign-key (cook cook-referential-integrity referential-integrity))
  ;~(plug foreign-key (cook cook-referential-integrity referential-integrity))
  foreign-key
  ==
::
::  parse urQL command
::
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
    ;~(sfix ordered-column-list whitespace)
  ==
++  parse-create-namespace  ;~  sfix
  parse-qualified-2-name
  whitespace
  ==
++  parse-create-table  ;~  plug
  :: table name
  ;~(pfix whitespace parse-qualified-3object)
  :: column defintions
  ;~(pfix whitespace (ifix [pal par] column-defintion-list))
  :: primary key
  (cook cook-primary-key ;~(pfix ;~(plug whitespace (jester 'primary') whitespace (jester 'key')) ;~(pose ;~(plug clustering ordered-column-list) ordered-column-list)))
  :: foreign keys
  ;~(sfix (more com full-foreign-key) whitespace)
  ==
++  parse-insert  ;~  plug 
  ;~(pfix whitespace parse-qualified-object)
  ;~(pose ;~(plug face-list ;~(pfix whitespace (jester 'values'))) ;~(pfix whitespace (jester 'values')))
  ;~(pfix whitespace (more whitespace (ifix [pal par] (more com clean-column-value))))  :: column-value-list
  whitespace
  ==
++  parse-drop-database  ;~  sfix
  ;~(pose ;~(plug ;~(pfix whitespace (jester 'force')) ;~(pfix whitespace sym)) ;~(pfix whitespace sym))
  whitespace
  ==
++  parse-drop-index  ;~  sfix
  ;~(pfix whitespace ;~(plug parse-face ;~(pfix whitespace ;~(pfix (jester 'on') ;~(pfix whitespace parse-qualified-3object)))))
  whitespace
  ==
++  parse-drop-namespace  ;~  sfix
  ;~(pose ;~(plug ;~(pfix whitespace (cold %force (jester 'force'))) parse-qualified-2-name) parse-qualified-2-name)
  whitespace
  ==
++  drop-table-or-view  ;~  sfix
  ;~(pose ;~(pfix whitespace ;~(plug (jester 'force') parse-qualified-3object)) parse-qualified-3object)
  whitespace
  ==
++  parse-grant  ;~  plug
  :: permission
  ;~(pfix whitespace ;~(pose (jester 'adminread') (jester 'readonly') (jester 'readwrite')))
  :: grantee
  ;~(pfix whitespace ;~(pfix (jester 'to') ;~(pfix whitespace ;~(pose (jester 'parent') (jester 'siblings') (jester 'moons') (stag %ships ship-list)))))
  ;~(sfix grant-object whitespace)
  ==
++  parse-revoke  ;~  plug
  :: permission
  ;~(pfix whitespace ;~(pose (jester 'adminread') (jester 'readonly') (jester 'readwrite') (jester 'all')))
  :: revokee
  ;~(pfix whitespace ;~(pfix (jester 'from') ;~(pfix whitespace ;~(pose (jester 'parent') (jester 'siblings') (jester 'moons') (jester 'all') (stag %ships ship-list)))))
  ;~(sfix grant-object whitespace)
  ==
++  parse-truncate-table  ;~  sfix
  ;~(pfix whitespace parse-qualified-object) 
  end-or-next-command
  ==
::
::  build ast output
::
++  build-create-database
  |=  parsed=*
  ^-  create-database:ast
  (create-database:ast %create-database parsed)
++  build-create-namespace
  |=  parsed=*
  ^-  create-namespace:ast
  ?@  parsed
    (create-namespace:ast %create-namespace current-database parsed)
  (create-namespace:ast %create-namespace -.parsed +.parsed)
++  build-create-index
  |=  parsed=*
  ^-  create-index:ast
  ?:  ?=([@ [* *]] [parsed])                              ::"create index ..."
    (create-index:ast %create-index -.parsed +<.parsed %.n %.n +>.parsed)
  ?:  ?=([[@ @] [* *]] [parsed])          
    ?:  =(-<.parsed %unique)                              ::"create unique index ..."
      (create-index:ast %create-index ->.parsed +<.parsed %.y %.n +>.parsed)
    ?:  =(-<.parsed %clustered)                           ::"create clustered index ..."
      (create-index:ast %create-index ->.parsed +<.parsed %.n %.y +>.parsed)
    ?:  =(-<.parsed %nonclustered)                        ::"create nonclustered index ..."
      (create-index:ast %create-index ->.parsed +<.parsed %.n %.n +>.parsed)
    !!
  ?:  ?=([[@ @ @] [* *]] [parsed])
    ?:  =(->-.parsed %clustered)                           ::"create unique clustered index ..."
      (create-index:ast %create-index ->+.parsed +<.parsed %.y %.y +>.parsed)
    ?:  =(->-.parsed %nonclustered)                        ::"create unique nonclustered index ..."
      (create-index:ast %create-index ->+.parsed +<.parsed %.y %.n +>.parsed)
    !!
  !!
++  build-create-table
  |=  parsed=[p=qualified-object:ast q=[r=(list column:ast) [s=(list *) t=(list *)]]]
  ~+
  ^-  create-table:ast
  =/  key-name  (crip (weld (weld "ix-primary-" (trip +>+<:p.parsed)) (weld "-" (trip +>+>:p.parsed))))
  =/  primary-key  (create-index:ast %create-index key-name p.parsed %.y +<:s.q.parsed +>:s.q.parsed)
  (create-table:ast %create-table p.parsed r.q.parsed primary-key (build-foreign-keys [p.parsed t.q.parsed]))
++  build-drop-database
  |=  parsed=*
  ^-  drop-database:ast
  ?@  parsed                                              :: name
    (drop-database:ast %drop-database parsed %.n)
  ?:  ?=([@ @] parsed)                                    :: force name
    (drop-database:ast %drop-database +.parsed %.y)
  !!
++  build-drop-index
  |=  parsed=*
  ^-  drop-index:ast
  (drop-index:ast %drop-index -.parsed +.parsed)
++  build-drop-namespace
  |=  parsed=*
  ^-  drop-namespace:ast
  ?@  parsed                                              :: name
    (drop-namespace:ast %drop-namespace current-database parsed %.n)
  ?:  ?=([@ @] parsed)                                    :: force name
    ?:  =(%force -.parsed)                 
      (drop-namespace:ast %drop-namespace current-database +.parsed %.y)
    (drop-namespace:ast %drop-namespace -.parsed +.parsed %.n)
  ?:  ?=([* [@ @]] parsed)                                :: force db.name
    (drop-namespace:ast %drop-namespace +<.parsed +>.parsed %.y)
  !!
++  build-drop-table
  |=  parsed=*
  ^-  drop-table:ast
  ?:  ?=([@ @ @ @ @ @] parsed)                     :: force qualified table name
    (drop-table:ast %drop-table +.parsed %.y)
  ?:  ?=([@ @ @ @ @] parsed)                              :: qualified table name
    (drop-table:ast %drop-table parsed %.n)
  !!
++  build-drop-view
  |=  parsed=*
  ^-  drop-view:ast
  ?:  ?=([@ @ @ @ @ @] parsed)                     :: force qualified view
    (drop-view:ast %drop-view +.parsed %.y)
  ?:  ?=([@ @ @ @ @] parsed)                              :: qualified view
    (drop-view:ast %drop-view parsed %.n)
  !!
++  build-grant
  |=  parsed=*
  ^-  grant:ast
  ?:  ?=([@ [@ [@ %~]] [@ @]] [parsed])             ::"grant adminread to ~sampel-palnet on database db"
    (grant:ast %grant -.parsed +<+.parsed +>.parsed)
  ?:  ?=([@ @ [@ @]] [parsed])                  ::"grant adminread to parent on database db"
    (grant:ast %grant -.parsed +<.parsed +>.parsed)
  ?:  ?=([@ [@ [@ *]] [@ *]] [parsed])         ::"grant Readwrite to ~zod,~bus,~nec,~sampel-palnet on namespace db.ns"
                                                ::"grant adminread to ~zod,~bus,~nec,~sampel-palnet on namespace ns" (ns previously cooked) 
                                                ::"grant Readwrite to ~zod,~bus,~nec,~sampel-palnet on db.ns.table"
    (grant:ast %grant -.parsed +<+.parsed +>.parsed)
  ?:  ?=([@ @ [@ [@ *]]] [parsed])              ::"grant readonly to siblings on namespace db.ns"
                                                ::"grant readwrite to moons on namespace ns" (ns previously cooked)   
    (grant:ast %grant -.parsed +<.parsed +>.parsed)
  !!
++  build-insert
  |=  parsed=*
  ^-  insert:ast
  ?:  ?=([[@ @ @ @ @] @ *] [parsed])          ::"insert rows"
    (insert:ast %insert -.parsed ~ (insert-values:ast %expressions +>-.parsed))
  ?:  ?=([[@ @ @ @ @] [* @] *] [parsed])          ::"insert column names rows"
    (insert:ast %insert -.parsed `+<-.parsed (insert-values:ast %expressions +>-.parsed))
  !!
++  build-revoke
  |=  parsed=*
  ^-  revoke:ast
  ?:  ?=([@ [@ [@ %~]] [@ @]] [parsed])         ::"revoke adminread from ~sampel-palnet on database db"
    (revoke:ast %revoke -.parsed +<+.parsed +>.parsed)
  ?:  ?=([@ @ [@ @]] [parsed])                  ::"revoke adminread from parent on database db"
    (revoke:ast %revoke -.parsed +<.parsed +>.parsed)
  ?:  ?=([@ [@ [@ *]] [@ *]] [parsed])          ::"revoke Readwrite from ~zod,~bus,~nec,~sampel-palnet on namespace db.ns"
                                                ::"revoke adminread from ~zod,~bus,~nec,~sampel-palnet on namespace ns" (ns previously cooked) 
                                                ::"revoke Readwrite from ~zod,~bus,~nec,~sampel-palnet on db.ns.table"
    (revoke:ast %revoke -.parsed +<+.parsed +>.parsed)
  ?:  ?=([@ @ [@ [@ *]]] [parsed])              ::"revoke readonly from siblings on namespace db.ns"
                                                ::"revoke readwrite from moons on namespace ns" (ns previously cooked) 
    (revoke:ast %revoke -.parsed +<.parsed +>.parsed)
  !!
++  build-truncate-table
  |=  parsed=*
  ^-  truncate-table:ast
  (truncate-table:ast %truncate-table parsed)
::
::  parse urQL script
::
++  parse
  |=  script=tape
  ^-  (list command-ast)
  =/  parse-command  ;~  pose
    (cook build-create-database ;~(pfix ;~(plug whitespace (jester 'create') whitespace (jester 'database')) parse-face))
    (cook build-create-namespace ;~(pfix ;~(plug whitespace (jester 'create') whitespace (jester 'namespace')) parse-create-namespace))
    (cook build-create-table ;~(pfix ;~(plug whitespace (jester 'create') whitespace (jester 'table')) parse-create-table))
    ::  ;~(pfix ;~(plug whitespace (jester 'create') whitespace (jester 'view')) )
    (cook build-create-index ;~(pfix ;~(plug whitespace (jester 'create')) parse-create-index))  ::must be last of creates
    (cook build-drop-database ;~(pfix ;~(plug whitespace (jester 'drop') whitespace (jester 'database')) parse-drop-database))
    (cook build-drop-index ;~(pfix ;~(plug whitespace (jester 'drop') whitespace (jester 'index')) parse-drop-index))
    (cook build-drop-namespace ;~(pfix ;~(plug whitespace (jester 'drop') whitespace (jester 'namespace')) parse-drop-namespace))
    (cook build-drop-table ;~(pfix ;~(plug whitespace (jester 'drop') whitespace (jester 'table')) drop-table-or-view))
    (cook build-drop-view ;~(pfix ;~(plug whitespace (jester 'drop') whitespace (jester 'view')) drop-table-or-view))
    (cook build-grant ;~(pfix ;~(plug whitespace (jester 'grant')) parse-grant))
    (cook build-insert ;~(pfix ;~(plug whitespace (jester 'insert') whitespace (jester 'into')) parse-insert))
    (cook build-revoke ;~(pfix ;~(plug whitespace (jester 'revoke')) parse-revoke))
    (cook build-truncate-table ;~(pfix ;~(plug whitespace (jester 'truncate') whitespace (jester 'table')) parse-truncate-table))
    ==
  ~|  'Current database name is not a proper term'
  =/  dummy  (scan (trip current-database) sym)
  ::
  :: main loop
  ::
                               :: trailing whitespace after last end-command (;)
  (wonk (;~(pose ;~(sfix (more mic parse-command) whitespace) (more mic parse-command)) [[1 1] script]))
  :: (scan script ;~(pose ;~(sfix (more mic parse-command) whitespace) (more mic parse-command)))
--
