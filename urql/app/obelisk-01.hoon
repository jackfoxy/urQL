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
^-  agent:gall
=|  state-0
=*  state  -
::

|_  =bowl:gall
+*  this  .
    default  ~(. (default-agent this %|) bowl)
++  on-init
  ^-  (quip card _this)
  ~&  >  '%obelisk init'
  =.  state  [%0 *(list @)]
  `this
::++  on-save   !>(state)
++  on-save   on-save:default
::++  on-load   |=(vase `..on-init)
++  on-load   :: on-load:default
  |=  old=vase
  ^-  (quip card _this)
  `this(state !<(state-0 old))
::++  on-poke   |=(cage !!)
++  on-poke   on-poke:default
::++  on-watch  |=(path !!)
++  on-watch  on-watch:default
::++  on-leave  |=(path `..on-init)
++  on-leave  on-leave:default
::++  on-peek   |=(path ~)
++  on-peek   on-peek:default
::++  on-agent  |=([wire sign:agent:gall] !!)
++  on-agent  on-agent:default
::++  on-arvo   |=([wire sign-arvo] !!)
++  on-arvo   on-arvo:default
::++  on-fail   |=([term tang] `..on-init)
++  on-fail   on-fail:default
--
