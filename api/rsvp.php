<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../config.php';

$payload = json_decode(file_get_contents('php://input'), true);
if (!is_array($payload)) {
    http_response_code(400);
    echo json_encode(['error' => 'Некорректный JSON'], JSON_UNESCAPED_UNICODE);
    exit;
}

$primary = $payload['primary_guest'] ?? [];
$first_name = trim((string)($primary['first_name'] ?? ''));
$last_name = trim((string)($primary['last_name'] ?? ''));

if ($first_name === '' || $last_name === '') {
    http_response_code(400);
    echo json_encode(['error' => 'Укажите имя и фамилию основного гостя.'], JSON_UNESCAPED_UNICODE);
    exit;
}

$attendance = trim((string)($payload['attendance'] ?? ''));
$transport = trim((string)($payload['transport'] ?? ''));
$accommodation = trim((string)($payload['accommodation'] ?? ''));
$dietary = trim((string)($payload['dietary'] ?? ''));
$comment = trim((string)($payload['comment'] ?? ''));
$survey_json = json_encode([
    'music' => $payload['music'] ?? '',
    'arrival_time' => $payload['arrival_time'] ?? ''
], JSON_UNESCAPED_UNICODE);

$family_members = $payload['family_members'] ?? [];
if (!is_array($family_members)) {
    http_response_code(400);
    echo json_encode(['error' => 'Список семьи должен быть массивом.'], JSON_UNESCAPED_UNICODE);
    exit;
}

$mysqli->begin_transaction();

try {
    $stmt = $mysqli->prepare('SELECT id FROM guests WHERE LOWER(first_name)=LOWER(?) AND LOWER(last_name)=LOWER(?) LIMIT 1');
    $stmt->bind_param('ss', $first_name, $last_name);
    $stmt->execute();
    $result = $stmt->get_result();
    $guest = $result->fetch_assoc();

    if ($guest) {
        $guest_id = (int)$guest['id'];
    } else {
        $stmt = $mysqli->prepare('INSERT INTO guests (first_name, last_name) VALUES (?, ?)');
        $stmt->bind_param('ss', $first_name, $last_name);
        $stmt->execute();
        $guest_id = $stmt->insert_id;
    }

    $submitted_at = date('Y-m-d H:i:s');
    $stmt = $mysqli->prepare('INSERT INTO rsvp_submissions (guest_id, attendance, transport, accommodation, dietary, comment, survey_json, submitted_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)');
    $stmt->bind_param('isssssss', $guest_id, $attendance, $transport, $accommodation, $dietary, $comment, $survey_json, $submitted_at);
    $stmt->execute();
    $submission_id = $stmt->insert_id;

    $stmtFamily = $mysqli->prepare('INSERT INTO family_members (submission_id, first_name, last_name) VALUES (?, ?, ?)');
    foreach ($family_members as $member) {
        $m_first = trim((string)($member['first_name'] ?? ''));
        $m_last = trim((string)($member['last_name'] ?? ''));
        if ($m_first === '' || $m_last === '') {
            continue;
        }
        $stmtFamily->bind_param('iss', $submission_id, $m_first, $m_last);
        $stmtFamily->execute();
    }

    $mysqli->commit();
    echo json_encode(['status' => 'ok', 'submission_id' => $submission_id], JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    $mysqli->rollback();
    http_response_code(500);
    echo json_encode(['error' => 'Ошибка сохранения RSVP'], JSON_UNESCAPED_UNICODE);
}
