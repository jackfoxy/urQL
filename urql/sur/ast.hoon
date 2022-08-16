:: abstract syntax trees for urQL parsing and execution
:: (really just data structures)
::
|%
::  helper types
::
+$  foreign-key-action   ?(%no-action %cascade %set-null %set-default)
+$  index-action         ?(%rebuild %disable %resume)
+$  order                ?(%ascending %descending)
+$  column-order         [column-name=@t column-order=order]
+$  all-or-any           ?(%all %any)
+$  bool-conjunction     ?(%and %or)
+$  column 
  $:
    %column 
    name=@t 
    column-type=*                  :: must accept any mold
    default-value=(unit *)
  ==
+$  qualifier
  $:
    ship=@p
    database=@t
    namespace=@t
  ==
+$  qualified-column
  $:
    column-qualifier=qualifier
    table=@t
    column=@t
    alias=@t
  ==
:: { = | <> | != | > | >= | !> | < | <= | !< }
+$  binary-operator      @tas
+$  unary-operator       ?(%y %n)
+$  binary-predicate     $:(* binary-operator *)
+$  unary-predicate      $:(unary-operator *)
+$  constant             ?(@ud @t @tas @da)
+$  expression
  $%
    [%constant constant]
    [%scalar-function scalar-function]     
    [%qualified-column qualified-column]
    [%unary-predicate unary-predicate]
    [%binary-predicate binary-predicate]
  ==
::
+$  if-then-else
  $:
    if=*                           :: predicate | bool expression
    then=expression
    else=expression
  ==
+$  case-when-then
  $:
    when=*                         :: predicate | bool expression
    then=expression
  ==
+$  case
  $:
    target=expression
    when-thens=(list case-when-then)
    else=expression
  ==
+$  subset-scalars       $%([%if-then-else if-then-else] [%case case])
+$  coalesce             (list subset-scalars)
+$  scalar-function
  $%
    [%if-then-else if-then-else]
    [%case case]
    [%coalesce coalesce]
  ==
::
::  query
::
+$  join-type            ?(%join %left-join %right-join %outer-join)
+$  query-object 
  $:  ::
      ship=(unit @p)
      database-name=@t
      namespace=@t
      object-name=@t               :: because index can be over table or view
      alias=(unit @t)
  ==
+$  predicate-between    $:(%predicate-between unary-operator * *)
+$  predicate-null       $:(%predicate-null unary-operator *)
+$  predicate-distinct   $:(%predicate-distinct unary-operator * *)
+$  predicate-in-query   $:(%predicate-query unary-operator *)
+$  predicate-in-list    $:(%predicate-list unary-operator *)
+$  predicate-any        $:(%predicate-any all-or-any * binary-operator *)
+$  predicate-exists     $:(%predicate-exists unary-operator *)
+$  simple-predicate
  $%
    [%unary-predicate unary-predicate]
    [%binary-predicate binary-predicate]
    [%predicate-between]
    [%predicate-null]
    [%predicate-distinct]
    [%predicate-in-query]
    [%predicate-in-list]
    [%predicate-any]
    [%predicate-exists]
  ==
+$  conjoined-predicate    
  $:
    %conjoined-predicate 
    bool-conjunction 
    simple-predicate
  ==
+$  predicate
  $:
    simple-predicate=simple-predicate
    conjoined-predicates=(unit (list conjoined-predicate))
  ==
+$  joined-object
  $:
    join=join-type
    object=query-object
    (unit predicate)
  ==
+$  from
  $:
    object=query-object
    joins=(list joined-object)
  ==
+$  select-columns       ?(%all query-object qualified-column)
+$  select
  $:
    %select
    top=(unit @ud)
    distinct=?
    columns=(list select-columns)
  ==
+$  by-name-or-number    ?(select-columns @ud)
+$  group-by             (list by-name-or-number)
+$  having               predicate
+$  simple-query
  $:
  from
  (unit predicate)
  select
  group-by
  having
  ==
+$  cte                  
  (list simple-query)              :: common table expression
+$  query                
  $:((unit cte) simple-query)      :: what we've all been waiting for
:: 
::  data manipulation ASTs
::
+$  delete
  $:
    %delete
    ship=(unit @p)
    database-name=@t
    namespace=@t
    table-name=@t
    cte=(unit cte)
    predicate
  ==
+$  insert-values        
    $%([%expressions (list expression)] [%query query])
+$  insert
  $:
    %insert
    ship=(unit @p)
    database-name=@t
    namespace=@t
    table-name=@t
    columns=(list @t)
    values=insert-values
  ==
+$  value-or-default     ?(%default expression)
+$  update
  $:
    (unit cte)
    qualifier=qualifier
    table=@tas
    columns=(list @t)
    values=(list value-or-default)
    predicate=(unit predicate)
  ==
+$  matching-action       
  $%([%insert insert] [%update update] [%delete delete])
+$  matching
  $:
    predicate=(unit predicate)
    predicate=(unit *)
    matching-action=(list matching-action)
  ==
+$  merge
  $:
    (unit cte)
    source-qualifier=qualifier
    source-table=@tas
    target-qualifier=qualifier
    target-table=@tas
    on-predicate=predicate
    when-matched=(unit matching)
    when-not-matched-by-target=(unit matching)
    when-not-matched-by-source=(unit matching)
  ==
+$  truncate-table
  $:
    %insert
    ship=(unit @p)
    database-name=@t
    namespace=@t
    table-name=@t
  ==
::
::  create ASTs
::
+$  create-database      $:([%create-database name=@t])
+$  create-index  
  $:
    %create-index
    database-name=@t
    namespace=@t
    name=@t
    object-name=@t                 :: because index can be over table or view
    is-unique=?
    is-clustered=?
    columns=(list column-order)
  ==
+$  create-namespace     $:([%create-namespace database-name=@t name=@t])
+$  foreign-key
  $:
    %create-foreign-key
    database-name=@t
    namespace=@t
    name=@t
    table-name=@t
    columns=(list @t)              :: the source columns
    reference-namespace=@t         :: reference table and columns
    reference-table-name=@t        :: in other words, the target index
    reference-columns=(list @t)
    on-delete=foreign-key-action   :: what to do when referenced item deletes
    on-update=foreign-key-action   :: and for updates?
  ==
+$  create-table
  $:
    %create-table
    database-name=@t
    namespace=@t                   :: defaults to 'dbo'
    name=@t
    columns=(list column)
    primary-key=create-index
    foreign-keys=(list foreign-key)
  ==
+$  create-trigger
  $:
    %create-trigger
    database-name=@t
    namespace=@t
    name=@t
    object-name=@t                 :: because trigger can be over table or view
    enabled=?
  ==
+$  create-type          $:([%create-type name=@t])
+$  create-view
  $:
    %create-view
    database-name=@t
    namespace=@t
    name=@t
    query=query                    :: awaiting construction of query
  ==
::
::  drop ASTs
::
+$  drop-database        $:([%drop-database name=@t force=?])
+$  drop-index
  $:
    %drop-index
    database-name=@t
    name=@t
    namespace=@t
    object-name=@t                 :: because index can be over table or view
  ==
+$  drop-namespace       $:([%drop-namespace database-name=@t name=@t force=?])
+$  drop-table
  $:
    %drop-table
    database-name=@t
    namespace=@t
    name=@t
    force=?
  ==
+$  drop-trigger
  $:
    %drop-trigger
    database-name=@t
    namespace=@t
    name=@t
    object-name=@t                 :: because trigger can be over table or view
  ==
+$  drop-type            $:([%drop-type name=@t])
+$  drop-view
  $:
    %drop-view
    database-name=@t
    namespace=@t
    name=@t
    force=?
  ==
::
::  alter ASTs
::
+$  alter-index
  $:
    %alter-index
    database-name=@t
    namespace=@t
    name=@t
    object-name=@t                 :: because index can be over table or view
    action=index-action
  ==
+$  alter-namespace
  $:
    %alter-namespace
    database-name=@t
    source-namespace=@t
    object-name=@t                 :: because it can be a table or view
    is-table=?
    target-namespace=@t
  ==
+$  alter-table
  $:
    %alter-table
    database-name=@t
    namespace=@t                   :: defaults to 'dbo'
    name=@t
    alter-columns=(unit (list column))
    add-columns=(unit (list column))
    drop-columns=(unit (list @t))
    add-foreign-keys=(unit (list foreign-key))
    drop-foreign-keys=(unit (list @t))
  ==
+$  alter-trigger
  $:
    %alter-trigger
    database-name=@t
    namespace=@t
    name=@t
    object-name=@t                 :: because trigger can be over table or view
    enabled=?
  ==
+$  alter-view
  $:
    %alter-view
    database-name=@t
    namespace=@t
    name=@t
    query=query                    :: awaiting construction of query
  ==
::
::  permissions
::
+$  grant-permission     ?(%adminread %readonly %readwrite)
+$  grantee              ?(%parent %siblings %moons (list @p))
+$  grant
  $:
    %grant
    permission=grant-permission
    to=grantee
    database=(unit @t)
    namespace=(unit @t)
    object=(unit @t)               :: because table or view
  ==
+$  grant-permission-all  ?(%adminread %readonly %readwrite %all)
+$  grantee-all           ?(%parent %siblings %moons %all (list @p))
+$  revoke
  $:
    %revoke
    permission=grant-permission-all
    to=grantee-all
    database=(unit @t)
    namespace=(unit @t)
    object=(unit @t)               :: because table or view
  ==
--
