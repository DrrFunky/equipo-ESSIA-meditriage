
# CreateTriageEvaluationRequestVitalSigns

Signos vitales medidos al ingreso.

## Properties

Name | Type
------------ | -------------
`heartRate` | number
`bloodPressureSystolic` | number
`bloodPressureDiastolic` | number
`temperatureCelsius` | number
`oxygenSaturationPercentage` | number

## Example

```typescript
import type { CreateTriageEvaluationRequestVitalSigns } from ''

// TODO: Update the object below with actual values
const example = {
  "heartRate": null,
  "bloodPressureSystolic": null,
  "bloodPressureDiastolic": null,
  "temperatureCelsius": null,
  "oxygenSaturationPercentage": null,
} satisfies CreateTriageEvaluationRequestVitalSigns

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CreateTriageEvaluationRequestVitalSigns
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


