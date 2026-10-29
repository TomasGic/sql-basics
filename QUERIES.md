## Selected queries that taught me something
**1. Record a new loan (a member borrowing a book today)**

```sql
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on) VALUES (7, 5, date('now'), date('now', '+14 days'), NULL);
```

**What this query taught me**: The query inserts a new row into the `loans` table. One thing worth pointing out is that the date function in SQL does not use math operators, such as `+`. It is designed to accept a specific structure: a base time string and optional modifiers separated by commas. If we want to calculate a new date which is 14 days from now, we need to pass`+14 days` as a second argument (modifier) to the date function (first argument being `now`). SQLite's internal date parser specifically looks for strings starting with + or - to add or subtract time.


**2. List all members who joined after August 30th 2026**

```sql
SELECT * FROM members WHERE joined_on > '2026-06-30';
```
**What this query taught me**: 
This query compares two dates, the one in the `joined_on` column and the specific one that we've provided. The interesting thing is the way that SQLite is able to do this even if it does not have a separate "Date" data type. In SQLite dates are stored as `TEXT` in the standard ISO format `YYYY-MM-DD`. SQLite is therefore able to do an alphabetical comparison, and since it compares the strings from left to right, the alphabetical comparison is idential to a chronological comparison. 

**3. Increase the `copies_total` of one book by one**.

```sql
UPDATE books
SET copies_total = copies_total + 1
WHERE title = 'Practical Object-Oriented Design in Ruby';
```
**What this query taught me**: 
Unlike many programming languages and certain database systems, such as Microsoft SQL Server, SQLite does not support shorthand operators like += or -=. Therefore, in our `UPDATE` query we explicitly have to write the new value assignment to the variable like this:  `copies_total = copies_total + 1`.

**4. Delete one member who does not have any loans**.

```sql
DELETE FROM members
WHERE id NOT IN (
    SELECT member_id FROM loans
);
```

**What this query taught me**:
This query is a nested query which consists of an inner query (`SELECT member_id FROM loans`) and outer query (`DELETE FROM members WHERE id NOT IN`). In order to correctly execute this query SQLite has to break it down into several steps.

* **Step 1: Run the inner query first**
SQLite looks at the loans table, grabs every single member_id found inside it, and builds a temporary, internal list or "set" of IDs (in our case it's `[1, 2, 3, 4]`). 

* **Step 2: SQLite scans the loans table row by row**
It looks at the column `member_id` and checks whether each member_id is found in the set of ids created in step 1. 

* **Step 3: Decision to keep or delete**
    * If the ID is NOT in the list, SQLite marks that member row for deletion and deletes it.

    * If the ID IS in the list, SQLite skips that row and leaves the   member untouched.

## Integrity checks 
The `schema.sql` defines several constraints to prevent invalid data from being entered into the database. 

**1. Foreign key constraints**: 
Foreign key constraints protect the referential integrity of the database. If we add a record to a table where the foreign key references a primary key that doesn't exit in another table, the database engine will throw an error. In our case trying to add a loan with a book_id that doesn't exist in the `books` table will throw a runtime error: `FOREIGN KEY constraint failed`. This is because of this line that we added when creating the `loans` table: `FOREIGN KEY (book_id) REFERENCES books(id)`. It is important to note that in order for the foreign key constraint to work, we need to do run `PRAGMA foreign_keys = ON` at the start of each sqlite3 session. Even though we turned on the foreign keys integrity check on in `schema.sql`, this setting does not persist in future database connections. This is because SQLite treats `PRAGMA foreign_keys = ON` as runtime configuration settings scoped to the individual database connection, not as part of the permanent database schema. The setting only lives in memory for the duration of a database connection and when the connection is terminated, it reverts back to the default 0.

Below is a short, reproducible check that proves that our foreign key constraints are enforced. You can open a new database connection using `sqlite3 -cmd 'PRAGMA foreign_keys = ON;' library.db` and paste in the sql code snippet to run the queries.

```sql
BEGIN TRANSACTION;
-- Inserting a valid loan with a valid book and member id
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on) VALUES 
(3, 1, '2026-10-27', '2026-11-10', NULL);

-- Inserting an invalid loan with a non-existent book id
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on) VALUES 
(13, 1, '2026-10-27', '2026-11-10', NULL);
-- Result: Runtime error: FOREIGN KEY constraint failed

-- Inserting an invalid loan with a non-existent member id
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on) VALUES 
(3, 10, '2026-10-27', '2026-11-10', NULL);
-- Result: Runtime error: FOREIGN KEY constraint failed

-- Revert changes to keep sample data unchanged
ROLLBACK;
```

**2. Constraints against duplicate records**: 
If we want a table column in the database to only contain unique values, we can add a `UNIQUE` constraint to that column. In our database, we have set up the constraint to not allow two identical email addresses in the `members` table like this: `email TEXT NOT NULL UNIQUE`. Trying to add a member with an email address that already exists in the database will throw a runtime error: `UNIQUE constraint failed: members.email`.

**3. Constraints against custom math/logic rules**:
The `squema.sql` file defines several custom logic rules using the `CHECK` SQL keyword:

* `copies_total INTEGER NOT NULL CHECK (copies_total >= 0)`: Does not allow values below 0 to be entered into the `copies_total` column.

* `due_on TEXT NOT NULL CHECK (due_on >= borrowed_on)`: This ensures that the due date cannot be before the date when the book was borrowed on. 

If we try to insert a book with `copies_total = -1`, the database engine will throw a runtime error: `CHECK constraint failed: copies_total >= 0`.

**4. Constraints against invalid dates**:
The `schema.sql` file lays down several constraints against invalid dates. Most of the date columns appear in the `loans` table: 

* `borrowed_on TEXT NOT NULL CHECK (borrowed_on IS date(borrowed_on))`: this check ensures that `borrowed_on` is a real calendar date and that it is in format `YYYY-MM-DD`.

* `due_on TEXT NOT NULL CHECK (due_on is date(due_on) AND due_on >= date(borrowed_on + '14 days'))`:
this check ensures that `due_on` is a real calendar date in format `YYYY-MM-DD` and that it is not less than 14 days after the borrowed date. 

* `returned_on TEXT CHECK (returned_on IS NULL OR (returned_on IS date(returned_on) AND returned_on >= borrowed_on))`: this ensures that returned_on is a real calendar date in format `YYYY-MM-DD` and that it is not before the borrowed date. 

Below is a set of checks that you can run yourself to verify the integrity of the date columns:

```sql
BEGIN TRANSACTION;
-- insert a loan with real calendar dates in the expected format (YYYY-MM-DD) that follow the business logic (due date is borrowed_on + 14 days, returned_on is not before borrowed_on)
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on) 
VALUES ( 1, 1, '2026-09-01', '2026-09-15', '2026-09-10');
-- This will run successfully
ROLLBACK;

-- insert a loan with returned date being the same as borrowed date
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on) 
VALUES ( 1, 4, '2026-09-01', '2026-09-15', '2026-09-01');
-- This will run successfully

-- insert a loan with returned_on as an impossible calendar date (2026-02-30):
BEGIN TRANSACTION;
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on)
VALUES (1, 2, '2026-02-01', '2026-02-15', '2026-02-30');
-- Result: Runtime error: CHECK constraint failed: returned_on IS NULL OR
-- (returned_on IS date(returned_on) AND returned_on >= borrowed_on)
ROLLBACK;

-- insert a loan with borrowed_on in julian day format
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on)
VALUES (1, 3, '2460825.5', '2026-06-25', '2026-06-30');
-- Result: Runtime error: CHECK constraint failed: borrowed_on IS date(borrowed_on)

-- insert a loan with invalid due date
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on)
VALUES (1, 1, '2026-10-01', 'not-a-date', NULL);
-- Result: Runtime error: CHECK constraint failed: due_on IS date(due_on) AND
-- due_on >= date(borrowed_on, '+14 days')

-- insert a loan with returned date before borrowed_date
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on) 
VALUES ( 2, 2, '2026-09-01', '2026-09-15', '2026-08-10');
-- Result: Runtime error: CHECK constraint failed: returned_on IS NULL OR
-- (returned_on IS date(returned_on) AND returned_on >= borrowed_on)

-- insert a loan with due date which is only 10 days after the borrowed date;
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on) 
VALUES ( 3, 3, '2026-09-01', '2026-09-11', '2026-09-10');
-- Result: Runtime error: CHECK constraint failed: due_on IS date(due_on) AND
-- due_on >= date(borrowed_on, '+14 days') 

