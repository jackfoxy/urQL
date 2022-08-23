# Reference Introduction

## urQL language diagrams

[ ] indicate optional entries.
{ } nest options separated by |. In some cases it groups a portion of the diagram to indicate optional repeating by [ ,...n ].
< > gives a hint for user input, e.g. \<alias>, \<table>, or is a placeholder for expanded diagram defined elsewhere, usually near where it is used.

The following hints are used througout the reference.

```
<db-qualifer> ::=
  { <database>.<namespace>. | <database>.. | <namespace>. }
```

```
<ship-qualifer> ::=
  { @p.<database>.<namespace>.
    | @p.<database>..
    | <database>.<namespace>.
    | <database>..
    | <namespace>. }
```

```
<table-view> ::=
  [ <ship-qualifer> ]{ <view> | <table> }
```

```
<common-table-expression> ::=
  { <alias> AS ( <query> ) } [ ,...n ] ;
```

`<query> ::=` from query diagram.

`<expression>  ::=` from query diagram.

Any other text outside of brakets is required within its context, including whitespace. All whitespace is the same and a single space or LF suffices. Whitespace around delimiting `;` and ',' is optional. There are some other cases where the optionality of whitespace is not clear in the diagram, usually before or after parentheses.

Multiple statements must be delimited by `;` and common table expressions, CTEs, must be terminated by `;` within the respective statement.

Keywords are uppercase. This is not a requirement, but is strongly suggested for readability.

## Functionality

urQL derives from SQL and varies only in a few cases. Queries are constructed in FROM..WHERE..SELECT.. order, unlike SQL, because this is the order of events in plan exection. The user should be cognizant of the ordering of events.

Reading and/or updating data on foreign ships is allowed provided the ship's pilot has granted permission. Cross database joins are allowed, but not cross ship joins. Views cannot be defined on foreign databases.

## Issues

1. how to handle views shadowing tables
2. relational division
3. stored procedures
4. https://github.com/sigilante/l10n localization of date/time