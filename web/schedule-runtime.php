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

    // Serialize admission and cleanup only, never the source fetch itself.
    $admission = @fopen("$jobs/admission.lock", "c");
    if ($admission === false || !flock($admission, LOCK_EX | LOCK_NB)) {
        if (is_resource($admission)) fclose($admission);
        return $snapshot !== null ? [200, $result + ["refreshing" => true]]
            : [202, ["snapshot" => null, "saved" => false, "refreshing" => true]];
    }
    try {
        tipoffCleanJobs($jobs);
        $key = hash("sha256", "$sport\n$day\n$zone");
        $lockPath = "$jobs/$key.lock";
        $attemptPath = "$jobs/$key.attempt";
        $lock = @fopen($lockPath, "c");
        if ($lock === false) throw new RuntimeException("Job lock unavailable");
        // A child inherits these locks. Closing our descriptors must NOT unlock them.
        if (!flock($lock, LOCK_EX | LOCK_NB)) {
            fclose($lock);
            $refreshing = true;
        } else {
            clearstatcache(true, $attemptPath);
            $attemptAge = is_file($attemptPath) ? time() - (int) filemtime($attemptPath) : PHP_INT_MAX;
            $refreshing = false;
            if ($attemptAge >= 30) {
                $slot = null;
                for ($index = 0; $index < 5; $index++) {
                    $candidate = @fopen("$jobs/slot-$index.lock", "c");
                    if ($candidate !== false && flock($candidate, LOCK_EX | LOCK_NB)) {
                        $slot = $candidate;
                        break;
                    }
                    if (is_resource($candidate)) fclose($candidate);
                }
                // Capacity is pending, not a failed/empty schedule. The client retries.
                $refreshing = true;
                if ($slot !== null) {
                    $command = ["/usr/bin/nohup", "/usr/bin/timeout", "85s",
                        "$runtime/TipoffCheck", "--web", $sport, $day, $zone, $cache];
                    $shell = implode(" ", array_map("escapeshellarg", $command)) . " </dev/null >/dev/null 2>&1 &";
                    $job = proc_open(["/bin/sh", "-c", $shell],
                        [0 => ["file", "/dev/null", "r"], 1 => ["file", "/dev/null", "w"],
                         2 => ["file", "/dev/null", "w"], 3 => $lock, 4 => $slot], $unused);
                    if (is_resource($job)) {
                        $started = proc_close($job) === 0;
                        if ($started) touch($attemptPath);
                        else $refreshing = false;
                    } else $refreshing = false;
                    fclose($slot);
                }
            }
            fclose($lock);
        }
    } catch (Throwable $error) {
        $refreshing = false;
    } finally {
        flock($admission, LOCK_UN);
        fclose($admission);
    }
    if ($snapshot !== null) {
        return [200, $result + ["refreshing" => $refreshing]];
    }
    return $refreshing ? [202, ["snapshot" => null, "saved" => false, "refreshing" => true]]
        : [503, ["error" => "Schedule unavailable", "refreshing" => false]];
}

// Called under admission.lock; never unlink a lock held by a running refresh.
// Fixed admission/slot locks are retained to avoid separate lock inodes.
function tipoffCleanJobs(string $jobs): void
{
    $marker = "$jobs/cleanup.attempt";
    clearstatcache(true, $marker);
    if (is_file($marker) && time() - (int) filemtime($marker) < 3600) return;
    foreach (glob("$jobs/*.lock") ?: [] as $path) {
        if (!preg_match('/^[a-f0-9]{64}\.lock$/', basename($path))) continue;
        $attempt = substr($path, 0, -5) . ".attempt";
        $modified = max((int) @filemtime($path), (int) @filemtime($attempt));
        if (time() - $modified < 86400) continue;
        $handle = @fopen($path, "r+");
        if ($handle === false) continue;
        if (flock($handle, LOCK_EX | LOCK_NB)) {
            @unlink($attempt);
            @unlink($path);
        }
        fclose($handle);
    }
    // Remove legacy orphan attempt files as well.
    foreach (glob("$jobs/*.attempt") ?: [] as $path) {
        if (!preg_match('/^[a-f0-9]{64}\.attempt$/', basename($path))) continue;
        if (!is_file(substr($path, 0, -8) . ".lock") && time() - (int) filemtime($path) >= 86400) @unlink($path);
    }
    touch($marker);
}
