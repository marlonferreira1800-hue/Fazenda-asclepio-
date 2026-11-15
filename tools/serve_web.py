"""Serve the exported Godot HTML5 build with proper WebAssembly MIME types."""

from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import sys


class GodotWebHandler(SimpleHTTPRequestHandler):
    extensions_map = {
        **SimpleHTTPRequestHandler.extensions_map,
        ".wasm": "application/wasm",
        ".js": "application/javascript",
        ".pck": "application/octet-stream",
    }

    def end_headers(self) -> None:
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


def main() -> None:
    web_dir = Path(__file__).resolve().parent.parent / "build" / "web"
    for port in range(8060, 8070):
        try:
            handler = partial(GodotWebHandler, directory=str(web_dir))
            server = ThreadingHTTPServer(("127.0.0.1", port), handler)
            print(f"SERVING_URL=http://127.0.0.1:{port}/", flush=True)
            server.serve_forever()
            return
        except OSError:
            continue
    print("ERROR=No free port found in 8060..8069", file=sys.stderr, flush=True)
    sys.exit(1)


if __name__ == "__main__":
    main()
