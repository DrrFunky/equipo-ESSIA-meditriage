# Bounded Contexts y Ubiquitous Language - MediTriage

Aplicando los principios de Domain-Driven Design (DDD), el dominio de MediTriage se divide en cuatro Bounded Contexts principales. Esto evita la ambigüedad del término "Paciente", dándole un significado estricto según la frontera.

## 1. Contexto Clínico (Core Domain)
* **Definición de Paciente:** Persona física presentando signos vitales, síntomas y requiriendo una categorización ESI[cite: 23].
* **Aggregate Root:** `Encounter` (Atención en Urgencias)[cite: 23].
* **Responsabilidad:** Captura de datos de salud y orquestación del flujo de triage.

## 2. Contexto de Identidad (Subdominio Genérico)
* **Definición de Paciente:** Persona natural con RUT validado, datos demográficos y consentimiento informado firmado[cite: 23].
* **Aggregate Root:** `Person`[cite: 23].
* **Responsabilidad:** Autenticación, validación civil y gestión del consentimiento (Ley 19.628).

## 3. Contexto de Auditoría (Subdominio de Soporte)
* **Definición de Paciente:** Referencia opaca (hash o UUID) asociada a las decisiones algorítmicas tomadas sobre él[cite: 23].
* **Aggregate Root:** `AuditLog`[cite: 23].
* **Responsabilidad:** Registro inmutable (Append-only) de las justificaciones de la IA para trazabilidad legal (Ley 21.719).

## 4. Contexto de Facturación (Subdominio Genérico)
* **Definición de Paciente:** Titular de un plan de salud, asociado a coberturas y cargos por atención de urgencia[cite: 23].
* **Aggregate Root:** `Account`[cite: 23].
* **Responsabilidad:** Integración con aseguradoras e ISAPRES.