<?php
declare(strict_types=1);

function validatePreferences(mixed $value): array
{
    $zone = $value['timeZone'] ?? null;
    $teams = $value['teams'] ?? null;
    if (!is_string($zone) || ($zone !== '' && !in_array(
        $zone, DateTimeZone::listIdentifiers(DateTimeZone::ALL_WITH_BC), true
    )) || !is_array($teams) || !array_is_list($teams)) {
        throw new InvalidArgumentException('Choose a supported time zone and teams.');
    }
    $catalog = json_decode(file_get_contents(__DIR__ . '/teams.json'), true, 16, JSON_THROW_ON_ERROR);
    $known = [];
    foreach ($catalog as $league => $clubs) {
        foreach ($clubs as $club) {
            $known[$league . ':' . $club['id']] = true;
        }
    }
    foreach ($teams as $team) {
        if (!is_string($team) || !isset($known[$team])) {
            throw new InvalidArgumentException('Choose teams from the list.');
        }
    }
    return ['timeZone' => $zone, 'teams' => array_values(array_unique($teams))];
}

function accountPreferences(string $directory, string $subject, ?array $write = null, bool $firstOnly = false): ?array
{
    $path = $directory . '/preferences-' . hash('sha256', $subject) . '.json';
    if ($write === null) {
        return is_file($path) ? json_decode(file_get_contents($path), true, 16, JSON_THROW_ON_ERROR) : null;
    }
    $lock = fopen($path . '.lock', 'c');
    if (!$lock) {
        throw new RuntimeException('Preferences unavailable');
    }
    $temporary = null;
    try {
        if (!flock($lock, LOCK_EX)) {
            throw new RuntimeException('Preferences unavailable');
        }
        if ($firstOnly && is_file($path)) {
            return json_decode(file_get_contents($path), true, 16, JSON_THROW_ON_ERROR);
        }
        $temporary = tempnam($directory, 'preferences-');
        if ($temporary === false ||
            file_put_contents($temporary, json_encode($write, JSON_THROW_ON_ERROR)) === false ||
            !rename($temporary, $path)) {
            throw new RuntimeException('Preferences unavailable');
        }
        return $write;
    } finally {
        if ($temporary && is_file($temporary)) {
            unlink($temporary);
        }
        fclose($lock);
    }
}
