CREATE DATABASE IF NOT EXISTS __DB_NAME__ CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS __DB_NAME__.guests (
    id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(120) NOT NULL,
    last_name VARCHAR(120) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_guests_name ON __DB_NAME__.guests (last_name, first_name);

CREATE TABLE IF NOT EXISTS __DB_NAME__.rsvp_submissions (
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
    CONSTRAINT fk_rsvp_guest FOREIGN KEY (guest_id) REFERENCES __DB_NAME__.guests (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_rsvp_guest_id ON __DB_NAME__.rsvp_submissions (guest_id);

CREATE TABLE IF NOT EXISTS __DB_NAME__.family_members (
    id INT NOT NULL AUTO_INCREMENT,
    submission_id INT NOT NULL,
    first_name VARCHAR(120) NOT NULL,
    last_name VARCHAR(120) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_family_submission FOREIGN KEY (submission_id)
        REFERENCES __DB_NAME__.rsvp_submissions (id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_family_submission_id ON __DB_NAME__.family_members (submission_id);

INSERT INTO __DB_NAME__.guests (first_name, last_name)
SELECT 'Анна', 'Иванова'
WHERE NOT EXISTS (
    SELECT 1 FROM __DB_NAME__.guests WHERE first_name = 'Анна' AND last_name = 'Иванова'
);

INSERT INTO __DB_NAME__.guests (first_name, last_name)
SELECT 'Сергей', 'Петров'
WHERE NOT EXISTS (
    SELECT 1 FROM __DB_NAME__.guests WHERE first_name = 'Сергей' AND last_name = 'Петров'
);

INSERT INTO __DB_NAME__.guests (first_name, last_name)
SELECT 'Мария', 'Соколова'
WHERE NOT EXISTS (
    SELECT 1 FROM __DB_NAME__.guests WHERE first_name = 'Мария' AND last_name = 'Соколова'
);
