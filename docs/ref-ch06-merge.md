# MERGE

`MERGE` provides a single SQL statement that can conditionally `INSERT`, `UPDATE` or `DELETE` rows, a task that would otherwise require multiple procedural language statements. It modifies the content of the `<target-table>`, using data from the `<source-table>` and static `<common-table-expression>` sources.

First, the MERGE command performs a join from `<source-table>` to `<target-table>` using `ON <merge-predicate>` producing zero or more candidate change rows. 

For each candidate change row, the status of `MATCHED` or `NOT MATCHED` is set just once.

If applicable, `NOT MATCHED` on `<target-table>` or `<source-table>` is set once.

Finally for each candidate change row the first `WHEN` under the applicable `MATCHED`/`NOT MATCHED` clause is executed.

A `WHEN` clause with no `AND <predicate>` implies unconditional execution. There can be no following `WHEN` clauses for that target/source matching condition.

When no `WHEN` clause evaluates as true the state remains unchanged (same as specifying `NOP`).

MERGE actions have the same effect as `UPDATE`, `INSERT`, or `DELETE` commands of the same names.

`MERGE` can either update the contents of an existing `<table>`, produce a new `<table>`, or produce a new (virtual) `<table-set>`.

When `MERGE INTO` is specified or implied `<target-table>` must be a base `<table>` and contents are updated in place. `PRODUCING NEW` may not be specified.

When `MERGE FROM` is specified then `PRODUCING NEW` must also be specified. `<target-table>` can be `<table>` or any virtual table (i.e. `<view>` or pass-thru `<table-set>`).

If `<new-table>` is specfied, it will be created as a new `<table>` and populated the same as when `<target-table>` is updated with `MERGE INTO`.

The output `<table-set>`'s row type will correspond to the row type of `<target-table>`. And its primary index (in the case when `<new-table>` is produced) will correspond to the primary index of `<target-table>`.

If the resulting virtual-table row type is a union type, then the output must be a virtual-table pass-thru, not an update to `<target-table>` or creation of `<new-table>`.

```
<merge> ::=
  MERGE [ { INTO | FROM } ] <target-table> [ [ AS ] <alias> ]
  [ PRODUCING NEW <new-table> [ [ AS ] <alias> ] ]
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
<target-table>               ::= <table-set>
<new-table>                  ::= <table-set>
<source-table>               ::= <table-set>
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

## API
```
+$  merge
  $:
    %merge
    target-table=table-set
    new-table=(unit table-set)
    source-table=table-set
    predicate=predicate
    matched=(list matching)
    unmatched-by-target=(list matching)
    unmatched-by-source=(list matching)
  ==
```

## TO DO: evaluate decision tree of target/source singleton/union type 

## Arguments

**`[ { INTO | FROM } ] <target-table> [ [ AS ] \<alias> ]`**
`<alias>` An alternative name to reference `<target-table>`.
* If `{ INTO | FROM }` is not specified default to `INTO`.
* If `<target-table>` is a virtual-table -- any `<table-set>` other than a base-table, i.e. qualified `<view>`, `<common-table-expression>`, `*`, or `( column-1 [,...column-n] )` -- then `FROM` is required.
* `INTO` must not accompany `PRODUCING NEW` argument.
* `FROM` must accompany `PRODUCING NEW` argument.
* `<target-table>` is the table, view, or CTE against which the data rows from `<table-source>` are matched based on `<merge-predicate>`. 
* If `<merge-predicate>` is not specifiec, `<table-source>` must have the same row type as `<target-table>` and matching requires every column in a given subtype. 
* If `INTO` is specified then `<target-table>` is a base-table target of any and all insert, update, or delete operations specified by the `WHEN` clauses.
* If `FROM` is specified then any insert, update, or delete operations specified by the `WHEN` clauses as well as matched but otherwise unaffected target table rows produce a new `<table-set>` as specified by the `PRODUCING NEW` clause.


**`[ PRODUCING NEW <new-table> [ [ AS ] \<alias> ] ]`**
`<alias>` An alternative name to reference `<target-table>`.

* Required when `FROM` specified.
* Prohibited when `INTO` implied or specified.
* If `<target-table>` has a row type which is a union type, `<new-table>` cannot be a base-table.

**`[ WITH <common-table-expression> [ ,...n ] ]`**
Specifies the temporary named result set or view, also known as common table expression, that's defined within the scope of the MERGE statement. The result set derives from a simple query and is referenced by the MERGE statement.

**`USING <source-table> [ [ AS ] \<alias> ]`**
`<alias>` An alternative name to reference `<target-table>`.

Specifies the data source that's matched with the data rows in `<target-table>` joining on `<merge-predicate>`. 
`<table-source>` can be a remote table or a derived table that accesses remote tables.

<`table-source>` can be a derived table that uses the Transact-SQL table value constructor to construct a table by specifying multiple rows.

**`[ [ SCALAR ] [ ,...n ] ]`**
TBD

**`ON <merge-predicate>`**
Specifies the conditions on which `<table-source>` joins with `<target-table>`, determining the matching.

* Any valid `<predicate>` not resulting in cartesian join.
* Resolves for any row sub-type between the target and source.
* If not specified, source and target must share row type and matching implies rows equal by value.

**`[ WHEN MATCHED [ AND <target-predicate> ] THEN <merge-matched> ] [ ...n ]`**
Specifies that all rows of *target-table, which join the rows returned by `<table-source>` ON `<merge-predicate>` or the implied join when `ON` predicate not present, and satisfy `<target-predicate>`, result in some action, possibly resulting in state change, according to the `<merge-matched>` clause.

* If two or more `WHEN` clauses are specified only the last clause may be unaccompanied by `AND <target-predicate>`. 
* The first `<target-predicate>` evaluating to true determines the `<merge-matched>` action. 
* `WHEN THEN <merge-matched>` clause without `AND <target-predicate>` implies unconditionally apply the `<target-predicate>` action.

**`[ WHEN NOT MATCHED [ BY TARGET ] [ AND <unmatched-target-predicate> ] THEN <merge-not-matched> ] [ ...n ]`**
Specifies that a row is inserted into target-table for every row returned by `<table-source>` ON `<merge-predicate>` that doesn't match a row in target-table, but satisfies an additional search condition, if present. The values to insert are specified by the `<merge-not-matched>` clause. The MERGE statement can have only one WHEN NOT MATCHED [ BY TARGET ] clause.


**`WHEN NOT MATCHED BY SOURCE [ AND <unmatched-source-predicate> ] THEN <merge-matched>`**
Specifies that all rows of *target-table, which don't match the rows returned by `<table-source>` ON `<merge-predicate>`, and that satisfy any additional search condition, are updated or deleted according to the `<merge-matched>` clause.

The MERGE statement can have at most two WHEN NOT MATCHED BY SOURCE clauses. If two clauses are specified, then the first clause must be accompanied by an AND `<predicate>` clause. For any given row, the second WHEN NOT MATCHED BY SOURCE clause is only applied if the first isn't. If there are two WHEN NOT MATCHED BY SOURCE clauses, then one must specify an UPDATE action and one must specify a DELETE action. Only columns from the target table can be referenced in `<predicate>`.

When no rows are returned by `<table-source>`, columns in the source table can't be accessed. If the update or delete action specified in the `<merge-matched>` clause references columns in the source table, error 207 (Invalid column name) is returned. For example, the clause WHEN NOT MATCHED BY SOURCE THEN UPDATE SET TargetTable.Col1 = SourceTable.Col1 may cause the statement to fail because Col1 in the source table is inaccessible.



AND <predicate>
Any valid predicate on the matching source and target row or nonmatching source or target.

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

`@@ROWCOUNT` returns the total number of rows [inserted=@ud updated=@ud deleted=@ud].

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

