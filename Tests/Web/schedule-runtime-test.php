<?php

declare(strict_types=1);
require dirname(__DIR__, 2) . '/web/schedule-runtime.php';

$base = sys_get_temp_dir() . '/tipoff-runtime-' . bin2hex(random_bytes(6));
mkdir($base);
$passed = 0;
function expect(bool $condition, string $message): void {
    if (!$condition) throw new RuntimeException($message);
}
function fixture(string $base, string $name, ?array $snapshot, bool $saved): string {
    $runtime = "$base/$name";
    mkdir("$runtime/cache", 0777, true);
    file_put_contents("$runtime/cached.json", json_encode(['snapshot' => $snapshot, 'saved' => $saved]));
    $code = <<<'CODE'
<?php
$root = __DIR__;
if ($argv[1] === '--web-cached') { echo file_get_contents("$root/cached.json"); exit; }
file_put_contents("$root/refreshes", $argv[3] . "\n", FILE_APPEND);
usleep(800000);
$result = ['snapshot' => ['day' => $argv[3], 'guide' => $argv[2], 'timeZone' => $argv[4], 'games' => [], 'source' => 'Fixture', 'fetchedAt' => '2026-11-06T20:00:00Z'], 'saved' => false];
file_put_contents("$root/cached.json.tmp", json_encode($result));
rename("$root/cached.json.tmp", "$root/cached.json");
CODE;
    file_put_contents("$runtime/TipoffCheck", '#!' . PHP_BINARY . "\n" . $code);
    chmod("$runtime/TipoffCheck", 0755);
    return $runtime;
}
$snapshot = ['day' => '2026-11-06', 'guide' => 'nba', 'timeZone' => 'America/Denver', 'games' => [], 'source' => 'Fixture', 'fetchedAt' => '2026-11-06T10:00:00Z'];
function check(string $label, callable $test): void {
    global $passed;
    $test(); $passed++; echo "PASS $label\n";
}
check('fresh cache never starts networking', function () use ($base, $snapshot) {
    $r = fixture($base, 'fresh', $snapshot, false);
    [$status, $body] = tipoffSchedule($r, 'nba', '2026-11-06', 'America/Denver');
    expect($status === 200 && $body['snapshot'] === $snapshot && !$body['refreshing'], 'fresh response');
    expect(!file_exists("$r/refreshes"), 'unexpected refresh');
});
check('stale cache returns promptly with original freshness', function () use ($base, $snapshot) {
    $r = fixture($base, 'stale', $snapshot, true);
    $start = microtime(true);
    [$status, $body] = tipoffSchedule($r, 'nba', '2026-11-06', 'America/Denver');
    expect(microtime(true) - $start < 0.5, 'request blocked on refresh');
    expect($status === 200 && $body['saved'] && $body['snapshot'] === $snapshot && $body['refreshing'], 'stale response');
});
check('busy date lock still serves cached data immediately', function () use ($base, $snapshot) {
    $r = fixture($base, 'busy', $snapshot, true);
    mkdir("$r/cache/web-requests");
    $key = hash('sha256', "nba\n2026-11-06\nAmerica/Denver");
    $lock = fopen("$r/cache/web-requests/$key.lock", 'c'); flock($lock, LOCK_EX);
    $start = microtime(true);
    [$status, $body] = tipoffSchedule($r, 'nba', '2026-11-06', 'America/Denver');
    expect(microtime(true) - $start < 0.5 && $status === 200 && $body['saved'], 'busy lock blocked cache');
    flock($lock, LOCK_UN); fclose($lock);
});
check('cold cache is pending then serves the completed refresh', function () use ($base) {
    $r = fixture($base, 'cold', null, false);
    [$status, $body] = tipoffSchedule($r, 'nba', '2026-11-06', 'America/Denver');
    expect($status === 202 && $body['refreshing'] && $body['snapshot'] === null, 'cold cache pretended to be empty');
    usleep(1000000);
    [$status, $body] = tipoffSchedule($r, 'nba', '2026-11-06', 'America/Denver');
    expect($status === 200 && !$body['saved'] && !$body['refreshing'], 'refresh result unavailable');
});
check('wrong-date snapshot is rejected', function () use ($base, $snapshot) {
    $r = fixture($base, 'wrong-day', $snapshot, false);
    expect(tipoffSchedule($r, 'nba', '2026-11-07', 'America/Denver')[0] === 503, 'date isolation lost');
});
check('wrong-zone snapshot is rejected', function () use ($base, $snapshot) {
    $r = fixture($base, 'wrong-zone', $snapshot, false);
    expect(tipoffSchedule($r, 'nba', '2026-11-06', 'America/New_York')[0] === 503, 'zone isolation lost');
});
check('malformed cached output is unavailable', function () use ($base) {
    $r = fixture($base, 'malformed', null, false);
    file_put_contents("$r/cached.json", '{bad');
    expect(tipoffSchedule($r, 'nba', '2026-11-06', 'America/Denver')[0] === 503, 'malformed cache accepted');
});
check('recent failed attempt is backed off without losing saved data', function () use ($base, $snapshot) {
    $r = fixture($base, 'backoff', $snapshot, true);
    mkdir("$r/cache/web-requests");
    $key = hash('sha256', "nba\n2026-11-06\nAmerica/Denver");
    touch("$r/cache/web-requests/$key.attempt", time() - 5);
    [$status, $body] = tipoffSchedule($r, 'nba', '2026-11-06', 'America/Denver');
    expect($status === 200 && $body['snapshot'] === $snapshot && !$body['refreshing'], 'failed attempt lost cache');
    expect(!file_exists("$r/refreshes"), 'failure backoff bypassed');
});
check('another date can refresh while this date is locked', function () use ($base) {
    $r = fixture($base, 'isolated-date', null, false);
    mkdir("$r/cache/web-requests");
    $key = hash('sha256', "nba\n2026-11-06\nAmerica/Denver");
    $lock = fopen("$r/cache/web-requests/$key.lock", 'c'); flock($lock, LOCK_EX);
    $start = microtime(true);
    [$status, $body] = tipoffSchedule($r, 'nba', '2026-11-07', 'America/Denver');
    expect($status === 202 && $body['refreshing'] && microtime(true) - $start < 0.5, 'other date was blocked');
    flock($lock, LOCK_UN); fclose($lock);
});

check('five occupied slots defer networking and preserve cache', function () use ($base, $snapshot) {
    $r = fixture($base, 'capacity', $snapshot, true);
    mkdir("$r/cache/web-requests");
    $locks = [];
    for ($i=0; $i<5; $i++) {
        $lock=fopen("$r/cache/web-requests/slot-$i.lock", 'c');
        flock($lock, LOCK_EX); $locks[]=$lock;
    }
    [$status,$body]=tipoffSchedule($r,'nba','2026-11-06','America/Denver');
    expect($status===200 && $body['refreshing'] && $body['snapshot']===$snapshot,'capacity lost saved data');
    expect(!file_exists("$r/refreshes"),'capacity exceeded');
    foreach ($locks as $lock) fclose($lock);
});
check('child holds both date and global slot until finished', function () use ($base) {
    $r=fixture($base,'inherited',null,false);
    tipoffSchedule($r,'nba','2026-11-06','America/Denver');
    $key=hash('sha256',"nba\n2026-11-06\nAmerica/Denver");
    foreach (["$key.lock",'slot-0.lock'] as $name) {
        $lock=fopen("$r/cache/web-requests/$name",'c');
        expect(!flock($lock,LOCK_EX|LOCK_NB),'child lost inherited lock'); fclose($lock);
    }
    usleep(1000000);
    $lock=fopen("$r/cache/web-requests/slot-0.lock",'c');
    expect(flock($lock,LOCK_EX|LOCK_NB),'slot not released'); fclose($lock);
});
check('cleanup removes expired records but retains active jobs', function () use ($base) {
    $jobs="$base/cleanup";mkdir($jobs);
    $old=str_repeat('a',64);$busy=str_repeat('b',64);
    foreach ([$old,$busy] as $key) foreach (['lock','attempt'] as $suffix) touch("$jobs/$key.$suffix",time()-90000);
    $lock=fopen("$jobs/$busy.lock",'r+');flock($lock,LOCK_EX);
    tipoffCleanJobs($jobs);
    expect(!file_exists("$jobs/$old.lock") && !file_exists("$jobs/$old.attempt"),'expired records retained');
    expect(file_exists("$jobs/$busy.lock") && file_exists("$jobs/$busy.attempt"),'active records deleted');
    fclose($lock);
});
echo "$passed tests executed, $passed passed\n";
