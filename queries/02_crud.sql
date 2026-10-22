-- insert a new author, then a new book by that author
INSERT INTO authors (name) VALUES ('Pat Shaughnessy
');

INSERT INTO books (title, author_id, copies_total) VALUES ('Ruby Under a Microscope: An Illustrated Guide to Ruby Internals', 4, 2);

-- insert a new member
INSERT INTO members (first_name, last_name, email, joined_on) VALUES ('Tomas', 'Harvanek', 'harvy@example.com', '2026-10-22');

-- record a new loan (a member borrowing a book today)
INSERT INTO loans (book_id, member_id, borrowed_on, due_on, returned_on) VALUES (7, 5, date('now'), date('now', '+14 days'), NULL);

-- list all books sorted by title
SELECT * FROM books ORDER BY title;

-- list all members who joined after August 30th 2026
SELECT * FROM members WHERE joined_on > '2026-06-30';

--list all loans that are not yet returned 
SELECT * FROM loans WHERE returned_on IS NULL;

--list all loans that are overdue
SELECT * FROM loans WHERE due_on > date('now')

--list the number of books each author has written
SELECT author_id, COUNT(*) FROM books GROUP BY author_id;

-- list 3 most recently joined members
SELECT * from members ORDER BY joined_on DESC LIMIT 3;
