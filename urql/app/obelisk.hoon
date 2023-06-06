/-  *obelisk
/+  default-agent, dbug
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0
  $:  [%0 values=(list @)]
  ==
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    default  ~(. (default-agent this %n) bowl)
++  on-init
  ^-  (quip card _this)
::  ~&  >  '%obelisk init'
  =.  state  [%0 *(list @)]
  `this
++  on-save   !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-state)
  ?-  -.old
    %0  `this(state old)
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  ?=(%obelisk-action mark)
  =/  act  !<(action vase)
  ?-    -.act
      %push
    ?:  =(our.bowl target.act)
      `this(values [value.act values])
    ?>  =(our.bowl src.bowl)
    :_  this
    [%pass /pokes %agent [target.act %obelisk] %poke mark vase]~
  ::
      %pop
    ?:  =(our.bowl target.act)
      `this(values ?~(values ~ t.values))
    ?>  =(our.bowl src.bowl)
    :_  this
    [%pass /pokes %agent [target.act %obelisk] %poke mark vase]~

  ::
  :: [%give %fact ~ %<requesting desk> !>(`update`[%init values])]
  ::                                       ^ this is a mark, also entry in sur/
  :: ASL lesson 3 8:50, 25:30

  ==
::++  on-watch  |=(path !!)
++  on-watch  on-watch:default
::++  on-leave  |=(path `..on-init)
++  on-leave  on-leave:default
::++  on-peek   |=(path ~)
++  on-peek   :: on-peek:default
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  (on-peek:default path)
    [%x %values ~]  ``noun+!>(values)
  ==
::++  on-agent  |=([wire sign:agent:gall] !!)
++  on-agent  on-agent:default
::++  on-arvo   |=([wire sign-arvo] !!)
++  on-arvo   on-arvo:default
::++  on-fail   |=([term tang] `..on-init)
++  on-fail   on-fail:default
--
