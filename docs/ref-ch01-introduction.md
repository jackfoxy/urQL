# Introduction

## Manifesto

## Functionality

The scripting language, _urQL_, derives from SQL and varies in only a few cases.

Queries are constructed in FROM..WHERE..SELECT.. order, the order of events in plan exection.
(The user should be cognizant of the ordering of events.)

Table definitions do not allow for nullable columns.
Columns are atoms with auras.

All user-defined names follow hoon term naming standard.

All except the simplest functions and statements separated into their own clause and aliased inline into select clause and predicates.
Emphasizes composability and improves readability.

There are no subqueries.
JOINs and/or CTEs handle all such use cases and emphasize composability.
CTEs can be referenced for certain use cases in predicates.
Emphasizes composability and improves readability.

Reading and/or updating data on foreign ships is allowed provided the ship's pilot has granted permission. Cross database joins are allowed, but not cross ship joins.
Views cannot be defined on foreign databases.
## urQL language diagrams

[ ] indicate optional entries.
{ } nest options | delimited.
In some cases it groups a portion of the diagram to indicate optional repeating [ ,...n ].
< > hint for user input, e.g. \<alias>, \<table>, or is a placeholder for expanded diagram defined elsewhere.

The following hints are used througout the reference.

```
<db-qualifer> ::=
  { <database>.<namespace>. | <database>.. | <namespace>. }
```

```
<ship-qualifer> ::=
  { @p.<database>.<namespace>.
    | @p.<database>..
    | <db-qualifer> }
```

```
<table-view> ::=
  [ <ship-qualifer> ]{ <table> | <view> }
```

```
<common-table-expression> ::=
  { <alias> AS ( <query> ) } [ ,...n ] ;
```

`<query> ::=` from query diagram.

`<expression>  ::=` from query diagram.

Text outside of brakets represents required keywords.

All whitespace is the same, a single space or LF suffices.
Whitespace around delimiting `;` and `,` is optional.
Whitespace is required on the outside of parentheses and optional on the inside.

Multiple statements must be delimited by `;`.

Keywords are uppercase. This is not a requirement, but is strongly suggested for readability.

## Issues

(incomplete list)
1. stored procedures
2. https://github.com/sigilante/l10n localization of date/time
3. triggers
