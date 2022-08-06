|%
+$  states   ?(%unknown %create)
+$  token    ?(@t %create tape)
++  resolve-face
  |=  [buffer=tape pos=[@ud @ud]]
  ^-  @t
  ~|  "Cannot parse {<pos>} to face"
  `@t`(scan (flop buffer) sym)
++  resolve-unknown
  |=  [buffer=tape pos=[@ud @ud]]
  ::^-  [states token]
  ~|  "Cannot parse {<pos>}"
  ?:  =('etaerc' (crip (cass buffer)))
    ::[%create %create]
    %create
  !!
++  parse
  |=  script=tape
  ~|  'Input script is empty.'
  ?>  !=((lent script) 0)
  ^-  (list token)
  =/  tokens  `(list token)`~
  =/  buffer  `tape`~
  =/  state   `states`%unknown
  =/  script-position  [1 1]
  =/  buffer-position  [1 1]
  |-
  ::  https://github.com/urbit/arvo/issues/1024
  ::
  ?:  =(~ script)
    ?:  &(=((lent tokens) 0) =((lent buffer) 0))
      ~|  "no input"
      !!
    ?-  state
      %unknown
        ~&  "state is: {<state>}"
        ~&  "tokens is: {<tokens>}"
        ~&  "buffer is: {<buffer>}"
        ~|  "incomplete statement {<buffer-position>}"
        !!
      %create
        tokens
        :: (flop `(list token)`[(resolve-face [buffer buffer-position]) tokens])
    ==
  ?-  state
    %unknown
      ?:  =(' ' -:script)
        ?.  (gth (lent buffer) 0)
          %=  $
          script           +:script
          script-position  [-:script-position +(+:script-position)]
          buffer-position  [-:buffer-position +(+:buffer-position)]
          ==
        =/  the-token  (resolve-unknown [buffer buffer-position])
        %=  $
        script           +:script
        state            the-token
        tokens           `(list token)`[the-token tokens]
        buffer           `tape`~
        script-position  [-:script-position +(+:script-position)]
        buffer-position  [-:script-position +(+:script-position)]
        ==
      ?:  =('\0a' -:script)
        ?.  (gth (lent buffer) 0)
          %=  $
          script           +:script
          script-position  [+(-:script-position) 1]
          buffer-position  [+(-:buffer-position) 1]
          ==
        =/  the-token  (resolve-unknown [buffer buffer-position])
        %=  $
        script           +:script
        state            the-token
        tokens           `(list token)`[the-token tokens]
        buffer           `tape`~
        script-position  [+(-:script-position) 1]
        buffer-position  [+(-:buffer-position) 1]
        == 
      %=  $
      script           +:script
      buffer           `tape`[-:script buffer]
      script-position  [-:script-position +(+:script-position)]
      ==
    %create
      !!
  ==
--
