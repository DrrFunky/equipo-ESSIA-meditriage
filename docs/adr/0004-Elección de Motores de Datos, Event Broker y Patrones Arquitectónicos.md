# ADR 0004 · Datos y Eventos (Persistencia, Broker y Patrones)

## Estado
Propuesto - 08/10/2026

## Contexto
El Contexto Clínico (Core Domain) gestiona el ciclo de vida del paciente en urgencias mediante el Aggregate Root `Encounter`. Sobre la infraestructura AWS definida en el ADR 0003, se requiere: (1) registrar el estado clínico con integridad transaccional; (2) publicar eventos de dominio de forma confiable hacia Motor IA, Auditoría, HIS Externo y Tablero, y consumir los emitidos por Identidad y HIS Externo (ver `event-catalog.md`); (3) garantizar trazabilidad legal de las decisiones de la IA sin exponer PII en los eventos (Leyes 19.628 y 21.719); y (4) soportar lecturas intensivas (dashboard de triage y sala de espera) sin degradar el modelo transaccional.

## Decisión
Se adoptan los siguientes motores y patrones, alineados con los servicios gestionados del ADR 0003:

- **Write Model (estado del Encounter):** PostgreSQL sobre Amazon RDS.
- **Broker de Eventos:** Amazon SNS FIFO (un tópico por tipo de evento) + Amazon SQS FIFO (una cola por consumidor, con DLQ FIFO).
- **Orden y deduplicación:** `MessageGroupId = encounter_id` y `MessageDeduplicationId = event_id`.
- **Read Model (CQRS):** OpenSearch para el dashboard de triage y Redis (ElastiCache) para el estado de la sala de espera.
- **Patrones aplicados:** CQRS y Outbox (tabla `outbox_event` en PostgreSQL).
- **Patrones descartados:** Event Sourcing y Saga.
- **Semántica de entrega:** at-least-once, con consumidores idempotentes por `event_id` (tabla `processed_event`).

## Justificación de los trade-offs

**Por qué PostgreSQL y no un motor NoSQL (MongoDB/DynamoDB):** El Encounter y sus entidades (signos vitales, síntomas, solicitudes y resultados de triage, confirmación) son relacionales y exigen transacciones ACID e integridad referencial. Además, el PPT del taller establece SQL como respuesta por defecto, y JSONB cubre los payloads flexibles sin necesidad de otro motor.

**Por qué SNS FIFO + SQS FIFO y no Kafka/RabbitMQ:** El ADR 0003 ya fijó SQS como broker, y Kafka (Amazon MSK) queda fuera del Free Tier y añade carga operativa que el MVP no justifica. Como cada evento tiene varios consumidores, un tópico SNS FIFO reparte cada evento a una cola SQS FIFO por consumidor (un tópico SNS estándar no puede entregar a colas FIFO, por eso ambos son FIFO). El relay publica con `MessageGroupId = encounter_id`, que conserva el orden de los eventos de una misma atención, y con `MessageDeduplicationId = event_id`. La deduplicación de FIFO cubre solo una ventana de 5 minutos, por lo que la entrega se sigue tratando como at-least-once y los consumidores siguen siendo idempotentes por `event_id` (`processed_event`). Cada cola tiene una Dead Letter Queue, también FIFO, para mensajes fallidos. Se asume que SQS no ofrece replay nativo, por lo que el replay se hace republicando desde `outbox_event`, que no se purga.

**Por qué Outbox:** Guardar el cambio de estado y publicar al broker no es atómico: si SNS falla tras el commit, se pierde el evento. Todo comando del Contexto Clínico escribirá en una misma transacción el cambio de estado y una fila en `outbox_event`. Un relay (proceso programado en el API Backend) lee las filas pendientes, publica a SNS y marca `published_at`.

**Por qué CQRS y no un solo modelo:** La lectura (dashboards con filtros y orden por prioridad ESI) difiere radicalmente de la escritura. Los comandos escriben solo en PostgreSQL, y proyectores que consumen desde SQS actualizan OpenSearch y Redis. Los proyectores son idempotentes por `event_id`.

**Por qué no Event Sourcing ni Saga:** Event Sourcing tiene curva de aprendizaje alta y replay costoso, y no lo necesitamos: la trazabilidad legal se cubre con el `AuditLog` del Contexto de Auditoría, en modelo append-only (sin permisos UPDATE/DELETE para el rol de aplicación y con `log_hash` encadenado). Saga se reevaluará cuando existan transacciones distribuidas con compensaciones (integración con Facturación e ISAPRES).

**Seguridad y privacidad:** El payload del `outbox_event` se construye ya enmascarado (`rut_hash`, sin nombre ni RUT en claro), por lo que ninguna PII viaja por el broker. RDS, SNS y SQS se cifran en reposo con AWS KMS y en tránsito con TLS, y el acceso se restringe por roles IAM mínimos.

**El riesgo asumido:** OpenSearch y ElastiCache tienen cobertura limitada en el Free Tier y pueden generar cobros por encima del ADR 0003. Se asume el riesgo en el MVP y se mitiga con Billing Alarms. Siguiendo la regla del taller ("especializa solo cuando mides que Postgres no alcanza"), si el costo o la complejidad resultan excesivos, las proyecciones pueden resolverse temporalmente con tablas de lectura en PostgreSQL.

## Consecuencias

**Gana:**
- Resiliencia: Outbox evita la pérdida de eventos ante caídas del broker, y las DLQ aíslan mensajes fallidos.
- Orden: SNS/SQS FIFO conserva el orden de los eventos de cada atención (`encounter_id`).
- Rendimiento: CQRS permite escalar las lecturas sin degradar la base operativa.
- Coherencia con el ADR 0003: un solo proveedor y servicios gestionados con baja carga operativa.
- Privacidad y auditoría: PII ausente de los eventos y registro legal inmutable separado del flujo operativo.

**Pierde / se vuelve más difícil:**
- Complejidad: tres almacenes (PostgreSQL, OpenSearch, Redis) más el broker y un relay Outbox que debe estar siempre operativo.
- Consistencia eventual: habrá una latencia entre el commit en PostgreSQL y su aparición en el dashboard.
- Duplicados: por at-least-once, todo consumidor debe ser idempotente.
- FIFO: ordena por `encounter_id`, pero su deduplicación cubre solo 5 minutos y tiene menor throughput que las colas estándar; es suficiente para el volumen del MVP.
- Sin replay nativo: reconstruir proyecciones exige republicar desde `outbox_event`.
- Gobierno de eventos: requiere versionado de schemas (`event_version`) y compatibilidad hacia atrás.
- Riesgo financiero: OpenSearch y ElastiCache exigen monitoreo de costos (FinOps).

---

# Anexo de Seguridad al ADR 0004: Audit Log inmutable y protección de PII

- **Estado:** Propuesto
- **Responsable:** Martín Durán (DevSecOps)
- **Revisión conjunta:** Cristóbal Araos (Tech Lead)
- **Relacionado:** ADR 0004 (datos y eventos), `event-catalog.md`, `der.png`

## 1. Contexto
MediTriage maneja datos de salud de pacientes (datos sensibles). Se requiere: (a) un registro de auditoría que no pueda alterarse ni borrarse, y (b) que ningún dato personal identificable (PII) salga en claro hacia el broker.

Decisiones base del ADR 0004: PostgreSQL como motor de persistencia y Amazon SNS FIFO + SQS FIFO como broker de mensajería, con patrones CQRS y Outbox.

## 2. Audit Log inmutable en PostgreSQL

### Requisitos
- Solo inserción (append-only): nadie modifica ni elimina registros.
- Trazabilidad: quién, qué, cuándo, desde dónde y sobre qué recurso.
- Detección de manipulación.

### Controles propuestos

| Control | Descripción |
|---|---|
| Rol dedicado | La aplicación escribe con un rol que solo tiene INSERT sobre `audit_log`. `REVOKE UPDATE, DELETE, TRUNCATE`. |
| Trigger de bloqueo | Trigger `BEFORE UPDATE OR DELETE` que lanza excepción, como defensa en profundidad. |
| Encadenamiento por hash | Cada registro guarda `prev_hash` y `hash` (SHA-256 del contenido + hash previo) para detectar alteraciones. |
| Particionado por fecha | Partición mensual para retención y archivado. |
| Auditoría de la base | Extensión `pgaudit` para registrar cambios de esquema y accesos privilegiados. Logs enviados a CloudWatch Logs. |
| Cifrado | Cifrado en reposo con AWS KMS y TLS obligatorio en conexiones (`rds.force_ssl`). |
| Réplica WORM | Exportación periódica a S3 con Object Lock en modo compliance, coherente con los servicios gestionados AWS definidos en `docs/arch`. |
| Acceso restringido | Lectura solo para rol de auditoría. Uso de rol administrador fuera de la operación diaria y con alertas. |

### Esquema mínimo
`audit_log(id, occurred_at, actor_id, actor_role, action, resource_type, resource_id, source_ip, request_id, prev_hash, hash)`

### Limitación a documentar
Un administrador de la base de datos podría evadir los controles internos (triggers, permisos). Por eso la réplica WORM externa en S3 es la garantía fuerte de inmutabilidad.

## 3. Protección de PII en el flujo hacia SNS/SQS

### Principio
Los eventos de dominio no transportan PII en claro. Se usa minimización + pseudonimización.

### Flujo (patrón Outbox)
1. El servicio guarda el cambio de negocio y el evento en la tabla `outbox_event` en la misma transacción.
2. El evento se construye ya sin PII directa: se usan `encounter_id` (UUID opaco) y `rut_hash` en lugar de RUT, nombre o contacto. El `rut_hash` se calcula con HMAC-SHA256 y una clave almacenada en AWS Secrets Manager (un hash simple de RUT se revierte por fuerza bruta, porque el espacio de RUT es pequeño).
3. Un publicador (relay) lee el outbox, valida el payload contra su schema y rechaza eventos con campos prohibidos.
4. El relay publica en el tópico SNS FIFO, que reparte a las colas SQS FIFO de cada consumidor. Los consumidores que necesiten PII la consultan por ID a un servicio autorizado.

### Clasificación de campos

| Tipo | Ejemplos | Tratamiento en eventos |
|---|---|---|
| PII directa | RUT, nombre, teléfono, correo | Prohibido en payload |
| Dato sensible de salud | diagnóstico, síntomas | Solo código/categoría, nunca texto libre |
| Identificador opaco | `encounter_id` (UUID), `rut_hash` | Permitido |
| Metadatos | timestamp, tipo de evento | Permitido |

### Controles en SNS y SQS
- Cifrado en reposo con SSE-KMS usando una clave propia (CMK), no la clave gestionada por defecto, en tópicos y colas.
- Cifrado en tránsito: política de tópico y de cola que deniegue acceso si `aws:SecureTransport` es falso.
- Control de acceso por IAM con mínimo privilegio: `sns:Publish` solo para el relay del outbox; `sqs:ReceiveMessage` y `sqs:DeleteMessage` solo para el consumidor de esa cola. La política de cada cola permite `sqs:SendMessage` únicamente al tópico SNS suscrito. Sin permisos comodín.
- Un tópico SNS FIFO por tipo de evento y una cola SQS FIFO por consumidor, para aislar el acceso por caso de uso.
- Dead-letter queue (DLQ) FIFO con `maxReceiveCount` definido, cifrada con KMS, sin PII y con acceso restringido.
- Retención acotada de mensajes (`MessageRetentionPeriod` al mínimo necesario).
- Idempotencia y orden: las colas son SQS FIFO (orden por `MessageGroupId = encounter_id`, `MessageDeduplicationId = event_id`). La deduplicación de FIFO cubre solo 5 minutos, por lo que se mantiene la entrega at-least-once: los consumidores deben ser idempotentes por `event_id` (tabla `processed_event`).
- Trazabilidad: CloudTrail activo para registrar llamadas de API sobre tópicos, colas y claves KMS.
- Red: VPC endpoints para SNS y SQS, sin salida por internet público.

## 4. Verificación (checklist de auditoría con Cristóbal)
- [ ] `audit_log` sin permisos UPDATE/DELETE para el rol de aplicación
- [ ] Trigger de bloqueo probado
- [ ] Cadena de hash verificable con script
- [ ] Exportación WORM a S3 Object Lock definida
- [ ] Ningún evento del catálogo contiene PII directa
- [ ] `rut_hash` calculado con HMAC y clave en Secrets Manager
- [ ] Validación de schema en el publicador del outbox
- [ ] Tópicos SNS y colas SQS con SSE-KMS y política de TLS obligatorio
- [ ] Roles IAM con mínimo privilegio por productor y consumidor
- [ ] DLQ FIFO configurada, cifrada y sin PII
- [ ] Consumidores idempotentes

## 5. Consideraciones normativas
Aplican la Ley 19.628 y la Ley 20.584 (derechos de los pacientes, reserva de la ficha clínica). Considerar además la Ley 21.719 de protección de datos personales. Confirmar con el docente el alcance normativo esperado.

## 6. Consecuencias
- (+) Trazabilidad y evidencia ante auditorías.
- (+) Menor superficie de exposición de datos en la cola.
- (+) SNS y SQS son servicios gestionados: menos operación y parches que un broker propio.
- (−) Complejidad adicional (hash chain, validación de schema, exportación WORM).
- (−) SNS/SQS FIFO ordena por `encounter_id`, pero su deduplicación cubre solo 5 minutos y tiene menor throughput que las colas estándar: se mantiene la idempotencia en consumidores.
