"""Canonical/legacy route checks without contacting schedule sources."""
import http.client
import importlib.util
import json
from pathlib import Path
from threading import Thread
from http.server import ThreadingHTTPServer

root = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('tipoff_preview', root / 'web/preview.py')
preview = importlib.util.module_from_spec(spec)
spec.loader.exec_module(preview)

class Routes(preview.Preview):
    def schedule(self, query):
        self.reply(json.dumps(query).encode(), 'application/json')
    def log_message(self, *_args):
        pass

server = ThreadingHTTPServer(('127.0.0.1', 0), Routes)
thread = Thread(target=server.serve_forever, daemon=True)
thread.start()
count = 0

def get(path):
    global count
    connection = http.client.HTTPConnection('127.0.0.1', server.server_port, timeout=5)
    connection.request('GET', path)
    response = connection.getresponse()
    result = response.status, dict(response.getheaders()), response.read()
    connection.close()
    count += 1
    return result

try:
    status, headers, body = get('/tipoff')
    assert status == 200
    assert b'rel="canonical" href="https://www.jimmyweber.com/tipoff"' in body
    assert b'property="og:url" content="https://www.jimmyweber.com/tipoff"' in body
    assert b'href="/tipoff"' in body and b'src="/tipoff/guide.js?' in body
    for path in ['/tipoff/', '/tip-off', '/tip-off/', '/sports', '/sports/', '/tip-off.html', '/tip-off?ref=legacy']:
        status, headers, _ = get(path)
        assert status == 308, path
        assert headers['Location'] == ('/tipoff?ref=legacy' if '?' in path else '/tipoff'), path
    for prefix in ['/tipoff', '/tip-off']:
        status, headers, body = get(prefix + '/guide.css?v=check')
        assert status == 200 and headers['Content-Type'] == 'text/css'
        assert b'.tipoff-brand' in body
        status, headers, body = get(prefix + '/guide.js?v=check')
        assert status == 200 and b'/tipoff/schedule?' in body
        status, headers, body = get(prefix + '/schedule?sport=nhl&day=2026-11-17&zone=America%2FDenver')
        assert status == 200 and headers['Content-Type'] == 'application/json'
        assert json.loads(body) == {'sport':['nhl'], 'day':['2026-11-17'], 'zone':['America/Denver']}
    status, _, body = get('/pages/projects/tipoff/')
    assert status == 200 and b'href="/tipoff"' in body
    for name in ('Tomorrow-Regular', 'Tomorrow-Medium', 'Tomorrow-SemiBold', 'Tomorrow-Bold'):
        status, _, body = get(f'/assets/fonts/tipoff/{name}.ttf')
        assert status == 200 and body.startswith(bytes((0, 1, 0, 0))), name
    status, _, body = get('/assets/fonts/tipoff/BarlowCondensed-ExtraBoldItalic.woff2')
    assert status == 200 and body.startswith(b'wOF2')
    status, _, body = get('/tipoff/settings.js')
    assert status == 200 and b'/tipoff/account' in body
    status, headers, body = get('/tipoff/teams.json')
    assert status == 200 and headers['Content-Type'] == 'application/json'
    assert {league: len(teams) for league, teams in json.loads(body).items()} == {
        'nba': 30, 'nfl': 32, 'wnba': 15, 'nhl': 32, 'mlb': 30}
    columns = {
        'nba': {'Eastern Conference': 15, 'Western Conference': 15},
        'nfl': {'AFC': 16, 'NFC': 16},
        'wnba': {'Eastern Conference': 7, 'Western Conference': 8},
        'nhl': {'Eastern Conference': 16, 'Western Conference': 16},
        'mlb': {'American League': 15, 'National League': 15},
    }
    for league, teams in json.loads(body).items():
        assert len({team['id'] for team in teams}) == len(teams)
        assert {group: sum(team['group'] == group for team in teams) for group in columns[league]} == columns[league]
    status, headers, body = get('/tipoff/time-zones.json')
    zones = json.loads(body)
    assert status == 200 and headers['Content-Type'] == 'application/json'
    north_america = {entry['zone']: entry for entry in zones['United States, Canada & Mexico']}
    assert 'America/Toronto' in north_america['America/New_York']['zones']
    assert 'America/Detroit' in north_america['America/New_York']['zones']
    assert 'America/Phoenix' not in north_america['America/Denver']['zones']
    assert 'America/Mexico_City' in north_america
    europe = {entry['zone']: entry for entry in zones['Europe']}
    assert {'Europe/Berlin', 'Europe/Rome'} <= set(europe['Europe/Paris']['zones'])
    status, _, body = get('/tipoff/privacy')
    assert status == 200 and b'content="https://www.jimmyweber.com/tipoff/privacy"' in body
    assert get('/tipoff/account')[0] == 503
    assert get('/tipoff/unknown')[0] == 404
finally:
    server.shutdown()
    server.server_close()
    thread.join()
print(f'{count} local canonical/legacy route checks passed')
