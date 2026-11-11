<?php
declare(strict_types=1);

require __DIR__ . '/../../web/accounts/vendor/autoload.php';

use Firebase\JWT\JWT;

function check(string $name, bool $passed): void
{
    global $count;
    if (!$passed) {
        throw new RuntimeException($name . ' failed');
    }
    ++$count;
}

function removeTree(string $path): void
{
    foreach (glob($path . '/*') as $entry) {
        is_dir($entry) ? removeTree($entry) : unlink($entry);
    }
    rmdir($path);
}

$count = 0;
$root = sys_get_temp_dir() . '/tipoff-account-test-' . bin2hex(random_bytes(8));
mkdir($root, 0700);
mkdir($root . '/public', 0700);
mkdir($root . '/data', 0700);
copy(__DIR__ . '/../../web/account.php', $root . '/public/account.php');
$listener = stream_socket_server('tcp://127.0.0.1:0');
$host = stream_socket_get_name($listener, false);
fclose($listener);
$origin = 'http://' . $host;
$config = [
    'client_id' => 'fixture.apps.googleusercontent.com',
    'origins' => [$origin],
    'data_dir' => $root . '/data',
    'secure_cookie' => true,
];
file_put_contents($root . '/config.php', '<?php return ' . var_export($config, true) . ';');

$key = openssl_pkey_new(['private_key_bits' => 2048, 'private_key_type' => OPENSSL_KEYTYPE_RSA]);
$rsa = openssl_pkey_get_details($key)['rsa'];
$base64 = static fn(string $value): string => rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
$keys = ['keys' => [[
    'kty' => 'RSA', 'kid' => 'fixture', 'alg' => 'RS256',
    'n' => $base64($rsa['n']), 'e' => $base64($rsa['e']),
]]];
file_put_contents($root . '/data/google-keys.json', json_encode(['expires' => time() + 300, 'keys' => $keys]));
$process = proc_open(
    [PHP_BINARY, '-S', $host, '-t', $root . '/public'],
    [0 => ['file', '/dev/null', 'r'], 1 => ['file', $root . '/server.log', 'a'], 2 => ['file', $root . '/server.log', 'a']],
    $pipes, null, [
        'TIPOFF_ACCOUNT_BACKEND' => realpath(__DIR__ . '/../../web/accounts'),
        'TIPOFF_ACCOUNT_CONFIG' => $root . '/config.php',
    ],
);
if (!is_resource($process)) {
    removeTree($root);
    throw new RuntimeException('Account server did not start');
}

function request(?string &$cookie, ?array $body = null, ?string $csrf = null, array $overrides = [], bool $signin = false): array
{
    global $origin;
    $headers = [];
    $curl = curl_init($origin . '/account.php' . ($signin ? '?signin=1' : ''));
    curl_setopt_array($curl, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 4,
        CURLOPT_HEADERFUNCTION => static function ($curl, string $line) use (&$headers): int {
            if (str_contains($line, ':')) {
                [$name, $value] = explode(':', $line, 2);
                $headers[strtolower($name)] = trim($value);
            }
            return strlen($line);
        },
    ]);
    if ($cookie !== null) {
        curl_setopt($curl, CURLOPT_COOKIE, $cookie);
    }
    if ($body !== null) {
        $fields = array_replace([
            'Origin' => $origin,
            'Content-Type' => 'application/json',
            'X-Tipoff-CSRF' => $csrf,
        ], $overrides);
        curl_setopt($curl, CURLOPT_HTTPHEADER, array_map(
            static fn($name, $value) => "$name: $value", array_keys($fields), $fields));
        curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($body, JSON_THROW_ON_ERROR));
    }
    $raw = curl_exec($curl);
    $status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
    if (isset($headers['set-cookie'])) {
        $cookie = explode(';', $headers['set-cookie'])[0];
    }
    return [$status, json_decode($raw ?: '{}', true, 16, JSON_THROW_ON_ERROR), $headers];
}

function token(string $subject, string $nonce, array $overrides = []): string
{
    global $key, $config;
    return JWT::encode(array_replace([
        'iss' => 'https://accounts.google.com', 'aud' => $config['client_id'],
        'sub' => $subject, 'nonce' => $nonce, 'iat' => time(), 'exp' => time() + 60,
    ], $overrides), $key, 'RS256', 'fixture');
}

try {
    $alice = $bob = $newBrowser = null;
    for ($attempt = 0; $attempt < 40; ++$attempt) {
        [$status, $anonymous, $headers] = request($alice);
        if ($status !== 0) {
            break;
        }
        usleep(25000);
    }
    check('Anonymous request has no cookie or private data', $status === 200 && $alice === null &&
        $anonymous === ['signedIn' => false, 'preferences' => null] && $headers['cache-control'] === 'private, no-store');
    [, $challenge, $headers] = request($alice, signin: true);
    $firstCookie = $alice;
    $cookie = $headers['set-cookie'];
    check('Cookie is private, scoped, and persists for 30 days', str_contains($cookie, 'Max-Age=2592000') &&
        str_contains($cookie, 'path=/tipoff/account') && str_contains($cookie, 'secure') &&
        str_contains($cookie, 'HttpOnly') && str_contains($cookie, 'SameSite=Lax') &&
        $headers['cache-control'] === 'private, no-store');

    $initial = ['timeZone' => 'America/New_York', 'teams' => ['nba:BOS', 'mlb:COL']];
    $login = ['action' => 'login', 'credential' => token('alice', $challenge['nonce']), 'preferences' => $initial];
    check('Origin protection', request($alice, $login, $challenge['csrf'], ['Origin' => 'https://example.com'])[0] === 403);
    check('CSRF protection', request($alice, $login, 'invalid')[0] === 403);
    check('JSON required', request($alice, $login, $challenge['csrf'], ['Content-Type' => 'text/plain'])[0] === 403);
    foreach ([
        'wrong issuer' => ['iss' => 'https://example.com'],
        'wrong audience' => ['aud' => 'other'],
        'wrong party' => ['azp' => 'other'],
        'wrong nonce' => ['nonce' => 'other'],
        'expired' => ['exp' => time() - 1],
        'future issuance' => ['iat' => time() + 600],
    ] as $name => $overrides) {
        $invalid = array_replace($login, ['credential' => token('alice', $challenge['nonce'], $overrides)]);
        check('Reject ' . $name, request($alice, $invalid, $challenge['csrf'])[0] === 401);
    }
    $invalid = array_replace($login, ['credential' => $login['credential'] . 'invalid']);
    check('Reject invalid signature', request($alice, $invalid, $challenge['csrf'])[0] === 401);
    [$status, $signedIn] = request($alice, $login, $challenge['csrf']);
    check('Login rotates credentials and imports first browser settings', $status === 200 && $alice !== $firstCookie &&
        $signedIn['csrf'] !== $challenge['csrf'] && $signedIn['signedIn'] && $signedIn['preferences'] === $initial);
    check('Returning browser cookie restores preferences', request($alice)[1]['preferences'] === $initial);
    check('Old session cannot access settings', request($firstCookie)[1]['preferences'] === null);

    foreach ([
        ['timeZone' => 'Planet/Mars', 'teams' => []],
        ['timeZone' => '', 'teams' => ['mlb:DEN']],
        ['timeZone' => '', 'teams' => 'nba:BOS'],
    ] as $bad) {
        check('Reject invalid preferences', request($alice, ['action' => 'save', 'preferences' => $bad], $signedIn['csrf'])[0] === 400);
    }
    $changed = ['timeZone' => 'UTC', 'teams' => []];
    $save = ['action' => 'save', 'preferences' => $changed];
    check('Save empty team list and UTC', request($alice, $save, $signedIn['csrf'])[1]['preferences'] === $changed);
    check('A repeated save is safe', request($alice, $save, $signedIn['csrf'])[1]['preferences'] === $changed);
    [, $bobChallenge] = request($bob, signin: true);
    [, $bobState] = request($bob, ['action' => 'login', 'credential' => token('bob', $bobChallenge['nonce'])], $bobChallenge['csrf']);
    check('Accounts are isolated', $bobState['signedIn'] && $bobState['preferences'] === null);
    [, $anotherChallenge] = request($newBrowser, signin: true);
    [, $otherDevice] = request($newBrowser, [
        'action' => 'login', 'credential' => token('alice', $anotherChallenge['nonce']), 'preferences' => $initial,
    ], $anotherChallenge['csrf']);
    check('Second browser restores account settings over guest settings', $otherDevice['preferences'] === $changed);
    $oldCookie = $alice;
    [, $signedOut] = request($alice, ['action' => 'logout'], $signedIn['csrf']);
    check('Logout rotates the session and clears the account view', $alice !== $oldCookie &&
        !$signedOut['signedIn'] && request($oldCookie)[1]['preferences'] === null);
    check('Signed-out writes fail', request($alice, $save, $signedOut['csrf'])[0] === 401);
    [, $challenge] = request($alice, signin: true);
    [, $returned] = request($alice, [
        'action' => 'login', 'credential' => token('alice', $challenge['nonce']),
    ], $challenge['csrf']);
    check('Signing in again restores saved choices', $returned['preferences'] === $changed);

    $sessionFile = $root . '/data/sessions/sess_' . explode('=', $alice, 2)[1];
    file_put_contents($sessionFile, preg_replace('/expires\|i:\d+;/', 'expires|i:1;', file_get_contents($sessionFile)));
    check('Expired server session stops returning private data', request($alice)[1]['preferences'] === null);
    check('An expired session on one browser leaves the other session and choices intact',
        request($newBrowser)[1]['preferences'] === $changed);
    require_once __DIR__ . '/../../web/accounts/preferences.php';
    $worker = <<<'PHP'
        require $argv[1];
        $settings = json_decode($argv[3], true, 16, JSON_THROW_ON_ERROR);
        for ($i = 0; $i < 25; ++$i) {
            accountPreferences($argv[2], 'concurrent', $settings);
            usleep(500);
        }
        PHP;
    $writers = [];
    foreach ([$initial, $changed] as $write) {
        $writers[] = proc_open(
            [PHP_BINARY, '-r', $worker, __DIR__ . '/../../web/accounts/preferences.php',
                $root . '/data', json_encode($write, JSON_THROW_ON_ERROR)],
            [0 => ['file', '/dev/null', 'r'], 1 => STDOUT, 2 => STDERR], $workerPipes,
        );
    }
    $allReadsComplete = true;
    for ($i = 0; $i < 25; ++$i) {
        $current = accountPreferences($root . '/data', 'concurrent');
        $allReadsComplete = $allReadsComplete && in_array($current, [null, $initial, $changed], true);
        usleep(500);
    }
    $writerResults = array_map(static fn($writer) => is_resource($writer) ? proc_close($writer) : -1, $writers);
    check('Concurrent writes always expose a complete settings document', $allReadsComplete &&
        $writerResults === [0, 0] && in_array(accountPreferences($root . '/data', 'concurrent'), [$initial, $changed], true));
    echo "$count account integration scenarios passed on PHP " . PHP_VERSION . PHP_EOL;
} finally {
    proc_terminate($process);
    proc_close($process);
    removeTree($root);
}
