# -- Etapa 1: Builder --
# Misma base Debian 12 / Python 3.11 que la imagen distroless final,
# para que las dependencias compiladas sean compatibles.
FROM python:3.11-slim-bookworm AS builder

ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /build
COPY requirements.txt .
# Se instalan en un directorio aislado (no en un venv) porque en distroless
# solo hay que copiar archivos: un venv apunta al python de la etapa builder.
RUN pip install --target=/deps -r requirements.txt

# -- Etapa 2: Runtime (distroless, non-root) --
# La variante :nonroot ejecuta como UID/GID 65532, el mismo que declara
# securityContext en k8s/deployment.yaml (runAsUser: 65532).
FROM gcr.io/distroless/python3-debian12:nonroot

ENV PYTHONPATH=/deps \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY --from=builder --chown=65532:65532 /deps /deps
COPY --chown=65532:65532 main.py .

USER 65532:65532
EXPOSE 8000

# El ENTRYPOINT de la imagen base ya es el intérprete de Python.
# No hay HEALTHCHECK: distroless no trae curl y Kubernetes usa sus propios probes.
CMD ["-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
