# Types
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
