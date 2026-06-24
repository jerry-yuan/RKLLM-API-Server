import os
import sys
import urllib.request

def main():
    bind = os.environ.get('GUNICORN_BIND', '0.0.0.0:8000')
    host, port = bind.split(':')
    if host == '0.0.0.0':
        host = '127.0.0.1'
    url = f'http://{host}:{port}/v1/models'
    try:
        urllib.request.urlopen(url, timeout=3)
        sys.exit(0)
    except Exception:
        sys.exit(1)

if __name__ == '__main__':
    main()