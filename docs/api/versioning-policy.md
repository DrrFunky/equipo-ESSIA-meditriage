# Política de Versionado y Evolución de API - MediTriage

Para garantizar la estabilidad de los clientes (SPA, tableros médicos, integraciones HIS) y mantener un diseño RESTful maduro, MediTriage adopta las siguientes políticas:

1. **Versionado Explícito en URI:** Todas las rutas de la API deben incluir la versión mayor en el path (ej. `/v1/triage-requests`).
2. **Evolución sin Ruptura (Non-breaking changes):** Queda estrictamente prohibido romper contratos existentes. Las actualizaciones solo pueden:
   * Agregar nuevos campos opcionales a los schemas de respuesta o request.
   * Agregar nuevos endpoints.
3. **Manejo de Errores Estandarizado:** Todos los errores retornados por la API deben cumplir estrictamente con el estándar **RFC 7807** (Problem Details for HTTP APIs), incluyendo campos como `type`, `title`, `status`, `detail`, `instance` y `trace_id` para facilitar la observabilidad[cite: 30].
4. **Idempotencia:** Las operaciones de mutación críticas (como registrar signos vitales o confirmar triage) exigirán el header `Idempotency-Key` en los métodos POST y PATCH, cacheando la respuesta por 24 horas para evitar duplicidades[cite: 30].