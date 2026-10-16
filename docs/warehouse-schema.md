\# Warehouse Schema (schema dw)



\## Tables



| Table | Grain (one row per...) |

|---|---|

| dw.dim\_employee | one employee job assignment version (one row per assignment\_id) |



\## Keys

\- employee\_key: surrogate key (SERIAL)

\- assignment\_id: natural key from employee\_assignments, unique

\- employee\_id: joins to the employee's full history



\## History

A transfer creates a new row. Old rows keep their dates, the last row has is\_current = TRUE and no valid\_to.

