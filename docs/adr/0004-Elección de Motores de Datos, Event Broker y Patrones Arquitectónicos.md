# ADR 0004 · Plataforma Base: Datos, Eventos, Kubernetes e IaC

## Estado
Aceptado - 15/10/2026

## Contexto
El sistema MediTriage (Core Domain: `Encounter`) requiere una infraestructura base robusta, escalable y segura sobre AWS (definido en ADR 0003). 
Para satisfacer las historias de usuario y requerimientos no funcionales (NFRs), se necesita:
1. **Datos y Eventos (S06):** Registrar el estado clínico con integridad ACID, publicar eventos de dominio asíncronos sin perder mensajes, proteger PII (Leyes 19.628 y 21.719) y soportar lecturas intensivas.
2. **Empaquetado y Orquestación (S07):** Ejecutar los microservicios de manera reproducible, inmutable, escalable bajo alta demanda y con la menor superficie de ataque posible.
3. **Provisionamiento (S07):** Codificar y auditar toda la infraestructura y configuración para evitar el "drift" de configuración manual y facilitar despliegues predecibles.

## Decisión
Se adoptan los siguientes motores, patrones y herramientas de plataforma:

### 1. Datos y Eventos
- **Write Model:** PostgreSQL sobre Amazon RDS.
- **Broker de Eventos:** Amazon SNS FIFO + Amazon SQS FIFO (con DLQ FIFO).
- **Read Model (CQRS):** OpenSearch (Dashboard) y Redis ElastiCache (Sala de espera).
- **Patrones:** CQRS y Outbox (tabla `outbox_event` en PostgreSQL). *Descartados: Event Sourcing y Saga.*

### 2. Empaquetado y Orquestación (K8s)
- **Construcción de Imágenes:** Docker *multi-stage builds* utilizando imágenes base **distroless** y ejecutando como usuario *non-root*. Etiquetado inmutable por digest (`@sha256`), prohibiendo el uso de `:latest`.
- **Orquestador:** Kubernetes (Amazon EKS para mantener coherencia con el ecosistema AWS).
- **Autoescalado:** Horizontal Pod Autoscaler (HPA) configurado para escalar réplicas basado en uso de CPU (>65%) y métricas de latencia de red.

### 3. Infraestructura como Código (IaC)
- **Herramienta IaC:** Terraform.
- **State Management:** Backend remoto en Amazon S3 con state locking obligatorio en DynamoDB.

## Justificación de los trade-offs

### Justificación de Datos y Eventos
* **PostgreSQL + Outbox:** El estado de un triage clínico exige transaccionalidad ACID. El patrón Outbox mitiga el riesgo de consistencia dual: actualizamos el estado del paciente y encolamos el evento hacia SNS en la misma transacción de base de datos.
* **Por qué SNS/SQS FIFO y no Kafka:** AWS ya es nuestro estándar. Kafka exige alto esfuerzo operativo que el MVP no justifica. SNS/SQS FIFO garantizan orden por paciente (`MessageGroupId`) y tolerancia a fallos mediante DLQs.

### Justificación de Contenedores y Kubernetes
* **Por qué Distroless y Multi-stage:** En salud, la seguridad es crítica. Separar la fase de *build* (con dependencias, compiladores) del *runtime* (distroless) reduce drásticamente el tamaño de la imagen (<80MB) y elimina vectores de ataque (no hay `shell`, ni `curl`, ni gestores de paquetes como `apt`). Ejecutar como *non-root* previene escalamiento de privilegios si el contenedor es comprometido.
* **Por qué Kubernetes (Amazon EKS):** Permite orquestación declarativa, *self-healing* de pods caídos y despliegues sin tiempo de inactividad (Zero Downtime Deployments). El HPA cubrirá los *spikes* de demanda en urgencias automáticamente.

### Justificación de IaC
* **Por qué Terraform y no Pulumi/CloudFormation:** Terraform es el estándar maduro de la industria. Su HCL declarativo es fácilmente auditable. A diferencia de CloudFormation (que nos amarra exclusivamente a AWS de manera rígida), Terraform ofrece un ecosistema más amplio de *providers* (ej. para configurar Kubernetes y AWS en el mismo repositorio). El estado remoto en S3 + DynamoDB previene condiciones de carrera cuando múltiples devs hacen despliegues.

## Consecuencias

**Gana:**
- **Seguridad (Zero Trust):** Superficie de ataque minimizada en contenedores y control estricto de accesos vía IaC. PII no viaja en los brokers.
- **Resiliencia Operativa:** Auto-sanación y autoescalado con K8s + eventos sin pérdida garantizados por el patrón Outbox.
- **Reproducibilidad:** Cualquier ambiente (dev, stg, prod) es clonable en minutos gracias a Terraform y los manifiestos declarativos de K8s.

**Pierde / Riesgos a mitigar:**
- **Curva de Aprendizaje y Complejidad:** El equipo debe manejar Kubernetes, Terraform HCL, y la consistencia eventual entre PostgreSQL y OpenSearch.
- **Sobrecarga de Gestión de Estado:** Obligación estricta de no corromper el `terraform.tfstate` y cuidar los *locks*.
- **FinOps:** EKS, OpenSearch y RDS encendidos 24/7 implican costos base mayores que alternativas serverless. Se deben configurar *Billing Alarms* agresivas.

---

# Anexo de Seguridad (Resumen)
* **Audit Log Inmutable:** Tabla en PostgreSQL de modo *append-only* (sin permisos UPDATE/DELETE) y encadenamiento criptográfico (`prev_hash`).
* **Protección PII:** Uso de UUIDs opacos (`encounter_id`) y hashing criptográfico HMAC para el RUT (`rut_hash`) en eventos. PII directa prohibida en payloads. Secretos gestionados vía Kubernetes Secrets o AWS Secrets Manager, inyectados en runtime.