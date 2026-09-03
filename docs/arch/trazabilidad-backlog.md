# 🔗 Matriz de Trazabilidad: Backlog (S02) → Contenedores (S03)

| Historia de Usuario (INVEST) | Contenedor Responsable (C4 L2) | Protocolo / Almacenamiento |
| :--- | :--- | :--- |
| **US01:** Registro de paciente, validación RUT y consentimiento | Single-Page Application (SPA) & Core API Application | HTTPS/REST $\rightarrow$ Consulta API Registro Civil |
| **US02:** Captura de síntomas y constantes vitales | Single-Page Application (SPA) & Core API Application | HTTPS/REST $\rightarrow$ PostgreSQL (cifrado en reposo) |
| **US03:** Motor IA explicable ESI (< 3s) y fallback manual | Core API Application, Broker Asíncrono & Servicio de Inferencia IA | Mensajería Asíncrona (AMQP/Redis) (SLA latencia < 3s) |
| **US04:** Tablero dinámico de priorización para personal médico | Single-Page Application (SPA) & Core API Application | WebSockets (actualización en tiempo real) |
| **US05:** Audit log inmutable y enmascaramiento PII (5 años) | Core API Application, Broker de Auditoría & Base de Datos Principal | Encolado de eventos $\rightarrow$ PostgreSQL (política append-only y pgcrypto) |
