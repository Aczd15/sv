# Wedding Invite Site

Сайт-приглашение на свадьбу с формой RSVP и **MySQL**-базой гостей.

## Запуск

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

export DB_HOST=127.0.0.1
export DB_PORT=3306
export DB_USER=root
export DB_PASSWORD=your_password
export DB_NAME=wedding_invite

python app.py
```

Откройте: http://127.0.0.1:5000

## Что внутри

- Красивый landing в бежево-бордово-белых цветах.
- Анимации появления блоков при скролле.
- Адаптив под мобильные устройства.
- Форма RSVP:
  - поиск по гостям,
  - добавление семьи,
  - мини-опрос (дорога, проживание, питание, музыка, время приезда).
- MySQL база с таблицами: `guests`, `rsvp_submissions`, `family_members`.


## Инициализация схемы вручную

```bash
mysql -u root -p wedding_invite < db/schema.sql
```

Важно: запускайте **весь файл** `db/schema.sql`, а не отдельный фрагмент строки.
