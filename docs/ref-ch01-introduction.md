# Introduction

## Manifesto

The relational data model is a fundamental component of the computing stack that until now has been conspicuously missing from Urbit. Why is this fundamental technology, with a sound foundation in relational algebra, set theory, and first order predicate calculus so frequently overlooked?

1. RDBMS technology is not typically covered in today's CS curriculums.
2. Developers don't want to hassle with setting up a server.
3. Proprietary closed-source RDBMS implementations.
4. Trendy _no sql_ alternatives.
5. Re-inventing the wheel for reasons.
6. The prevalence of artificial keys in real world SQL implementations.

Some of these reasons are irrational, others are just wrong.

1. Speculatively, this may be because there is nothing new to discover. The relational model rests on well-understood math theory.
2. Urbit fixes this.
3. Urbit fixes this.
4. Most programmers will never face a situation where an RDBMS is inadequate or inferior for the task. _Key-value Store_ is a very simple  relational database. The SQL standard was hastily developed and has some unnecessary baggage which makes it hard to master. Cyclic graphs such as social graphs are difficult to model and work with in SQL. This can be addressed in a blank-slate Urbit implementation.
5. New and junior programmers with little or no SQL exposure mistakenly think they can write better/faster IO by hand, whereas experienced engineers know to use SQL first for all the functionality wherein it can be used (except sorting, which is not strictly part of the relational model).
6. Explaining the case for using natural keys on tables over artificial keys is beyond the scope of this document. See for instance [keys demo](https://github.com/ami-levin/Keys-Session/blob/master/Keys_Demo.sql). Suffice it to say almost all sample databases for learning SQL incorporate artificial keys, which reinforces wrong practices, so most SQL database implementations also make this mistake. Artificial keys make the database schema brittle and hard for humans to comprehend.


An Urbit native RDBMS implementation opens new opportunities for composability. All of a ship's data is transparently available for _mash up_ apps and _ad hoc_ queries. Search comes for free.

An Urbit RDBMS deserves a _first principles_ approach to design and implementation. The _urQL_ language is heavily influenced by _The Third Manifesto_ (Date and Darwen), emphasizing composability and type safety. Areas where SQL was too hastily designed and/or developed without regard to theory (like nullable columns) have been eliminated, making urQL much more like the _Query Language_ Codd and Date would have been proud of.

## Functionality

The Urbit RDBMS (still to be named) consists of

1. A scripting language and parser (this document)
2. A plan builder
3. Eventually, a front-end app...anyone can write one from the parser and plan APIs.

The scripting language, _urQL_, derives from SQL and varies in only a few cases.

Queries are constructed in FROM..WHERE..SELECT.. order, the order of events in plan execution.
(The user should be cognizant of the ordering of events.)

Columns are atoms with auras.
Table definitions do not allow for nullable columns.

All user-defined names follow the hoon term naming standard.

All except the simplest functions are collected in their own section and aliased inline into SELECT clause and predicates.
Emphasizes composability and improves readability.

There are no subqueries.
JOINs and/or CTEs handle all such use cases and emphasize composability.
CTEs can be referenced for certain use cases in predicates.

Relational division is supported with a DIVIDED BY operator.

Reading and/or updating data on foreign ships is allowed provided the ship's pilot has granted permission.
Cross database joins are allowed, but not cross ship joins.
Views cannot be defined on foreign databases.

Queries can operate on previous versions and data of the databases via the AS OF clause.

This document has placeholders for Stored Procedures and Triggers, which have yet to be defined. We anticipate these will be points for integration with hoon.
Pivoting and Windowing will be in a future release.

## urQL language diagrams and general syntax

[ ] indicate optional entries.
{ } nest options | delimited.
In some cases { } groups a portion of the diagram to indicate optional repeating [ ,...n ].
\<...> user supplied argument which either expands to a diagram defined elsewhere or hints for user input, e.g. `<alias>`, `<new-table>`. 
The intelligent reader is assumed intuitive enough to understand these are labels corresponding to typed nouns in the given context.

Text outside of brackets represents required keywords.
Keywords are uppercase. This is not a requirement, but is strongly suggested for readability.

All whitespace is the same, a single space or LF suffices.
Whitespace around delimiting `;` and `,` is optional.
Whitespace is required on the outside of parentheses and optional on the inside.

Multiple statements must be delimited by `;`.

All object names follow the hoon rules for terms, i.e. character set restricted to lower-case alpha-numeric and hypen characters and first character must be alphabetic.

Column, table, and other aliases provide an alternative to referencing the qualified object name and follow the hoon term naming standards except that upper-case alphabetic characters are allowed and alias evaluation is case agnositc, e.g. `t1` and `T1` represent the same alias.

All objects in the database *sys* and namespace *sys* are owned by the system and read only for all user commands. The namespace *sys* may not be specified in any other database.

## Common hints used throughout the reference

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
<common-table-expression> ::=
  <transform> [ AS ] <alias>
```
`<transform> ::=` from transform diagram.
When used as a CTE `<transform>` output must be a pass-thru virtual-table.

`<alias> ::= @t` case-agnostic, see alias naming discussion above.

Each `<common-table-expression>` is always referenced by alias, never inlined.

```
<table-set> ::=
  [ <ship-qualifer> ]{ <table> | <view> }
  | <common-table-expression>
  | ( column-1 [,...column-n] )
  | *
```

If not qualified, `<table> | <view>` references the host ship, current database, and the default user namespace, `dbo`.

When `<view>, <table>` have the same name within a namespace, `<view>` is said to "shadow" `<table>` wherever syntax accepts `<table> | <view>`. 

`<table>` is the only manifestation of `<table-set>` that is not a computation and the `<table-set>` set consists of one row type. This is a base-table.

`<view>` evaluated (possibly cached) to resolve `<transform>`.

Every other manifestation of `<table-set>` is a virtual-table and the row type may be a union type.

`( column-1 [,...column-n] )` assigns column names to the widest row type of an incoming pass-thru table. `*` accepts an incoming pass-thru virtual-table assuming column names established by the previous statement that created the pass-thru.

## Issues

(incomplete list)
1. stored procedures TBD
2. https://github.com/sigilante/l10n localization of date/time TBD
3. triggers TBD
4. SELECT single column named top, bottom, or distinct is problematic
5. Add `DISTINCT` and other advanced aggregate features. Grouping Sets. Rollup. Cube. GROUPING function. Feature T301, 'Functional dependencies' from SQL 1999.
6. column:ast vase
7. value-literal:ast vase
8. parse `with` statement (and make `with` first part of merge)
9. parse scalars and aggregates
10. grouping FROM/SELECT statements after set operation
11. The parser currently parses the syntax *MERGE... PRODUCING... WITH...*. This will eventually be refactored to *WITH... MERGE...*.
12. add aura @uc Bitcoin address 0c1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa
13. remove support of untyped atom @?
