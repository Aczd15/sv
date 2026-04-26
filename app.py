from __future__ import annotations

import json
import os
from datetime import datetime
from pathlib import Path
from typing import Any

import mysql.connector
from flask import Flask, jsonify, render_template, request

BASE_DIR = Path(__file__).resolve().parent
SCHEMA_PATH = BASE_DIR / "db" / "schema.sql"

app = Flask(__name__)


def get_db_config() -> dict[str, Any]:
    return {
        "host": os.getenv("DB_HOST", "127.0.0.1"),
        "port": int(os.getenv("DB_PORT", "3306")),
        "user": os.getenv("DB_USER", "root"),
        "password": os.getenv("DB_PASSWORD", ""),
        "database": os.getenv("DB_NAME", "wedding_invite"),
    }


def get_db_connection() -> mysql.connector.MySQLConnection:
    return mysql.connector.connect(**get_db_config())


def init_db() -> None:
    cfg = get_db_config()
    db_name = cfg.pop("database")

    admin_conn = mysql.connector.connect(**cfg)
    admin_conn.autocommit = True
    with admin_conn.cursor() as cursor:
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{db_name}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
    admin_conn.close()

    conn = get_db_connection()
    conn.autocommit = True
    schema_sql = SCHEMA_PATH.read_text(encoding="utf-8")
    statements = [stmt.strip() for stmt in schema_sql.split(";") if stmt.strip()]
    with conn.cursor() as cursor:
        for statement in statements:
            cursor.execute(statement)
    conn.close()


@app.route("/")
def index() -> str:
    return render_template("index.html")


@app.route("/api/guests/search", methods=["GET"])
def search_guest() -> Any:
    q = request.args.get("q", "").strip()
    if len(q) < 2:
        return jsonify({"matches": []})

    like_query = f"%{q}%"
    conn = get_db_connection()
    with conn.cursor(dictionary=True) as cursor:
        cursor.execute(
            """
            SELECT id, first_name, last_name
            FROM guests
            WHERE LOWER(CONCAT(first_name, ' ', last_name)) LIKE LOWER(%s)
               OR LOWER(CONCAT(last_name, ' ', first_name)) LIKE LOWER(%s)
            ORDER BY last_name, first_name
            LIMIT 10
            """,
            (like_query, like_query),
        )
        rows = cursor.fetchall()
    conn.close()

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

    conn = get_db_connection()
    conn.autocommit = False
    try:
        with conn.cursor(dictionary=True) as cursor:
            cursor.execute(
                """
                SELECT id FROM guests
                WHERE LOWER(first_name) = LOWER(%s) AND LOWER(last_name) = LOWER(%s)
                LIMIT 1
                """,
                (first_name, last_name),
            )
            guest_row = cursor.fetchone()

            if guest_row:
                guest_id = guest_row["id"]
            else:
                cursor.execute(
                    "INSERT INTO guests (first_name, last_name) VALUES (%s, %s)",
                    (first_name, last_name),
                )
                guest_id = cursor.lastrowid

            cursor.execute(
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
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    guest_id,
                    attendance,
                    transport,
                    accommodation,
                    dietary,
                    comment,
                    json.dumps(survey_json, ensure_ascii=False),
                    datetime.utcnow(),
                ),
            )
            submission_id = cursor.lastrowid

            for member in family_members:
                m_first = str(member.get("first_name", "")).strip()
                m_last = str(member.get("last_name", "")).strip()
                if not m_first or not m_last:
                    continue

                cursor.execute(
                    """
                    INSERT INTO family_members (submission_id, first_name, last_name)
                    VALUES (%s, %s, %s)
                    """,
                    (submission_id, m_first, m_last),
                )

        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

    return jsonify({"status": "ok", "submission_id": submission_id})


if __name__ == "__main__":
    init_db()
    app.run(debug=True)
