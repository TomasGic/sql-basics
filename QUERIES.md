# Selected queries that taught me something
1. **Record a new loan (a member borrowing a book today)**

```sql
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on) VALUES (7, 5, date('now'), date('now', '+14 days'), NULL);
```

**What this query taught me**: The query inserts a new row into the `loans` table. One thing worth pointing out is that the date function in SQL does not use math operators, such as `+`. It is designed to accept a specific structure: a base time string and optional modifiers separated by commas. If we want to calculate a new date which is 14 days from now, we need to pass`+14 days` as a second argument (modifier) to the date function (first argument being `now`). SQLite's internal date parser specifically looks for strings starting with + or - to add or subtract time.


2. **List all members who joined after August 30th 2026**

```sql
SELECT * FROM members WHERE joined_on > '2026-06-30';
```
**What this query taught me**: 
This query compares two dates, the one in the `joined_on` column and the specific one that we've provided. The interesting thing is the way that SQLite is able to do this even if it does not have a separate "Date" data type. In SQLite dates are stored as `TEXT` in the standard ISO format `YYYY-MM-DD`. SQLite is therefore able to do an alphabetical comparison, and since it compares the strings from left to right, the alphabetical comparison is idential to a chronological comparison. 

3. **Increase the `copies_total` of one book by one**.

```sql
UPDATE books
SET copies_total = copies_total + 1
WHERE title = 'Practical Object-Oriented Design in Ruby';
```
**What this query taught me**: 
Unlike many programming languages and certain database systems, such as Microsoft SQL Server, SQLite does not support shorthand operators like += or -=. Therefore, in our `UPDATE` query we explicitly have to write the new value assignment to the variable like this:  `copies_total = copies_total + 1`.

4. **Delete one member who does not have any loans**.

```sql
DELETE FROM members
WHERE id NOT IN (
    SELECT member_id FROM loans
);
```

## What this query taught me
This query is a nested query which consists of an inner query (`SELECT member_id FROM loans`) and outer query (`DELETE FROM members WHERE id NOT IN`). In order to correctly execute this query SQLite has to break it down into several steps.

* **Step 1: Run the inner query first**
SQLite looks at the loans table, grabs every single member_id found inside it, and builds a temporary, internal list or "set" of IDs (in our case it's `[1, 2, 3, 4]`). 

* **Step 2: SQLite scans the loans table row by row**
It looks at the column `member_id` and checks whether each member_id is found in the set of ids created in step 1. 

* **Step 3: Decision to keep or delete**
    * If the ID is NOT in the list, SQLite marks that member row for deletion and deletes it.

    * If the ID IS in the list, SQLite skips that row and leaves the   member untouched.
