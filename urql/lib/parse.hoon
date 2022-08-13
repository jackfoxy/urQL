/-  ast
|%
+$  states   ?(%unknown %create)
+$  command-ast
  $%
    create-database:ast
    create-index:ast
    create-namespace:ast
    create-table:ast
    create-view:ast
  ==
+$  command
  $%
    %create-database
    %create-index
    %create-namespace
    %create-table
    %create-view
  ==
::
::  the main event
::
++  parse
  |=  [current-database=@t script=tape]
  ~|  'Input script is empty.'
  ?>  !=((lent script) 0)
::  ^-  (list command-ast)
  =/  commands  `(list command-ast)`~
  ::
  :: parser rules
  ::
  =/  whitespace  (star ;~(pose gah (just '\09') (just '\0d')))
  =/  end-or-next-command  ;~(pose ;~(plug whitespace mic) whitespace mic)
  =/  parse-face  ;~(pfix whitespace sym)
  =/  parse-qualified  ;~(pfix whitespace ;~((glue dot) parse-face parse-face))
  =/  parse-db-qualified-name  ;~(pose parse-qualified parse-face)
  =/  parse-command  ;~  pose
      (cold %create-database ;~(plug whitespace (jest2 'create') whitespace (jest2 'database')))
      (cold %create-index ;~(plug whitespace (jest2 'create') whitespace (jest2 'index')))
      (cold %create-namespace ;~(plug whitespace (jest2 'create') whitespace (jest2 'namespace')))
      (cold %create-table ;~(plug whitespace (jest2 'create') whitespace (jest2 'table')))
      (cold %create-view ;~(plug whitespace (jest2 'create') whitespace (jest2 'view')))
::      (cold  ;~(plug whitespace (jest2 '') whitespace (jest2 '')))
      ==
  ::
  =/  script-position  [1 1]
  |-
  ?:  =(~ script)                  ::  https://github.com/urbit/arvo/issues/1024
    (flop commands)
  ~|  "Error parsing command keyword: {<script-position>}"
  =/  command-nail  u.+3:q.+3:(parse-command [script-position script])
  ?-  `command`p.command-nail
    %create-database
      !!
    %create-index
      !!
    %create-namespace
      =/  position  p.q.command-nail
      ~|  "Cannot parse name {<p.q.command-nail>} to face in create-namespace"   
      =/  qualified-name-nail  u.+3:q.+3:(parse-db-qualified-name [[1 1] q.q.command-nail])
      =/  last-nail  (end-or-next-command q:qualified-name-nail)
      =/  namespace-ast  ?@  p.qualified-name-nail
        (create-namespace:ast %create-namespace current-database p.qualified-name-nail)
      (create-namespace:ast %create-namespace -:p.qualified-name-nail +:p.qualified-name-nail)
      ?:  (gth -.p:last-nail -.position)           :: if we advanced to next input line
        %=  $
          script           q.q.u.+3.q:last-nail    :: then use the current position
          script-position  [p.p.q.+3.+3.q:last-nail q.p.q.+3.+3.q:last-nail]
          commands         [`command-ast`namespace-ast commands]
        ==
      %=  $                                      
        script           q.q.u.+3.q:last-nail      :: else add starting column to current column position
        script-position  [p:position (add q:position q.p.q.+3.+3.q.last-nail)]
        commands         [`command-ast`namespace-ast commands]
      ==
    %create-table
      !!
    %create-view
      !!
    ==
::  !!
::  ?-  state
::    %unknown
::      ?:  =(' ' -:script)
::        ?.  (gth (lent buffer) 0)
::          %=  $
::          script           +:script
::          script-position  [-:script-position +(+:script-position)]
::          buffer-position  [-:buffer-position +(+:buffer-position)]
::          ==
::        =/  the-command  (resolve-unknown [buffer buffer-position])
::        %=  $
::        script           +:script
::        state            the-command
::        commands           `(list command)`[the-command commands]
::        buffer           `tape`~
::        script-position  [-:script-position +(+:script-position)]
::        buffer-position  [-:script-position +(+:script-position)]
::        ==
::      ?:  =('\0a' -:script)
::        ?.  (gth (lent buffer) 0)
::          %=  $
::          script           +:script
::          script-position  [+(-:script-position) 1]
::          buffer-position  [+(-:buffer-position) 1]
::          ==
::        =/  the-command  (resolve-unknown [buffer buffer-position])
::        %=  $
::        script           +:script
::        state            the-command
::        commands           `(list command)`[the-command commands]
::        buffer           `tape`~
::        script-position  [+(-:script-position) 1]
::        buffer-position  [+(-:buffer-position) 1]
::        == 
::      %=  $
::      script           +:script
::      buffer           `tape`[-:script buffer]
::      script-position  [-:script-position +(+:script-position)]
::      ==
::    %create
::      !!
::  ==
::--
::
::  turn an atom into upper case cord
::
++  trip-cuss-crip
  |=  target=@
  ^-  @t
  (crip (cuss (trip `@t`target)))
::
::  match a cord, case agnostic
::
++  jest2
  |=  daf=@t
  |=  tub=nail
  =+  fad=daf
  |-  ^-  (like @t)
  ?:  =(`@`0 daf)
    [p=p.tub q=[~ u=[p=fad q=tub]]]
  ?:  |(?=(~ q.tub) !=((trip-cuss-crip (end 3 daf)) (trip-cuss-crip i.q.tub)))
    (fail tub)
  $(p.tub (lust i.q.tub p.tub), q.tub t.q.tub, daf (rsh 3 daf))
--