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
    joined_on TEXT NOT NULL CHECK (joined_on IS date(joined_on))
);

CREATE TABLE loans (
    id INTEGER PRIMARY KEY,
    book_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    borrowed_on TEXT NOT NULL CHECK (borrowed_on IS date(borrowed_on)),
    due_on TEXT NOT NULL CHECK (
        due_on IS date(due_on) AND
        due_on >= date(borrowed_on, '+14 days')
    ),
    returned_on TEXT CHECK (
        returned_on IS NULL OR
        (returned_on IS date(returned_on) AND returned_on >= borrowed_on)
    ),
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (member_id) REFERENCES members(id)
);