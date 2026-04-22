CREATE TABLE IF NOT EXISTS guests (
    id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(120) NOT NULL,
    last_name VARCHAR(120) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_guests_name ON guests (last_name, first_name);

CREATE TABLE IF NOT EXISTS rsvp_submissions (
    id INT NOT NULL AUTO_INCREMENT,
    guest_id INT NOT NULL,
    attendance VARCHAR(120) NOT NULL,
    transport VARCHAR(120) NULL,
    accommodation VARCHAR(180) NULL,
    dietary VARCHAR(255) NULL,
    comment TEXT NULL,
    survey_json TEXT NULL,
    submitted_at DATETIME NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_rsvp_guest FOREIGN KEY (guest_id) REFERENCES guests (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_rsvp_guest_id ON rsvp_submissions (guest_id);

CREATE TABLE IF NOT EXISTS family_members (
    id INT NOT NULL AUTO_INCREMENT,
    submission_id INT NOT NULL,
    first_name VARCHAR(120) NOT NULL,
    last_name VARCHAR(120) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_family_submission FOREIGN KEY (submission_id)
        REFERENCES rsvp_submissions (id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_family_submission_id ON family_members (submission_id);

INSERT INTO guests (first_name, last_name)
SELECT 'Анна', 'Иванова'
WHERE NOT EXISTS (
    SELECT 1 FROM guests WHERE first_name = 'Анна' AND last_name = 'Иванова'
);

INSERT INTO guests (first_name, last_name)
SELECT 'Сергей', 'Петров'
WHERE NOT EXISTS (
    SELECT 1 FROM guests WHERE first_name = 'Сергей' AND last_name = 'Петров'
);

INSERT INTO guests (first_name, last_name)
SELECT 'Мария', 'Соколова'
WHERE NOT EXISTS (
    SELECT 1 FROM guests WHERE first_name = 'Мария' AND last_name = 'Соколова'
);
