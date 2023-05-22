# ALTER INDEX
Alters the structure of an existing `<index>`

```
ALTER [ UNIQUE ] [ NONCLUSTERED | CLUSTERED ] INDEX [ <db-qualifer> ]<index>
ON { <table> | <view> }
[ ( <column> [ ASC | DESC ] [ ,...n ] ) ]
{ DISABLE | RESUME}
```


## API
```
+$  alter-index
  $:
    %alter-index
    name=qualified-object
    object=qualified-object
    columns=(list ordered-column)
    action=index-action
  ==
```

## Arguments

**`[ <db-qualifer> ]<index>`**
Target index.

## Remarks
The command results in a state change of the Obelisk agent.

Cannot alter primary key and foreign key indices.

`RESUME` will rebuild the index if the underlying object is dirty.

TO DO: investigate hoon ordered maps to determine what exactly "clustered" means in hoon. It may be that multiple clustering indices are possibley, freaking out most DBAs.

## Produced Metadata

## Exceptions
column does not exist
UNIQUE specified and existing values are not unique for the column(s) specified

# ALTER NAMESPACE

```
ALTER NAMESPACE [ <database>. ]<namespace>
  TRANSFER { TABLE | VIEW } [ <db-qualifer> ]{ <table> | <view> }
```


## API
```
+$  alter-namespace
  $:
    %alter-namespace
    database-name=@tas
    source-namespace=@tas
    object-type=object-type
    target-namespace=@tas
    target-name=@tas
  ==
```

## Arguments

** **


## Remarks
The command results in a state change of the Obelisk agent.

The namespace *sys* cannot be altered, nor can objects be transferred in or out of it.

## Produced Metadata

## Exceptions

# ALTER PROCEDURE

TBD

```
ALTER { PROC | PROCEDURE }
    [<db-qualifer>]<procedure>
    [ { #<parameter> <data-type> } ] [ ,...n ]
AS { <urql command>; | *hoon } [ ;...n ]
```


# ALTER TABLE

```
ALTER TABLE [ <db-qualifer> ]{ <table> }
  { ALTER COLUMN ( { <column>  <aura> } [ ,... n ] )
    | ADD COLUMN ( { <column>  <aura> } [ ,... n ] )
    | DROP COLUMN ( { <column> } [ ,... n ] )
    | ADD FOREIGN KEY <foreign-key> (<column> [ ,... n ])
      REFERENCES [<namespace>.]<table> (<column> [ ,... n ])
      [ ON DELETE { NO ACTION | CASCADE } ]
      [ ON UPDATE { NO ACTION | CASCADE } ]
      [ ,... n ]
    | DROP FOREIGN KEY ( <foreign-key> [ ,... n ] } )
```

Example:
```
ALTER TABLE my-table
DROP FOREIGN KEY fk-1, fk-2
```


## API
```
+$  alter-table
  $:
    %alter-table
    table=qualified-object
    alter-columns=(list column)
    add-columns=(list column)
    drop-columns=(list @tas)
    add-foreign-keys=(list foreign-key)
    drop-foreign-keys=(list @tas)
  ==
```

## Arguments

** **

## Remarks
The command results in a state change of the Obelisk agent.

## Produced Metadata

## Exceptions

# ALTER TRIGGER

TBD

```
ALTER TRIGGER { [ <db-qualifer> ]{ <trigger> } | ALL ]
     ON { SERVER | <database.name> | <table> | <view> }
     [ ENABLE | DISABLE ]
```

# ALTER VIEW

```
ALTER VIEW [ <db-qualifer> ]{ <view> }
( { [<alias>.] <column> } [ ,...n ] )
AS <select_statement>
```


## API
```
+$  alter-view
  $:
    %alter-view
    view=qualified-object
    transform
  ==
```

## Arguments

** **

## Remarks
The command results in a state change of the Obelisk agent.

## Produced Metadata

## Exceptions