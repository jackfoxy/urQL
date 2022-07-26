:: abstract syntax trees for urQL parsing and execution
::
|%
::
::  simple union types
::
+$  referential-integrity-action   ?(%delete-cascade %update-cascade)
+$  index-action         ?(%rebuild %disable %resume)
+$  all-or-any           ?(%all %any)
+$  bool-conjunction     ?(%and %or)
+$  object-type          ?(%table %view)
+$  join-type            ?(%join %left-join %right-join %outer-join %outer-join-all %cross-join)
+$  grant-permission     ?(%adminread %readonly %readwrite)
+$  grantee              ?(%parent %siblings %moons (list @p))
+$  revoke-permission    ?(%adminread %readonly %readwrite %all)
+$  revoke-from          ?(%parent %siblings %moons %all (list @p))
::
::  command component types
::
+$  value-literal        
  $:
    value-type=@tas
    value=@
  ==
+$  value-literal-list        
  $:
    %value-literal-list
    value-type=@tas
    value-list=@t       ::  (crip ; delimited tape)
  ==
+$  ordered-column
  $:      
    %ordered-column
    column-name=@t
    is-ascending=?
  ==
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
+$  cte-name             @t
+$  column-qualifier     $%(qualified-object cte-name)
+$  qualified-column
  $:
    %qualified-column
    qualifier=column-qualifier
    column=@t
    alias=(unit @t)
  ==
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
::
::  expressions
::
:: { = | <> | != | > | >= | !> | < | <= | !< | BETWEEN...AND... | IS DISTINCT FROM | IS NOT DISTINCT FROM }
+$  ternary-operator     %between
+$  inequality-operator  ?(%neq %gt %gte %lt %lte)
+$  all-any-operator     ?(%all %any)
+$  binary-operator      ?(%eq inequality-operator %distinct %not-distinct %in all-any-operator)
+$  unary-operator       ?(%not %exists)
+$  conjunction          ?(%and %or)
+$  ops-and-conjs        ?(ternary-operator binary-operator unary-operator conjunction)
::+$  predicate-component  ?(ternary-operator binary-operator unary-operator conjunction qualified-column value-literal value-literal-list) :: aggregate)
+$  predicate-component  ?(ops-and-conjs qualified-column value-literal value-literal-list) :: aggregate)
+$  predicate            (tree predicate-component) ::* :: would like to be (tree predicate-component), but type system does not support
+$  datum                $%(qualified-column value-literal)
+$  datum-or-scalar      $@(datum scalar-function)
+$  scalar-operator      ?(%lus %tar %hep %fas %ket)
+$  scalar-token         ?(%pal %par scalar-operator)
+$  arithmatic
  $:
    %arithmetic
    operator=scalar-operator
    left=*                         :: datum-or-scalar
    right=*                        :: datum-or-scalar
  ==
+$  if-then-else
  $:
    %if-then-else
    if=*                           :: predicate
    then=*                         :: datum-or-scalar
    else=*                         :: datum-or-scalar
  ==
+$  case-when-then
  $:
    when=*                         :: predicate | datum
    then=*                         :: datum-or-scalar
  ==
+$  case
  $:
    %case
    target=datum
    cases=(list case-when-then)
    else=*                         :: datum-or-scalar
  ==
+$  coalesce 
  $:
    %coalesce           
    data=(list datum)
  ==
+$  scalar-function
  $%
    if-then-else
    case
    coalesce
  ==
::
::  query
::
+$  selected-scalar
  $%
    %selected-scalar 
    scalar=scalar-function 
    alias=(unit @t)
  ==
+$  selected-object
  $%
    %all-columns 
    query-object
  ==
+$  query-object 
  $:
      %query-object
      object=qualified-object
      alias=(unit @t)
  ==
+$  joined-object
  $%
    %joined-object
    join=join-type
    object=query-object
    predicate=(unit predicate)
  ==
+$  from
  $:
    %from
    object=query-object
    joins=(list joined-object)
  ==
+$  aggregate-source     $%(qualified-column selected-scalar)
+$  aggregate
  $:
  %aggregate
  function=@t
  source=aggregate-source ::*                         :: should be aggregate-source
  ==
+$  selected-aggregate
  $:
  %selected-aggregate
  aggregate=aggregate
  alias=(unit @t)
  ==
+$  selected-column      ?(%all qualified-column selected-object) :: selected-aggregate) ::  scalar-function or selected-scalar fish-loop
+$  select
  $:
    %select
    top=(unit @ud)
    bottom=(unit @ud)
    distinct=?
    columns=(list selected-column)
  ==
+$  grouping-column      ?(qualified-column @ud)
+$  ordering-column
  $:
  %ordering-column
  grouping-column
  is-ascending=?
  ==
+$  group-by             (list grouping-column)
+$  having               predicate
+$  order-by             (list ordering-column)
+$  simple-query
  $:
    %simple-query
    (unit from)
    (list scalar-function)
    (unit predicate)
    select
    (unit group-by)
    (unit having)
    (unit order-by)
  ==
+$  cte-query
  $:  
    %cte
    name=@t
    simple-query
  ==
+$  ctes                  
  (map @t cte-query)                :: common table expressions
+$  query                
  $:((unit ctes) simple-query)      :: what we've all been waiting for
:: 
::  data manipulation ASTs
::
+$  delete
  $:
    %delete
    table=qualified-object
    cte=(unit ctes)
    predicate
  ==
+$  insert-values        $%([%data (list (list datum))] [%query query])
+$  insert
  $:
    %insert
    table=qualified-object
    columns=(unit (list @t))
    values=insert-values
  ==
+$  value-or-default     ?(%default datum)
+$  update
  $:
    %update
    (unit ctes)
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
    (unit ctes)
    source-table=qualified-object
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
    name=qualified-object
    object=qualified-object
    columns=(list ordered-column)
    action=index-action
  ==
+$  alter-namespace
  $:
    %alter-namespace
    database-name=@t
    source-namespace=@t
    object-type=object-type                 :: because it can be a table or view
    target-namespace=@t
    target-name=@t
  ==
+$  alter-table
  $:
    %alter-table
    table=qualified-object
    alter-columns=(list column)
    add-columns=(list column)
    drop-columns=(list @t)
    add-foreign-keys=(list foreign-key)
    drop-foreign-keys=(list @t)
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
+$  grant-object         ?([%database @t] [%namespace [@t @t]] qualified-object)
+$  grant
  $:
    %grant
    permission=grant-permission
    to=grantee
    grant-target=grant-object
  ==
+$  revoke-object        ?([%database @t] [%namespace [@t @t]] %all qualified-object)
+$  revoke
  $:
    %revoke
    permission=revoke-permission
    from=revoke-from
    revoke-target=revoke-object
  ==
--
