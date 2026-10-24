PRAGMA foreign_keys = ON;

CREATE TABLE authors (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE books (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER NOT NULL,
    copies_total INTEGER NOT NULL CHECK (copies_total >= 0),
    FOREIGN KEY (author_id) REFERENCES authors(id)
);

CREATE TABLE members (
    id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    joined_on TEXT NOT NULL CHECK (date(joined_on) IS NOT NULL)
);

CREATE TABLE loans (
    id INTEGER PRIMARY KEY,
    book_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    borrowed_on TEXT NOT NULL,
    due_on TEXT NOT NULL CHECK (due_on >= borrowed_on),
    returned_on TEXT,
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (member_id) REFERENCES members(id)
);