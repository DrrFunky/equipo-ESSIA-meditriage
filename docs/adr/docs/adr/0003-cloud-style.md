# ADR 0003 · Estilo Cloud y Servicios Gestionados

## Estado
Aceptado - 10/09/2026

## Contexto
MediTriage necesita pasar de una arquitectura definida (ADR 0002: Monolito
Modular con desacoplamiento asíncrono del módulo de IA) a un despliegue real
en la nube para probar la viabilidad del MVP. Las restricciones del proyecto
son claras:

- **Sin presupuesto:** proyecto académico, no se puede exigir tarjeta de
  crédito personal a los integrantes del equipo.
- **Sin equipo de operaciones:** no hay un SRE ni DevOps a tiempo completo
  que pueda operar infraestructura propia (IaaS) de forma segura.
- **Time-to-market corto:** se necesita un entorno funcional para demostrar
  el producto en las próximas sesiones, no en semanas.
- **Los NFRs del ADR 0002 siguen vigentes:** latencia de inferencia <3s
  (p95), cifrado en tránsito y en reposo, y disponibilidad con fallback
  manual si el motor de IA falla.

Bajo el framework de decisión visto en el taller (¿es diferenciador del
producto? → constrúyelo; ¿existe un servicio managed maduro? → úsalo),
ninguno de los componentes de infraestructura (hosting web, base de datos,
cola de mensajes) es diferenciador de MediTriage — el diferenciador real es
el motor de IA que sugiere el ESI. Por lo tanto, toda la infraestructura de
soporte debe delegarse a servicios gestionados.

## Decisión
Se mantiene el **Monolito Modular** definido en el ADR 0002, desplegado en
la nube mediante una estrategia **PaaS (Platform as a Service) en capa
100% gratuita**, sin migrar a Serverless ni a una arquitectura de
microservicios. Los servicios gestionados elegidos por contenedor son:

| Contenedor | Servicio elegido | Plan |
|---|---|---|
| Frontend (SPA) | Vercel | Hobby Tier (gratis) |
| API Backend + Worker IA | Render | Free Web Services & Background Workers |
| Base de datos (PostgreSQL) | Supabase | Free Tier |
| Broker de mensajería (colas) | CloudAMQP | Plan "Little Lemur" |

## Justificación de los trade-offs

**Por qué PaaS y no otra estrategia:**
- **Vs. IaaS propio (ej. EC2/VMs manuales):** descartado porque requiere
  operar el sistema operativo, parches de seguridad, escalado manual y
  configuración de red — trabajo que ningún integrante del equipo tiene
  tiempo ni experiencia de sobra para hacer bien. PaaS delega todo eso al
  proveedor.
- **Vs. Serverless completo (ej. Lambda + API Gateway):** descartado porque
  obligaría a reescribir el backend como funciones stateless independientes,
  perdiendo la simplicidad del Monolito Modular que ya se justificó en el
  ADR 0002. Migrar ahora implicaría un costo de refactor no justificado para
  un MVP.
- **PaaS es el punto intermedio correcto:** mantiene la topología del
  Monolito Modular (un backend, un worker de IA, una base de datos, una
  cola), pero cada pieza corre en un servicio gestionado sin que el equipo
  tenga que operar servidores.

**Qué se sacrifica:**
- **Cold start en Render:** los servicios gratuitos entran en "spin down"
  tras 15 minutos sin tráfico, generando un retraso perceptible en la
  primera petición tras inactividad. Esto entra en tensión directa con el
  NFR de latencia <3s (p95) del ADR 0002 — **en un entorno de evaluación
  académica es aceptable**, porque el tráfico de prueba es intermitente y
  no hay pacientes reales esperando. **En un despliegue de producción real,
  este trade-off dejaría de ser aceptable** y obligaría a migrar a un plan
  pago con "always-on" para no arriesgar vidas por un timeout evitable.
- **Límite de almacenamiento (Supabase 500MB):** suficiente para el volumen
  de datos de un MVP académico (perfiles, logs de auditoría, consentimientos
  informados), pero no escalaría a un hospital real sin subir de plan.
- **Dependencia de múltiples proveedores distintos:** al usar Vercel +
  Render + Supabase + CloudAMQP en vez de un solo proveedor (ej. todo en
  AWS), se gana costo cero, pero se pierde la conveniencia de una sola
  consola de administración y se introduce más superficie de configuración
  de red/CORS entre servicios de distintos dominios.

## Consecuencias
**Gana:**
- Despliegue funcional sin costo, permitiendo validar el MVP antes de
  cualquier inversión real.
- Mantiene la coherencia arquitectónica con el ADR 0002: el desacoplamiento
  asíncrono del motor de IA se traduce directamente a CloudAMQP como cola
  gestionada, sin cambiar el diseño lógico del sistema.
- Cifrado en tránsito (HTTPS por defecto en Vercel) y en reposo (Supabase)
  cumplen el NFR de seguridad y privacidad sin configuración adicional.

**Pierde / se vuelve más difícil:**
- El cold start de Render introduce latencia variable no controlada por el
  equipo, riesgo que debe documentarse como limitación conocida del MVP.
- Migrar de un proveedor gratuito a uno pago (cuando el proyecto crezca)
  exige revisar configuración, límites y posibles cambios de API por
  proveedor — mitigado parcialmente si se respeta el patrón Ports &
  Adapters mencionado en el taller (pegar la arquitectura a interfaces, no
  a un proveedor específico).
- Cuatro proveedores distintos significan cuatro paneles de monitoreo
  separados, dificultando la observabilidad centralizada en esta etapa.

## Alternativas descartadas
- **IaaS propio (EC2, VMs de Azure/GCP):** descartado por falta de
  presupuesto y de un SRE dedicado para operar servidores, parches de
  seguridad y escalado manual.
- **Serverless completo (FaaS para todo el backend):** descartado porque
  exige reescribir el Monolito Modular como funciones independientes,
  perdiendo transacciones ACID naturales y aumentando la complejidad de
  testing para un MVP con tiempo acotado.
- **Un solo proveedor todo-en-uno (ej. todo en AWS con capa gratuita):**
  evaluado pero descartado porque las capas gratuitas de AWS para bases de
  datos administradas (RDS) y colas (SQS) tienen límites de tiempo (12
  meses) o requieren tarjeta de crédito, mientras que Vercel/Render/
  Supabase/CloudAMQP no la exigen y son gratuitos de forma indefinida en
  sus tiers actuales.
