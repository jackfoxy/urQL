# Introduction

## Introduction

A _first principles_ approach should guide the design and implementation of an Urbit RDBMS. The _urQL_ language, influenced by _The Third Manifesto_ (Date and Darwen), emphasizes composability and type safety. The areas where SQL design was hurried or neglected in terms of theoretical considerations (like nullable columns) have been excluded or corrected, making urQL closer to the _Query Language_ that Codd and Date would have endorsed.

An Urbit-native RDBMS implementation presents new opportunities for composability. Any desk's data is readily available for _mash up_ apps and _ad hoc_ queries, and every desk persisting data to an RDBMS already has search functionality built-in.

## Functionality

The Urbit RDBMS, Obelisk, consists of:

1. A scripting language, urQL, and parser.
2. A a database engine, Obelisk.
3. A front-end agent app using the parser and Obelisk APIs. (currently does not exist)

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

## Common documenataion structures

The following are some common language structures used throughout the reference.

```
<db-qualifier> ::= { <database>.<namespace>. | <database>.. | <namespace>. }
```

Provides the fully qualified path to a `<table>` or `<view>` object on the host ship. (NOTE: `<view>` is not yet implemented and is intended to be similar similar to SQL view.)

`<database>` defaults to the current-databse property of the Obelisk agent.

`<namespace>` defaults to 'dbo' (database owner).

```
<ship-qualifier> ::=
  { @p.<database>.<namespace>.
  | @p.<database>..
  | <db-qualifier> }
```

Adds ship qualification to the database/namespace qualifier.

```
<common-table-expression> ::= <transform> [ AS ] <alias>
```
`<transform> ::=` from transform diagram. (More on `<transform>` under `<table-set>`.)

`<alias> ::= @t` case-agnostic, see alias naming discussion above.

Each CTE is always referenced by alias, never inlined.

```
<table-set> ::=
  [ <ship-qualifier> ]{ <table> | <view> }
  | <common-table-expression>
  | *
```

When `<view>, <table>` have the same name within a namespace, `<view>` is said to "shadow" `<table>` wherever syntax accepts `<table>` or `<view>`. 

A base-tables, `<table>`, are the sole source of content in an Obelisk database and the only manifestation of `<table-set>` that is not a computation.

The `<transform>` command returns a `<table-set>`, hence every `<table-set>` is typed by one or more equivalent urQL `<transform>` commands. This is true because every `<transform>` command is idempotent. (More on this in the section on __Time__.)

The row type is defined by the component columns and may be a union type. Hence rows of `<table-set>`s that are not also `<table>`s may be of varying length (jagged). The order of rows may be determined in the `<transform>` command, and so `<table-set>`s are not strictly __sets___ in the mathematical sense.

```
<as-of-time> ::=
  AS OF { NOW
          | <timestamp>
          | n { SECONDS | MINUTES | HOURS | DAYS | WEEKS | MONTHS | YEARS } AGO
          | <inline-scalar>
        }
```


## Literals

urQL supports most of the aura types implemented in Urbit as literals for the INSERT and SELECT commands. The *loobean* Urbit literal types is supported by *different* literals in urQL than normally in Urbit. urQL supports some literal types in multiple ways. Dates, timespans, and ships can all be represented in INSERT without the leading **~**. Unsigned decimal can be represented without the dot thousands separator. In some cases the support between INSERT and SELECT is not the same.

Column types (auras) not supported for INSERT can only be inserted into tables through the API.

| Aura |     Description      |     INSERT         |     SELECT         |
| :--- |:-------------------- |:------------------:|:------------------:|
| @c   | UTF-32               | ~-~45fed. | **not supported** |
| @da  | date                 | ~2020.12.25 | ~2020.12.25 |
|      |                      | ~2020.12.25..7.15.0 | ~2020.12.25..7.15.0 |
|      |                      | ~2020.12.25..7.15.0..1ef5 | ~2020.12.25..7.15.0..1ef5 |
|      |                      | 2020.12.25 | 2020.12.25 |
|      |                      | 2020.12.25..7.15.0 | 2020.12.25..7.15.0 |
|      |                      | 2020.12.25..7.15.0..1ef5 | 2020.12.25..7.15.0..1ef5 
| @dr  | timespan             | ~d71.h19.m26.s24..9d55 | ~d71.h19.m26.s24..9d55 |
|      |                      | ~d71.h19.m26.s24 | ~d71.h19.m26.s24 |
|      |                      | ~d71.h19.m26 | ~d71.h19.m26 |
|      |                      | ~d71.h19 | ~d71.h19 |
|      |                      | ~d71 | ~d71 |
|      |                      | d71.h19.m26.s24..9d55 |  |
|      |                      | d71.h19.m26.s24 |  |
|      |                      | d71.h19.m26 |  |
|      |                      | d71.h19 |  |
|      |                      | d71 |  |
| @f   | loobean              | y, n, Y, N | Y, N |
| @if  | IPv4 address         | .195.198.143.90 | .195.198.143.90 |
| @is  | IPv6 address         | .0.0.0.0.0.1c.c3c6.8f5a | .0.0.0.0.0.1c.c3c6.8f5a |
| @p   | ship name            | ~sampel-palnet | ~sampel-palnet |
|      |                      | sampel-palnet  |  |
| @q   | phonemic base        | **not supported** | **not supported** |
| @rh  | half float (16b)     | **not supported** | **not supported** |
| @rs  | single float (32b)   | .3.14, .-3.14 | .3.14, .-3.14 |
| @rd  | double float (64b)   | .~3.14, .~-3.14 | .~3.14, .~-3.14 |
| @rq  | quad float (128b)    | **not supported** | **not supported** |
| @sb  | signed binary        | --0b10.0000 | --0b10.0000 |
|      |                      | -0b10.0000 | -0b10.0000 |
| @sd  | signed decimal       | --20, -20 | --20, -20 |
| @sv  | signed base32        | --0v201.4gvml.245kc | --0v201.4gvml.245kc |
|      |                      | -0v201.4gvml.245kc | -0v201.4gvml.245kc |
| @sw  | signed base64        | --0w2.04AfS.G8xqc | --0w2.04AfS.G8xqc |
|      |                      | -0w2.04AfS.G8xqc | -0w2.04AfS.G8xqc |
| @sx  | signed hexadecimal   | --0x2004.90fd | --0x2004.90fd |
|      |                      | -0x2004.90fd | -0x2004.90fd |
| @t   | UTF-8 text (cord)    | 'cord', 'cord\\\\'s' <sup>1</sup> | 'cord', 'cord\\\\'s' <sup>1</sup> |
| @ta  | ASCII text (knot)    | *support pending* | *support pending* |
| @tas | ASCII text (term)    | *support pending* | *support pending* |
| @ub  | unsigned binary      | 10.1011 | 10.1011 |
| @ud  | unsigned decimal     | 2.222 | 2.222 |
|      |                      | 2222 | 2222 |
| @uv  | unsigned base32      | **not supported** | **not supported** |
| @uw  | unsigned base64      | e2O.l4Xpm | **not supported** |
| @ux  | unsigned hexadecimal | 0x12.6401 | 0x12.6401 |

 <sup>1</sup> Example of embedding single quote in @t literal.

## Types
All data representations (nouns) of the Obelisk system are strongly typed.

## Column Types
The fundamental data element in Obelisk is an atom that is typed by an aura. Data cells, which are intersections of a `<table-set>` row and column, are typed atoms.

Obelisk supports the following auras (see ch12-literals for representing the atomic types):

| Aura |         Description          |
| :--- |:---------------------------- |
| @c   | UTF-32                       |
| @da  | date                         |
| @dr  | timespan                     |
| @f   | loobean                      |
| @if  | IPv4 address                 |
| @is  | IPv6 address                 |
| @p   | ship name                    |
| @q   | phonemic base                |
| @rh  | half float (16b)             |
| @rs  | single float (32b)           |
| @rd  | double float (64b)           |
| @rq  | quad float (128b)            |
| @sb  | signed (low bit) binary      |
| @sd  | signed (low bit) decimal     |
| @sv  | signed (low bit) base32      |
| @sw  | signed (low bit) base64      |
| @sx  | signed (low bit) hexadecimal |
| @t   | UTF-8 text (cord)            |
| @ta  | ASCII text (knot, url safe)  |
| @tas | ASCII text (term)            |
| @ub  | unsigned binary              |
| @ud  | unsigned decimal             |
| @uv  | unsigned base32              |
| @uw  | unsigned base64              |
| @ux  | unsigned hexadecimal         |

Columns are typed by an aura and indexed by name.
```
<column-type> ::=
  <aura/name>
```

## Table Row and Table Types

All datasets in Obelisk are sets, meaning each typed element, `<row-type>`, only exists once. 
Datasets are also commonly regarded as tables, which is accurate when the index of each cell (row/column intersection) can be calculated. This calculation is possible when the `SELECT` statement includes an `ORDER BY` clause.

All tables originate from, or are derived from, base tables created by the `CREATE TABLE` command.

A base-table (`<table>`) row has a default type, which is the table's atomic aura-typed columns in a fixed order.
```
<row-type> ::= list <aura>
```
Each base table is typed by its `<row-type>`.
```
<table-type> ::= (list <row-type>)
```
A base table's definition includes a unique primary row order, giving it `list` type rather than `set` type. This is not true for all `<table-set>` instances.

Rows from `<view>`s, `<common-table-expression>`s, and the command output from `<transform>`, or any other table that is not a base-table, can only have an immutable row order if it is explicitly specified (i.e., the `SELECT` statement includes an `ORDER BY` clause). In general, these other tables have types that are unions of `<row-type>`s.

When the `<table-set-type>` is a union of `<row-type>`s. There is a `<row-type>` representing the full width of the `SELECT` statement and as many `<row-type>` sub-types as necessary to represent any unjoined outer `JOIN`s that result in a selected row. 

Sub-types align their columns with the all-column `<row-type>`, regardless of the SELECT statement's construction.

In general, `<table-set>`s have the type:
```
<table-set-type> ::= 
  (list <row-type>)
  | (set (<all-column-row-type> | <row-sub-type-1> | ... | <row-sub-type-n> ))
```

## Additional Types
All the static types in Obelisk API are defined in `sur/ast/hoon`.

## Remarks

Even `<table>`s can be typed as sets, because a `SELECT` statement without an `ORDER BY` clause has an undefined row order.

Regardless of the presence of `ORDER BY`, any `<table-set>` emitted by any step in a `<transform>`, a CTE, or a `<view>` is a list of `<row-type>` in some (possibly arbitrary) order.

Ultimately, "set" is the most important concept because every `<table-set>` will have one unique row value for any given sub-type of `<row-type>`.
