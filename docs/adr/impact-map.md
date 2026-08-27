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

### Actor 3: Médico Jefe / Auditor Clínico
* **Impacto:** Puede monitorear los cuellos de botella en tiempo real y auditar las decisiones pasadas de la IA en caso de reclamos médicos.
* **Deliverable:** Tablero dinámico de pacientes priorizados y un sistema de Audit Log inmutable que registra cada recomendación de la IA por 5 años.