# Backlog — MeditrIAge

Historias de usuario derivadas del Impact Map, con checklist INVEST aplicado.

**Goal (trazabilidad):** Reducir el tiempo de priorización del triage de 25
minutos a menos de 3 minutos, mejorando la gestión de la sala de espera en
urgencias y asegurando que los pacientes críticos sean detectados a tiempo.


## Historia 1 — Sugerencia ESI automatizada

**Actor:** Enfermera de Triage
**Goal relacionado:** Reducir tiempo de priorización

Como enfermera de triage,
quiero recibir una sugerencia de categoría ESI (1-5) generada por IA al
ingresar los datos del paciente, 
para priorizar la atención en menos de 30 segundos.

**INVEST:**
- I: no depende de otras historias, es la entrada principal del flujo.
- N: no especifica modelo ni arquitectura, solo el resultado esperado.
- V: reemplaza el cálculo manual del ESI, núcleo del objetivo de negocio.
- E: el equipo conoce el alcance del motor IA a construir.
- S: acotada a "generar y mostrar" la sugerencia.
- T: verificable con escenarios Gherkin (feliz/borde/error).


## Historia 2 — Justificación clínica explicable

**Actor:** Enfermera de Triage
**Goal relacionado:** Reducir tiempo de priorización / confianza clínica

Como enfermera de triage,
quiero ver una justificación clínica legible de por qué la IA sugirió esa
categoría ESI,
para poder validarla con confianza antes de aceptarla.

**INVEST:**
- I: complementa la Historia 1 pero se puede construir y probar por separado.
- N: no define el formato exacto de la explicación, solo que debe ser legible.
- V: sin esto la IA es una "caja negra" y la enfermera no puede validar.
- E: el equipo sabe qué variables clínicas explicar.
- S: acotada a mostrar la justificación junto a la sugerencia.
- T: se verifica que la justificación aparezca y sea coherente con los datos ingresados.

  
## Historia 3 — Registro inicial del paciente

**Actor:** Paciente
**Goal relacionado:** Gestión de sala de espera / captura de datos base

Como paciente,
quiero completar un formulario de registro con validación de RUT,
síntomas/signos vitales y un check explícito de consentimiento informado,
para que mis datos ingresen correctamente y de forma segura al sistema.

**INVEST:**
- I: es el punto de entrada de datos, no depende de otras historias.
- N: no fija tecnología de validación de RUT, solo el resultado.
- V: sin datos de entrada no hay ESI que sugerir.
- E: alcance conocido (formulario + validaciones + consentimiento).
- S: *(revisar en Gherkin; si crece, dividir en "registro de datos" y "consentimiento")*.
- T: validación de RUT y consentimiento son verificables.


## Historia 4 — Tablero de priorización en tiempo real

**Actor:** Médico Jefe
**Goal relacionado:** Gestión de sala de espera en urgencias

Como médico jefe,
quiero ver un tablero dinámico con los pacientes priorizados en tiempo real,
para identificar cuellos de botella en la sala de espera de urgencias.

**INVEST:**
- I: consume datos ya generados por las historias 1-3, pero se implementa como módulo aparte.
- N: no define tecnología de visualización, solo el resultado.
- V: da visibilidad operativa al médico jefe.
- E: alcance claro (listado priorizado en tiempo real).
- S: acotada a la visualización, no a la lógica de priorización (ya resuelta en H1).
- T: se verifica que refleje el estado actual de pacientes.

  
## Historia 5 — Audit log de decisiones IA

**Actor:** Médico Jefe / Auditor Clínico
**Goal relacionado:** Trazabilidad y cumplimiento normativo

Como auditor clínico,
quiero consultar un registro inmutable de cada recomendación de la IA
(guardado 5 años),
para auditar decisiones pasadas en caso de reclamos médicos.

**INVEST:**
- I: se puede construir en paralelo, solo requiere que la IA genere eventos.
- N: no define motor de almacenamiento, solo el requisito de inmutabilidad y retención.
- V: crítico para cumplimiento legal y defensa ante reclamos.
- E: alcance conocido (log + retención + consulta).
- S: acotada al registro y consulta, no a la lógica de decisión.
- T: se verifica que cada recomendación quede registrada y sea inmutable.
