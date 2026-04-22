CREATE TABLE IF NOT EXISTS guests (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(120) NOT NULL,
    last_name VARCHAR(120) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_guests_name (last_name, first_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS rsvp_submissions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    guest_id BIGINT UNSIGNED NOT NULL,
    attendance VARCHAR(120) NOT NULL,
    transport VARCHAR(120) NULL,
    accommodation VARCHAR(180) NULL,
    dietary VARCHAR(255) NULL,
    comment TEXT NULL,
    survey_json JSON NULL,
    submitted_at DATETIME NOT NULL,
    PRIMARY KEY (id),
    KEY idx_rsvp_guest_id (guest_id),
    CONSTRAINT fk_rsvp_guest FOREIGN KEY (guest_id) REFERENCES guests (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS family_members (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    submission_id BIGINT UNSIGNED NOT NULL,
    first_name VARCHAR(120) NOT NULL,
    last_name VARCHAR(120) NOT NULL,
    PRIMARY KEY (id),
    KEY idx_family_submission_id (submission_id),
    CONSTRAINT fk_family_submission FOREIGN KEY (submission_id)
        REFERENCES rsvp_submissions (id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
