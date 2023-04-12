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

```
MERGE [ { INTO | FROM } ] [ <target-table> [ [ AS ] <alias> ] ]
[ PRODUCING NEW [ <ship-qualifer> ]<new-table> ]
[ WITH (<query>) AS <alias> [ ,...n ] ]
USING <source-table> [ [ AS ] <alias> ]
[ [ SCALAR ] [ ,...n ] ]
  ON <merge-predicate>
  [ WHEN MATCHED [ AND <target-predicate> ]
    THEN <merge-matched> ] [ ...n ]
  [ WHEN NOT MATCHED [ BY TARGET ] [ AND <target-predicate> ]
    THEN <merge-not-matched> ]
  [ WHEN NOT MATCHED BY SOURCE [ AND <source-predicate> ]
    THEN <merge-matched> ] [ ...n ]
```

```
<target-table> ::= <table-object>
```

```
<source-table> ::=
  <common-table-expression> 
  | <table-view>
```

```
<merge-predicate>  ::= <predicate>
<target-predicate> ::= <predicate>
<source-predicate> ::= <predicate>
```

```
<merge-matched> ::=
  { UPDATE [ SET ] { <column> = <scalar-expression> }  [ ,...n ]
    | DELETE
  }
```

```
<merge-not-matched> ::=
  INSERT [ ( <column> [ ,...n ] ) ]
    VALUES ( <scalar-expression> [ ,...n ] )
```

Discussion:
Cross ship merges not allowed.
The discussion of `INSERT` also applies when not matched by target.
In the case of multiple `WHEN MATCHED` or `WHEN NOT MATCHED` and overlapping predicates, the cases are processed in order, so the first successful takes precedence.
Tables in the namespace *sys* cannot be merged into.

## Arguments

**[ { INTO | FROM } ] [ \<ship-qualifer> ] \<target-table>**

* If `{ INTO | FROM }` is not specified default to `INTO`.
* IF `<target-table>` is a view or `*` (streamed `<table-object>`) then `FROM` is required.
* `INTO` must not accompany `PRODUCING NEW` argument.
* `FROM` must accompany `PRODUCING NEW` argument.
* `<target-table>` is the table, view, or CTE against which the data rows from `<table-source>` are matched based on `<merge-predicate>`. 
* If `INTO` is specified then `<target-table>` is the target of any insert, update, or delete operations specified by the `WHEN` clauses.
* If `FROM` is specified then any insert, update, or delete operations specified by the `WHEN` clauses as well as matched but otherwise unaffected target table rows produce a new `<table-object>` as specified for the `PRODUCING NEW` clause.

**[ AS ] \<alias>**

An alternative name to reference `<target-table>`.

[ WITH (<query>) AS <alias> [ ,...n ] ]
Specifies the temporary named result set or view, also known as common table expression, that's defined within the scope of the MERGE statement. The result set derives from a simple query and is referenced by the MERGE statement.

**USING \<table-source>**

Specifies the data source that's matched with the data rows in `<target-table>` joining on `<merge-predicate>`. 
<table-source> can be a remote table or a derived table that accesses remote tables.

<table-source> can be a derived table that uses the Transact-SQL table value constructor to construct a table by specifying multiple rows.

[ AS ] table-alias
An alternative name to reference a table for the table-source.

ON <predicate>
Specifies the conditions on which <table-source> joins with <target-table>, determining the matching.
Any valid <predicate> not resulting in cartesian join.

WHEN MATCHED THEN <merge-matched>
Specifies that all rows of *target-table, which match the rows returned by <table-source> ON <merge-predicate>, and satisfy any additional search condition, are either updated or deleted according to the <merge-matched> clause.

The MERGE statement can have, at most, two WHEN MATCHED clauses. If two clauses are specified, the first clause must be accompanied by an AND <search-condition> clause. For any given row, the second WHEN MATCHED clause is only applied if the first isn't. If there are two WHEN MATCHED clauses, one must specify an UPDATE action and one must specify a DELETE action. When UPDATE is specified in the <merge-matched> clause, and more than one row of <table-source> matches a row in target-table based on <merge-predicate>, SQL Server returns an error. The MERGE statement can't update the same row more than once, or update and delete the same row.

WHEN NOT MATCHED [ BY TARGET ] THEN <merge-not-matched>
Specifies that a row is inserted into target-table for every row returned by <table-source> ON <merge-predicate> that doesn't match a row in target-table, but satisfies an additional search condition, if present. The values to insert are specified by the <merge-not-matched> clause. The MERGE statement can have only one WHEN NOT MATCHED [ BY TARGET ] clause.

WHEN NOT MATCHED BY SOURCE THEN <merge-matched>
Specifies that all rows of *target-table, which don't match the rows returned by <table-source> ON <merge-predicate>, and that satisfy any additional search condition, are updated or deleted according to the <merge-matched> clause.

The MERGE statement can have at most two WHEN NOT MATCHED BY SOURCE clauses. If two clauses are specified, then the first clause must be accompanied by an AND <predicate> clause. For any given row, the second WHEN NOT MATCHED BY SOURCE clause is only applied if the first isn't. If there are two WHEN NOT MATCHED BY SOURCE clauses, then one must specify an UPDATE action and one must specify a DELETE action. Only columns from the target table can be referenced in <predicate>.

When no rows are returned by <table-source>, columns in the source table can't be accessed. If the update or delete action specified in the <merge-matched> clause references columns in the source table, error 207 (Invalid column name) is returned. For example, the clause WHEN NOT MATCHED BY SOURCE THEN UPDATE SET TargetTable.Col1 = SourceTable.Col1 may cause the statement to fail because Col1 in the source table is inaccessible.

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

<merge-not-matched>
Specifies the values to insert into the target table.

(column-list)
A list of one or more columns of the target table in which to insert data. Columns must be specified as a single-part name or else the MERGE statement will fail. column-list must be enclosed in parentheses and delimited by commas.

VALUES (values-list)
A comma-separated list of constants, variables, or expressions that return values to insert into the target table. Expressions can't contain an EXECUTE statement.

DEFAULT VALUES
Forces the inserted row to contain the default values defined for each column.

For more information about this clause, see INSERT (Transact-SQL).

<predicate>
Specifies the search conditions to specify <merge-search-condition> or <predicate>.

## Remarks
At least one of the three MATCHED clauses must be specified, but they can be specified in any order. A variable can't be updated more than once in the same MATCHED clause.

Any insert, update, or delete action specified on the target table by the MERGE statement are limited by any constraints defined on it, including unique indices and any cascading referential integrity constraints. If IGNORE-DUP-KEY is ON for any unique indexes on the target table, MERGE ignores this setting.

## Produced Metadata

@@ROWCOUNT returns the total number of rows [inserted=@ud updated=@ud deleted=@ud].

## Exceptions
target table does not exist
source-table does not exists
new-table already exists
shadowed matching case
duplicate unique keys
referential integrity violation

## Syntax Rules
1) Let TN be the <table name> contained in <target table> TT and let T be the table identified by TN.
2) If <merge when not matched clause> is specified, then T shall be insertable-into or trigger insertable-into.
3) If <merge update specification> is specified, then T shall be updatable or trigger updatable.
4) If <merge delete specification> is specified, then T shall be updatable or trigger deletable.
5) T shall not be an old transition table or a new transition table.
6) For each leaf generally underlying table of T whose descriptor includes a user-defined type name UDTN,
the data type descriptor of the user-defined type UDT identified by UDTN shall indicate that UDT is
instantiable.
7) If T is a view, then <target table> is effectively replaced by:
ONLY ( TN )
8) Case:
a) If <merge correlation name> is specified, then let CN be the <correlation name> contained in <merge
correlation name>. CN is an exposed <correlation name>.
b) Otherwise, let CN be the <table name> contained in <target table>. CN is an exposed <table or query
name>.
9) The scope of CN is the <search condition> immediately contained in the <merge statement>, the <search
condition> immediately contained in a <merge when matched clause>, the <search condition> immediately
contained in a <merge when not matched clause>, and the <set clause list>.
10) Let TR be the <table reference> immediately contained in <merge statement>. TR shall not directly contain
a <joined table>.
11) The <correlation name> or <table or query name> that is exposed by TR shall not be equivalent to CN.
12) If an <insert column list> is omitted, then an <insert column list> that identifies all columns of T in the
ascending sequence of their ordinal position within T is implicit.
13) Case:
a) If some underlying column of a column referenced by a <column name> contained in <insert column
list> is a system-generated self-referencing column or a derived self-referencing column, then <override
clause> shall be specified.
b) If for some n, some underlying column of the column referenced by the <column name> contained
in the n-th ordinal position in <insert column list> is an identity column, system-time period start
column, or system-time period end column whose descriptor includes an indication that values are
always generated, and the n-th <contextually typed value specification> simply contained in any
<merge insert value element> simply contained in the <merge insert value list> is not a <default
specification>, then <override clause> shall be specified.
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
19) Let DSC be the <search condition> immediately contained in <merge statement>.
Case:
a) If T is a system-versioned table, then let ENDCOL be the system-time period end column of T. Let
ENDVAL be the highest value supported by the declared type of ENDCOL. Let SC1 be
(DSC) AND (ENDCOL = ENDVAL)
b) Otherwise, let SC1 be DSC.




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
