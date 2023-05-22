# DROP DATABASE

`DROP DATABASE [ FORCE ] <database-name>`


## API
```
+$  drop-database        
  $: 
    %drop-database
    name=@tas
    force=?
  ==
```

## Arguments

** **

## Remarks
The command results in a state change of the Obelisk agent.

Only succeeds when no *populated* tables exist in the database unless `FORCE` is specified.

## Produced Metadata

## Exceptions


# DROP INDEX

```
DROP INDEX <index-name>
  ON [ <db-qualifer> ] { <table-name> | <view-name> }
```


## API
```
+$  drop-index
  $:
    %drop-index
    name=@tas
    object=qualified-object
  ==
```

## Arguments

** **

## Remarks
The command results in a state change of the Obelisk agent.

Cannot drop indices whose names begin with "pk-" as these are table primary keys.

drop of fk- same as alter-table
TO DO: update create-index to indicate name must be unique
       work out at what level?
      how to deal with alter namespace considerations.

## Produced Metadata

## Exceptions


# DROP NAMESPACE

`DROP NAMESPACE [ FORCE ] [ <database-name>. ]<namespace-name>`


## API
```
+$  drop-namespace
  $:
    %drop-namespace 
    database-name=@tas 
    name=@tas 
    force=?
  ==
```

## Arguments

** **

## Remarks
The command results in a state change of the Obelisk agent.

Only succeeds when no tables or views are in the namespace, unless `FORCE` is specified, possibly resulting in cascading object drops described in `DROP TABLE`.

Cannot drop namespaces *dbo* and *sys*.

## Produced Metadata

## Exceptions


# DROP TABLE

`DROP TABLE [ FORCE ] [ <db-qualifer> ]{ <table-name> }`


## API
```
+$  drop-table
  $:
    %drop-table
    table=qualified-object
    force=?
  ==
```


## Arguments

** **

## Remarks
The command results in a state change of the Obelisk agent.

Cannot drop if used in a view or foreign key, unless `FORCE` is specified, resulting in cascading object drops.

## Produced Metadata

## Exceptions


# DROP TRIGGER

TBD

```
DROP TRIGGER   [ <db-qualifer> ]{ <trigger-name> }
  ON { <table-name> | <view-name> }
```


# DROP TYPE

TBD

`DROP TYPE <type-name>`


## Remarks
Cannot drop if type-name is in use.


# DROP VIEW

`DROP VIEW [ FORCE ] [ <db-qualifer> ]<view-name>`


## API
```
+$  drop-view
  $:
    %drop-view
    view=qualified-object
    force=?
  ==
```

## Arguments

** **

## Remarks
The command results in a state change of the Obelisk agent.

Cannot drop if used in another view, unless `FORCE` is specified, resulting in cascading object drops.

## Produced Metadata

## Exceptions

