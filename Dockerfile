FROM python:3.12-slim

# Install shared library
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget libgomp1 && \
    wget -O /usr/lib/librkllmrt.so https://raw.githubusercontent.com/airockchip/rknn-llm/release-v1.2.3/rkllm-runtime/Linux/librkllm_api/aarch64/librkllmrt.so &&\
    chmod +x /usr/lib/librkllmrt.so && \
    wget -O /usr/lib/librknnrt.so https://raw.githubusercontent.com/airockchip/rknn-toolkit2/v2.3.2/rknpu2/runtime/Linux/librknn_api/aarch64/librknnrt.so &&\
    chmod +x /usr/lib/librknnrt.so && \
    apt-get purge -y wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
# RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
RUN pip install --upgrade pip && \
    pip install flask flask-cors gunicorn numpy Pillow

# Install RKLLM-API-Server
COPY ./api.py /app/
WORKDIR /app
VOLUME /root/models
EXPOSE 8000

ENV RKLLM_LOG_LEVEL=1
ENV RKLLM_API_LOG_LEVEL=INFO
ENV GUNICORN_BIND=0.0.0.0:8000

# Configure Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import os, urllib.request, sys; \
    bind = os.environ.get('GUNICORN_BIND', '0.0.0.0:8000'); \
    host, port = bind.split(':'); \
    host = '127.0.0.1' if host == '0.0.0.0' else host; \
    url = f'http://{host}:{port}/v1/models'; \
    try: \
        urllib.request.urlopen(url, timeout=3); \
        sys.exit(0); \
    except Exception: \
        sys.exit(1)"

CMD ["gunicorn","-c","gunicorn.config.py","api:app"]
