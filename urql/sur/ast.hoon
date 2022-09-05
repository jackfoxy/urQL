:: abstract syntax trees for urQL parsing and execution
::
|%
::  helper types
::
+$  referential-integrity-action   ?(%delete-cascade %update-cascade)
+$  index-action         ?(%rebuild %disable %resume)
+$  ordered-column
  $:      
    %ordered-column
    column-name=@t
    is-ascending=?
  ==
+$  all-or-any           ?(%all %any)
+$  bool-conjunction     ?(%and %or)
+$  default-or-column-value  ?(%default [@ta @])
+$  column 
  $:
    %column 
    name=@t 
    column-type=@t
  ==
+$  qualified-object
  $:
    %qualified-object
    ship=(unit @p)
    database=@t
    namespace=@t
    name=@t
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
    table=qualified-object
    column=@t
    alias=@t
  ==
:: { = | <> | != | > | >= | !> | < | <= | !< }
+$  binary-operator      @tas
+$  unary-operator       ?(%y %n)
+$  binary-predicate     $:(* binary-operator *)
+$  unary-predicate      $:(unary-operator *)
+$  constant             ?(@ud @t @tas @da @p)
+$  expression
  $%
    default-or-column-value
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
    table=qualified-object
    cte=(unit cte)
    predicate
  ==
+$  insert-values        
    $%([%expressions (list (list expression))] [%query query])
+$  insert
  $:
    %insert
    table=qualified-object
    columns=(unit (list @t))
    values=insert-values
  ==
+$  value-or-default     ?(%default expression)
+$  update
  $:
    %update
    (unit cte)
    table=qualified-object
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
    %merge
    (unit cte)
    source-qualifier=qualifier
    source-table=qualified-object
    target-qualifier=qualifier
    target-table=qualified-object
    on-predicate=predicate
    when-matched=(unit matching)
    when-not-matched-by-target=(unit matching)
    when-not-matched-by-source=(unit matching)
  ==
+$  truncate-table
  $:
    %truncate-table
    table=qualified-object
  ==
::
::  create ASTs
::
+$  create-database      $:([%create-database name=@t])
+$  create-index  
  $:
    %create-index
    name=@t
    object-name=qualified-object                 :: because index can be over table or view
    is-unique=?
    is-clustered=?
    columns=(list ordered-column)
  ==
+$  create-namespace     $:([%create-namespace database-name=@t name=@t])

+$  foreign-key
  $:
    %foreign-key
    name=@t
    table=qualified-object
    columns=(list ordered-column)                                         :: the source columns
    reference-table=qualified-object                          :: reference (target) table
    reference-columns=(list @t)                               :: and columns
    referential-integrity=(list referential-integrity-action) :: what to do when referenced item deletes or updates
  ==
+$  create-table
  $:
    %create-table
    table=qualified-object
    columns=(list column)
    primary-key=create-index
    foreign-keys=(list foreign-key)
  ==
+$  create-trigger
  $:
    %create-trigger
    name=@t
    object=qualified-object                 :: because trigger can be over table or view
    enabled=?
  ==
+$  create-type          $:([%create-type name=@t])
+$  create-view
  $:
    %create-view
    view=qualified-object
    query=query                    :: awaiting construction of query
  ==
::
::  drop ASTs
::
+$  drop-database        $:([%drop-database name=@t force=?])
+$  drop-index
  $:
    %drop-index
    name=@t
    object=qualified-object                :: because index can be over table or view
  ==
+$  drop-namespace       $:([%drop-namespace database-name=@t name=@t force=?])
+$  drop-table
  $:
    %drop-table
    table=qualified-object
    force=?
  ==
+$  drop-trigger
  $:
    %drop-trigger
    name=@t
    object=qualified-object               :: because trigger can be over table or view
  ==
+$  drop-type            $:([%drop-type name=@t])
+$  drop-view
  $:
    %drop-view
    view=qualified-object
    force=?
  ==
::
::  alter ASTs
::
+$  alter-index
  $:
    %alter-index
    name=@t
    object=qualified-object               :: because index can be over table or view
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
    table=qualified-object
    alter-columns=(unit (list column))
    add-columns=(unit (list column))
    drop-columns=(unit (list @t))
    add-foreign-keys=(unit (list foreign-key))
    drop-foreign-keys=(unit (list @t))
  ==
+$  alter-trigger
  $:
    %alter-trigger
    name=@t
    object=qualified-object                 :: because trigger can be over table or view
    enabled=?
  ==
+$  alter-view
  $:
    %alter-view
    view=qualified-object
    query=query                    :: awaiting construction of query
  ==
::
::  permissions
::
+$  grant-permission     ?(%adminread %readonly %readwrite)
+$  grantee              ?(%parent %siblings %moons (list @p))
+$  grant-object         ?([%database @t] [%namespace [@t @t]] qualified-object)
+$  grant
  $:
    %grant
    permission=grant-permission
    to=grantee
    grant-target=grant-object
  ==
+$  revoke-permission    ?(%adminread %readonly %readwrite %all)
+$  revoke-from          ?(%parent %siblings %moons %all (list @p))
+$  revoke-object        ?([%database @t] [%namespace [@t @t]] %all qualified-object)
+$  revoke
  $:
    %revoke
    permission=revoke-permission
    from=revoke-from
    revoke-target=revoke-object
  ==
--
