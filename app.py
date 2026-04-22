from __future__ import annotations

import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Any

from flask import Flask, jsonify, render_template, request

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "db" / "wedding_invite.db"
SCHEMA_PATH = BASE_DIR / "db" / "schema.sql"

app = Flask(__name__)


def get_db_connection() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db() -> None:
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    schema_sql = SCHEMA_PATH.read_text(encoding="utf-8")
    with get_db_connection() as conn:
        conn.executescript(schema_sql)


@app.route("/")
def index() -> str:
    return render_template("index.html")


@app.route("/api/guests/search", methods=["GET"])
def search_guest() -> Any:
    q = request.args.get("q", "").strip()
    if len(q) < 2:
        return jsonify({"matches": []})

    like_query = f"%{q}%"
    with get_db_connection() as conn:
        rows = conn.execute(
            """
            SELECT id, first_name, last_name
            FROM guests
            WHERE lower(first_name || ' ' || last_name) LIKE lower(?)
               OR lower(last_name || ' ' || first_name) LIKE lower(?)
            ORDER BY last_name, first_name
            LIMIT 10
            """,
            (like_query, like_query),
        ).fetchall()

    matches = [
        {"id": row["id"], "first_name": row["first_name"], "last_name": row["last_name"]}
        for row in rows
    ]
    return jsonify({"matches": matches})


@app.route("/api/rsvp", methods=["POST"])
def submit_rsvp() -> Any:
    data = request.get_json(silent=True) or {}

    primary = data.get("primary_guest", {})
    first_name = str(primary.get("first_name", "")).strip()
    last_name = str(primary.get("last_name", "")).strip()

    if not first_name or not last_name:
        return jsonify({"error": "Укажите имя и фамилию основного гостя."}), 400

    transport = str(data.get("transport", "")).strip()
    accommodation = str(data.get("accommodation", "")).strip()
    attendance = str(data.get("attendance", "")).strip()
    comment = str(data.get("comment", "")).strip()
    dietary = str(data.get("dietary", "")).strip()

    family_members = data.get("family_members", [])
    if not isinstance(family_members, list):
        return jsonify({"error": "Список семьи должен быть массивом."}), 400

    survey_json = {
        "music": data.get("music", ""),
        "arrival_time": data.get("arrival_time", ""),
    }

    with get_db_connection() as conn:
        guest_row = conn.execute(
            """
            SELECT id FROM guests
            WHERE lower(first_name) = lower(?) AND lower(last_name) = lower(?)
            LIMIT 1
            """,
            (first_name, last_name),
        ).fetchone()

        if guest_row:
            guest_id = guest_row["id"]
        else:
            cursor = conn.execute(
                "INSERT INTO guests (first_name, last_name) VALUES (?, ?)",
                (first_name, last_name),
            )
            guest_id = cursor.lastrowid

        cursor = conn.execute(
            """
            INSERT INTO rsvp_submissions (
                guest_id,
                attendance,
                transport,
                accommodation,
                dietary,
                comment,
                survey_json,
                submitted_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                guest_id,
                attendance,
                transport,
                accommodation,
                dietary,
                comment,
                str(survey_json),
                datetime.utcnow().isoformat(timespec="seconds"),
            ),
        )
        submission_id = cursor.lastrowid

        for member in family_members:
            m_first = str(member.get("first_name", "")).strip()
            m_last = str(member.get("last_name", "")).strip()
            if not m_first or not m_last:
                continue

            conn.execute(
                """
                INSERT INTO family_members (submission_id, first_name, last_name)
                VALUES (?, ?, ?)
                """,
                (submission_id, m_first, m_last),
            )

        conn.commit()

    return jsonify({"status": "ok", "submission_id": submission_id})


if __name__ == "__main__":
    init_db()
    app.run(debug=True)
