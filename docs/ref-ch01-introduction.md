# Introduction

## Manifesto

A _first principles_ approach should guide the design and implementation of an Urbit RDBMS. The _urQL_ language, influenced by _The Third Manifesto_ (Date and Darwen), emphasizes composability and type safety. The areas where SQL design was hurried or neglected in terms of theoretical considerations (like nullable columns) have been excluded or corrected, making urQL closer to the _Query Language_ that Codd and Date would have endorsed.

An Urbit-native RDBMS implementation presents new opportunities for composability. Any desk's data is readily available for _mash up_ apps and _ad hoc_ queries, and every desk persisting data to an RDBMS already has search functionality built-in.

## Functionality

The Urbit RDBMS, Obelisk, consists of:

1. A scripting language and parser (as documented here).
2. A plan builder.
3. A front-end agent app using the parser and APIs.

The scripting language, _urQL_, is a derivation of SQL with significant variations.

Queries are constructed in FROM..WHERE..SELECT.. order, mirroring the order of events in plan execution. (Users should be aware of the event ordering.)

Columns are typed atoms. Table definitions do not permit nullable columns.

All user-defined names (excepting aliases) follow the hoon term naming standard.

Functions, apart from the simplest ones, are grouped in their own clause and inlined into SELECT clause and predicates by alias.

Inlined sub-queries are prohibited to enhance readability. JOINs and/or CTEs accommodate all related use cases and promote composability. CTEs can be referenced for certain use cases in predicates.

Relational division is supported with a DIVIDED BY operator.

Set operations support nesting of queries on the right side of the operator.

All data manipulation commands (DELETE, INSERT, MERGE, UPDATE), along with the SELECT statement, can accept a dataset output by the previous TRANSFORM step and send its output dataset to the next step. 

Reading and/or updating data on foreign ships is permissible if the ship's pilot has granted permission. Cross database joins are allowed, but cross ship joins are not. Views cannot be defined on foreign databases.

Queries can operate on previous versions and data of the databases through the the AS OF clause.

This document has placeholders for Stored Procedures and Triggers, which have yet to be defined. These will be points for integration with hoon and other agents.

## urQL language diagrams and general syntax

[ ] indicate optional entries.
{ } nest options | delimited. If there is a default, it is the first entry.
In some cases { } groups a portion of the diagram to indicate optional repeating [ ,...n ].
\<...> Represents a user-supplied argument that either expands to a diagram defined elsewhere or hints at user input, e.g. `<alias>`, `<new-table>`.

Text outside of brackets represents required keywords.
Keywords are uppercase. This is not a requirement, but is strongly suggested for readability.

All whitespace is treated the same; a single space or line feed suffices.
Whitespace around delimiting `;` and `,` is optional.
Whitespace is required on the outside of parentheses and optional on the inside.

Multiple statements must be delimited by `;`.

All object names follow the hoon rules for terms, i.e. character set restricted to lower-case alpha-numeric and hypen characters and first character must be alphabetic.

Column, table, and other aliases provide an alternative to referencing the qualified object name and follow the hoon term naming standard, except that upper-case alphabetic characters are permitted and alias evaluation is case agnositc, e.g. `t1` and `T1` represent the same alias.

All objects in the database *sys* and namespace *sys* are system-owned and read-only for all user commands. The namespace *sys* may not be specified in any user-defined database.

## Common structures throughout the reference
The following are some common language structures used throughout the reference:

```
<db-qualifer> ::= { <database>.<namespace>. | <database>.. | <namespace>. }
```

Provides the fully qualified path to a `<table>` or `<view>` object on the host ship.

`<database>` defaults to the current-databse property of the Obelisk agent.

`<namespace>` defaults to 'dbo' (database owner).

```
<ship-qualifer> ::=
  { @p.<database>.<namespace>.
  | @p.<database>..
  | <db-qualifer> }
```

Adds ship qualification.

```
<common-table-expression> ::= <transform> [ AS ] <alias>
```
`<transform> ::=` from transform diagram.

`<alias> ::= @t` case-agnostic, see alias naming discussion above.

Each CTE is always referenced by alias, never inlined.

```
<table-set> ::=
  [ <ship-qualifer> ]{ <table> | <view> }
  | <common-table-expression>
  | ( column-1 [,...column-n] )
  | *
```

When `<view>, <table>` have the same name within a namespace, `<view>` is said to "shadow" `<table>` wherever syntax accepts `<table>` or `<view>`. 

A base-table, `<table>`, is the only manifestation of `<table-set>` that is not a computation.

Every `<table-set>` is a virtual-table and the row type may be a union type.

If not cached, `<view>` must be evaluated to resolve.

`( column-1 [,...column-n] )` assigns column names to the widest row type of an incoming pass-thru table.

`*` accepts an incoming pass-thru virtual-table assuming column names established by the previous set-command (`DELETE`, `INSERT`, `MERGE`, `QUERY`, or `UPDATE`) that created the pass-thru.

Similarly `*` as the output of `DELETE`, `INSERT`, `MERGE` creates a pass-thru virtual-table for consumption by the next step or ultimate product of a `<transform>`.

## Issues

1. Stored procedures - To Be Designed (TBD)
2. Triggers - TBD
3. Localization of date/time - TBD (See: https://github.com/sigilante/l10n)
4. `SELECT` single column named `top` or `bottom` may cause problems
5. Add `DISTINCT` and other advanced aggregate features like Grouping Sets, Rollup, Cube, GROUPING function. Feature T301 'Functional dependencies' from SQL 1999 specification needs to be added.
6. Change column:ast and value-literal:ast to vase in parser and AST.
7. Set operators, multiple commands per `<transform>` not complete in the parser.
8. Scalar and aggregate functions incompletely implemented in parser and not fully desinged.
9. Add aura @uc Bitcoin address 0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa
10. Custom types and support for arbitrary noun columns - TBD
11. Pivoting and windowing will be implemented in a future release.
12. `<view>` not implemented in parser and caching is TBD
