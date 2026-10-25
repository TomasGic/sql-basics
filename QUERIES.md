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
Foreign key constraints protect the referential integrity of the database. If we add a record to a table where the foreign key references a primary key that doesn't exit in another table, the database engine will throw an error. In our case trying to add a loan with a book_id that doesn't exist in the `books` table will throw a runtime error: `FOREIGN KEY constraint failed`. This is because of this line that we added when creating the `loans` table: `FOREIGN KEY (book_id) REFERENCES books(id)`. It is important to note that in order for the foreign key constraint to work, we need to do run `PRAGMA foreign_keys = ON` at the start of each sqlite3 session. 

**2. Constraints against duplicate records**: 
If we want a table column in the database to only contain unique values, we can add a `UNIQUE` constraint to that column. In our database, we have set up the constraint to not allow two identical email addresses in the `members` table like this: `email TEXT NOT NULL UNIQUE`. Trying to add a member with an email address that already exists in the database will throw a runtime error: `UNIQUE constraint failed: members.email`.

**3. Constraints against custom math/logic rules**:
The `squema.sql` file defines three custom logic rules using the `CHECK` SQL keyword. 
* `joined_on TEXT NOT NULL CHECK (date(joined_on) IS NOT NULL)`: This ensures that the value in the `joined_on` column is a date. 

* `copies_total INTEGER NOT NULL CHECK (copies_total >= 0)`: Does not allow values below 0 to be entered into the `copies_total` column.

* `due_on TEXT NOT NULL CHECK (due_on >= borrowed_on)`: This ensures that the due date cannot be before the date when the book was borrowed on. 

If we try to insert a book with `copies_total = -1`, the database engine will throw a runtime error: `CHECK constraint failed: copies_total >= 0`.
