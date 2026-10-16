# ADR 0005 · Plataforma Base: Contenedores, Kubernetes e Infraestructura como Código (IaC)

## Estado
Aceptado - 15/10/2026

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
   - **Motor:** Kubernetes. Para ambientes productivos en la nube se utilizará **Amazon EKS**. Para el desarrollo y pruebas en entornos locales, se utilizará el clúster integrado de **Docker Desktop**.
   - **Escalabilidad:** Implementación de Horizontal Pod Autoscaler (HPA) configurado para escalar réplicas basado en uso de CPU (**objetivo del 50%**) y latencia. (Nota: probado y validado en el `hpa.yaml` de la iteración actual).

3. **Infraestructura como Código (IaC):** 
   - **Herramienta:** Terraform (HCL).
   - **Gestión de Estado:** 
     - **Producción (AWS):** Backend remoto en Amazon S3 con bloqueo de estado (*state locking*) obligatorio mediante Amazon DynamoDB.
     - **Desarrollo Local:** Backend de `kubernetes`, almacenando el `.tfstate` como un *Secret* dentro del clúster local de Docker Desktop para simplificar el flujo de trabajo sin depender de la nube.

## Justificación de los trade-offs

**Por qué Kubernetes (EKS) y no alternativas (ECS/Serverless):** 
Kubernetes provee la resiliencia que un sistema de triage requiere: *self-healing* (reinicio de contenedores caídos) y *Zero Downtime Deployments* nativos. Aunque alternativas propietarias como AWS ECS son más simples de operar, Kubernetes es el estándar agnóstico de la industria y facilita la portabilidad si MediTriage deba desplegarse *on-premise* en los servidores del hospital en el futuro.

**Por qué Terraform y no CloudFormation o Pulumi:** 
Terraform ofrece un equilibrio ideal entre madurez del ecosistema y control declarativo. A diferencia de CloudFormation (propietario exclusivo de AWS), Terraform nos permite gestionar múltiples *providers* (AWS, Kubernetes, etc.) con el mismo lenguaje y flujo de trabajo. Frente a Pulumi, el lenguaje HCL de Terraform impone una barrera declarativa que evita que la infraestructura se convierta en código imperativo impredecible. 

**Por qué Distroless y Multi-stage:** 
En un contexto de salud, minimizar la superficie de ataque es vital. El enfoque *multi-stage* compila las dependencias en una capa y transfiere solo los binarios al *runtime*. Las imágenes *distroless* carecen de gestores de paquetes (ej. `apt`), `shell` (bash/sh) y utilidades de red (`curl`, `wget`). Si un atacante logra comprometer la aplicación, no tendrá herramientas para escalar el ataque. Además, forzar `USER nonroot` evita el escalamiento de privilegios hacia el nodo *host*.

## Consecuencias y Limitaciones Actuales

**Gana:**
- **Seguridad *Zero Trust*:** Contenedores mínimos sin shell previenen inyecciones y movimientos laterales.
- **Auditoría y GitOps:** Toda la infraestructura está versionada en Git.
- **Inmutabilidad:** El tag por SHA256 garantiza despliegues 100% predecibles.

**Limitaciones asumidas (Pierde / se vuelve más difícil):**
- **Estado en memoria (Mocking temporal):** Para agilizar esta entrega de infraestructura, los servicios locales podrían estar usando un estado en memoria temporal en lugar de conectar directamente al clúster final de base de datos.
- **Auth Stub:** La autenticación real está temporalmente simulada (*stubbed*), pendiente de integración con el servicio de identidad definitivo.
- **Debugging en producción:** Al no haber *shell* ni comandos básicos en la imagen *distroless*, tareas como ejecutar comandos dentro del pod (`kubectl exec -it`) se vuelven imposibles. El equipo deberá depender de logs estructurados, observabilidad y contenedores efímeros de depuración de K8s.
- **Costos Base (FinOps):** El *Control Plane* de EKS tiene un costo fijo continuo, lo que encarece la arquitectura en producción frente a soluciones monolíticas.
