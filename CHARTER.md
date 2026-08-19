# 📋 Team Charter — MediTriage

## 1. 🎯 Propósito y Misión del Equipo

Nuestra misión como equipo es desarrollar MediTriage para optimizar el flujo de atención en urgencias mediante inteligencia artificial, la cual recopilara tanto sus antecedentes medicos como sus datos personales, dando un veredicto sobre su estado de salud actual y a que escala de ESI pertenece

---

## 2. 👥 Integrantes y Roles Asignados

| Integrante | Rol Asignado | Justificación y Responsabilidades |
| :--- | :--- | :--- |
| **Martín Garrido** | **Product Owner (PO)** | Responsable de priorizar el backlog clínico, alinear las necesidades de urgencia médica con el MVP y gestionar el tablero Kanban. |
| **Cristóbal Araos** | **Tech Lead** | Responsable del diseño de arquitectura, asegurar latencia < 3s, integración del motor de IA explicable y definir estándares de código. |
| **Martín Durán** | **DevSecOps & Compliance Lead** | Responsable de la seguridad de datos médicos sensibles (Ley 19.628 / 21.719), cifrado en tránsito/reposo, anonimización de PII y pipeline CI/CD. |
| **Alonso Plane** | **QA & Architecture Lead** | Responsable de la calidad del software, cumplimiento de la Definition of Done (DoD), estrategia de pruebas automatizadas y trazabilidad de entrega. |

---

## 3. ✅ Definition of Done (DoD) Preliminar

Para que un incremento se considere completado, debe cumplir con:
1. **Calidad y Código:** Cobertura de pruebas unitarias acordada, código formateado y sin errores de linters.
2. **Seguridad y Privacidad:** Datos PII enmascarados en logs; cifrado en tránsito y reposo según normativa chilena.
3. **Validación Funcional / IA:** Recomendación ESI (1-5) con justificación explicable y tiempo de respuesta < 3 segundos.
4. **Trazabilidad:** Registro de auditoría generado, revisión por pares (Peer Review) aprobada y documentación actualizada.

---

## 4. 🤖 Política de Uso de Inteligencia Artificial

## 1. Política de Uso de Inteligencia Artificial (IA)

* **Asistencia, no reemplazo:** El motor de IA operará estrictamente como una herramienta de apoyo clínico para el triage. La decisión final sobre el flujo de atención y derivación del paciente recae siempre en el personal de salud humano.
* **Transparencia y Explicabilidad:** El modelo de IA tiene prohibido operar bajo un enfoque de "caja negra". El sistema debe documentar y justificar de forma legible cada sugerencia de categorización ESI (1 al 5) mostrada en el tablero dinámico.
* **Privacidad por Diseño y Minimización:** El modelo de IA procesará únicamente los datos estrictamente necesarios para su función (síntomas, signos vitales e historia clínica relevante). La IA no utilizará datos de identidad para calcular el nivel de riesgo.
* **Tolerancia a Fallos y Alta Disponibilidad:** Dado que la IA apoya un entorno crítico (urgencias), el motor debe estar diseñado para cumplir el SLA del 99.5% mensual. En caso de caída del servicio de IA, el sistema debe permitir que el personal médico continúe el triage de manera manual sin bloqueos.

## 2. Seguridad y Cumplimiento Legal (Normativa Chilena)

**Cumplimiento de Privacidad (Ley 19.628 y Ley 21.719):**
* **Consentimiento Informado:** El registro de pacientes mediante validación de RUT debe incluir la captura explícita del consentimiento informado, autorizando el tratamiento de sus datos de salud (considerados datos sensibles por la legislación chilena).
* **Alineación Normativa:** El manejo de la información se ceñirá a los estándares de protección y confidencialidad exigidos por la Ley 21.719, garantizando los derechos de los pacientes sobre su información médica.
* **Cifrado Obligatorio:** Todo dato sensible recolectado o generado por la plataforma debe estar protegido mediante cifrado fuerte tanto en tránsito (comunicaciones entre el formulario, la IA y los tableros) como en reposo (bases de datos).
* **Enmascaramiento de PII (Personal Identifiable Information):** Para proteger la identidad de los pacientes frente a accesos no autorizados o análisis técnicos, toda Información de Identificación Personal (RUT, nombre, contacto) será enmascarada u ofuscada en los registros del sistema (logs).
* **Auditoría y Trazabilidad Inmutable:** Cada recomendación de triage generada por el motor de IA quedará registrada en un audit log con marca de tiempo. Por mandato de diseño, este registro será inmutable y deberá conservarse de forma segura e íntegra por un período de 5 años para su revisión por parte del Auditor clínico.

---

## 5. 💬 Canales de Comunicación y Reglas de Trabajo

- **Canal de Slack oficial:** `#equipo-XX-meditriage` (uso obligatorio para notificar Pull Requests, anuncios formales y comunicación asíncrona).
- **Canal de trabajo síncrono:** Servidor de Discord propio para llamadas de voz rápidas, pair programming y coordinación del día a día.
- **Reglas de Trabajo:**
  - Todo código debe pasar por un Pull Request (PR) y ser revisado por al menos un integrante distinto al autor antes de hacer *merge* a `main`.
  - Las ramas deben seguir la nomenclatura estándar: `feature/nombre-tarea` o `bugfix/nombre-bug`.
  - Respetar los horarios de descanso; los mensajes fuera de horario se responderán al día siguiente.
- **Cadencia de reuniones:**
  - **Dailies:** Lunes, miércoles y viernes (reuniones de 15 minutos vía Discord o actualización rápida por Slack) para destrabar bloqueos.
  - **Planning / Review:** Una vez por semana para revisar el avance del Kanban y planificar las tareas del siguiente sprint.