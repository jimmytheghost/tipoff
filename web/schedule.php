<?php

declare(strict_types=1);

header("Content-Type: application/json; charset=utf-8");
header("Cache-Control: no-store");

$sport = $_GET["sport"] ?? null;
$day = $_GET["day"] ?? null;
$zone = $_GET["zone"] ?? null;

if (
    !in_array($sport, ["nba", "nfl", "wnba", "nhl", "mlb"], true) ||
    !is_string($day) ||
    !preg_match('/\A(\d{4})-(\d{2})-(\d{2})\z/', $day, $parts) ||
    !checkdate((int) $parts[2], (int) $parts[3], (int) $parts[1]) ||
    !is_string($zone) ||
    !in_array($zone, DateTimeZone::listIdentifiers(DateTimeZone::ALL_WITH_BC), true)
) {
    http_response_code(400);
    echo '{"error":"Invalid schedule request"}';
    exit;
}

require __DIR__ . "/schedule-runtime.php";
[$status, $result] = tipoffSchedule("/var/www/deployments/tipoff-runtime", $sport, $day, $zone);
http_response_code($status);
echo json_encode($result, JSON_UNESCAPED_SLASHES);
