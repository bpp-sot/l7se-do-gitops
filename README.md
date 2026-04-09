# L7SE DevOps – Topic 9: GitOps with Argo CD

**BPP University | Level 7 Software Engineering | DevOps Module**

This repository supports the hands-on lab for Topic 9: *DevOps with GitOps*. You will install and configure **Argo CD** on a local Kubernetes cluster, connect it to this Git repository as the single source of truth, and observe how changes to manifests are automatically reconciled onto the cluster.

---

## Learning outcomes

By the end of this lab you will be able to:

- Explain the GitOps model and how it differs from traditional push-based CI/CD
- Install Argo CD and navigate its web UI and CLI
- Create an Argo CD `Application` that targets a Git repository
- Trigger a deployment by committing a change to a Kubernetes manifest
- Explain and demonstrate Argo CD's drift detection and self-healing behaviour
- Apply Kustomize overlays to manage environment-specific configuration

---

## What's in this repo

```
.devcontainer/
  devcontainer.json     ← Codespace config: Minikube + kubectl + Argo CD CLI
  setup.sh              ← Auto-runs on Codespace creation (~5–8 min)

app/
  server.js             ← Simple Express app: shows version, env, colour
  package.json
  Dockerfile

k8s/
  base/                 ← Shared Kubernetes manifests (Deployment + Service)
  overlays/
    dev/                ← Dev environment: 1 replica, blue
    staging/            ← Staging environment: 2 replicas, amber

exercises/
  exercise-01.md        ← Orient: explore the cluster and Argo CD components
  exercise-02.md        ← Explore the Argo CD UI and CLI
  exercise-03.md        ← Create your first Argo CD Application
  exercise-04.md        ← The GitOps loop: commit → sync → deploy
  exercise-05.md        ← Self-healing and drift detection
  solutions/
    argocd-application.yaml

scripts/
  start-argocd-ui.sh    ← Expose the Argo CD dashboard via port-forward
  get-argocd-password.sh ← Retrieve the initial admin password
  reset-lab.sh          ← Reset to a clean state

.github/workflows/
  validate.yml          ← CI: validates Kustomize manifests on push/PR
```

---

## Getting started

### Using GitHub Codespaces (recommended)

You do not need Docker Desktop or any local tooling. Everything runs inside a GitHub Codespace.

1. Click the green **Code** button on this repo's GitHub page
2. Select **Codespaces** → **Create codespace on main**
3. Wait for the Codespace to build — this takes **5–8 minutes** on first launch as it starts Minikube and installs Argo CD onto the cluster
4. You'll see the success message in the terminal when setup is complete

> **Note:** Do not close the terminal during setup. If the Codespace times out or is interrupted, run `bash .devcontainer/setup.sh` manually to resume.

### Using a local machine (alternative)

If you have Docker Desktop and `kubectl` installed locally, you can clone the repo and run `bash .devcontainer/setup.sh`. You'll need at least 4 GB of RAM available for the Minikube cluster.

---

## Running the exercises

Work through the exercises in order — each builds on the previous:

| Exercise | Title | Time |
|---|---|---|
| [Exercise 1](exercises/exercise-01.md) | Orient: explore the cluster | ~15 min |
| [Exercise 2](exercises/exercise-02.md) | Explore the Argo CD UI | ~15 min |
| [Exercise 3](exercises/exercise-03.md) | Create your first Application | ~20 min |
| [Exercise 4](exercises/exercise-04.md) | The GitOps loop | ~25 min |
| [Exercise 5](exercises/exercise-05.md) | Self-healing and drift detection | ~20 min |

**Total: approximately 95 minutes.** Your tutor will indicate which exercises to complete in the session and which to finish independently.

---

## Accessing the Argo CD UI

1. In a new terminal, run:
   ```bash
   bash scripts/start-argocd-ui.sh
   ```
2. Open the **Ports** tab at the bottom of VS Code
3. Find port `8080` and click the **globe icon** 🌐
4. Log in with username `admin` and the password from:
   ```bash
   bash scripts/get-argocd-password.sh
   ```

---

## Architecture overview

```
┌─────────────────────────────────────────────────────────┐
│                   GitHub Codespace                      │
│                                                         │
│   ┌──────────────────────────────────────────────────┐  │
│   │              Minikube cluster                    │  │
│   │                                                  │  │
│   │  ┌─────────────────┐   ┌─────────────────────┐   │  │
│   │  │  argocd ns      │   │  gitops-app ns      │   │  │
│   │  │                 │   │                     │   │  │
│   │  │  argocd-server  │──>│  gitops-demo-app    │   │  │
│   │  │  repo-server    │   │  (your app)         │   │  │
│   │  │  app-controller │   └─────────────────────┘   │  │
│   │  └────────┬────────┘                             │  │
│   │           │ watches                              │  │
│   └───────────┼──────────────────────────────────────┘  │
│               │                                         │
│               v                                         │
│   ┌───────────────────────┐                             │
│   │  This Git repository  │ ← single source of truth    │
│   │  k8s/overlays/dev/    │                             │
│   └───────────────────────┘                             │
└─────────────────────────────────────────────────────────┘
```

---

## The demo application

The app (`app/server.js`) is a minimal Express server that displays its own version number, environment name, and a configurable colour — all set via environment variables in the Kubernetes manifests. This makes changes to those manifests immediately visible in the browser, which helps illustrate the GitOps reconciliation loop clearly.

---

## Key commands reference

```bash
# Cluster
kubectl get nodes
kubectl get pods -n argocd
kubectl get pods -n gitops-app

# Argo CD CLI
argocd app list
argocd app get gitops-demo-dev
argocd app get gitops-demo-dev --refresh   # force Git poll
argocd app history gitops-demo-dev
argocd app sync gitops-demo-dev            # manual sync trigger

# Port-forwarding
bash scripts/start-argocd-ui.sh            # Argo CD UI on port 8080
kubectl port-forward svc/gitops-demo-app -n gitops-app 3000:80   # app on port 3000

# Lab management
bash scripts/get-argocd-password.sh        # retrieve admin password
bash scripts/reset-lab.sh                  # clean slate
```

---

## Further reading

- OpenGitOps principles: [https://opengitops.dev](https://opengitops.dev)
- Argo CD documentation: [https://argo-cd.readthedocs.io](https://argo-cd.readthedocs.io)
- Kustomize documentation: [https://kustomize.io](https://kustomize.io)
- CNCF GitOps Working Group: [https://github.com/cncf/tag-app-delivery](https://github.com/cncf/tag-app-delivery)

---

*BPP University — Level 7 Software Engineering DevOps Module, Topic 9: DevOps with GitOps*
