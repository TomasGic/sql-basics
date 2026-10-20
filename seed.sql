-- inserting data into authors
INSERT INTO authors (name) VALUES ('Sandi Metz');
INSERT INTO authors (name) VALUES ('Robert C. Martin');
INSERT INTO authors (name) VALUES ('Jay Wengrow');

-- inserting data into books
INSERT INTO books (title, author_id, copies_total) 
VALUES ('Practical Object-Oriented Design in Ruby', 1, 1);

INSERT INTO books (title, author_id, copies_total) 
VALUES ('Clean Code', 2, 2);

INSERT INTO books (title, author_id, copies_total) 
VALUES ('Clean Architecture', 2, 2);

INSERT INTO books (title, author_id, copies_total) 
VALUES ('A Common-Sense Guide to Data Structures and Algorithms', 3, 1);

INSERT INTO books (title, author_id, copies_total) 
VALUES ('99 Bottles of OOP', 1, 1);

INSERT INTO books (title, author_id, copies_total)
VALUES ('Agile Software Development: Principles, Patterns, and Practices', 2, 3);

-- inserting data into members
INSERT INTO members (first_name, last_name, email, joined_on)
VALUES ('Tomas', 'Gic', 'tomas.gic@example.com', '2026-01-05');

INSERT INTO members (first_name, last_name, email, joined_on)
VALUES ('Martin', 'Kocurek', 'martin.kocurek@example.com', '2026-02-05');

INSERT INTO members (first_name, last_name, email, joined_on)
VALUES ('Lukas', 'Rohac', 'lukas.rohac@example.com', '2026-03-05');

INSERT INTO members (first_name, last_name, email, joined_on)
VALUES ('Lubos', 'Valasek', 'lubos.valasek@example.com', '2026-04-05');

-- inserting data into loans
INSERT INTO (book_id, member_id, borrowed_on, due_on, returned_on) VALUES 
-- Loan 1: Returned on time
(1, 1, '2026-09-01', '2026-09-15', '2026-09-10'),

-- Loan 2: Returned after due date
(2, 2, '2026-09-05', '2026-09-19', '2026-09-22'),

-- Loan 3: overdue (Due date has passed, but returned_on is NULL)
(3, 3, '2026-10-01', '2026-10-15', NULL),

-- Loan 4: Currently active
(4, 4, '2026-10-10', '2026-10-24', NULL),

-- Loan 5: Returned on time
(5, 1, '2026-09-18', '2026-10-02', '2026-10-01'),

-- Loan 6: Currently active
(6, 3, '2026-10-12', '2026-10-26', NULL);


