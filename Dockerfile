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
RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
RUN pip install --upgrade pip && \
    pip install flask flask-cors gunicorn numpy Pillow

COPY ./api.py /app/
WORKDIR /app
VOLUME /root/models
CMD ["gunicorn","-w","1","-k","gthread","--threads","4","--timeout","300","-b","0.0.0.0:8000","--access-logfile","-","--error-logfile","-","api:app"]
