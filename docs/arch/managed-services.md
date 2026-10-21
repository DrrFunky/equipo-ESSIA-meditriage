# Servicios Gestionados Cloud (MediTriage)

**Autor:** Martín Durán (DevSecOps & Compliance Lead)
**Proveedor Cloud Seleccionado:** AWS (Amazon Web Services)
**Objetivo:** Cumplir con SLA de 99.5%, protección de PII (Leyes 19.628 y 21.719) y optimización de costos para el MVP.
**Revisión:** 21/10/2026 (S07). El cómputo de la API, del worker de IA y de los proyectores pasa de Elastic Beanstalk y Lambda a contenedores sobre Kubernetes (ver ADR 0004, que refina la decisión de cómputo del ADR 0003).

La siguiente selección de infraestructura define los contenedores de nuestro sistema, equilibrando la máxima seguridad clínica con los límites de la capa gratuita (AWS Free Tier) para no disparar el presupuesto inicial.

## Resumen por contenedor del C4 L2

| Contenedor (C4 L2) | Tecnología / servicio | Estado |
|---|---|---|
| SPA Web | AWS Amplify Hosting | Planificado |
| API Backend | Contenedor (FastAPI) en Kubernetes: Docker Desktop (dev) y Amazon EKS (objetivo prod) | **Implementado en local (S07)** |
| Base de Datos Relacional | Amazon RDS para PostgreSQL | Planificado (hoy el estado está en memoria) |
| Broker de Mensajería | Amazon SNS FIFO + SQS FIFO | Planificado |
| Servicio de IA (Worker) | Contenedor en Kubernetes (Deployment) | Planificado |
| Proyectores de Lectura | Contenedor en Kubernetes (Deployment) | Planificado |
| Read Model: Dashboard | Amazon OpenSearch Service | Planificado |
| Read Model: Sala de Espera | Amazon ElastiCache (Redis) | Planificado |

## 1. Frontend (Aplicación SPA Web)
*   **Servicio AWS:** AWS Amplify Hosting.
*   **SLA 99.5%:** Despliega la aplicación globalmente usando la red de CloudFront, asegurando alta disponibilidad frente a caídas regionales.
*   **Protección PII:** Emite y renueva automáticamente certificados SSL/TLS, forzando que la captura de síntomas y RUT en el formulario viaje exclusivamente por HTTPS cifrado hacia la API.

## 2. API Backend (Python / FastAPI)
*   **Plataforma:** Contenedor en Kubernetes. Desarrollo y pruebas en el clúster de Docker Desktop; objetivo de producción en Amazon EKS. Imagen multi-stage con base distroless, usuario no-root (UID 65532) y publicada en GHCR, referenciada siempre por digest (nunca `:latest`).
*   **SLA 99.5%:** Mínimo 2 réplicas con `RollingUpdate` (`maxUnavailable: 0`), probes de readiness y liveness sobre `GET /health`, reinicio automático de contenedores caídos (*self-healing*) y HPA por CPU al 50% (2 a 5 réplicas), lo que mantiene la recepción de triage operativa y sin caídas durante los despliegues.
*   **Protección PII:** Actúa como la zona de intercepción. En producción se ubica en una red privada virtual (VPC) aislada, siendo el único punto autorizado para ejecutar el enmascaramiento del RUT antes de derivar la información. Los pods corren con `readOnlyRootFilesystem`, sin escalamiento de privilegios y con todas las capabilities eliminadas.
*   **Configuración y secretos:** la configuración no secreta vive en un `ConfigMap`; las credenciales van en un `Secret` (placeholder gestionado por Terraform en dev, AWS Secrets Manager en producción).

## 3. Base de Datos Relacional (PostgreSQL)
*   **Servicio AWS:** Amazon RDS para PostgreSQL (Capa gratuita `db.t3.micro`).
*   **SLA 99.5%:** Los respaldos automáticos y las ventanas de mantenimiento gestionadas por AWS aseguran que el registro de pacientes no se pierda por fallos de hardware.
*   **Protección PII:** Es crítico para DevSecOps. Se habilitará el **cifrado en reposo (AES-256)** integrado con AWS KMS. En caso de una vulneración del servidor físico, la base de datos de historiales médicos y consentimientos informados será ilegible sin las llaves maestras.
*   **Nota:** en la entrega S07 la API aún guarda el estado en memoria; la conexión a RDS queda pendiente.

## 4. Broker de Mensajería (Colas de IA, proyecciones y auditoría)
*   **Servicio AWS:** Amazon SNS FIFO (un tópico por tipo de evento) + Amazon SQS FIFO (una cola por consumidor, con Dead Letter Queue FIFO).
*   **SLA 99.5%:** Son servicios gestionados y sin servidores que operar. Si la IA sufre un cuello de botella, ninguna solicitud de paciente se pierde: quedan encoladas. El orden por atención se conserva con `MessageGroupId = encounter_id`, y la entrega es at-least-once con consumidores idempotentes por `event_id`.
*   **Protección PII:** Los eventos salen del Outbox ya sin PII directa (`rut_hash`, sin nombre ni RUT). Cifrado en tránsito (TLS obligatorio por política) y en reposo con SSE-KMS sobre tópicos, colas y DLQ.

## 5. Servicio de IA (Worker de Inferencia)
*   **Plataforma:** Contenedor en Kubernetes (Deployment propio), con la misma imagen base distroless y no-root que la API. Consume `triage.requested` desde su cola SQS mediante long polling y publica `triage.completed` o `triage.failed`.
*   **SLA 99.5% & Costos:** Escala por réplicas (HPA) cuando llegan muchos pacientes de urgencia a la vez. Al correr en el mismo clúster no agrega un servicio de pago adicional, pero **no escala a cero**: mantiene al menos una réplica activa. Si el equipo mide que el worker se beneficia de escalar a cero, Lambda queda como evolución posible.
*   **Tolerancia a fallos:** si el worker no responde en el tiempo esperado, el sistema activa el *fallback manual* y la enfermera categoriza sin bloquear la atención.

## 6. Proyectores de Lectura y Read Models (CQRS)
*   **Proyectores:** Deployment en Kubernetes que consume los eventos desde SQS y actualiza los read models de forma idempotente (por `event_id`).
*   **Amazon OpenSearch Service:** proyección para el tablero de triage priorizado por ESI.
*   **Amazon ElastiCache (Redis):** estado en tiempo real de la sala de espera.
*   **Costos:** ambos servicios tienen cobertura limitada en el Free Tier. Se asume el riesgo en el MVP y se mitiga con Billing Alarms; si el costo resulta excesivo, las proyecciones pueden resolverse temporalmente con tablas de lectura en PostgreSQL (ver ADR 0004).

## 7. Plataforma de ejecución e infraestructura como código
*   **Kubernetes:** Docker Desktop en desarrollo; Amazon EKS como objetivo de producción. El plano de control de EKS tiene costo fijo por hora y **no está cubierto por el Free Tier**, por lo que el MVP se demuestra en el clúster local con los mismos manifiestos y EKS se evaluará cuando haya presupuesto.
*   **Registro de imágenes:** GitHub Container Registry (GHCR).
*   **Terraform:** crea el namespace `meditriage` y el `Secret` placeholder. Backend `kubernetes` en local (el estado se guarda como Secret del clúster); objetivo en producción: backend remoto en S3 con bloqueo en DynamoDB.
*   **Costos transversales:** se configurarán alertas de facturación (Billing Alarms) en la cuenta AWS, como indica el ADR 0003.
