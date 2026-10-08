# ADR 0004 · Datos y Eventos (Persistencia, Broker y Patrones)

## Estado
Propuesto - 08/10/2026

## Contexto
El Contexto Clínico (Core Domain) gestiona el ciclo de vida del paciente en urgencias mediante el Aggregate Root `Encounter`. Sobre la infraestructura AWS definida en el ADR 0003, se requiere: (1) registrar el estado clínico con integridad transaccional; (2) publicar eventos de dominio de forma confiable hacia Motor IA, Auditoría, HIS Externo y Tablero, y consumir los emitidos por Identidad y HIS Externo (ver `event-catalog.md`); (3) garantizar trazabilidad legal de las decisiones de la IA sin exponer PII en los eventos (Leyes 19.628 y 21.719); y (4) soportar lecturas intensivas (dashboard de triage y sala de espera) sin degradar el modelo transaccional.

## Decisión
Se adoptan los siguientes motores y patrones, alineados con los servicios gestionados del ADR 0003:

- Write Model (estado del `Encounter`): **PostgreSQL** sobre Amazon RDS
- Broker de Eventos: **Amazon SNS + SQS** (colas FIFO, una cola por consumidor)
- Read Model (CQRS): **OpenSearch** para el dashboard de triage y **Redis** (ElastiCache) para el estado de la sala de espera
- Patrones aplicados: **CQRS** y **Outbox** (tabla `outbox_event` en PostgreSQL)
- Patrones descartados: **Event Sourcing** y **Saga**
- Semántica de entrega: **at-least-once**, con consumidores idempotentes por `event_id` (tabla `processed_event`)

## Justificación de los trade-offs

**Por qué PostgreSQL y no un motor NoSQL (MongoDB/DynamoDB):**
El `Encounter` y sus entidades (signos vitales, síntomas, solicitudes y resultados de triage, confirmación) son relacionales y exigen transacciones ACID e integridad referencial. Además, el PPT del taller establece SQL como respuesta por defecto, y `JSONB` cubre los payloads flexibles sin necesidad de otro motor.

**Por qué SNS + SQS y no Kafka/RabbitMQ:**
El ADR 0003 ya fijó SQS como broker, y Kafka (Amazon MSK) queda fuera del Free Tier y añade carga operativa que el MVP no justifica. Como cada evento tiene varios consumidores, SNS reparte a una cola SQS por consumidor, y el uso de colas FIFO con `MessageGroupId = encounter_id` conserva el orden de los eventos de una misma atención, con `event_id` como `MessageDeduplicationId`. Cada cola tiene una Dead Letter Queue para mensajes fallidos. Se asume que SQS no ofrece replay nativo, por lo que el replay se hace republicando desde `outbox_event`, que no se purga.

**Por qué Outbox:**
Guardar el cambio de estado y publicar al broker no es atómico: si SNS falla tras el commit, se pierde el evento. Todo comando del Contexto Clínico escribirá en una misma transacción el cambio de estado y una fila en `outbox_event`. Un relay (proceso programado en el API Backend) lee las filas pendientes, publica a SNS y marca `published_at`.

**Por qué CQRS y no un solo modelo:**
La lectura (dashboards con filtros y orden por prioridad ESI) difiere radicalmente de la escritura. Los comandos escriben solo en PostgreSQL, y proyectores que consumen desde SQS actualizan OpenSearch y Redis. Los proyectores son idempotentes por `event_id`.

**Por qué no Event Sourcing ni Saga:**
Event Sourcing tiene curva de aprendizaje alta y replay costoso, y no lo necesitamos: la trazabilidad legal se cubre con el `AuditLog` del Contexto de Auditoría, en modelo append-only (sin permisos `UPDATE`/`DELETE` para el rol de aplicación y con `log_hash` encadenado). Saga se reevaluará cuando existan transacciones distribuidas con compensaciones (integración con Facturación e ISAPRES).

**Seguridad y privacidad:**
El payload del `outbox_event` se construye ya enmascarado (`rut_hash`, sin nombre ni RUT en claro), por lo que ninguna PII viaja por el broker. RDS, SNS y SQS se cifran en reposo con AWS KMS y en tránsito con TLS, y el acceso se restringe por roles IAM mínimos.

**El riesgo asumido:**
OpenSearch y ElastiCache tienen cobertura limitada en el Free Tier y pueden generar cobros por encima del ADR 0003. Se asume el riesgo en el MVP y se mitiga con Billing Alarms. Siguiendo la regla del taller ("especializa solo cuando mides que Postgres no alcanza"), si el costo o la complejidad resultan excesivos, las proyecciones pueden resolverse temporalmente con tablas de lectura en PostgreSQL.

## Consecuencias
**Gana:**
- Resiliencia: Outbox evita la pérdida de eventos ante caídas del broker, y las DLQ aíslan mensajes fallidos.
- Rendimiento: CQRS permite escalar las lecturas sin degradar la base operativa.
- Coherencia con el ADR 0003: un solo proveedor y servicios gestionados con baja carga operativa.
- Privacidad y auditoría: PII ausente de los eventos y registro legal inmutable separado del flujo operativo.

**Pierde / se vuelve más difícil:**
- Complejidad: tres almacenes (PostgreSQL, OpenSearch, Redis) más el broker y un relay Outbox que debe estar siempre operativo.
- Consistencia eventual: habrá una latencia entre el commit en PostgreSQL y su aparición en el dashboard.
- Duplicados: por at-least-once, todo consumidor debe ser idempotente.
- Sin replay nativo: reconstruir proyecciones exige republicar desde `outbox_event`.
- Gobierno de eventos: requiere versionado de schemas (`event_version`) y compatibilidad hacia atrás.
- Riesgo financiero: OpenSearch y ElastiCache exigen monitoreo de costos (FinOps).
