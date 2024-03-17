# urQL
Scripting language grammar and parser for an Urbit RDBMS.

Pull Requests are appreciated, but you should start a discussion before you proceed. If green-lit then open an issue.

Actively seeking contributors to add/improve the following functionality:

1) speed-up INSERT parsing
2) FROM clause to support AS OF
3) parse CREATE VIEW
4) parse DROP VIEW
5) create uql/hoon mark file

## Usage
Build the library.

`=parse -build-file /=urql=/lib/parse/hoon`

Submit a command for parsing in the dojo.

`(parse:parse(default-database 'db1') "FROM foo SELECT TOP 10 *")`

Successful commands will return a typed list of commands parsed into their respective data structures.

## Sample database

urQL scripts for the Animal Shelter sample database are in the folder urql/gen/animal-shelter.

To parse the entire DDL and load script:

```
=uql `tape`(reel .^(wain %cx /=urql=/gen/animal-shelter/all-animal-shelter/txt) |=([a=cord b=tape] (weld (trip a) b)))
(parse:parse(default-database 'db1') uql)
```

This will likely take about a minute as parsing the 22K rows of calendar table insert urQL is slow (looking for contributors to speed insert parsing).

## Utilities
Error messages and failed tests return untyped hoon data, which looks like a blizard of big numbers. To make it suitable for human viewing there is a utility to change the atom big numbers to cords for all the urQL key words, type-tags, and many of the variable names.

1. Install the latest dotnet. Works on Linux and Mac.
2. Save the noun the dojo gave you to a file.
3. The utility will add '2' to the file name and save it (e.g. input.txt becomes input.txt2)

```
> dotnet fsi display-hoon.fsx input.txt

> cat input.txt2
[[%selected-aggregate COUNT %qualified-column [%qualified-object 0 'UNKNOWN' 'COLUMN-OR-CTE' %foo] %foo 0] %as CountFoo]
```
