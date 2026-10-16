## Contenedorización (S07 · Martín Durán)

**Imagen:** `ghcr.io/guffy0921/meditriage`

- Dockerfile multi-stage: etapa builder (`python:3.11-slim`) y etapa final `distroless/python3-debian12:nonroot`.
- Corre como usuario non-root (UID 65532), sin shell ni gestor de paquetes.
- Dependencias fijadas en `requirements.txt`; solo se copia `main.py` a la imagen final.
- Probes de Kubernetes sobre `GET /health`; `GET /load` se usa solo para probar el HPA.

**Construcción y publicación**

```bash
docker build -t ghcr.io/guffy0921/meditriage:0.3.0 .
docker run --rm -p 8000:8000 ghcr.io/guffy0921/meditriage:0.3.0
docker push ghcr.io/guffy0921/meditriage:0.3.0
```

**Digest para los manifiestos (nunca `:latest`):**

```
ghcr.io/guffy0921/meditriage@sha256:d3b51ad156d797748185190428748c9fa38744bc96ec5a935f542eeb69624350
```

**Limitaciones:** estado en memoria por pod, autenticación Bearer simulada y `/load` solo para la demo del HPA.
