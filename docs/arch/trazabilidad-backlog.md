# 🔗 Matriz de Trazabilidad: Backlog (S02) → Contenedores (S03)

| Historia de Usuario (INVEST) | Contenedor Responsable (C4 L2) | Protocolo / Almacenamiento |
| :--- | :--- | :--- |
| **US01:** Registro de paciente, validación RUT y consentimiento | Aplicación SPA Web & API Backend | HTTPS/REST $\rightarrow$ Servicio de Registro Civil (JSON/HTTPS) |
| **US02:** Captura de síntomas y constantes vitales | Aplicación SPA Web & API Backend | HTTPS/REST $\rightarrow$ PostgreSQL / Amazon RDS (cifrado en reposo con KMS) |
| **US03:** Motor IA explicable ESI (< 3s) y fallback manual | API Backend, Broker de Mensajería (Amazon SNS FIFO + SQS FIFO) & Servicio de IA (Worker) | Eventos asíncronos (`triage.requested`, `triage.completed`, `triage.failed`) vía Amazon SNS FIFO + SQS FIFO (SLA latencia < 3s) |
| **US04:** Tablero dinámico de priorización para personal médico | Aplicación SPA Web, API Backend & Read Models (OpenSearch / Redis) | WebSockets (actualización en tiempo real) + consultas CQRS sobre OpenSearch y Redis |
| **US05:** Audit log inmutable y enmascaramiento PII (5 años) | API Backend, Broker de Mensajería (Amazon SNS FIFO + SQS FIFO) & Base de Datos Relacional (PostgreSQL / Amazon RDS) | Outbox $\rightarrow$ Amazon SNS FIFO + SQS FIFO $\rightarrow$ PostgreSQL (schema `auditoria` append-only, hash encadenado) |
