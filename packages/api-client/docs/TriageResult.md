
# TriageResult

Objeto que contiene la categoría ESI calculada por la IA y su justificación clínica explicable. 

## Properties

Name | Type
------------ | -------------
`id` | string
`patientId` | string
`esiCategory` | number
`justification` | string
`confirmedByNurse` | boolean
`status` | string

## Example

```typescript
import type { TriageResult } from ''

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "patientId": null,
  "esiCategory": null,
  "justification": null,
  "confirmedByNurse": null,
  "status": null,
} satisfies TriageResult

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as TriageResult
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


