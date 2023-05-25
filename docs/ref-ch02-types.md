# Types
All data representations (nouns) of the Obelisk system are strongly typed.

## Column Types
The fundamental data element in Obelisk is an atom that is typed by an aura. Data cells, which are intersections of a `<table-set>` row and column, are typed atoms. . 

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
