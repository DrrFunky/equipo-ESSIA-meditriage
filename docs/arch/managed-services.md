# Servicios Gestionados Cloud (MediTriage)

**Autor:** Martín Durán (DevSecOps & Compliance Lead)
**Proveedor Cloud Seleccionado:** AWS (Amazon Web Services)
**Objetivo:** Cumplir con SLA de 99.5%, protección de PII (Leyes 19.628 y 21.719) y optimización de costos para el MVP.

La siguiente selección de infraestructura en la nube define los contenedores de nuestro sistema, equilibrando la máxima seguridad clínica con los límites de la capa gratuita (AWS Free Tier) para no disparar el presupuesto inicial.

## 1. Frontend (Aplicación SPA Web)
*   **Servicio AWS:** AWS Amplify Hosting.
*   **SLA 99.5%:** Despliega la aplicación globalmente usando la red de CloudFront, asegurando alta disponibilidad frente a caídas regionales.
*   **Protección PII:** Emite y renueva automáticamente certificados SSL/TLS, forzando que la captura de síntomas y RUT en el formulario viaje exclusivamente por HTTPS cifrado hacia la API.

## 2. API Backend (Python / FastAPI)
*   **Servicio AWS:** AWS Elastic Beanstalk (Entorno Docker de instancia única para MVP).
*   **SLA 99.5%:** Monitorea la salud del contenedor web y lo reinicia automáticamente en caso de fallo, manteniendo la recepción de triage operativa.
*   **Protección PII:** Actúa como la zona de intercepción. Se configura en una red privada virtual (VPC) aislada, siendo el único punto autorizado para ejecutar el enmascaramiento del RUT antes de derivar la información.

## 3. Base de Datos Relacional (PostgreSQL)
*   **Servicio AWS:** Amazon RDS para PostgreSQL (Capa gratuita `db.t3.micro`).
*   **SLA 99.5%:** Los respaldos automáticos y las ventanas de mantenimiento gestionadas por AWS aseguran que el registro de pacientes no se pierda por fallos de hardware.
*   **Protección PII:** Es crítico para DevSecOps. Se habilitará el **cifrado en reposo (AES-256)** integrado con AWS KMS. En caso de una vulneración del servidor físico, la base de datos de historiales médicos y consentimientos informados será ilegible sin las llaves maestras.

## 4. Broker de Mensajería (Colas de IA y Auditoría)
*   **Servicio AWS:** Amazon SQS (Simple Queue Service - Estándar).
*   **SLA 99.5%:** Es un servicio serverless con escalamiento infinito. Garantiza que si la IA sufre un cuello de botella, ninguna solicitud de paciente se pierda; todas quedan encoladas de forma segura.
*   **Protección PII:** Recibe los datos desde la API ya enmascarados y aplica cifrado en tránsito (TLS) y en reposo (SSE-SQS) sobre las colas, asegurando el cumplimiento legal del audit log.

## 5. Servicio de IA (Worker de Inferencia)
*   **Servicio AWS:** AWS Lambda (Container Image Support).
*   **SLA 99.5% & Costos:** Al usar *serverless functions*, el sistema escala automáticamente si llegan muchos pacientes de urgencia a la vez. Lo más importante para el presupuesto: **solo se cobra por el tiempo exacto de procesamiento**. Si no hay pacientes, el costo del Worker de IA es $0.
