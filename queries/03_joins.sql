-- Which book was written by which author?
SELECT books.title AS book_title, authors.name AS author FROM books JOIN authors ON books.author_id=authors.id;


-- Which member has which book currently on loan and when is it due? 
SELECT members.first_name, members.last_name, books.title AS book_on_loan, loans.due_on 
FROM loans
JOIN books ON books.id=loans.book_id
JOIN members ON members.id=loans.member_id
WHERE loans.returned_on IS NULL;

-- Which member has overdue books now?
SELECT members.first_name, members.last_name, books.title AS book_on_loan, loans.due_on
FROM loans
JOIN members ON members.id=loans.member_id
JOIN books ON books.id=loans.book_id
WHERE loans.due_on > date('now');

-- How many times has each book been borrowed, most popular first?
SELECT books.id AS book_id, books.title, COUNT(loans.id) AS times_borrowed FROM books
JOIN loans ON books.id=loans.book_id
GROUP BY books.id
ORDER BY times_borrowed DESC;

-- Which members have never borrowed anything?
SELECT members.id, members.first_name, members.last_name FROM members
LEFT JOIN loans ON members.id=loans.member_id
WHERE loans.member_id IS NULL;

