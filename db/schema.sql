CREATE DATABASE IF NOT EXISTS wedding_invite CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wedding_invite.guests (
    id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(120) NOT NULL,
    last_name VARCHAR(120) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_guests_name ON wedding_invite.guests (last_name, first_name);

CREATE TABLE IF NOT EXISTS wedding_invite.rsvp_submissions (
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
    CONSTRAINT fk_rsvp_guest FOREIGN KEY (guest_id) REFERENCES wedding_invite.guests (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_rsvp_guest_id ON wedding_invite.rsvp_submissions (guest_id);

CREATE TABLE IF NOT EXISTS wedding_invite.family_members (
    id INT NOT NULL AUTO_INCREMENT,
    submission_id INT NOT NULL,
    first_name VARCHAR(120) NOT NULL,
    last_name VARCHAR(120) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_family_submission FOREIGN KEY (submission_id)
        REFERENCES wedding_invite.rsvp_submissions (id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_family_submission_id ON wedding_invite.family_members (submission_id);

INSERT INTO wedding_invite.guests (first_name, last_name)
SELECT 'Анна', 'Иванова'
WHERE NOT EXISTS (
    SELECT 1 FROM wedding_invite.guests WHERE first_name = 'Анна' AND last_name = 'Иванова'
);

INSERT INTO wedding_invite.guests (first_name, last_name)
SELECT 'Сергей', 'Петров'
WHERE NOT EXISTS (
    SELECT 1 FROM wedding_invite.guests WHERE first_name = 'Сергей' AND last_name = 'Петров'
);

INSERT INTO wedding_invite.guests (first_name, last_name)
SELECT 'Мария', 'Соколова'
WHERE NOT EXISTS (
    SELECT 1 FROM wedding_invite.guests WHERE first_name = 'Мария' AND last_name = 'Соколова'
);
