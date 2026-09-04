# Impact Map - MediTriage

## 1. Goal (Objetivo)
**Reducir el tiempo de priorización del triage de 25 minutos a menos de 3 minutos**, mejorando la gestión de la sala de espera en urgencias y asegurando que los pacientes críticos sean detectados a tiempo.

---

## 2. Actores, Impactos y Entregables (Deliverables)

Para lograr el objetivo, necesitamos cambiar el comportamiento de los siguientes actores a través de entregables específicos:

### Actor 1: Enfermera de Triage
* **Impacto:** Deja de calcular manualmente el índice ESI. Ahora obtiene y valida una sugerencia de priorización automatizada en menos de 30 segundos.
* **Deliverable:** Interfaz de evaluación con motor IA que sugiere la categoría ESI (1 al 5) e incluye una justificación clínica legible (modelo explicable, no "caja negra").

### Actor 2: Paciente
* **Impacto:** Entrega su información inicial de manera fluida, sabiendo que sus datos sensibles están protegidos según la normativa vigente.
* **Deliverable:** Formulario de registro inicial con validación de RUT, captura de síntomas/signos vitales y un check explícito de consentimiento informado.

### Actor 3: Médico Jefe de Turno
* **Impacto:** Gestiona eficientemente la sala de urgencias y reduce cuellos de botella mediante visibilidad en tiempo real de la demanda y severidad de los pacientes.
* **Deliverable:** Tablero dinámico de pacientes priorizados con actualización en vivo y gestión visual de boxes de atención.

### Actor 4: Auditor Clínico
* **Impacto:** Valida la adherencia a protocolos médicos y responde a reclamos o auditorías legales revisando la justificación de las decisiones tomadas por el sistema.
* **Deliverable:** Sistema de Audit Log inmutable (append-only) con anonimización de PII que conserva la trazabilidad de cada recomendación de la IA por 5 años.

