
# PatientRegistration

Payload con los datos del paciente y el check explícito de consentimiento informado. 

## Properties

Name | Type
------------ | -------------
`id` | string
`rut` | string
`fullName` | string
`vitalSigns` | object
`consentGiven` | boolean
`consentTimestamp` | Date

## Example

```typescript
import type { PatientRegistration } from ''

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "rut": 12.345.678-9,
  "fullName": null,
  "vitalSigns": null,
  "consentGiven": null,
  "consentTimestamp": null,
} satisfies PatientRegistration

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as PatientRegistration
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


