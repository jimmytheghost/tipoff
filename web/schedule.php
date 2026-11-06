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

$runtime = "/var/www/deployments/tipoff-runtime";
$cache = "$runtime/cache";
// One refresh per sport at a time, including its saved listings and Altitude data.
$command = [
    "/usr/bin/flock", "-w", "20", "$cache/$sport.lock",
    "/usr/bin/timeout", "85s", "$runtime/TipoffCheck",
    "--web", $sport, $day, $zone, $cache,
];
$process = proc_open(
    $command,
    [0 => ["file", "/dev/null", "r"], 1 => ["pipe", "w"], 2 => ["file", "/dev/null", "w"]],
    $pipes
);
if (is_resource($process)) {
    $body = stream_get_contents($pipes[1]);
    fclose($pipes[1]);
    $exitCode = proc_close($process);
    if ($exitCode === 0 && is_string($body) && is_array(json_decode($body, true))) {
        echo $body;
        exit;
    }
}

http_response_code(503);
echo '{"error":"Schedule unavailable"}';
