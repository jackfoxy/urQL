# Types
All data representations (nouns) of the Obelisk system are strongly typed.

## Column Types
The fundamental data element is an atom typed by an aura. 
All data cells (the intersection of a `<table-set>` row and column) are a typed atom. 

Obelisk supports the following auras:

|aura|type|representation|
|----|----|--------------|
|@c|unicode codepoint|~-~45fed.|
|@da|date, absolute|~2020.12.25..7.15.0..1ef5|
|@dr|date, relative|~d71.h19.m26.s24.9d55|
|@f|loobean|%.y|
|@if|IPv4 address|.195.198.143.90|
|@is|IPv6 address|.0.0.0.0.0.1c.c3c6.8f5a|
|@p|phonemic base|~laszod-dozser-fosrum-fanbyr|
|@q|phonemic base, unscrambled|.~laszod-dozser-dalteb-hilsyn|
|@rh|IEEE-754 half-precision, 16-bit|.~~3.14|
|@rs|IEEE-754 single-precision, 32-bit|.3.141592653589793|
|@rd|IEEE-754 double-precision, 64-bit|.~3.141592653589793|
|@rq|IEEE-754 quadruple-precision, 128-bit|.~~~3.141592653589793|
|@s|integer, signed (sign bit low)||
|@sb|signed binary|--0b10.0000|
|@sd|signed decimal|--1.000|
|@sv|signed base-32|--0v201.4gvml.245kc|
|@sw|signed base-64|--0w2.04AfS.G8xqc|
|@sx|signed hexadecimal|--0x2004.90fd|
|@t|UTF-8 text (cord)|'urbit'|
|@ta|ASCII text (knot)|~.urbit|
|@tas|ASCII text symbol (term)|%urbit|
|@ub|unsigned binary|0b10.1011|
|@ud|unsigned decimal|8.675.309|
|@uv|unsigned base-32|0v88nvd|
|@uw|unsigned base-64|0wx5~J|
|@ux|unsigned hexadecimal|0x84.5fed|

Columns are typed by an aura and indexed by name.
```
<column-type> ::=
  <aura/name>
```

## Table Row and Table Types

All datasets in Obelisk are sets, meaning each typed element (the `<row-type>`) only exists once. 
They are also commonly regarded as tables, but this is only true when the index of each cell (row/column intersenction) can be calculated, and this is only true when the `SELECT` statement includes and `ORDER BY` clause.

All tables either are, or derive from, base-tables spawned by `CREATE TABLE`. 

Base-table (`<table>`) rows have exactly one type, the table's atomic aura-typed columns in a fixed order.
```
<row-type> ::= 
  list <aura>
```
Each base-table is itself typed by its `<row-type>`.
```
<table-type> ::= 
  (list <row-type>)
```
Base-table definitions include a unique primary ordering of rows, hence it has list type, not set type. This is not the case for every other instance of `<table-set>`.

Rows from `<view>`s, `<common-table-expression>`'s, and command output from `<transform>`, or any other table that is not a base-table can only have an immutable row ordering, if it was so specified (i.e. the `SELECT` statement has an `ORDER BY` clause). In general all these other tables have types that are unions of `<row-type>`s.

When the `<table-set-type>` is a union of `<row-type>`s there is a `<row-type>` that represents the full width of the SELECT statement and as many `<row-type>` sub-types as necessary to represent any unjoined LEFT or RIGHT JOINs that resulted in a row. 

Sub-types are column-wise aligned with the all-column `<row-type>`, regardless of how the SELECT statement is constructed.

In general `<table-set>`s have the type:
```
<table-set-type> ::= 
  (list <row-type>)
  | (set (<all-column-row-type> | <row-sub-type-1> | ... | <row-sub-type-n> ))
```

## Other Types
All the static types in Obelisk API are defined in sur/ast/hoon.

## Remarks

Ultimately even `<table>`s can be typed as sets, because `SELECT` without `ORDER BY` has undefined row order.

On the other hand, regardless of the presence of `ORDER BY` any `<table-set>` emitted by any step in a `<transform>` is a list of `<row-type>` in some (possibly arbitrary) order.

And ultimately "set" is the most important concept because every `<table-set>` will have one unique row value for any given `sub-type` of `<row-type>`.
