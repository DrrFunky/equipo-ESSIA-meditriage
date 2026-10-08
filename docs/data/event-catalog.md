# Catálogo de Eventos de Dominio

El flujo asíncrono de MediTriage se basa en los siguientes eventos inmutables, aplicando semántica de entrega *at-least-once*[cite: 23]. Todo consumidor debe implementar operaciones idempotentes utilizando el `event_id`.

| ID | Evento (Pasado) | Productor | Consumidor(es) principales | Payload (Schema resumido) |
| :--- | :--- | :--- | :--- | :--- |
| 01 | `patient.registered` | API Identidad | Clínico, Facturación | `rut_hash`, `consent_signed`, `timestamp` |
| 02 | `vitals.captured` | API Clínico | Motor IA | `fc`, `pa`, `sato2`, `temp`, `encounter_id` |
| 03 | `symptoms.reported` | API Clínico | Motor IA | `symptoms_list`, `encounter_id` |
| 04 | `triage.requested` | API Clínico | Motor IA | `encounter_id`, `vitals`, `symptoms` |
| 05 | `triage.completed` | Motor IA (Worker) | API Clínico, Auditoría | `esi_category`, `reasoning`, `model_version` |
| 06 | `triage.failed` | Motor IA (Worker) | API Clínico | `error_code`, `encounter_id` |
| 07 | `triage.confirmed` | API Clínico | HIS Externo, Tablero | `final_esi`, `nurse_id`, `override_applied` |
| 08 | `patient.attended` | HIS Externo | Tablero, Facturación | `physician_id`, `box_number`, `encounter_id` |
| 09 | `audit.record.created` | API Auditoría | Data Lake | `log_hash`, `event_reference_id` |
| 10 | `patient.discharged` | HIS Externo | Clínico, Facturación | `discharge_reason`, `encounter_id` |

## Semántica y Patrones
* Todos los eventos emitidos por el **Contexto Clínico** utilizarán el **Patrón Outbox** sobre PostgreSQL[cite: 23]. Esto garantiza que la actualización del estado del `Encounter` y la publicación del evento hacia el broker (ej. RabbitMQ/Kafka) ocurran en una única transacción atómica.