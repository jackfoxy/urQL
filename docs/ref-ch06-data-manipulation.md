# BULK INSERT

TBD


# DELETE
```
DELETE [ FROM ] [ <ship-qualifer> ]<table>
[ WITH (<query>) AS <alias> [ ,...n ] ]
[ WHERE <predicate> ]
```

Discussion:
Data in the namespace *sys* cannot be deleted.


# INSERT

```
INSERT INTO [ <ship-qualifer> ]<table>
  [ ( <column> [ ,...n ] ) ]
  { VALUES (<scalar-expression> [ ,...n ] ) [ ,...n ]
    | <query> }
```

```
<scalar-expression> ::=
  { <constant>
    | <scalar-function>
    | <scalar-query>
    | [ unary-operator ] expression
    | expression <binary-operator> expression }
```

Discussion:
The `VALUES` or `<query>` must provide data for all columns in the expected order.
Tables in the namespace *sys* cannot be inserted into.
Cord values are represented in single quotes 'this is a cord'.
Escape single quotes with double backslash thusly `'this is a cor\\'d'`.

# MERGE
`MERGE` performs actions that modify rows in the `<target-table>`, using the `<source-table>` and static `<common-table-expression>` sources from an applicable `WITH` clause. 

`MERGE` provides a single SQL statement that can conditionally `INSERT`, `UPDATE` or `DELETE` rows, a task that would otherwise require multiple procedural language statements.

First, the MERGE command performs a join from `<source-table>` to `<target-table>` using `ON <merge-predicate>` producing zero or more candidate change rows. 

For each candidate change row, the status of `MATCHED` or `NOT MATCHED` is set just once.

If applicable, `NOT MATCHED` on `<target-table>` or `<source-table>` is set once.

Finally for each candidate change row the first `WHEN` under the applicable `MATCHED`/`NOT MATCHED` clause is executed.

A `WHEN` clause with no `AND <predicate>` implies unconditional execution. There can be no following `WHEN` clauses for that target/source matching condition.

When no `WHEN` clause evaluates as true the state remains unchanged (same as specifying `NOP`).

MERGE actions have the same effect as `UPDATE`, `INSERT`, or `DELETE` commands of the same names.

When `MERGE INTO` is specified or implied `PRODUCING NEW` may not be specified and the resulting `INSERT`s and `UPDATE`s apply to `<target-table>` or `<new-table>`.

When `MERGE FROM` is specified then `PRODUCING NEW` must also be specified. 

If `<new-table>` is specfied as a base-table, that table must not pre-exist.

`<new-table>`'s row type will correspond to the row type of `<target-table>`.

`<new-table>`'s primary index will correspond to the primary index of `<target-table>`.

If the resulting virtual-table row type is a union type, then the output must be a virtual-table pass-thru, not an update to `<target-table>` or `<new-table>` as a base-table.

BREAKING CHANGE: The parser currently parses the syntax *MERGE... PRODUCING... WITH...*. This will eventually be refactored to *WITH... MERGE...*.
```
MERGE [ { INTO | FROM } ] <target-table> [ [ AS ] <alias> ]
[ PRODUCING NEW <new-table> [ [ AS ] <alias> ] ]
[ WITH <common-table-expression> [ ,...n ] ]
USING <source-table> [ [ AS ] <alias> ]
[ [ SCALAR ] [ ,...n ] ]
  [ ON <merge-predicate> ]
  [ WHEN MATCHED [ AND <matched-predicate> ]
    THEN <merge-matched> ] [ ...n ]
  [ WHEN NOT MATCHED [ BY TARGET ] [ AND <unmatched-target-predicate> ]
    THEN <merge-not-matched> ] [ ...n ] 
  [ WHEN NOT MATCHED BY SOURCE [ AND <unmatched-source-predicate> ]
    THEN <merge-matched> ] [ ...n ]
```

```
<target-table>               ::= <table-object>
<new-table>                  ::= <table-object>
<source-table>               ::= <table-object>
<matched-predicate>          ::= <predicate>
<unmatched-target-predicate> ::= <predicate>
<unmatched-source-predicate> ::= <predicate>
```

```
<merge-matched> ::=
  { UPDATE [ SET ] { <column> = <scalar-expression> }  [ ,...n ]
    | DELETE
    | NOP
  }
```

```
<merge-not-matched> ::=
  INSERT [ ( <column> [ ,...n ] ) ]
    VALUES ( <scalar-expression> [ ,...n ] )
  | NOP
```

## TO DO: evaluate decision tree of target/source singleton/union type 

## Arguments

**[ { INTO | FROM } ] \<target-table> [ [ AS ] \<alias> ]**
`<alias>` An alternative name to reference `<target-table>`.
* If `{ INTO | FROM }` is not specified default to `INTO`.
* If `<target-table>` is a virtual-table -- any `<table-object>` other than a base-table, i.e. qualified `<view>`, `<common-table-expression>`, `*`, or `( column-1 [,...column-n] )` -- then `FROM` is required.
* `INTO` must not accompany `PRODUCING NEW` argument.
* `FROM` must accompany `PRODUCING NEW` argument.
* `<target-table>` is the table, view, or CTE against which the data rows from `<table-source>` are matched based on `<merge-predicate>`. 
* If `<merge-predicate>` is not specifiec, `<table-source>` must have the same row type as `<target-table>` and matching requires every column in a given subtype. 
* If `INTO` is specified then `<target-table>` is a base-table target of any and all insert, update, or delete operations specified by the `WHEN` clauses.
* If `FROM` is specified then any insert, update, or delete operations specified by the `WHEN` clauses as well as matched but otherwise unaffected target table rows produce a new `<table-object>` as specified by the `PRODUCING NEW` clause.


**[ PRODUCING NEW \<new-table> [ [ AS ] \<alias> ] ]**
`<alias>` An alternative name to reference `<target-table>`.

* Required when `FROM` specified.
* Prohibited when `INTO` implied or specified.
* If `<target-table>` has a row type which is a union type, `<new-table>` cannot be a base-table.

**[ WITH <\common-table-expression> [ ,...n ] ]**
Specifies the temporary named result set or view, also known as common table expression, that's defined within the scope of the MERGE statement. The result set derives from a simple query and is referenced by the MERGE statement.

**USING \<source-table> [ [ AS ] \<alias> ]**
`<alias>` An alternative name to reference `<target-table>`.

Specifies the data source that's matched with the data rows in `<target-table>` joining on `<merge-predicate>`. 
`<table-source>` can be a remote table or a derived table that accesses remote tables.

<`table-source>` can be a derived table that uses the Transact-SQL table value constructor to construct a table by specifying multiple rows.

**[ [ SCALAR ] [ ,...n ] ]**
TBD

**ON \<merge-predicate>**
Specifies the conditions on which `<table-source>` joins with `<target-table>`, determining the matching.

* Any valid `<predicate>` not resulting in cartesian join.
* Resolves for any row sub-type between the target and source.
* If not specified, source and target must share row type and matching implies rows equal by value.

**[ WHEN MATCHED [ AND \<target-predicate> ] THEN \<merge-matched> ] [ ...n ]**
Specifies that all rows of *target-table, which join the rows returned by `<table-source>` ON `<merge-predicate>` or the implied join when `ON` predicate not present, and satisfy `<target-predicate>`, result in some action, possibly resulting in state change, according to the `<merge-matched>` clause.

* If two or more `WHEN` clauses are specified only the last clause may be unaccompanied by `AND <target-predicate>`. 
* The first `<target-predicate>` evaluating to true determines the `<merge-matched>` action. 
* `WHEN THEN <merge-matched>` clause without `AND <target-predicate>` implies unconditionally apply the `<target-predicate>` action.

**[ WHEN NOT MATCHED [ BY TARGET ] THEN \<merge-not-matched> ] [ ...n ]**
Specifies that a row is inserted into target-table for every row returned by `<table-source>` ON `<merge-predicate>` that doesn't match a row in target-table, but satisfies an additional search condition, if present. The values to insert are specified by the `<merge-not-matched>` clause. The MERGE statement can have only one WHEN NOT MATCHED [ BY TARGET ] clause.

**WHEN NOT MATCHED BY SOURCE THEN \<merge-matched>**
Specifies that all rows of *target-table, which don't match the rows returned by `<table-source>` ON `<merge-predicate>`, and that satisfy any additional search condition, are updated or deleted according to the `<merge-matched>` clause.

The MERGE statement can have at most two WHEN NOT MATCHED BY SOURCE clauses. If two clauses are specified, then the first clause must be accompanied by an AND `<predicate>` clause. For any given row, the second WHEN NOT MATCHED BY SOURCE clause is only applied if the first isn't. If there are two WHEN NOT MATCHED BY SOURCE clauses, then one must specify an UPDATE action and one must specify a DELETE action. Only columns from the target table can be referenced in `<predicate>`.

When no rows are returned by `<table-source>`, columns in the source table can't be accessed. If the update or delete action specified in the `<merge-matched>` clause references columns in the source table, error 207 (Invalid column name) is returned. For example, the clause WHEN NOT MATCHED BY SOURCE THEN UPDATE SET TargetTable.Col1 = SourceTable.Col1 may cause the statement to fail because Col1 in the source table is inaccessible.

AND <predicate>
Any valid predicate on the matching source and target row or nonmatching source or target.

<output-clause>
Returns a row for every row in target-table that's updated, inserted, or deleted, in no particular order. $action can be specified in the output clause. $action is a column of type nvarchar(10) that returns one of three values for each row: 'INSERT', 'UPDATE', or 'DELETE', according to the action done on that row. The OUTPUT clause is the recommended way to query or count rows affected by a MERGE. For more information about the arguments and behavior of this clause, see OUTPUT Clause (Transact-SQL).

<merge-matched>
Specifies the update or delete action that's applied to all rows of target-table that don't match the rows returned by <table-source> ON <merge-predicate>, and which satisfy any additional search condition.

UPDATE SET <set-clause>
Specifies the list of column or variable names to update in the target table and the values with which to update them.

For more information about the arguments of this clause, see UPDATE. Setting a variable to the same value as a column isn't supported.

DELETE
Specifies that the rows matching rows in target-table are deleted.

NOP
State unaltered.

<merge-not-matched>
Specifies the values to insert into the target table.

(column-list)
A list of one or more columns of the target table in which to insert data. Columns must be specified as a single-part name or else the MERGE statement will fail. column-list must be enclosed in parentheses and delimited by commas.

No <column name> of T shall be identified more than once in an <insert column list>.

every column name must be accounted for once, referencing the most recently set column names

VALUES (values-list)
A comma-separated list of constants, variables, or expressions that return values to insert into the target table. Expressions can't contain an EXECUTE statement.

NOP
State unaltered.

For more information about this clause, see INSERT (Transact-SQL).

<predicate>
Specifies the search conditions to specify <merge-search-condition> or <predicate>.

## Remarks
Cross ship merges not allowed.
The discussion of `INSERT` also applies when not matched by target.
In the case of multiple `WHEN MATCHED` or `WHEN NOT MATCHED` and overlapping predicates, the cases are processed in order, so the first successful takes precedence.
Tables in the namespace *sys* cannot be merged into.

At least one of the three MATCHED clauses must be specified, but they can be specified in any order. A variable can't be updated more than once in the same MATCHED clause.

Any insert, update, or delete action specified on the target table by the MERGE statement are limited by any constraints defined on it, including unique indices and any cascading referential integrity constraints. If IGNORE-DUP-KEY is ON for any unique indexes on the target table, MERGE ignores this setting.

## Produced Metadata

@@ROWCOUNT returns the total number of rows [inserted=@ud updated=@ud deleted=@ud].

## Exceptions
`<target-table>` does not exist
`GRANT` permission on `<target-table>` violated
`<source-table>` does not exists
`GRANT` permission on `<source-table>` violated
`<new-table>` already exists
referential integrity violation
unique key violation
  -- for updateable `<target-table>` unique key violation is a violation of the primary index or any other unique index defined on the table
  -- for otherwise base-table `<target-table>` producing pass-thru or new base-table output, `<target-table>` primary index determines unique key violations
  -- for pass-thru `<target-table>` the `<target-table>` columns validated in `<merge-predicate>`, or all target columns in the case of its absence, determine unique key violations

## Syntax Rules
13) Case:
c) If for some n, some underlying column of the column referenced by the <column name> contained
in the n-th ordinal position in <insert column list> is an identity column whose descriptor includes an
indication that values are generated by default and <override clause> is specified, then <override
clause> shall specify OVERRIDING USER VALUE.
Data manipulation 961
IWD 9075-2:201?(E)
14.12 <merge statement>d) If for some n, some underlying column of the column referenced by the <column name> contained
in the n-th ordinal position in <insert column list> is a system-time period start column or a systemtime period end column whose descriptor includes an indication that values are always generated and
<override clause> is specified, then <override clause> shall specify OVERRIDING USER VALUE.
e) Otherwise, <override clause> shall not be specified.
14) The <search condition> immediately contained in a <merge statement>, the <search condition> immediately
contained in a <merge when matched clause>, and the <search condition> immediately contained in a
<merge when not matched clause> shall not generally contain a <routine invocation> whose subject routine
is an SQL-invoked routine that possibly modifies SQL-data.
15) Each column identified by an <object column> in a <set clause list> is an update object column. Each
column identified by a <column name> in an implicit or explicit <insert column list> is an insert object
column. Each update object column and each insert object column is an object column.
16) If <merge when not matched clause> is specified and if T is not trigger insertable-into or if <merge when
matched clause> is specified and if T is not trigger updatable, then every object column shall identify an
updatable column of T.
NOTE 476 — The notion of updatable columns of base tables is defined in Subclause 4.15, “Tables”. The notion of updatable
columns of viewed tables is defined in Subclause 11.32, “<view definition>”.
17) No <column name> of T shall be identified more than once in an <insert column list>.
18) For each <merge when not matched clause>:
a) Let NI be the number of <merge insert value element>s contained in <merge insert value list>. Let
EXP1, EXP2, ... , EXPNI be those <merge insert value element>s.
b) The number of <column name>s in the <insert column list> shall be equal to NI.
c) The declared type of every <contextually typed value specification> CVS in a <merge insert value
list> is the data type DT indicated in the column descriptor for the positionally corresponding column
in the explicit or implicit <insert column list>. If CVS is an <empty specification> that specifies
ARRAY, then DT shall be an array type. If CVS is an <empty specification> that specifies MULTISET,
then DT shall be a multiset type.
d) Every <merge insert value element> whose positionally corresponding <column name> in <insert
column list> references a column of which some underlying column is a generated column shall be a
<default specification>.
e) For 1 (one) ≤ i ≤ NI, the Syntax Rules of Subclause 9.2, “Store assignment”, are applied with EXPi
as VALUE and the column of table T identified by the i-th <column name> in the <insert column list>
as TARGET.




# TRUNCATE TABLE

`TRUNCATE TABLE [ <ship-qualifer> ]<table>`

Discussion:
Tables in the namespace *sys* cannot be truncated.


# UPDATE

```
UPDATE [ <ship-qualifer> ]<table>
SET { <column> = <scalar-expression> } [ ,...n ]
[ WITH (<query>) AS <alias> [ ,...n ] ]
[ WHERE <predicate> ]
```

Discussion:
Tables in the namespace *sys* cannot be updated.
