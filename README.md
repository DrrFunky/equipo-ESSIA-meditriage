## Descripción

> **MediTriage** es un sistema de apoyo a la priorización clínica en servicios de urgencia. Un motor de IA sugiere la categoría **ESI (1 a 5)** a partir de síntomas y signos vitales, con una justificación legible, y la enfermera de triage siempre confirma o corrige la sugerencia. La IA asiste y no reemplaza al personal de salud.

**Principios del proyecto** (del `CHARTER.md`):
- La IA no es una caja negra: cada sugerencia ESI incluye su justificación.
- Cumplimiento de las leyes chilenas 19.628 y 21.719: consentimiento informado, PII enmascarada en logs y cifrado en tránsito y en reposo.
- Registro de auditoría inmutable, con marca de tiempo, conservado 5 años.
- Objetivos: latencia de inferencia < 3 s (p95) y SLA de 99,5 %.
- Si la IA falla, el personal puede seguir el triage de forma manual.

## Equipo

| Integrante | Rol |
|---|---|
| Martín Garrido | Product Owner |
| Cristóbal Araos | Tech Lead |
| Martín Durán | DevSecOps & Compliance Lead |
| Alonso Plane | QA & Architecture Lead |

## Stack

- **API:** Python 3.11, FastAPI, Uvicorn, Pydantic
- **Contenedor:** Docker multi-stage, imagen final distroless non-root (UID 65532), publicada en GHCR
- **Orquestación:** Kubernetes (Deployment, Service, Ingress, ConfigMap, HPA) con Kustomize
- **IaC:** Terraform (provider de Kubernetes, estado en el backend `kubernetes`)
- **Contrato de API:** OpenAPI 3.1 (`api/openapi.yaml`)

## Estructura del repositorio

```
.
├── main.py                 # API FastAPI mínima (S07)
├── Dockerfile              # multi-stage, distroless, non-root
├── requirements.txt
├── api/                    # contrato OpenAPI, ejemplos y política de versionado
├── k8s/                    # manifiestos de Kubernetes (+ README con evidencias)
├── terraform/              # namespace y backend de estado
├── docs/
│   ├── adr/                # decisiones de arquitectura (0001 a 0005)
│   ├── arch/               # atributos de calidad, servicios gestionados, trazabilidad
│   ├── c4/                 # diagramas C4 (contexto y contenedores)
│   ├── data/               # contextos acotados, DER, catálogo de eventos
│   ├── scenarios/          # historias de usuario en Gherkin (US01 a US05)
│   ├── backlog.md
│   ├── impact-map.md
│   └── 12-factor-checklist.md
└── CHARTER.md              # misión, roles, DoD y política de IA
```

## Endpoints de la API

| Método | Ruta | Para qué |
|---|---|---|
| POST | `/patients` | Registrar paciente (valida RUT y consentimiento) |
| POST | `/triage-evaluations` | Solicitar una evaluación ESI sugerida |
| PATCH | `/triage-evaluations/{id}` | Confirmar o corregir manualmente |
| GET | `/triage-board` | Tablero priorizado (ESI 1 primero) |
| GET | `/audit-logs` | Registro de auditoría |
| GET | `/health` | Probe de Kubernetes (sin auth) |
| GET | `/load` | Genera carga para probar el HPA (solo demo) |

Las rutas de negocio requieren token Bearer (simulado en esta entrega).

## Cómo correrlo

**Local con Docker**
```bash
docker build -t ghcr.io/guffy0921/meditriage:0.3.0 .
docker run --rm -p 8000:8000 ghcr.io/guffy0921/meditriage:0.3.0
curl http://localhost:8000/health
```
La documentación interactiva queda en `http://localhost:8000/docs`.

**En Kubernetes (clúster local de Docker Desktop)**
```bash
cd terraform && terraform init && terraform apply   # crea el namespace "meditriage"
cd ..
kubectl apply -k k8s/
kubectl get all,ingress,configmap -n meditriage
```
Requiere `metrics-server` para que funcione el HPA.

**Imagen publicada (fijada por digest, nunca `:latest`)**
```
ghcr.io/guffy0921/meditriage@sha256:d3b51ad156d797748185190428748c9fa38744bc96ec5a935f542eeb69624350
```

## Enlaces a ADRs

| ADR | Tema |
|---|---|
| [0001](docs/adr/0001-eleccion-iniciativa.md) | Elección de la iniciativa MediTriage |
| [0002](docs/adr/0002-estilo-arquitectonico.md) | Estilo arquitectónico (monolito modular) |
| [0003](docs/adr/0003-cloud-style.md) | Estilo cloud y servicios gestionados (AWS) |
| [0004](docs/adr/0004-datos-y-eventos.md) | Datos y eventos |
| [0005](docs/adr/0005-plataforma-k8s.md) | Contenedores, Kubernetes y Terraform |

Nota para Alonso: la rúbrica menciona `0004-plataforma-k8s.md`, pero ese número ya estaba ocupado por el ADR de datos y eventos, por eso la plataforma quedó como 0005.

## Evidencias (S07)

- Capturas de `kubectl get all` y de la prueba del HPA: [`k8s/README.md`](k8s/README.md#evidencias)
- Prueba del HPA: la CPU subió de 2 % a 361 % con carga sintética y las réplicas pasaron de 2 a 4.
- Diagramas C4: [`docs/c4/`](docs/c4/)

## Limitaciones conocidas

- El estado vive en memoria de cada pod. Con varias réplicas, cada una tiene el suyo. En producción irían PostgreSQL y SQS.
- La autenticación Bearer es un stub y solo verifica que el header exista.
- El motor ESI es de reglas simples (`rules-v0`), no criterio clínico validado.
- `/load` existe solo para probar el HPA y debe retirarse fuera de la demo.
- Sin shell en la imagen distroless, no se puede usar `kubectl exec`. Se depura con logs.

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
