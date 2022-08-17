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
    %truncate-table
  ==
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
++  cook-four-pat-ps
  |=  a=[[@ @] * [@ @] * [@ @] * [@ @]]
  ;:(weld (trip `@t`-<.a) (trip `@t`->.a) "-" (trip `@t`+>-<.a) (trip `@t`+>->.a) "-" (trip `@t`+>+>-<.a) (trip `@t`+>+>->.a) "-" (trip `@t`+>+>+>-.a) (trip `@t`+>+>+>+.a))
++  cook-galaxy 
  |=  a=[@ @]
  ['~' (trip +.a)]
++  cook-star 
  |=  a=[* [@ @]]
  ;:(weld "~" (trip `@t`+<.a) (trip `@t`+>.a))
++  cook-planet 
  |=  a=[* [@ @] * [@ @]]
  ;:(weld "~" (trip `@t`+<-.a) (trip `@t`+<+.a) "-" (trip `@t`+>+<.a) (trip `@t`+>+>.a))
++  cook-moon
  |=  a=[@ tape]
  ['~' +.a]
::++  cook-comet  
::  |=  a=[* tape * tape]
::  ;:(weld "~" +<.a "--" +>+<.a)    
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
  =/  word-prefix  ;~  pose
        (jest 'doz')
        (jest 'mar')
        (jest 'bin')
        (jest 'wan')
        (jest 'sam')
        (jest 'lit')
        (jest 'sig')
        (jest 'hid')
        (jest 'fid')
        (jest 'lis')
        (jest 'sog')
        (jest 'dir')
        (jest 'wac')
        (jest 'sab')
        (jest 'wis')
        (jest 'sib')
        (jest 'rig')
        (jest 'sol')
        (jest 'dop')
        (jest 'mod')
        (jest 'fog')
        (jest 'lid')
        (jest 'hop')
        (jest 'dar')
        (jest 'dor')
        (jest 'lor')
        (jest 'hod')
        (jest 'fol')
        (jest 'rin')
        (jest 'tog')
        (jest 'sil')
        (jest 'mir')
        (jest 'hol')
        (jest 'pas')
        (jest 'lac')
        (jest 'rov')
        (jest 'liv')
        (jest 'dal')
        (jest 'sat')
        (jest 'lib')
        (jest 'tab')
        (jest 'han')
        (jest 'tic')
        (jest 'pid')
        (jest 'tor')
        (jest 'bol')
        (jest 'fos')
        (jest 'dot')
        (jest 'los')
        (jest 'dil')
        (jest 'for')
        (jest 'pil')
        (jest 'ram')
        (jest 'tir')
        (jest 'win')
        (jest 'tad')
        (jest 'bic')
        (jest 'dif')
        (jest 'roc')
        (jest 'wid')
        (jest 'bis')
        (jest 'das')
        (jest 'mid')
        (jest 'lop')
        (jest 'ril')
        (jest 'nar')
        (jest 'dap')
        (jest 'mol')
        (jest 'san')
        (jest 'loc')
        (jest 'nov')
        (jest 'sit')
        (jest 'nid')
        (jest 'tip')
        (jest 'sic')
        (jest 'rop')
        (jest 'wit')
        (jest 'nat')
        (jest 'pan')
        (jest 'min')
        (jest 'rit')
        (jest 'pod')
        (jest 'mot')
        (jest 'tam')
        (jest 'tol')
        (jest 'sav')
        (jest 'pos')
        (jest 'nap')
        (jest 'nop')
        (jest 'som')
        (jest 'fin')
        (jest 'fon')
        (jest 'ban')
        (jest 'por')
        (jest 'wor')
        (jest 'sip')
        (jest 'ron')
        (jest 'nor')
        (jest 'bot')
        (jest 'wic')
        (jest 'soc')
        (jest 'wat')
        (jest 'dol')
        (jest 'mag')
        (jest 'pic')
        (jest 'dav')
        (jest 'bid')
        (jest 'bal')
        (jest 'tim')
        (jest 'tas')
        (jest 'mal')
        (jest 'lig')
        (jest 'siv')
        (jest 'tag')
        (jest 'pad')
        (jest 'sal')
        (jest 'div')
        (jest 'dac')
        (jest 'tan')
        (jest 'sid')
        (jest 'fab')
        (jest 'tar')
        (jest 'mon')
        (jest 'ran')
        (jest 'nis')
        (jest 'wol')
        (jest 'mis')
        (jest 'pal')
        (jest 'las')
        (jest 'dis')
        (jest 'map')
        (jest 'rab')
        (jest 'tob')
        (jest 'rol')
        (jest 'lat')
        (jest 'lon')
        (jest 'nod')
        (jest 'nav')
        (jest 'fig')
        (jest 'nom')
        (jest 'nib')
        (jest 'pag')
        (jest 'sop')
        (jest 'ral')
        (jest 'bil')
        (jest 'had')
        (jest 'doc')
        (jest 'rid')
        (jest 'moc')
        (jest 'pac')
        (jest 'rav')
        (jest 'rip')
        (jest 'fal')
        (jest 'tod')
        (jest 'til')
        (jest 'tin')
        (jest 'hap')
        (jest 'mic')
        (jest 'fan')
        (jest 'pat')
        (jest 'tac')
        (jest 'lab')
        (jest 'mog')
        (jest 'sim')
        (jest 'son')
        (jest 'pin')
        (jest 'lom')
        (jest 'ric')
        (jest 'tap')
        (jest 'fir')
        (jest 'has')
        (jest 'bos')
        (jest 'bat')
        (jest 'poc')
        (jest 'hac')
        (jest 'tid')
        (jest 'hav')
        (jest 'sap')
        (jest 'lin')
        (jest 'dib')
        (jest 'hos')
        (jest 'dab')
        (jest 'bit')
        (jest 'bar')
        (jest 'rac')
        (jest 'par')
        (jest 'lod')
        (jest 'dos')
        (jest 'bor')
        (jest 'toc')
        (jest 'hil')
        (jest 'mac')
        (jest 'tom')
        (jest 'dig')
        (jest 'fil')
        (jest 'fas')
        (jest 'mit')
        (jest 'hob')
        (jest 'har')
        (jest 'mig')
        (jest 'hin')
        (jest 'rad')
        (jest 'mas')
        (jest 'hal')
        (jest 'rag')
        (jest 'lag')
        (jest 'fad')
        (jest 'top')
        (jest 'mop')
        (jest 'hab')
        (jest 'nil')
        (jest 'nos')
        (jest 'mil')
        (jest 'fop')
        (jest 'fam')
        (jest 'dat')
        (jest 'nol')
        (jest 'din')
        (jest 'hat')
        (jest 'nac')
        (jest 'ris')
        (jest 'fot')
        (jest 'rib')
        (jest 'hoc')
        (jest 'nim')
        (jest 'lar')
        (jest 'fit')
        (jest 'wal')
        (jest 'rap')
        (jest 'sar')
        (jest 'nal')
        (jest 'mos')
        (jest 'lan')
        (jest 'don')
        (jest 'dan')
        (jest 'lad')
        (jest 'dov')
        (jest 'riv')
        (jest 'bac')
        (jest 'pol')
        (jest 'lap')
        (jest 'tal')
        (jest 'pit')
        (jest 'nam')
        (jest 'bon')
        (jest 'ros')
        (jest 'ton')
        (jest 'fod')
        (jest 'pon')
        (jest 'sov')
        (jest 'noc')
        (jest 'sor')
        (jest 'lav')
        (jest 'mat')
        (jest 'mip')
        (jest 'fap')
        ==
  =/  word-suffix  ;~  pose
        (jest 'fes')
        (jest 'nev')
        (jest 'nel')
        (jest 'pec')
        (jest 'teg')
        (jest 'rep')
        (jest 'tel')
        (jest 'mur')
        (jest 'fyr')
        (jest 'weg')
        (jest 'sen')
        (jest 'byr')
        (jest 'nyt')
        (jest 'mud')
        (jest 'tes')
        (jest 'lyr')
        (jest 'mun')
        (jest 'bec')
        (jest 'sed')
        (jest 'fed')
        (jest 'lux')
        (jest 'dem')
        (jest 'dyn')
        (jest 'lyn')
        (jest 'nyl')
        (jest 'nys')
        (jest 'sug')
        (jest 'ryc')
        (jest 'wer')
        (jest 'fyn')
        (jest 'lys')
        (jest 'rem')
        (jest 'lud')
        (jest 'ryl')
        (jest 'hul')
        (jest 'seb')
        (jest 'nyr')
        (jest 'ler')
        (jest 'dun')
        (jest 'ret')
        (jest 'des')
        (jest 'fet')
        (jest 'hes')
        (jest 'nes')
        (jest 'rud')
        (jest 'rel')
        (jest 'hus')
        (jest 'nyd')
        (jest 'wel')
        (jest 'fen')
        (jest 'lyd')
        (jest 'ryd')
        (jest 'lec')
        (jest 'ned')
        (jest 'rup')
        (jest 'lex')
        (jest 'ner')
        (jest 'len')
        (jest 'luc')
        (jest 'nul')
        (jest 'fex')
        (jest 'fur')
        (jest 'duc')
        (jest 'wed')
        (jest 'myl')
        (jest 'lev')
        (jest 'typ')
        (jest 'byt')
        (jest 'dyt')
        (jest 'pex')
        (jest 'mel')
        (jest 'run')
        (jest 'bep')
        (jest 'bus')
        (jest 'def')
        (jest 'lur')
        (jest 'dev')
        (jest 'pem')
        (jest 'sud')
        (jest 'byl')
        (jest 'tun')
        (jest 'hut')
        (jest 'mug')
        (jest 'ber')
        (jest 'deb')
        (jest 'lep')
        (jest 'fyl')
        (jest 'tuc')
        (jest 'rym')
        (jest 'pub')
        (jest 'mex')
        (jest 'tec')
        (jest 'syl')
        (jest 'nus')
        (jest 'lus')
        (jest 'ten')
        (jest 'mer')
        (jest 'fer')
        (jest 'nem')
        (jest 'leg')
        (jest 'tyc')
        (jest 'tus')
        (jest 'tyr')
        (jest 'fep')
        (jest 'ryx')
        (jest 'ryg')
        (jest 'pyx')
        (jest 'num')
        (jest 'ryn')
        (jest 'dux')
        (jest 'leb')
        (jest 'bex')
        (jest 'rus')
        (jest 'ted')
        (jest 'mec')
        (jest 'ref')
        (jest 'rev')
        (jest 'fun')
        (jest 'red')
        (jest 'res')
        (jest 'pun')
        (jest 'lyx')
        (jest 'seg')
        (jest 'tyn')
        (jest 'rum')
        (jest 'neb')
        (jest 'dus')
        (jest 'lyt')
        (jest 'med')
        (jest 'nub')
        (jest 'wyt')
        (jest 'ren')
        (jest 'rux')
        (jest 'nux')
        (jest 'tud')
        (jest 'fel')
        (jest 'sur')
        (jest 'tex')
        (jest 'deg')
        (jest 'dut')
        (jest 'set')
        (jest 'meb')
        (jest 'ter')
        (jest 'syp')
        (jest 'pel')
        (jest 'myr')
        (jest 'tug')
        (jest 'tux')
        (jest 'bel')
        (jest 'bet')
        (jest 'det')
        (jest 'mes')
        (jest 'myn')
        (jest 'dyl')
        (jest 'wet')
        (jest 'syr')
        (jest 'wex')
        (jest 'dec')
        (jest 'ruc')
        (jest 'sel')
        (jest 'sym')
        (jest 'wyx')
        (jest 'mus')
        (jest 'ben')
        (jest 'hep')
        (jest 'fus')
        (jest 'teb')
        (jest 'rex')
        (jest 'nyx')
        (jest 'mut')
        (jest 'sum')
        (jest 'web')
        (jest 'tev')
        (jest 'nym')
        (jest 'mul')
        (jest 'sec')
        (jest 'net')
        (jest 'meg')
        (jest 'rec')
        (jest 'wyn')
        (jest 'sem')
        (jest 'sup')
        (jest 'tyd')
        (jest 'reg')
        (jest 'syn')
        (jest 'rul')
        (jest 'pet')
        (jest 'sub')
        (jest 'nut')
        (jest 'den')
        (jest 'reb')
        (jest 'rys')
        (jest 'pur')
        (jest 'nep')
        (jest 'der')
        (jest 'bur')
        (jest 'wyc')
        (jest 'sef')
        (jest 'dex')
        (jest 'bes')
        (jest 'tep')
        (jest 'wyd')
        (jest 'tyl')
        (jest 'rut')
        (jest 'mev')
        (jest 'het')
        (jest 'dul')
        (jest 'pyl')
        (jest 'feb')
        (jest 'hex')
        (jest 'byn')
        (jest 'wen')
        (jest 'met')
        (jest 'tul')
        (jest 'led')
        (jest 'tem')
        (jest 'ped')
        (jest 'sul')
        (jest 'del')
        (jest 'pes')
        (jest 'sep')
        (jest 'lut')
        (jest 'mep')
        (jest 'lun')
        (jest 'nex')
        (jest 'syd')
        (jest 'tyv')
        (jest 'ryt')
        (jest 'hec')
        (jest 'lug')
        (jest 'put')
        (jest 'dys')
        (jest 'dep')
        (jest 'lup')
        (jest 'peg')
        (jest 'heb')
        (jest 'nup')
        (jest 'dyr')
        (jest 'syx')
        (jest 'ryp')
        (jest 'sun')
        (jest 'wyl')
        (jest 'ser')
        (jest 'wep')
        (jest 'dur')
        (jest 'syt')
        (jest 'pen')
        (jest 'ful')
        (jest 'let')
        (jest 'sut')
        (jest 'per')
        (jest 'sev')
        (jest 'wes')
        (jest 'bud')
        (jest 'nec')
        (jest 'zod')
        ==
  =/  pat-p-word  ;~(plug word-prefix word-suffix)
  =/  four-pat-p-words  ;~(plug pat-p-word hep pat-p-word hep pat-p-word hep pat-p-word)
  =/  parse-four-pat-ps  (cook cook-four-pat-ps four-pat-p-words)
  =/  whitespace  (star ;~(pose gah (just '\09') (just '\0d')))
  =/  end-or-next-command  ;~(pose ;~(plug whitespace mic) whitespace mic)
  =/  parse-galaxy  (cook cook-galaxy ;~(plug sig word-suffix))
  =/  parse-star  (cook cook-star ;~(plug sig pat-p-word))
  =/  parse-planet  (cook cook-planet ;~(plug sig pat-p-word hep pat-p-word))
  :: to do: 3 word moon
  =/  parse-moon  (cook cook-moon ;~(plug sig parse-four-pat-ps))
::  =/  parse-comet  
::        (cook cook-comet ;~(plug sig parse-four-pat-ps (stun [5 10] hep) parse-four-pat-ps))
  =/  parse-face  ;~(pfix whitespace sym)
  =/  parse-qualified-2-name  ;~(pose ;~(pfix whitespace ;~((glue dot) sym sym)) parse-face)
  =/  parse-qualified-3  ;~  pose
          ;~((glue dot) (star sym) (star sym) (star sym))
          ;~(plug (star sym) dot dot (star sym))
          ;~((glue dot) (star sym) (star sym))
          (star sym)
        ==
  =/  parse-qualified-3-name  ;~(pfix whitespace parse-qualified-3)
  =/  parse-force-or-3-name  ;~(pose ;~(pfix whitespace (jester 'force')) parse-qualified-3-name)
  =/  parse-ship  ;~  pose
      ::    parse-comet
          parse-moon
          parse-planet
          parse-star
          parse-galaxy
        ==
  =/  parse-ship-db-qualified  ;~  pose
          ;~((glue dot) parse-ship (star sym) (star sym) (star sym))
          ;~(plug ;~(sfix parse-ship dot) (star sym) dot dot (star sym))
          ;~((glue dot) parse-ship (star sym) (star sym))
          parse-qualified-3
        ==
  =/  parse-force-qualified-name  ;~  sfix 
        ;~(pose ;~(plug parse-force-or-3-name parse-qualified-3-name) parse-qualified-3-name) 
        end-or-next-command
        ==
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
      (cold %truncate-table ;~(plug whitespace (jester 'truncate') whitespace (jester 'table')))
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
      =/  parse-create-namespace  ;~  sfix
            parse-qualified-2-name
            end-or-next-command
            ==
      ~|  "Cannot parse name to face in create-namespace {<p.q.command-nail>}"
            =/  create-namespace-nail  (parse-create-namespace [[1 1] q.q.command-nail])
      =/  parsed  (wonk create-namespace-nail)
      =/  cursor  p.q.u.+3:q.+3:create-namespace-nail
      =/  next-cursor  ?:  (gth -.cursor -.script-position)   :: if we advanced to next input line
            [(add -.cursor -.script-position) +.cursor]       ::   add lines and use nail cursor column
          [-.cursor (add +.cursor +.script-position)]         :: else add column positions
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
      !!
    %drop-index
      !!
    %drop-namespace
      !!
    %drop-table
      ~|  "Cannot parse drop-table {<p.q.command-nail>}"   
      =/  drop-table-nail  (parse-force-qualified-name [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-table-nail)
      =/  cursor  p.q.u.+3:q.+3:drop-table-nail
      =/  next-cursor  ?:  (gth -.cursor -.script-position)   :: if we advanced to next input line
            [(add -.cursor -.script-position) +.cursor]       ::   add lines and use nail cursor column
          [-.cursor (add +.cursor +.script-position)]         :: else add column positions
      ?:  ?=([@ [[@ %~] [@ %~] [@ %~]]] parsed)               :: "drop table force db.ns.name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table i.+<.parsed i.+>-.parsed i.+>+.parsed %.y) commands]
        ==
      ?:  ?=([@ [[@ %~] @ [@ %~]]] parsed)                  :: "drop table force db..name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table i.+<.parsed 'dbo' +>+<.parsed %.y) commands]
        ==
      ?:  ?=([@ [[@ %~] [@ %~]]] parsed)                      :: "drop table force ns.name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table current-database i.+<.parsed +>-.parsed %.y) commands]
        ==
      ?:  ?=([@ [@ %~]] parsed)                               :: "drop table force name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table current-database 'dbo' +<.parsed %.y) commands]
        ==
      ?:  ?=([[[@ %~] [@ %~] [@ %~]] %~] parsed)              :: "drop table db.ns.name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table i.-<.parsed i.->-.parsed i.->+.parsed %.n) commands]
        ==
      ?:  ?=([[[@ %~] @ [@ %~]] %~] parsed)                 :: "drop table db..name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table i.-<.parsed 'dbo' ->+<.parsed %.n) commands]
        ==
      ?:  ?=([[[@ %~] [@ %~]] %~] parsed)                     :: "drop table ns.name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table current-database i.-<.parsed ->-.parsed %.n) commands]
        ==
      ?:  ?=([[@ %~] %~] parsed)                              :: "drop table name"
        %=  $
          script           q.q.u.+3.q:drop-table-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-table:ast %drop-table current-database 'dbo' -<.parsed %.n) commands]
        ==
      !!
    %drop-view
      ~|  "Cannot parse drop-view {<p.q.command-nail>}"   
      =/  drop-view-nail  (parse-force-qualified-name [[1 1] q.q.command-nail])
      =/  parsed  (wonk drop-view-nail)
      =/  cursor  p.q.u.+3:q.+3:drop-view-nail
      =/  next-cursor  ?:  (gth -.cursor -.script-position)   :: if we advanced to next input line
            [(add -.cursor -.script-position) +.cursor]       ::   add lines and use nail cursor column
          [-.cursor (add +.cursor +.script-position)]         :: else add column positions
      ?:  ?=([@ [[@ %~] [@ %~] [@ %~]]] parsed)               :: "drop view force db.ns.name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view i.+<.parsed i.+>-.parsed i.+>+.parsed %.y) commands]
        ==
      ?:  ?=([@ [[@ %~] @ [@ %~]]] parsed)                  :: "drop view force db..name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view i.+<.parsed 'dbo' +>+<.parsed %.y) commands]
        ==
      ?:  ?=([@ [[@ %~] [@ %~]]] parsed)                      :: "drop view force ns.name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view current-database i.+<.parsed +>-.parsed %.y) commands]
        ==
      ?:  ?=([@ [@ %~]] parsed)                               :: "drop view force name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view current-database 'dbo' +<.parsed %.y) commands]
        ==
      ?:  ?=([[[@ %~] [@ %~] [@ %~]] %~] parsed)              :: "drop view db.ns.name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view i.-<.parsed i.->-.parsed i.->+.parsed %.n) commands]
        ==
      ?:  ?=([[[@ %~] @ [@ %~]] %~] parsed)                 :: "drop view db..name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view i.-<.parsed 'dbo' ->+<.parsed %.n) commands]
        ==
      ?:  ?=([[[@ %~] [@ %~]] %~] parsed)                     :: "drop view ns.name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view current-database i.-<.parsed ->-.parsed %.n) commands]
        ==
      ?:  ?=([[@ %~] %~] parsed)                              :: "drop view name"
        %=  $
          script           q.q.u.+3.q:drop-view-nail
          script-position  next-cursor
          commands         
            [`command-ast`(drop-view:ast %drop-view current-database 'dbo' -<.parsed %.n) commands]
        ==
      !!
    %truncate-table
      =/  parse-truncate-table  ;~  sfix
            ;~(pfix whitespace parse-ship-db-qualified)
            end-or-next-command
            ==   
      ~|  "Cannot parse truncate-table {<p.q.command-nail>}"
      =/  truncate-table-nail  (parse-truncate-table [[1 1] q.q.command-nail])
      =/  parsed  (wonk truncate-table-nail)
      =/  cursor  p.-.truncate-table-nail
      =/  next-cursor  ?:  (gth -.cursor -.script-position)   :: if we advanced to next input line
            [(add -.cursor -.script-position) +.cursor]       ::   add lines and use nail cursor column
          [-.cursor (add +.cursor +.script-position)]         :: else add column positions

      ~|  "command-nail:     {<command-nail>}"
      ~|  "q.q.command-nail:     {<q.q.command-nail>}"
::      ~|  "truncate-table-nail:  {<truncate-table-nail>}"
      ~|  "parsed:  {<parsed>}"
      ~|  "next-cursor:  {<next-cursor>}"
::      ~|  "q.q.u.+3.q:truncate-table-nail:  {<q.q.u.+3.q:truncate-table-nail>}"

      =/  yikes  0
      !!

    ::[['~' 'z' 'o' 'd'] [i=25.188 t=~] [i=29.550 t=~] [i=1.701.667.182 t=~]]
::      ?:  ?=([[@ [@ %~] [@ %~] [@ %~]]] parsed)               :: "truncate table ~zod.db.ns.name"
::        %=  $
::          script           q.q.u.+3.q:truncate-table-nail
::          script-position  next-cursor
::          commands
::            [`command-ast`(truncate-table:ast %truncate-table (unit 'zod') 'db' 'ns' 'name') commands]         
::            [`command-ast`(truncate-table:ast %truncate-table (unit -.parsed) i.+<.parsed i.+>.parsed i.+>+.parsed) commands]
::        ==
::      !!  
    ==
--
