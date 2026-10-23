# Serves the logo render page and saves the PNG it POSTs into design/logo/out/.
#   python3 design/logo/render_server.py   then open http://localhost:8765/logo.html
import http.server
import os
import re
import sys
from urllib.parse import parse_qs, urlparse

ROOT = os.path.dirname(os.path.abspath(__file__))
FONT = os.environ.get("LOGO_FONT", "/System/Library/Fonts/Supplemental/Arial Rounded Bold.ttf")
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8765


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def do_GET(self):
        if urlparse(self.path).path == "/font.ttf":
            with open(FONT, "rb") as f:
                data = f.read()
            self.send_response(200)
            self.send_header("Content-Type", "font/ttf")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
        else:
            super().do_GET()

    def do_POST(self):
        name = parse_qs(urlparse(self.path).query).get("name", ["render.png"])[0]
        if not re.fullmatch(r"[\w.-]+\.png", name):
            self.send_error(400, "bad file name")
            return
        os.makedirs(os.path.join(ROOT, "out"), exist_ok=True)
        data = self.rfile.read(int(self.headers["Content-Length"]))
        with open(os.path.join(ROOT, "out", name), "wb") as f:
            f.write(data)
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"saved")


print(f"Logo renderer on http://localhost:{PORT}/logo.html")
http.server.ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
