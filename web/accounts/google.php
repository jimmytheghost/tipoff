<?php
declare(strict_types=1);

use Firebase\JWT\JWK;
use Firebase\JWT\JWT;

function verifyGoogleIdentity(string $token, string $clientId, string $nonce, array $keys): string
{
    $rsa = array_filter($keys['keys'] ?? [], static fn(array $key) =>
        ($key['kty'] ?? '') === 'RSA' && ($key['alg'] ?? 'RS256') === 'RS256');
    $claims = JWT::decode($token, JWK::parseKeySet(['keys' => $rsa], 'RS256'));
    if (!in_array($claims->iss ?? '', ['accounts.google.com', 'https://accounts.google.com'], true) ||
        ($claims->aud ?? '') !== $clientId ||
        (isset($claims->azp) && $claims->azp !== $clientId) ||
        !is_int($claims->iat ?? null) || $claims->iat > time() ||
        !is_int($claims->exp ?? null) || $claims->exp <= time() ||
        !is_string($claims->sub ?? null) || !preg_match('/^[A-Za-z0-9_-]{1,255}$/D', $claims->sub) ||
        !is_string($claims->nonce ?? null) || !hash_equals($nonce, $claims->nonce)) {
        throw new UnexpectedValueException('Invalid Google identity');
    }
    return $claims->sub;
}

function googleKeys(string $directory): array
{
    $file = $directory . '/google-keys.json';
    $lock = fopen($directory . '/google-keys.lock', 'c');
    if (!$lock) {
        throw new RuntimeException('Google sign-in unavailable');
    }
    try {
        if (!flock($lock, LOCK_EX)) {
            throw new RuntimeException('Google sign-in unavailable');
        }
        $cached = is_file($file) ? json_decode(file_get_contents($file), true) : null;
        if (($cached['expires'] ?? 0) > time() && !empty($cached['keys']['keys'])) {
            return $cached['keys'];
        }
        $curl = curl_init('https://www.googleapis.com/oauth2/v3/certs');
        $maxAge = 300;
        curl_setopt_array($curl, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_TIMEOUT => 10,
            CURLOPT_HEADERFUNCTION => static function ($curl, string $header) use (&$maxAge): int {
                if (preg_match('/^cache-control:.*max-age=(\d+)/i', $header, $match)) {
                    $maxAge = min(86400, (int) $match[1]);
                }
                return strlen($header);
            },
        ]);
        $body = curl_exec($curl);
        $status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
        curl_close($curl);
        if ($body === false || $status !== 200) {
            throw new RuntimeException('Google sign-in unavailable');
        }
        $keys = json_decode($body, true, 16, JSON_THROW_ON_ERROR);
        if (empty($keys['keys']) ||
            file_put_contents($file, json_encode(['expires' => time() + $maxAge, 'keys' => $keys],
                JSON_THROW_ON_ERROR)) === false) {
            throw new RuntimeException('Google sign-in unavailable');
        }
        return $keys;
    } finally {
        fclose($lock);
    }
}
