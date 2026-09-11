# ADR 0003 · Estilo Cloud y Servicios Gestionados

## Estado
Aceptado - 10/09/2026

## Contexto
MediTriage necesita pasar de una arquitectura definida (Monolito Modular) a un despliegue en la nube para probar el MVP. Se requiere cumplir con los NFRs definidos en el ADR 0002: latencia de inferencia <3s (p95), cifrado de PII (Leyes 19.628 y 21.719) y un SLA de 99.5%.

## Decisión
Se mantiene el Monolito Modular, pero se desplegará utilizando servicios gestionados de **AWS (Amazon Web Services)**, apoyándonos en la capa gratuita (AWS Free Tier) para mantener los costos controlados durante el MVP.

Los servicios elegidos por contenedor son:
- Frontend (SPA): AWS Amplify
- API Backend: AWS Elastic Beanstalk
- Worker de IA: AWS Lambda
- Base de Datos (PostgreSQL): Amazon RDS
- Broker de Mensajería: Amazon SQS

## Justificación de los trade-offs

**Por qué AWS y no PaaS 100% gratuito (Vercel/Render):** 
Aunque proveedores como Render y Vercel no exigen tarjeta de crédito, sus capas gratuitas sufren de "cold starts" severos tras inactividad. Esto rompe directamente nuestro atributo de calidad de latencia (<3s). AWS (mediante Lambda y Beanstalk) nos da mayor control sobre los tiempos de respuesta clínicos. Además, AWS KMS y las VPC nos entregan el nivel de seguridad y cifrado legal que exige el manejo de datos médicos sensibles (PII).

**El riesgo asumido:** 
AWS Free Tier requiere ingresar una tarjeta de crédito y tiene límites de uso mensual. Se asume el riesgo de posibles cobros menores si el tráfico supera la capa gratuita, priorizando garantizar la disponibilidad (SLA 99.5%) y la velocidad del triage. El equipo mitigará esto configurando alertas de facturación (Billing Alarms).

## Consecuencias
**Gana:**
- Infraestructura de grado empresarial con un solo proveedor unificado.
- Cumplimiento estricto de los NFRs de seguridad (cifrado en tránsito y reposo) y latencia clínica.
- Escalabilidad automática asegurada para el Worker de IA mediante Lambda.

**Pierde / se vuelve más difícil:**
- Riesgo financiero: requiere monitoreo activo de costos (FinOps) para evitar sorpresas en la tarjeta de crédito.
- Mayor curva de aprendizaje para el equipo al configurar redes privadas (VPC) y permisos (IAM) en comparación con un PaaS simple.
