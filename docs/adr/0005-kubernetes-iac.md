# ADR 0005 · Plataforma Base: Contenedores, Kubernetes e Infraestructura como Código (IaC)

## Estado
Propuesto - 15/10/2026

## Contexto
Continuando con la evolución arquitectónica de MediTriage (ADR 0003 y ADR 0004), el equipo necesita definir el estándar tecnológico para el ciclo de vida de los microservicios clínicos. Se requiere asegurar que los despliegues sean reproducibles, escalables ante variaciones de carga en los servicios de urgencia, y altamente seguros para proteger la infraestructura frente a vulnerabilidades. Además, la creación y configuración de la infraestructura debe ser auditable y automatizada para evitar el "drift" (desvío) de configuración manual.

## Decisión
Se adoptan las siguientes herramientas y patrones de plataforma:

1. **Empaquetado de Contenedores:** 
   - **Estrategia:** Docker con *multi-stage builds*.
   - **Runtime:** Imágenes base **distroless** (ej. `gcr.io/distroless/python3-debian12`).
   - **Seguridad:** Ejecución estricta con directiva `USER nonroot`.
   - **Trazabilidad:** Etiquetado inmutable por *digest* (`@sha256:...`), prohibiendo explícitamente el uso del tag `:latest` en producción.

2. **Orquestación:** 
   - **Motor:** Kubernetes. Para ambientes productivos se utilizará Amazon EKS (alineado con la exclusividad AWS del ADR 0003). Para desarrollo local, clústeres efímeros con `kind` o `minikube`.
   - **Escalabilidad:** Implementación de Horizontal Pod Autoscaler (HPA) basado en métricas de CPU (objetivo 65%) y latencia.

3. **Infraestructura como Código (IaC):** 
   - **Herramienta:** Terraform (HCL).
   - **Gestión de Estado:** Backend remoto (S3) con bloqueo de estado (*state locking*) obligatorio mediante DynamoDB.

## Justificación de los trade-offs

**Por qué Distroless y Multi-stage:** 
En un contexto de salud, minimizar la superficie de ataque es vital. El enfoque *multi-stage* compila las dependencias en una capa y transfiere solo los binarios al *runtime*. Las imágenes *distroless* carecen de gestores de paquetes (ej. `apt`), `shell` (bash/sh) y utilidades de red (`curl`, `wget`). Si un atacante logra comprometer la aplicación (RCE), no tendrá herramientas para escalar el ataque o descargar payloads externos. Además, forzar `USER nonroot` evita el escalamiento de privilegios hacia el nodo *host*.

**Por qué Kubernetes (EKS):** 
Kubernetes provee la resiliencia que un sistema de triage requiere: *self-healing* (reinicio de contenedores caídos) y *Zero Downtime Deployments* nativos. Aunque AWS ECS es más simple, Kubernetes es el estándar agnóstico de la industria y facilita la migración si MediTriage se comercializa *on-premise* en hospitales en el futuro. El HPA garantiza que el sistema escale horizontalmente de forma automática si hay picos de concurrencia en la sala de urgencias.

**Por qué Terraform y no CloudFormation o Pulumi:** 
Terraform ofrece un equilibrio ideal entre madurez del ecosistema y control declarativo. A diferencia de CloudFormation (propietario de AWS), Terraform permite gestionar múltiples *providers* (AWS, Kubernetes, GitHub) con el mismo flujo de trabajo. Frente a Pulumi, el lenguaje HCL de Terraform impone una barrera declarativa que evita que la infraestructura se convierta en "código espagueti" imperativo. El uso de S3 + DynamoDB para el backend asegura que si dos ingenieros (ej. DevSecOps y Tech Lead) aplican cambios simultáneos, no se corromperá el estado de la infraestructura.

## Consecuencias

**Gana:**
- **Seguridad *Zero Trust*:** Contenedores mínimos sin shell previenen inyecciones y movimientos laterales.
- **Auditoría y GitOps:** Toda la infraestructura está versionada en Git. Cada cambio es un *commit* revisable.
- **Inmutabilidad:** El tag por SHA256 garantiza que la imagen que pasó QA sea exactamente la misma que corre en producción.
- **Disponibilidad:** El HPA previene caídas por agotamiento de recursos.

**Pierde / se vuelve más difícil:**
- **Debugging en producción:** Al no haber *shell* ni comandos básicos en la imagen *distroless*, tareas como un simple `ping` o ejecutar comandos dentro del pod (`kubectl exec`) se vuelven complejas. El equipo deberá depender exclusivamente de observabilidad remota, logs estructurados y contenedores efímeros de depuración (K8s Ephemeral Containers).
- **Curva de aprendizaje:** El equipo debe manejar YAMLs de Kubernetes y configuración HCL de Terraform.
- **Gestión del Estado:** Riesgo operativo si un desarrollador aplica cambios sin conectarse al *backend* remoto de Terraform (corrupción del *state*).
- **Costos Base (FinOps):** El *Control Plane* de EKS tiene un costo por hora fijo que no aplica la capa gratuita, lo que encarece el MVP frente a un despliegue puramente Serverless o Monolítico.
