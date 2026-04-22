<?php
$DB_HOST = getenv('DB_HOST') ?: '127.0.0.1';
$DB_USER = getenv('DB_USER') ?: 'root';
$DB_PASSWORD = getenv('DB_PASSWORD') ?: '';
$DB_NAME = getenv('DB_NAME') ?: 'wedding_invite';
$DB_PORT = (int)(getenv('DB_PORT') ?: 3306);

$mysqli = new mysqli($DB_HOST, $DB_USER, $DB_PASSWORD, $DB_NAME, $DB_PORT);
if ($mysqli->connect_errno) {
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['error' => 'Ошибка подключения к базе: ' . $mysqli->connect_error], JSON_UNESCAPED_UNICODE);
    exit;
}
$mysqli->set_charset('utf8mb4');
