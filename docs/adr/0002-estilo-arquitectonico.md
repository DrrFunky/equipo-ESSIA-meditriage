# ADR 0002 · Elección de estilo arquitectónico

## Estado
Aceptado — 2026-09-03

## Contexto
MediTriage es un sistema de apoyo a la priorización clínica en urgencias,
donde un motor de IA sugiere la categoría ESI (1-5) a partir de los signos
vitales y el historial médico del paciente. El Product Owner (Martín G.) ha
definido tres atributos de calidad críticos que condicionan la arquitectura:

1. **Performance:** latencia de inferencia clínica < 3s (percentil 95). Si el
   motor de IA tarda más, se interrumpe el flujo de la enfermera de triage y
   se generan cuellos de botella físicos en la sala de espera.
2. **Seguridad y Privacidad:** cifrado fuerte obligatorio en reposo y en
   tránsito, con enmascaramiento total de PII en logs. El sistema procesa
   diagnósticos y signos vitales ligados a la identidad del paciente, bajo
   las leyes chilenas 19.628 y 21.719.
3. **Disponibilidad:** SLA de 99.5% mensual, con mecanismo de fallback
   manual inmediato si el motor de IA falla. Las urgencias operan 24/7 y la
   recepción de pacientes no puede detenerse.

El equipo es pequeño (proyecto académico, 4 personas), el dominio aún no
está del todo maduro, y se trata de un MVP. Al mismo tiempo, el motor de IA
es el componente de mayor riesgo del sistema: es el más propenso a fallar o
degradarse en performance, y es el que debe poder caerse sin tumbar el resto
del sistema (para cumplir el NFR de disponibilidad con fallback).

## Estilos candidatos evaluados

### Opción A — Monolito Modular
- **Cuándo se elige:** equipo pequeño (<15 personas), dominio aún no maduro, MVP.
- **Fortaleza:** simple de operar, transacciones ACID naturales, deploy único.
- **Costo real:** escalabilidad acoplada, deploys grandes, riesgo de "big ball of mud" si no hay disciplina de módulos.
- **Frente a los NFRs de MediTriage:** favorece la latencia <3s (sin overhead de red entre servicios) y facilita centralizar el cifrado/PII. La disponibilidad con fallback se resuelve desacoplando solo el módulo de IA de forma asíncrona.

### Opción B — Microservicios / Event-Driven
- **Cuándo se elige:** dominio maduro con bounded contexts claros, múltiples equipos, sistemas asíncronos con workflows largos.
- **Fortaleza:** escalado independiente, desacoplamiento máximo, resiliencia por bulkhead, replay de eventos.
- **Costo real:** complejidad operacional alta, red como punto único de falla, consistencia eventual, exige idempotencia y orden en los eventos.
- **Frente a los NFRs de MediTriage:** el equipo (6 personas) y la madurez del dominio no justifican esta complejidad; la latencia agregada por llamadas de red entre servicios pone en riesgo el NFR de <3s p95.

**Conclusión de la evaluación:** ninguna opción es "pura" en su forma extrema.
Se opta por un híbrido pragmático: Monolito Modular como base, aplicando el
principio de Event-Driven solo al componente de mayor riesgo (el motor de
IA), para obtener disponibilidad con fallback sin pagar el costo operacional
completo de microservicios.

## Decisión
Se adopta un **Monolito Modular** para MediTriage, con el módulo de
inferencia IA desacoplado mediante comunicación asíncrona (cola de mensajes)
respecto al resto del sistema, permitiendo fallback manual inmediato si el
motor de IA no responde.

## Justificación de la elección técnica para MediTriage

Se elige Monolito Modular con desacoplamiento asíncrono del módulo de IA
porque responde directamente a los 3 NFRs priorizados:

- **Performance (<3s p95):** un monolito evita el overhead de llamadas de
  red entre servicios distribuidos, reduciendo la latencia total del
  pipeline de inferencia.
- **Seguridad y Privacidad:** centralizar el sistema en un único despliegue
  simplifica aplicar cifrado en reposo/tránsito y enmascaramiento de PII de
  forma consistente, en vez de replicar controles de seguridad en múltiples
  servicios.
- **Disponibilidad (99.5% + fallback):** el módulo de IA se desacopla
  mediante una cola asíncrona. Si el motor de inferencia falla o se
  satura, el resto del sistema (registro, triage manual, tablero) sigue
  operando con normalidad, habilitando el fallback manual sin bloquear la
  atención de pacientes.

## Consecuencias
**Gana:**
- Operación simple para un equipo pequeño y un MVP: un solo deploy, sin la
  complejidad operacional de una red de microservicios.
- Transacciones ACID naturales para el registro de pacientes y el audit log,
  evitando problemas de consistencia eventual en datos clínicos sensibles.
- El desacoplamiento asíncrono del módulo de IA refuerza la disponibilidad
  99.5% con fallback (detallado arriba).

**Pierde / se vuelve más difícil:**
- Requiere disciplina real de módulos: si los límites internos no se
  respetan, el monolito se convierte en un "big ball of mud" difícil de
  mantener.
- El módulo de IA, aunque desacoplado a nivel de comunicación, sigue
  desplegándose junto al resto — si en el futuro necesita escalar de forma
  independiente (por ejemplo, más cómputo para el modelo), la extracción a
  un servicio separado tendrá un costo de refactor.
- No hay aislamiento de fallos tan fuerte como en microservicios: un bug
  grave en otro módulo podría, en teoría, afectar la disponibilidad general
  (mitigado parcialmente por el diseño modular y el fallback manual).

## Alternativas descartadas
- **Microservicios desde el día 0:** descartado por el tamaño del equipo y
  la madurez del dominio. La complejidad operacional (red como punto único
  de falla, consistencia eventual, múltiples despliegues) no se justifica
  para un MVP académico, y el riesgo de latencia agregada por llamadas de
  red entre servicios pone en riesgo el NFR de <3s p95.
- **Event-driven puro (todo el sistema, no solo el módulo de IA):**
  descartado porque dificulta rastrear el flujo clínico completo y exige
  garantías de idempotencia y orden que agregan complejidad innecesaria para
  el alcance actual del proyecto. Se aprovecha su ventaja (desacoplamiento
  asíncrono) solo para el módulo de IA, no para todo el sistema.

## Stack y tecnologías tentativas por contenedor
- **Frontend (SPA):** interfaz de triage para la enfermera + formulario de
  registro del paciente. Tecnología tentativa: React o Vue.
- **API / Backend (Monolito Modular):** módulos internos separados por
  bounded context (registro de pacientes, triage, auditoría). Tecnología
  tentativa: Node.js (NestJS) o Python (FastAPI/Django).
- **Base de datos:** almacenamiento relacional para datos clínicos y
  paciente, con cifrado en reposo habilitado. Tecnología tentativa:
  PostgreSQL con extensión de cifrado (pgcrypto) o cifrado a nivel de disco.
- **Cola / broker asíncrono:** desacopla las solicitudes de inferencia del
  resto del sistema y habilita el fallback si el motor de IA no responde.
  Tecnología tentativa: RabbitMQ o Redis Streams.
- **Módulo de inferencia IA:** servicio interno (o proceso worker) que
  consume de la cola, ejecuta el modelo de scoring ESI y publica el
  resultado. Tecnología tentativa: Python (FastAPI + modelo scikit-learn /
  PyTorch) como worker separado dentro del mismo monolito modular.
- **Audit log:** almacenamiento append-only / inmutable para las
  recomendaciones de la IA (retención 5 años). Tecnología tentativa: tabla
  particionada en PostgreSQL con triggers de solo-inserción, o un almacén
  de eventos tipo event store.
