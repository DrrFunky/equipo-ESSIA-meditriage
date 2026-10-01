
# CreateTriageEvaluationRequest


## Properties

Name | Type
------------ | -------------
`patientId` | string
`symptoms` | Array&lt;string&gt;
`vitalSigns` | [CreateTriageEvaluationRequestVitalSigns](CreateTriageEvaluationRequestVitalSigns.md)

## Example

```typescript
import type { CreateTriageEvaluationRequest } from ''

// TODO: Update the object below with actual values
const example = {
  "patientId": null,
  "symptoms": ["dolor torácico opresivo","dificultad para respirar"],
  "vitalSigns": null,
} satisfies CreateTriageEvaluationRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CreateTriageEvaluationRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


