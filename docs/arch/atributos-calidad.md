# Top 3 Atributos de Calidad (NFRs) - MediTriage
Como Product Owner, he definido los siguientes tres atributos de calidad críticos (Requisitos No Funcionales) que el equipo técnico deberá asegurar al diseñar la arquitectura del sistema MediTriage:

## 1. Performance (Rendimiento)

Métrica objetivo: Latencia de inferencia clínica < 3s (percentil 95).

Impacto en el negocio: En un entorno de urgencias médicas, la fluidez es vital. Si el motor de IA tarda más de 3 segundos en devolver la sugerencia de categorización ESI tras ingresar los signos vitales, interrumpirá el flujo natural de la enfermera de triage. Esto generaría cuellos de botella físicos en la sala de espera, anulando por completo nuestro objetivo principal (reducir los tiempos de priorización).

## 2. Seguridad y Privacidad

Métrica objetivo: Cifrado fuerte obligatorio en reposo (bases de datos) y en tránsito (comunicaciones API); enmascaramiento total de PII (Información de Identificación Personal) en logs.

Impacto en el negocio: El sistema procesa diagnósticos, síntomas y signos vitales ligados a la identidad de un paciente. El cumplimiento estricto de las leyes chilenas 19.628 (Protección de la Vida Privada) y 21.719 (Derechos y Deberes de los Pacientes) es un requerimiento legal innegociable. Una brecha de datos sin cifrar expondría a la red de salud a demandas severas y pérdida absoluta de viabilidad del proyecto.

## 3. Disponibilidad (Availability)

Métrica objetivo: SLA de 99.5% mensual para los servicios base, con un mecanismo de fallback (respaldo) manual inmediato si el motor de IA sufre una caída.

Impacto en el negocio: Las urgencias operan 24/7 y la recepción de pacientes jamás puede detenerse. Si el modelo de IA falla o se desconecta, el sistema debe permitir que el personal médico continúe el registro y categorización manual de pacientes sin bloqueos en la interfaz. Un SLA alto asegura la estabilidad, y el fallback mitiga los riesgos de retrasar atenciones de riesgo vital por culpa de un fallo de software.
