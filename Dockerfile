# -- Etapa 1: Builder (instala dependencias) --
FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /build
COPY requirements.txt .
RUN pip install --target=/deps -r requirements.txt

# -- Etapa 2: Runtime distroless (sin shell, sin apt, usuario non-root) --
FROM gcr.io/distroless/python3-debian12:nonroot

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/deps

WORKDIR /app

COPY --from=builder --chown=65532:65532 /deps /deps
COPY --chown=65532:65532 main.py .

# UID numerico del usuario "nonroot" de distroless
USER 65532:65532

EXPOSE 8000

ENTRYPOINT ["/usr/bin/python3", "-m", "uvicorn"]
CMD ["main:app", "--host", "0.0.0.0", "--port", "8000"]