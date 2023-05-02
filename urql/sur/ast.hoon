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
    value-list=@t
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
+$  qualified-column
  $:
    %qualified-column
    qualifier=qualified-object
    column=@t
    alias=(unit @t)
  ==
+$  foreign-key
  $:
    %foreign-key
    name=@t
    table=qualified-object
    columns=(list ordered-column)                             :: the source columns
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
+$  binary-operator      ?(%eq inequality-operator %equiv %not-equiv %in)
+$  unary-operator       ?(%not %exists)
+$  conjunction          ?(%and %or)
+$  ops-and-conjs        ?(ternary-operator binary-operator unary-operator all-any-operator conjunction)
+$  predicate-component  ?(ops-and-conjs qualified-column value-literal value-literal-list aggregate)
+$  predicate            (tree predicate-component)
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
+$  simple-query
  $:
    %simple-query
    from=(unit from)
    scalars=(list scalar-function)
    predicate=(unit predicate)
    group-by=(list grouping-column)
    having=(unit predicate)
    selection=select
    order-by=(list ordering-column)
  ==
+$  from
  $:
    %from
    object=query-object
    joins=(list joined-object)
  ==
+$  query-row
  $:
    %query-row
    (list @t)
  ==
+$  query-source  $%(query-row qualified-object)
+$  query-object
  $:
    %query-object
    object=query-source
    alias=(unit @t)
  ==
+$  joined-object
  $:
    %joined-object
    join=join-type
    object=query-object
    predicate=(unit predicate)
  ==
+$  select
  $:
    %select
    top=(unit @ud)
    bottom=(unit @ud)
    distinct=?
    columns=(list selected-column)
  ==
+$  selected-column
  $%(qualified-column qualified-object selected-aggregate selected-value) :: scalar-function or selected-scalar) fish-loop
+$  selected-aggregate
  $:
    %selected-aggregate
    aggregate=aggregate
    alias=(unit @t)
  ==
+$  selected-scalar
  $:
    %selected-scalar
    scalar=scalar-function
    alias=(unit @t)
  ==
+$  selected-value
  $:
    %selected-value
    value=value-literal
    alias=(unit @t)
  ==
+$  aggregate
  $:
  %aggregate
  function=@t
  source=aggregate-source
  ==
+$  aggregate-source     $%(qualified-column) :: selected-scalar)
+$  grouping-column      ?(qualified-column @ud)
+$  ordering-column
  $:
  %ordering-column
  column=grouping-column
  is-ascending=?
  ==
+$  cte-query
  $:
    %cte
    name=@t
    simple-query
  ==
+$  collection-operators  ?(%union %combine %except %intersect %divided-by %divided-by-with-remainder)
+$  operated-query
  $:
    %operated-query
    operator=collection-operators
    simple-query
  ==
+$  query
  $:
  %query
  ctes=(list cte-query)
  simple-query
  (list operated-query)
  ==
::
::  data manipulation ASTs
::
+$  delete
  $:
    %delete
    table=qualified-object
    ctes=(list cte-query)
    predicate=(unit predicate)
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
    table=qualified-object
    columns=(list @t)
    values=(list value-or-default)
    ctes=(list cte-query)
    predicate=(unit predicate)
  ==
+$  merge
  $:
    %merge
    target-table=(unit query-object)
    new-table=(unit query-object)
    source-table=(unit query-object)
    ctes=(list cte-query)
    predicate=predicate
    matched=(list matching)
    unmatched-by-target=(list matching)
    unmatched-by-source=(list matching)
  ==
+$  matching
  $:
    %matching
    predicate=(unit predicate)
    matching-profile=matching-profile
  ==
+$  matching-action  ?(%insert %update %delete)
+$  matching-profile
  $%([%insert (list [@t datum])] [%update (list [@t datum])] %delete)
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
    object-name=qualified-object
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
    object=qualified-object
    enabled=?
  ==
+$  create-type          $:([%create-type name=@t])
+$  create-view
  $:
    %create-view
    view=qualified-object
    query=query
  ==
::
::  drop ASTs
::
+$  drop-database        $:([%drop-database name=@t force=?])
+$  drop-index
  $:
    %drop-index
    name=@t
    object=qualified-object
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
    object=qualified-object
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
    object-type=object-type
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
    object=qualified-object
    enabled=?
  ==
+$  alter-view
  $:
    %alter-view
    view=qualified-object
    query=query
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
