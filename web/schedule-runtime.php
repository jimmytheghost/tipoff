<?php

declare(strict_types=1);

// Read the typed Swift cache without networking. Refreshes run outside the HTTP request.
function tipoffSchedule(string $runtime, string $sport, string $day, string $zone): array
{
    $cache = "$runtime/cache";
    $process = proc_open(
        ["/usr/bin/timeout", "5s", "$runtime/TipoffCheck", "--web-cached", $sport, $day, $zone, $cache],
        [0 => ["file", "/dev/null", "r"], 1 => ["pipe", "w"], 2 => ["file", "/dev/null", "w"]],
        $pipes
    );
    if (!is_resource($process)) {
        return [503, ["error" => "Schedule unavailable"]];
    }
    $body = stream_get_contents($pipes[1]);
    fclose($pipes[1]);
    $exitCode = proc_close($process);
    $result = is_string($body) ? json_decode($body, true) : null;
    if ($exitCode !== 0 || !is_array($result) || !array_key_exists("saved", $result)) {
        return [503, ["error" => "Schedule unavailable"]];
    }
    $snapshot = $result["snapshot"] ?? null;
    if ($snapshot !== null && (
        !is_array($snapshot) || ($snapshot["day"] ?? null) !== $day ||
        ($snapshot["timeZone"] ?? null) !== $zone || ($snapshot["guide"] ?? "nba") !== $sport
    )) {
        return [503, ["error" => "Schedule unavailable"]];
    }
    if ($snapshot !== null && !$result["saved"]) {
        return [200, $result + ["refreshing" => false]];
    }

    $jobs = "$cache/web-requests";
    if (!is_dir($jobs) && !@mkdir($jobs, 0775, true) && !is_dir($jobs)) {
        return $snapshot !== null ? [200, $result + ["refreshing" => false]]
            : [503, ["error" => "Schedule unavailable"]];
    }
    // Each sport/date/zone has its own job. A slow date cannot lock other dates out.
    $key = hash("sha256", "$sport\n$day\n$zone");
    $lockPath = "$jobs/$key.lock";
    $attemptPath = "$jobs/$key.attempt";
    $lock = @fopen($lockPath, "c");
    if ($lock === false) {
        return $snapshot !== null ? [200, $result + ["refreshing" => false]]
            : [503, ["error" => "Schedule unavailable"]];
    }
    $available = flock($lock, LOCK_EX | LOCK_NB);
    clearstatcache(true, $attemptPath);
    $attemptAge = is_file($attemptPath) ? time() - (int) filemtime($attemptPath) : PHP_INT_MAX;
    $launch = $available && $attemptAge >= 30;
    if ($launch) {
        touch($attemptPath);
    }
    if ($available) {
        flock($lock, LOCK_UN);
    }
    fclose($lock);
    if ($launch) {
        $command = ["/usr/bin/nohup", "/usr/bin/flock", "-n", $lockPath,
            "/usr/bin/timeout", "85s", "$runtime/TipoffCheck", "--web", $sport, $day, $zone, $cache];
        $shell = implode(" ", array_map("escapeshellarg", $command)) . " </dev/null >/dev/null 2>&1 &";
        $job = proc_open(["/bin/sh", "-c", $shell],
            [0 => ["file", "/dev/null", "r"], 1 => ["file", "/dev/null", "w"], 2 => ["file", "/dev/null", "w"]], $unused);
        if (is_resource($job)) {
            proc_close($job);
        }
    }
    $refreshing = $launch || !$available || $attemptAge < 2;
    if ($snapshot !== null) {
        return [200, $result + ["refreshing" => $refreshing]];
    }
    return $refreshing ? [202, ["snapshot" => null, "saved" => false, "refreshing" => true]]
        : [503, ["error" => "Schedule unavailable", "refreshing" => false]];
}
