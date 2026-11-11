<?php
declare(strict_types=1);

// The production deployment installs only this entry point under the web root.
$backend = getenv('TIPOFF_ACCOUNT_BACKEND') ?: '/var/www/tipoff-private/accounts';
$directory = realpath($backend);
$public = realpath($_SERVER['DOCUMENT_ROOT'] ?? '');
if (!$directory || !$public || $directory === $public ||
    str_starts_with($directory, $public . DIRECTORY_SEPARATOR) ||
    !is_file($directory . '/api.php')) {
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: private, no-store');
    http_response_code(503);
    echo '{"error":"Google sign-in is unavailable."}';
    exit;
}
require $directory . '/api.php';
