"""Loopback-only Tipoff preview server."""
import datetime
from http.client import HTTPConnection
import mimetypes
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import re
import subprocess
import sys
from threading import Lock
from urllib.parse import parse_qs, urlsplit

WEB = Path(__file__).resolve().parent
CACHE = WEB.parent / ".build" / "web-cache"
LOCKS = {sport: Lock() for sport in ("nba", "nfl", "wnba", "nhl", "mlb")}
PAGE_ASSETS = {
    "/tipoff": "index.html",
    "/tipoff/guide.js": "guide.js",
    "/tipoff/guide.css": "guide.css",
    "/tipoff/settings.js": "settings.js",
    "/tipoff/teams.json": "accounts/teams.json",
    "/tipoff/privacy": "privacy.html",
    "/tip-off/guide.js": "guide.js",
    "/tip-off/guide.css": "guide.css",
    "/assets/img/projects/tipoff-header-mark.png": "brand-mark.png",
    "/assets/img/projects/tipoff-favicon.svg": "favicon.svg",
    "/assets/img/projects/tipoff-home-mark.svg": "home-mark.svg",
    "/pages/projects/tipoff/": "portfolio-preview.html",
    **{
        f"/assets/fonts/tipoff/{name}": f"fonts/{name}"
        for name in (
            "Tomorrow-Regular.ttf",
            "Tomorrow-Medium.ttf",
            "Tomorrow-SemiBold.ttf",
            "Tomorrow-Bold.ttf",
            "Tomorrow-OFL.txt",
            "BarlowCondensed-ExtraBoldItalic.woff2",
            "BarlowCondensed-OFL.txt",
        )
    },
}


class Preview(BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlsplit(self.path)
        if url.path in {"/", "/sports", "/sports/", "/tip-off", "/tip-off/", "/tip-off.html", "/tipoff/"}:
            self.send_response(308)
            self.send_header("Location", "/tipoff" + ("?" + url.query if url.query else ""))
            self.end_headers()
        elif url.path in {"/tipoff/schedule", "/tip-off/schedule"}:
            self.schedule(parse_qs(url.query))
        elif url.path == "/tipoff/account":
            self.account(url.query)
        elif url.path in PAGE_ASSETS:
            self.file(WEB / PAGE_ASSETS[url.path])
        else:
            self.send_error(404)

    def do_POST(self):
        url = urlsplit(self.path)
        if url.path == "/tipoff/account":
            self.account(url.query)
        else:
            self.send_error(404)

    def account(self, query):
        port = os.environ.get("TIPOFF_ACCOUNT_PREVIEW_PORT", "")
        if not port.isdecimal() or not 1 <= int(port) <= 65535:
            self.send_error(503, "Google sign-in is unavailable")
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            length = -1
        if not 0 <= length <= 16384:
            self.send_error(413)
            return
        headers = {key: self.headers[key] for key in
                   ("Origin", "Cookie", "Content-Type", "X-Tipoff-CSRF", "Sec-Fetch-Site")
                   if key in self.headers}
        connection = HTTPConnection("127.0.0.1", int(port), timeout=12)
        try:
            connection.request(self.command, "/account.php" + ("?" + query if query else ""),
                               self.rfile.read(length), headers)
            response = connection.getresponse()
            body = response.read()
            self.send_response(response.status)
            for key, value in response.getheaders():
                if key.lower() in {"content-type", "cache-control", "set-cookie", "x-content-type-options"}:
                    self.send_header(key, value)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        except (BrokenPipeError, ConnectionResetError):
            pass
        except OSError:
            self.send_error(503, "Google sign-in is unavailable")
        finally:
            connection.close()

    def reply(self, content, media_type):
        self.send_response(200)
        self.send_header("Content-Type", media_type)
        self.send_header("Content-Length", str(len(content)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        try:
            self.wfile.write(content)
        except (BrokenPipeError, ConnectionResetError):
            pass

    def file(self, path):
        if not path.is_file():
            self.send_error(404)
            return
        self.reply(path.read_bytes(), mimetypes.guess_type(path)[0])

    def schedule(self, query):
        try:
            sport, day, zone = (query[key][0] for key in ("sport", "day", "zone"))
            if sport not in LOCKS or datetime.date.fromisoformat(day).isoformat() != day:
                raise ValueError
            if not re.fullmatch(r"[A-Za-z0-9_+/-]{1,64}", zone):
                raise ValueError
        except (KeyError, ValueError):
            self.send_error(400, "Invalid schedule request")
            return

        with LOCKS[sport]:
            try:
                result = subprocess.run(
                    [BINARY, "--web", sport, day, zone, str(CACHE)],
                    capture_output=True, check=True, timeout=180,
                )
            except subprocess.CalledProcessError:
                self.send_error(400, "Invalid schedule request")
                return
            except subprocess.TimeoutExpired:
                self.send_error(504, "Schedule request timed out")
                return
        self.reply(result.stdout, "application/json")


if __name__ == "__main__":
    BINARY, port = sys.argv[1:]
    with ThreadingHTTPServer(("127.0.0.1", int(port)), Preview) as server:
        print(f"Local: http://127.0.0.1:{server.server_port}/tipoff", flush=True)
        server.serve_forever()
