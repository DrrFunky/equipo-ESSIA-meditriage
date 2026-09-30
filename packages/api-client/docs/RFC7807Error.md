
# RFC7807Error

Esquema de manejo de errores estructurado según RFC 7807. 

## Properties

Name | Type
------------ | -------------
`type` | string
`title` | string
`status` | number
`detail` | string
`instance` | string

## Example

```typescript
import type { RFC7807Error } from ''

// TODO: Update the object below with actual values
const example = {
  "type": https://meditriage.example.com/errors/validation-error,
  "title": Datos de registro inválidos,
  "status": 400,
  "detail": El campo 'rut' no cumple con el formato esperado.,
  "instance": /v1/patients,
} satisfies RFC7807Error

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as RFC7807Error
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


