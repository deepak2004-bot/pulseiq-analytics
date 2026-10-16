\# Phase 1 Review



\*\*Done:\*\*

\- Task 1 (ETL pipeline): PR #1 and follow-up PR #3 (duplicate employee IDs). 5 tests pass.

\- Task 2 (warehouse, dim\_employee): PR #2. 1,606 rows, repeat run gives the same count, EMP-0002 transfer check passes.



\*\*In progress:\*\*

\- Task 2 payroll checks, which need fact\_payroll (Task 5).



\*\*Blocked:\*\*

\- Negative-pay rule (Task 1) needs the payroll sheet, so it moves to the payroll loader.

\- Employee-ID check on facts applies once facts are loaded.

\- No rejected rows in the current data, so the rejection rules are proven by tests only.



\*\*Next phase plan:\*\* Phase 2 (payroll, leave, finance), starting with the payroll dashboard data.

