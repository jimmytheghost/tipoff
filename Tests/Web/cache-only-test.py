"""Run after swift build --product TipoffCheck; no network access is needed."""
import datetime
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

BINARY = str(Path(sys.argv.pop(1) if len(sys.argv) > 1 else '.build/debug/TipoffCheck').resolve())
EPOCH = 978307200

class CachedWebScheduleTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.snapshot = dict(day='2026-11-06', timeZone='America/Denver', source='Fixture', limitedCoverage=False,
                             fetchedAt=datetime.datetime.now(datetime.timezone.utc).timestamp() - EPOCH, games=[])
    def tearDown(self):
        self.temp.cleanup()
    def path(self):
        directory = self.root / 'nba'
        directory.mkdir(exist_ok=True)
        return directory / '2026-11-06-America_Denver.json'
    def run_cached(self, day='2026-11-06', zone='America/Denver'):
        return subprocess.run([BINARY, '--web-cached', 'nba', day, zone, str(self.root)], capture_output=True, timeout=2)
    def write(self):
        self.path().write_text(json.dumps(self.snapshot))
    def test_fresh_cache_is_iso8601_and_read_only(self):
        self.write(); before = self.path().read_bytes()
        result = json.loads(self.run_cached().stdout)
        self.assertFalse(result['saved'])
        self.assertTrue(result['snapshot']['fetchedAt'].endswith('Z'))
        self.assertEqual(self.path().read_bytes(), before)
    def test_stale_cache_retains_freshness(self):
        self.snapshot['fetchedAt'] = 0; self.write()
        result = json.loads(self.run_cached().stdout)
        self.assertTrue(result['saved'])
        self.assertEqual(result['snapshot']['fetchedAt'], '2001-01-01T00:00:00Z')
    def test_missing_cache_is_not_an_empty_schedule(self):
        result = json.loads(self.run_cached().stdout)
        self.assertIsNone(result.get('snapshot'))
        self.assertFalse(result['saved'])
    def test_malformed_cache_is_not_an_empty_schedule(self):
        self.path().write_text('{bad')
        self.assertIsNone(json.loads(self.run_cached().stdout).get('snapshot'))
    def test_wrong_identity_is_rejected(self):
        self.snapshot['timeZone'] = 'America/New_York'; self.write()
        self.assertIsNone(json.loads(self.run_cached().stdout).get('snapshot'))
    def test_unknown_telemetry_is_excluded_and_cache_unchanged(self):
        self.snapshot['score'] = 100; self.write(); before = self.path().read_bytes()
        result = self.run_cached()
        self.assertNotIn(b'score', result.stdout)
        self.assertEqual(self.path().read_bytes(), before)
    def test_invalid_day_is_rejected(self):
        self.assertNotEqual(self.run_cached(day='2026-02-30').returncode, 0)

if __name__ == '__main__':
    unittest.main()
