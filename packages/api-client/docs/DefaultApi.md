# DefaultApi

All URIs are relative to *https://api.meditriage.example.com/v1*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**createTriageEvaluation**](DefaultApi.md#createtriageevaluationoperation) | **POST** /triage-evaluations | Solicitar una evaluación de triage asistida por IA |
| [**getAuditLogs**](DefaultApi.md#getauditlogs) | **GET** /audit-logs | Consultar el registro de auditoría de decisiones IA |
| [**getTriageBoard**](DefaultApi.md#gettriageboard) | **GET** /triage-board | Consultar el tablero de pacientes priorizados |
| [**registerPatient**](DefaultApi.md#registerpatient) | **POST** /patients | Registrar un nuevo paciente |
| [**updateTriageEvaluation**](DefaultApi.md#updatetriageevaluationoperation) | **PATCH** /triage-evaluations/{id} | Confirmar o aplicar fallback manual sobre una evaluación |



## createTriageEvaluation

> TriageResult createTriageEvaluation(idempotencyKey, createTriageEvaluationRequest)

Solicitar una evaluación de triage asistida por IA

Envía los signos vitales y síntomas del paciente para que el motor de IA sugiera la categoría ESI y su justificación clínica (mapea Historias 1 y 2: Sugerencia ESI automatizada y Justificación clínica explicable). 

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '';
import type { CreateTriageEvaluationOperationRequest } from '';

async function example() {
  console.log("🚀 Testing  SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: BearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    idempotencyKey: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // CreateTriageEvaluationRequest
    createTriageEvaluationRequest: ...,
  } satisfies CreateTriageEvaluationOperationRequest;

  try {
    const data = await api.createTriageEvaluation(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` |  | [Defaults to `undefined`] |
| **createTriageEvaluationRequest** | [CreateTriageEvaluationRequest](CreateTriageEvaluationRequest.md) |  | |

### Return type

[**TriageResult**](TriageResult.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`, `application/problem+json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | Evaluación aceptada y encolada para procesamiento asíncrono |  -  |
| **400** | Datos de evaluación inválidos |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getAuditLogs

> Array&lt;GetAuditLogs200ResponseInner&gt; getAuditLogs(from, to)

Consultar el registro de auditoría de decisiones IA

Devuelve el registro inmutable de recomendaciones de la IA para fines de trazabilidad. 

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '';
import type { GetAuditLogsRequest } from '';

async function example() {
  console.log("🚀 Testing  SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: BearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // Date (optional)
    from: 2013-10-20,
    // Date (optional)
    to: 2013-10-20,
  } satisfies GetAuditLogsRequest;

  try {
    const data = await api.getAuditLogs(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **from** | `Date` |  | [Optional] [Defaults to `undefined`] |
| **to** | `Date` |  | [Optional] [Defaults to `undefined`] |

### Return type

[**Array&lt;GetAuditLogs200ResponseInner&gt;**](GetAuditLogs200ResponseInner.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | Registro de auditoría |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getTriageBoard

> Array&lt;TriageResult&gt; getTriageBoard()

Consultar el tablero de pacientes priorizados

Devuelve el listado de pacientes priorizados en tiempo real. 

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '';
import type { GetTriageBoardRequest } from '';

async function example() {
  console.log("🚀 Testing  SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: BearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  try {
    const data = await api.getTriageBoard();
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters

This endpoint does not need any parameter.

### Return type

[**Array&lt;TriageResult&gt;**](TriageResult.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | Listado de pacientes priorizados |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## registerPatient

> PatientRegistration registerPatient(idempotencyKey, patientRegistration)

Registrar un nuevo paciente

Registra un paciente (mapea Historia 3: registro y validación de RUT) junto con el check explícito de consentimiento informado. Historia Must Have según priorización MoSCoW — obligatoria por la Ley 19.628 para procesar datos sensibles de salud. 

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '';
import type { RegisterPatientRequest } from '';

async function example() {
  console.log("🚀 Testing  SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: BearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string | Clave única generada por el cliente para evitar registros duplicados si la solicitud se reenvía (ej. por mala conexión). 
    idempotencyKey: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // PatientRegistration
    patientRegistration: ...,
  } satisfies RegisterPatientRequest;

  try {
    const data = await api.registerPatient(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **idempotencyKey** | `string` | Clave única generada por el cliente para evitar registros duplicados si la solicitud se reenvía (ej. por mala conexión).  | [Defaults to `undefined`] |
| **patientRegistration** | [PatientRegistration](PatientRegistration.md) |  | |

### Return type

[**PatientRegistration**](PatientRegistration.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`, `application/problem+json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **201** | Paciente registrado exitosamente |  -  |
| **400** | Datos de registro inválidos |  -  |
| **409** | Conflicto de idempotencia (solicitud duplicada con datos distintos) |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## updateTriageEvaluation

> TriageResult updateTriageEvaluation(id, idempotencyKey, updateTriageEvaluationRequest)

Confirmar o aplicar fallback manual sobre una evaluación

Permite a la enfermera de triage confirmar la sugerencia ESI generada por la IA, o aplicar el fallback manual si el motor de IA no respondió. 

### Example

```ts
import {
  Configuration,
  DefaultApi,
} from '';
import type { UpdateTriageEvaluationOperationRequest } from '';

async function example() {
  console.log("🚀 Testing  SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: BearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new DefaultApi(config);

  const body = {
    // string
    id: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // string
    idempotencyKey: 38400000-8cf0-11bd-b23e-10b96e4ef00d,
    // UpdateTriageEvaluationRequest
    updateTriageEvaluationRequest: ...,
  } satisfies UpdateTriageEvaluationOperationRequest;

  try {
    const data = await api.updateTriageEvaluation(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **id** | `string` |  | [Defaults to `undefined`] |
| **idempotencyKey** | `string` |  | [Defaults to `undefined`] |
| **updateTriageEvaluationRequest** | [UpdateTriageEvaluationRequest](UpdateTriageEvaluationRequest.md) |  | |

### Return type

[**TriageResult**](TriageResult.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`, `application/problem+json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | Evaluación actualizada |  -  |
| **404** | Evaluación no encontrada |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

