<?php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../config.php';

$q = isset($_GET['q']) ? trim($_GET['q']) : '';
if (mb_strlen($q) < 2) {
    echo json_encode(['matches' => []], JSON_UNESCAPED_UNICODE);
    exit;
}

$like = '%' . $q . '%';
$sql = "SELECT id, first_name, last_name
        FROM guests
        WHERE LOWER(CONCAT(first_name, ' ', last_name)) LIKE LOWER(?)
           OR LOWER(CONCAT(last_name, ' ', first_name)) LIKE LOWER(?)
        ORDER BY last_name, first_name
        LIMIT 10";

$stmt = $mysqli->prepare($sql);
$stmt->bind_param('ss', $like, $like);
$stmt->execute();
$result = $stmt->get_result();

$matches = [];
while ($row = $result->fetch_assoc()) {
    $matches[] = $row;
}

echo json_encode(['matches' => $matches], JSON_UNESCAPED_UNICODE);
