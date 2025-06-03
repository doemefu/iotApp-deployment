# IoT Application Deployment

This repository contains the automation and Kubernetes manifests for the IoT Application. The original project began as a monolithic Spring Boot backend and has been refactored into a set of microservices. All services run in containers and are orchestrated on a Raspberry Pi via K3s.

## Microservices Overview

| Service | Language | Responsibilities |
|---------|----------|-----------------|
| Auth Service | Java / Spring Boot | Authentication, JWT generation and validation |
| User Management Service | Java / Spring Boot | Manage users, roles and permissions |
| Device Management Service | Python / FastAPI | Register and monitor IoT devices, handle MQTT messages |
| Data Processing Service | Python / FastAPI | Process incoming device data and expose APIs |
| Frontend | JavaScript | Web interface for users |

Infrastructure components include PostgreSQL, InfluxDB, Mosquitto and Traefik. The configuration for these components lives in the `k8s/` directory.

## Repository Structure

- `ansible/` – Playbooks to bootstrap Raspberry Pi nodes and install K3s and Helm charts.
- `k8s/` – Kubernetes manifests for all services and infrastructure.
- `archive/` – Deprecated or legacy manifests kept for reference.
- `scripts/` – Helper scripts, including a local testing environment.
- `tests/` – Pytest suite validating the manifests.

## Getting Started

### Prerequisites
- Docker
- [kind](https://kind.sigs.k8s.io/) for running a local Kubernetes cluster
- Python 3.11 with `pytest` and `pyyaml`

### Local Test Environment

To spin up a local cluster and apply all manifests, run:

```bash
scripts/setup_local_env.sh
```

The script expects `kind` and `kubectl` to be available. It will create a cluster named `iotapp`, create the `iot` namespace, and apply all manifests from the `k8s/` directory.

### Deploying to Raspberry Pi

1. Configure your hosts in `ansible/inventory/inventory.yml`.
2. Execute the base deployment which installs Traefik, cert‑manager and monitoring tools:
   ```bash
   ansible-playbook -i ansible/inventory/inventory.yml ansible/deploy_basis.yml
   ```
3. Deploy the application services:
   ```bash
   ansible-playbook -i ansible/inventory/inventory.yml ansible/deploy_services.yml
   ```

Credentials for pulling container images are expected as extra variables or environment variables as shown in the GitHub Actions workflow.

### Running Tests

Install test requirements and run `pytest`:

```bash
pip install -r requirements-dev.txt
pytest
```

The test suite ensures that all YAML manifests load correctly and that the cluster issuer referenced in the ingress matches the issuer manifest.

## Known Issues

- The ingress annotation for the frontend previously referenced `letsencrypt-production`. It has been corrected to `letsencrypt-prod` to match the cluster issuer in `k8s/98-deployment-prod/cluster-issuer.yaml`.
- Ensure Traefik is deployed (via Helm in `ansible/deploy_basis.yml`) before applying the dashboard ingress in `k8s/00-traefik`.

