/-  ast
|%
+$  states   ?(%unknown %create)
+$  command-ast
  $%
    [%create-database create-database:ast]
    [%create-index create-index:ast]
    [%create-namespace create-namespace:ast]
    [%create-table create-table:ast]
    [%create-view create-view:ast]
  ==
+$  command
  $%
    %create-database
    %create-index
    %create-namespace
    %create-table
    %create-view
  ==

::++  resolve-face
::  |=  [buffer=tape pos=[@ud @ud]]
::  ^-  @t
::  ~|  "Cannot parse {<pos>} to face"
::  `@t`(scan (flop buffer) sym)
::++  resolve-unknown
::  |=  [buffer=tape pos=[@ud @ud]]
::  ::^-  [states command]
::  ~|  "Cannot parse {<pos>}"
::  ?:  =('etaerc' (crip (cass buffer)))
::    ::[%create %create]
::    %create
::  !!
++  parse
  |=  [current-database=@t script=tape]
  ~|  'Input script is empty.'
  ?>  !=((lent script) 0)
::  ^-  (list command)
::  =/  commands  `(list command)`~
  ::
  :: parser rules
  ::
  =/  whitespace  (star ;~(pose gah (just '\09') (just '\0d')))
  =/  parse-face  ;~(pfix whitespace sym)
  =/  parse-qualified  ;~(pfix whitespace ;~((glue dot) parse-face parse-face))
  =/  parse-db-qualified-name  ;~(pose parse-qualified parse-face)
  =/  parse-command  ;~  pose
      (cold %create-database ;~(plug whitespace (jest 'create') whitespace (jest 'database')))
      (cold %create-index ;~(plug whitespace (jest 'create') whitespace (jest 'index')))
      (cold %create-namespace ;~(plug whitespace (jest 'create') whitespace (jest 'namespace')))
      (cold %create-table ;~(plug whitespace (jest 'create') whitespace (jest 'table')))
      (cold %create-view ;~(plug whitespace (jest 'create') whitespace (jest 'view')))
::      (cold  ;~(plug whitespace (jest '') whitespace (jest '')))
      ==
  ::
  =/  buffer  `(list *)`~
  =/  state   `states`%unknown
  =/  script-position  [1 1]
  =/  buffer-position  [1 1]
  |-
  ?:  =(~ script)                  ::  https://github.com/urbit/arvo/issues/1024
::    ?:  &(=((lent commands) 0) =((lent buffer) 0))
    ?:  =((lent buffer) 0)
      ~|  "no input"
      !!
    ?-  state
      %unknown
        ~&  "state is: {<state>}"
::        ~&  "commands is: {<commands>}"
        ~&  "buffer is: {<buffer>}"
        ~|  "incomplete statement {<buffer-position>}"
        !!
      %create
        !!
        ::commands
        :: (flop `(list command)`[(resolve-face [buffer buffer-position]) commands])
    ==
  =/  command-nail  u.+3:q.+3:(parse-command [[1 1] script])
  ?-  `command`p.command-nail
    %create-database
      !!
    %create-index
      !!
    %create-namespace
      =/  position  p.q.command-nail
      ~|  "Cannot parse name {<position>} to face in create-namespace"   
      =/  qualified-name-nail  u.+3:q.+3:(parse-db-qualified-name [[1 1] q.q.command-nail])
      ?@  p.qualified-name-nail
        (create-namespace:ast %create-namespace current-database p.qualified-name-nail)
      (create-namespace:ast %create-namespace -:p.qualified-name-nail +:p.qualified-name-nail)
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
--
