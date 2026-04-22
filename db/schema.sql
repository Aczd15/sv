PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS guests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rsvp_submissions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    guest_id INTEGER NOT NULL,
    attendance TEXT NOT NULL,
    transport TEXT,
    accommodation TEXT,
    dietary TEXT,
    comment TEXT,
    survey_json TEXT,
    submitted_at TEXT NOT NULL,
    FOREIGN KEY (guest_id) REFERENCES guests (id)
);

CREATE TABLE IF NOT EXISTS family_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    submission_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    FOREIGN KEY (submission_id) REFERENCES rsvp_submissions (id) ON DELETE CASCADE
);

INSERT INTO guests (first_name, last_name)
SELECT 'Анна', 'Иванова'
WHERE NOT EXISTS (SELECT 1 FROM guests WHERE first_name = 'Анна' AND last_name = 'Иванова');

INSERT INTO guests (first_name, last_name)
SELECT 'Сергей', 'Петров'
WHERE NOT EXISTS (SELECT 1 FROM guests WHERE first_name = 'Сергей' AND last_name = 'Петров');

INSERT INTO guests (first_name, last_name)
SELECT 'Мария', 'Соколова'
WHERE NOT EXISTS (SELECT 1 FROM guests WHERE first_name = 'Мария' AND last_name = 'Соколова');
