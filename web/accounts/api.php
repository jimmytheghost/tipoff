<?php
declare(strict_types=1);

require_once __DIR__ . '/preferences.php';
require_once __DIR__ . '/google.php';

const SESSION_LIFETIME = 30 * 24 * 60 * 60;

function reply(array $body, int $status = 200): never
{
    http_response_code($status);
    echo json_encode($body, JSON_THROW_ON_ERROR);
    exit;
}

function renewSession(?string $subject = null): void
{
    if (!session_regenerate_id(true)) {
        throw new RuntimeException('Session unavailable');
    }
    $_SESSION = [
        'csrf' => bin2hex(random_bytes(32)),
        'nonce' => bin2hex(random_bytes(32)),
    ];
    if ($subject !== null) {
        $_SESSION['subject'] = $subject;
        $_SESSION['expires'] = time() + SESSION_LIFETIME;
    }
}

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: private, no-store');
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: same-origin');
header_remove('Access-Control-Allow-Origin');
header_remove('Access-Control-Allow-Credentials');

try {
    $configFile = getenv('TIPOFF_ACCOUNT_CONFIG') ?: __DIR__ . '/config.php';
    if (!is_file($configFile) || !is_file(__DIR__ . '/vendor/autoload.php')) {
        reply(['error' => 'Google sign-in is unavailable.'], 503);
    }
    $config = require $configFile;
    $method = $_SERVER['REQUEST_METHOD'];
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    if (($origin !== '' && !in_array($origin, $config['origins'], true)) ||
        ($_SERVER['HTTP_SEC_FETCH_SITE'] ?? '') === 'cross-site') {
        reply(['error' => 'Refresh the page and try again.'], 403);
    }
    if ($method !== 'GET' && $method !== 'POST') {
        header('Allow: GET, POST');
        reply(['error' => 'Method not allowed.'], 405);
    }
    if ($method === 'POST' && ($origin === '' || strtolower(trim(explode(';',
        $_SERVER['CONTENT_TYPE'] ?? '')[0])) !== 'application/json')) {
        reply(['error' => 'Refresh the page and try again.'], 403);
    }
    if ($method === 'GET' && !isset($_COOKIE['tipoff_session']) && !isset($_GET['signin'])) {
        reply(['signedIn' => false, 'preferences' => null]);
    }

    umask(0077);
    $directory = realpath($config['data_dir']);
    $public = realpath($_SERVER['DOCUMENT_ROOT']);
    if (!$directory || !$public || $directory === $public ||
        str_starts_with($directory, $public . DIRECTORY_SEPARATOR)) {
        throw new RuntimeException('Private storage unavailable');
    }
    $sessions = $directory . '/sessions';
    if (!is_dir($sessions) && !@mkdir($sessions, 0700) && !is_dir($sessions)) {
        throw new RuntimeException('Sessions unavailable');
    }
    ini_set('session.use_strict_mode', '1');
    ini_set('session.use_only_cookies', '1');
    ini_set('session.gc_maxlifetime', (string) SESSION_LIFETIME);
    session_save_path($sessions);
    session_cache_limiter('');
    session_name('tipoff_session');
    session_set_cookie_params([
        'lifetime' => SESSION_LIFETIME,
        'path' => '/tipoff/account',
        'secure' => $config['secure_cookie'],
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    if (!session_start()) {
        throw new RuntimeException('Session unavailable');
    }
    if (isset($_SESSION['subject']) && ($_SESSION['expires'] ?? 0) <= time()) {
        renewSession();
    }
    $_SESSION['csrf'] ??= bin2hex(random_bytes(32));
    $_SESSION['nonce'] ??= bin2hex(random_bytes(32));

    if ($method === 'POST') {
        if (!hash_equals($_SESSION['csrf'], $_SERVER['HTTP_X_TIPOFF_CSRF'] ?? '')) {
            reply(['error' => 'Refresh the page and try again.'], 403);
        }
        $raw = file_get_contents('php://input', false, null, 0, 16385);
        if (strlen($raw) > 16384) {
            reply(['error' => 'Request too large.'], 413);
        }
        try {
            $body = json_decode($raw, true, 16, JSON_THROW_ON_ERROR);
        } catch (JsonException) {
            reply(['error' => 'Invalid request.'], 400);
        }
        $action = $body['action'] ?? null;
        if ($action === 'login') {
            if (isset($_SESSION['subject'])) {
                reply(['error' => 'Sign out before switching accounts.'], 409);
            }
            $attempts = array_filter($_SESSION['attempts'] ?? [], static fn(int $time) => $time > time() - 60);
            if (count($attempts) >= 10) {
                reply(['error' => 'Wait a minute before trying sign-in again.'], 429);
            }
            $_SESSION['attempts'] = [...$attempts, time()];
            require_once __DIR__ . '/vendor/autoload.php';
            try {
                $token = $body['credential'] ?? null;
                if (!is_string($token) || strlen($token) > 12000 || substr_count($token, '.') !== 2) {
                    throw new UnexpectedValueException('Invalid credential');
                }
                $subject = verifyGoogleIdentity($token, $config['client_id'], $_SESSION['nonce'], googleKeys($directory));
            } catch (UnexpectedValueException | DomainException | InvalidArgumentException) {
                reply(['error' => 'Google sign-in could not be verified.'], 401);
            }
            if (isset($body['preferences'])) {
                accountPreferences($directory, $subject, validatePreferences($body['preferences']), true);
            }
            renewSession($subject);
        } elseif ($action === 'logout') {
            renewSession();
        } elseif ($action === 'save') {
            if (!isset($_SESSION['subject'])) {
                reply(['error' => 'Sign in again to save to your account.'], 401);
            }
            accountPreferences($directory, $_SESSION['subject'], validatePreferences($body['preferences'] ?? null));
        } else {
            reply(['error' => 'Invalid request.'], 400);
        }
    }

    $subject = $_SESSION['subject'] ?? null;
    reply([
        'signedIn' => $subject !== null,
        'preferences' => $subject !== null ? accountPreferences($directory, $subject) : null,
        'csrf' => $_SESSION['csrf'],
        ...($subject === null && isset($_GET['signin'])
            ? ['nonce' => $_SESSION['nonce'], 'clientId' => $config['client_id']]
            : []),
    ]);
} catch (InvalidArgumentException $error) {
    reply(['error' => $error->getMessage()], 400);
} catch (Throwable $error) {
    error_log('Tipoff account request failed: ' . get_class($error));
    reply(['error' => 'Tipoff accounts are temporarily unavailable.'], 503);
}
