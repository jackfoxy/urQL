# Performance

## Parse and insert performance on sample database

Unscientific performance measurements of parsing and inserting sample data into tables of the `animal-shelter` sample database.

Timings used the `%bout` hint and are typical of many observed iterations.

The measurements were taken on a fake zod 2GB loom, 411k, vere 3.1, exectiong a single urQL script running under Mint Linux on a 3rd generation Intel Core i7 with 32GB of RAM. The script included CREATE TABLE before each INSERT. Only the INSERT was timed.

Parsing is the step of applying the %obelisk parser to a urQL INSERT script command, producing an AST object.

Inserting is the step of applying the %obelisk API to the INSERT data structure. Hence parsing can be skipped when working directly with the API. Of course the host program still must construct the data structure.

The longest running parse time of 54 seconds on 197K data cells has been observed to vary as much as 6 seconds in either direction.

The smaller table loads of the sample database have been omitted as their times are skewed by programmtic overhead and therefore not indicative of per row and per data cell timings. The other major variable is the table columns definition. The columns are mostly of aura types @t, @ud, @da, and @rs; and because of this variable nature per row and per cell performance, especially in parsing, is not perfectly linear.

| TABLE | Rows | Columns | Cells | Parse Time | Insert Time | Parse / Row | Parse / Cell | Insert / Row | Insert / Cell |
| :---- | ---: | ------: | ----: | ---------: | ----------: | ----------: | -----------: | -----------: | ------------: |
|%adoptions| 70| 5| 350| 101.90| 6.56|  1.456| 0.291|  0.094| 0.019|
|%vaccinations| 95| 7| 665| 174.73| 9.79|  1.839| 0.263|  0.103| 0.015|
|%animals| 100| 8| 800| 199.82| 9.71|  1.998| 0.250|  0.097| 0.012|
|%common-person-names| 100| 4| 400| 85.10| 7.43|  0.851| 0.213|  0.074| 0.019|
|%persons| 120| 8| 960| 261.20| 12.93|  2.177| 0.272|  0.108| 0.013|
|%common-animal-names| 300| 4| 1,200| 240.57| 27.02|  0.802| 0.200|  0.090| 0.023|
|%breeds| 469| 3| 1,407| 622.81| 59.94|  1.328| 0.443|  0.128| 0.043|
|%calendar-us-fed-holiday| 601| 2| 1,202| 427.81| 42.85|  0.712| 0.356|  0.071| 0.036|
|%cities| 4,065| 4| 16,260| 4,224.86| 521.60|  1.039| 0.260|  0.128| 0.032|
|%city-zip-codes| 15,503| 3| 46,509| 8,381.66| 3,880.32|  0.541| 0.180|  0.250| 0.083|
|%calendar| 21,916| 9| 197,244| 54,081.41| 2,415.45|  2.468| 0.274|  0.110| 0.012|

(The insert performance of %city-zip-codes is noteworthy and unexplained.)