# Wedding Invite Site (XAMPP)

Сайт-приглашение на свадьбу, который можно запустить через **XAMPP (Apache + MySQL)**.

## 1) Куда положить проект

Скопируйте папку проекта в:

- **Windows:** `C:\xampp\htdocs\wedding-invite`
- **macOS/Linux:** `<xampp>/htdocs/wedding-invite`

## 2) Запустить XAMPP

В панели XAMPP запустите:
- **Apache**
- **MySQL**

## 3) Создать БД и таблицы

1. Откройте `http://localhost/phpmyadmin`
2. Вкладка **SQL**
3. Выполните содержимое файла `db/schema.sql` целиком.

> Файл сам создаёт БД `wedding_invite` и таблицы.

## 4) Настроить подключение к БД

Отредактируйте `config.php`:
- `$DB_HOST`
- `$DB_USER`
- `$DB_PASSWORD`
- `$DB_NAME`
- `$DB_PORT`

Для стандартного XAMPP обычно:
- host: `127.0.0.1`
- user: `root`
- password: `` (пустой)
- db: `wedding_invite`
- port: `3306`

## 5) Открыть сайт

Откройте в браузере:

`http://localhost/wedding-invite/`

## Что реализовано

- Красивый landing в бежево-бордово-белых цветах.
- Плавные анимации появления блоков при прокрутке.
- Мобильная адаптация.
- RSVP-форма:
  - поиск гостя,
  - добавление членов семьи,
  - мини-опрос (дорога, проживание, питание, музыка, время прибытия).
- Данные сохраняются в MySQL таблицы: `guests`, `rsvp_submissions`, `family_members`.
