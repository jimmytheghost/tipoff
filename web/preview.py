"""Loopback-only Tipoff preview server."""
import datetime
import mimetypes
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
    "/tip-off": "index.html",
    "/tip-off/guide.js": "guide.js",
    "/tip-off/guide.css": "guide.css",
    "/pages/projects/tipoff/": "portfolio-preview.html",
}


class Preview(BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlsplit(self.path)
        if url.path in {"/", "/sports", "/sports/", "/tip-off/"}:
            self.send_response(308)
            self.send_header("Location", "/tip-off")
            self.end_headers()
        elif url.path == "/tip-off/schedule":
            self.schedule(parse_qs(url.query))
        elif url.path in PAGE_ASSETS:
            self.file(WEB / PAGE_ASSETS[url.path])
        else:
            self.send_error(404)

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
        print(f"Local: http://127.0.0.1:{server.server_port}/tip-off", flush=True)
        server.serve_forever()
