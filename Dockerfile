FROM python:3.10-slim AS base

ENV PATH "/opt/venv/bin:$PATH"
ENV PYTHONUNBUFFERED True
ENV PYTHONDONTWRITEBYTECODE True
ENV PYTHONPATH app

FROM base AS builder
RUN python -m venv /opt/venv
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip -r requirements.txt

FROM base
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
COPY main.py .

RUN apt-get update && apt-get install --yes --no-install-recommends libjemalloc2

ARG PORT=8000
ENV PORT $PORT
EXPOSE $PORT

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app