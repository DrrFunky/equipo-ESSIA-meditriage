# language: es
Característica: US02 - Formulario de síntomas y captura de signos vitales
  Como Enfermera de Triage
  Quiero registrar los signos vitales y síntomas reportados del paciente
  Para proveer la información clínica requerida por el motor de priorización

  Escenario: Captura completa de constantes vitales dentro de rangos normales (Camino Feliz)
    Dado que la enfermera ingresa los signos vitales: FC "75 bpm", PA "120/80", SatO2 "98%", Temp "36.5°C"
    Y describe el motivo de consulta "Cefalea leve de 2 horas de evolución"
    Cuando presiona "Enviar a evaluación de triage"
    Entonces el sistema valida y almacena los datos de forma cifrada
    Y los envía al motor de IA para su categorización.

  Escenario: Captura con signos vitales en el umbral crítico (Caso Borde)
    Dado que la enfermera registra una saturación de oxígeno de "90%" en el límite crítico
    Cuando confirma el ingreso de los datos
    Entonces el sistema marca una alerta visual de "Parámetro crítico en límite inferior"
    Y prioriza el envío inmediato al motor de evaluación.

  Escenario: Intento de envío con campos obligatorios vacíos (Caso de Error)
    Dado que la enfermera omite el campo obligatorio de "Presión Arterial"
    Cuando intenta enviar el formulario
    Entonces el sistema impide el envío
    Y resalta el campo faltante con el mensaje "Debe ingresar la presión arterial para continuar".