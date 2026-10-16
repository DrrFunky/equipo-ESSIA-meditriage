# Manifiestos Kubernetes · MediTriage API

| Archivo | Qué define |
|---|---|
| `configmap.yaml` | Configuración no secreta (`APP_ENV`, `LOG_LEVEL`, `PORT`) |
| `deployment.yaml` | 2 réplicas, imagen por digest, usuario non-root, probes y requests/limits |
| `service.yaml` | Service `ClusterIP` (80 → 8000) |
| `ingress.yaml` | Entrada HTTP en `meditriage.local` |
| `hpa.yaml` | Autoescalado por CPU al 50 % (2 a 5 réplicas) |
| `kustomization.yaml` | Permite aplicar todo con `kubectl apply -k k8s/` |

## Cómo desplegar

```bash
kubectl apply -k k8s/
kubectl get all,ingress,configmap -n meditriage
```

## Evidencias

### Recursos desplegados (`kubectl get all`)

<img width="1194" height="87" alt="kubectl-get-all" src="https://github.com/user-attachments/assets/1c5f8380-73bf-4931-8851-f95a46735a43" />


### Prueba del HPA con carga sintética

1. Terminal A: `kubectl get hpa -n meditriage -w`
2. Terminal B (generador de carga):
   ```bash
   kubectl run load-generator -n meditriage --image=busybox:1.36 --restart=Never -- \
     /bin/sh -c "while true; do wget -q -O- http://meditriage-api/health; done"
   ```
3. Capturar cuando `TARGETS` supere 50 % y `REPLICAS` suba de 2.
4. Limpiar: `kubectl delete pod load-generator -n meditriage`

<img width="1107" height="407" alt="hpa-scaling" src="https://github.com/user-attachments/assets/7e5181cf-31c2-4cbf-8ff7-0cd5b29f0750" />

