# 12-Factor Checklist - MediTriage

| Factor | Estado | Acción (Gaps detectados) | Responsable |
| :--- | :--- | :--- | :--- |
| **01. Codebase** | Cumple | Mantener un repositorio único en Git para el monolito modular de MediTriage. Evitar código copiado entre servicios. | Cristóbal Araos |
| **02. Dependencies** | Cumple | Declarar librerías de forma aislada (ej. `requirements.txt` o Poetry para FastAPI, `package.json` para Next.js). No depender del SO subyacente. | Cristóbal Araos |
| **03. Config** | **No Cumple** | Eliminar archivos estáticos tipo `config.dev.json` del repositorio. Las llaves de BD y endpoints (ej. `DATABASE_URL`) deben inyectarse como variables de entorno. | Martín Durán |
| **04. Backing services** | Cumple | PostgreSQL y RabbitMQ deben ser tratables como recursos adjuntos, conectables vía URL sin recompilar el código. | Cristóbal Araos |
| **05. Build, release, run** | **No Cumple** | Configurar el pipeline CI/CD para separar estrictamente la compilación de la ejecución. Prohibido editar código directamente en producción. | Martín Durán |
| **06. Processes** | Cumple | Los procesos del backend deben ser stateless. La sesión y el estado del triage no deben vivir en la memoria del proceso[cite: 17]. | Cristóbal Araos |
| **07. Port binding** | Cumple | La aplicación debe publicar su propio puerto (FastAPI/Next.js) sin depender de servidores externos pesados[cite: 17]. | Cristóbal Araos |
| **08. Concurrency** | Cumple | Escalar mediante la adición de procesos (ej. múltiples workers de IA), en lugar de depender de hilos internos o escalado vertical infinito[cite: 17]. | Cristóbal Araos |
| **09. Disposability** | **No Cumple** | Implementar un *graceful shutdown* en el Worker de IA. El pod debe recibir la señal `SIGTERM` y terminar de procesar o devolver el mensaje a la cola en <30s[cite: 17]. | Alonso Plane |
| **10. Dev/prod parity** | Cumple | Mantener los entornos locales, de staging y producción lo más idénticos posible utilizando contenedores. | Martín Durán |
| **11. Logs** | **No Cumple** | Tratar los logs como flujos de eventos. Dirigirlos a `stdout` (ej. logs JSON estructurados) para que un agregador externo enmascare la PII[cite: 17]. | Martín Durán |
| **12. Admin processes** | Cumple | Ejecutar scripts de administración (ej. migraciones de BD) en un entorno idéntico al de los procesos regulares de la app. | Cristóbal Araos |