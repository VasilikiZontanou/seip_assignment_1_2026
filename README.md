# Software Engineering in Practice — Assignment 1 (2026) | Vasiliki (Vicky) Zontanou
## Advanced DevOps: Production-Grade CI/CD, External Configuration, and Orchestration
A containerized Node.js Express application deployed to a local Kubernetes cluster via an automated GitHub Actions CI/CD pipeline.

---

## Prerequisites

Ensure the following tools are installed on your local machine before proceeding:

- [Git](https://git-scm.com/) & a verified GitHub account
- [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)

---

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── ci-cd.yaml        # GitHub Actions CI/CD pipeline
├── k8s/
│   ├── configmap.yaml        # Non-sensitive environment configuration
│   ├── secret.yaml           # Base64-encoded sensitive credentials
│   ├── deployment.yaml       # Kubernetes Deployment (3 replicas)
│   └── service.yaml          # ClusterIP Service
├── Dockerfile                # Production-optimized container blueprint
├── server.js                 # Node.js Express application (not modified)
├── package.json
└── README.md
```

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/VasilikiZontanou/seip_assignment_1_2026.git
cd seip_assignment_1_2026
```

---

## Step 2: Start Minikube

Start a local Kubernetes cluster using Minikube:

```bash
minikube start
```

Wait for the cluster to initialize. You should see a message confirming kubectl is configured to use the `minikube` cluster.

---

## Step 3: Apply the Kubernetes Manifests

Apply all manifests in the `k8s/` directory with a single command:

```bash
kubectl apply -f k8s/
```

Expected output:

```
configmap/echo-api-config created
secret/echo-api-secret created
deployment.apps/echo-api-deployment created
service/echo-api-service created
```

---

## Step 4: Verify the Cluster State

Check that all 3 pods are running and the service is available:

```bash
kubectl get all -n default
```

You should see 3 pods with `Running` status, the deployment showing `3/3` ready, and the `echo-api-service` ClusterIP service.

Verify the ConfigMap and Secret were created:

```bash
kubectl get configmap,secret
```

You should see `echo-api-config` and `echo-api-secret` listed.

---

## Step 5: Access the Application

Since the service is of type `ClusterIP` (internal only), use `kubectl port-forward` to expose it to your local machine:

```bash
kubectl port-forward service/echo-api-service 9090:80
```

Keep this terminal open while accessing the application. The app is now available at `http://localhost:9090`.

---

## API Endpoints

With port-forwarding active, test the following endpoints in your browser or with `curl`:

| Endpoint | Description | Expected Response |
|---|---|---|
| `GET /` | Returns the welcome message and environment | `{"message":"...","environment":"production"}` |
| `GET /health` | Health check used by Kubernetes probes | `{"status":"Healthy"}` |
| `GET /secure-config` | Returns authorization status and masked secret suffix | `{"status":"Authorized","injected_secret_suffix":"**********XXXX"}` |

**Example curl commands:**

```bash
curl http://localhost:9090/
curl http://localhost:9090/health
curl http://localhost:9090/secure-config
```

---

## CI/CD Pipeline

The GitHub Actions workflow at `.github/workflows/ci-cd.yaml` automates the following steps on every push to the `main` branch:

1. **Checkout** — checks out the repository code.
2. **Authenticate** — logs into GHCR using the built-in `GITHUB_TOKEN` (no manual secrets required).
3. **Build & Push** — builds the Docker image from the Dockerfile and pushes it to `ghcr.io/vasilikiZontanou/echo-api:latest`.

The published image can be viewed at:
`https://github.com/VasilikiZontanou?tab=packages`
