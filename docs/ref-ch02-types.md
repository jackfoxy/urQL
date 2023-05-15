# Types
All data presentations (nouns) of the Obelisk system available for user interaction -- whether reading, manipulation, or creation -- are strongly typed.

The fundamental data element is an atom typed by an aura. All data cells (the intersection of a table row and table column) are a typed atom. Obelisk supports the following auras:

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

All datasets in Obelisk are tables. All tables either are, or derive from, base-tables spawned by `CREATE TABLE`. 

Base-table rows have exactly one type, the table's atomic aura-typed columns in a fixed order.
```
<row-type> ::= list @
```
Each base-table is itself typed by its own definition.
```
<base-table> ::= list <row-type>
```
Base-table definitions include a unique primary ordering of rows, hence its type. This is not the case for every other instance of table (dataset).
```
<table> ::= {<row-type>} | list <row-type>
```
Rows from `<view>`s, `<common-table-expression>`'s, and command output from `<query>`, `<merge>`, or any other table that is not a base-table can only have an immutable row ordering if it was so specified. In general all these other tables are sets of `<row-type>`. And functionally all tables are sets of `<row-type>` anyway.
