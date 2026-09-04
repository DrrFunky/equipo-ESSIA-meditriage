### Mapeo de Puertos y Protocolos

* **SPA Web ↔ API Backend:** Comunicación bidireccional externa vía **HTTPS (Puerto 443)** utilizando *payloads* en formato JSON. Garantiza el cifrado en tránsito desde el dispositivo del usuario hasta los servidores.
* **API Backend ↔ Servicio de IA:** Comunicación interna de baja latencia utilizando **gRPC (Puerto 50051)** con *Protocol Buffers*. Esto asegura que la respuesta de triage se procese en menos de 3 segundos, cumpliendo el requerimiento de latencia.
* **API Backend ↔ Base de Datos (PostgreSQL):** Conexión interna vía **TCP/TLS (Puerto 5432)**.
* **API Backend ↔ Broker de Auditoría:** Conexión interna vía **AMQP (Puerto 5672)** para encolar los eventos sin bloquear el hilo principal de ejecución, asegurando alta disponibilidad.

### Flujo de Enmascaramiento de PII (Cumplimiento Ley 19.628)

1. **Captura en Texto Plano:** La SPA Web envía el RUT y el nombre del paciente a la API Backend mediante HTTPS.
2. **Punto de Intercepción (Backend):** La API Backend es el único componente que conoce la identidad real del paciente para poder guardar el registro de ingreso y el consentimiento informado en la Base de Datos.
3. **Proceso de Enmascaramiento:** Antes de que la API Backend solicite la sugerencia ESI, ejecuta una función de enmascaramiento (ej. *hashing* criptográfico SHA-256 o tokenización) sobre el RUT, nombre y cualquier dato de contacto.
4. **Derivación Segura:** 
    * El **Servicio de IA** recibe exclusivamente los síntomas, signos vitales y un ID anonimizado a través de gRPC. La IA nunca lee el RUT.
    * El **Broker de Auditoría** recibe el evento de la decisión de IA asociado a un ID tokenizado, garantizando que los logs inmutables a 5 años no contengan Información de Identificación Personal directa, previniendo fugas de datos de salud sensibles.