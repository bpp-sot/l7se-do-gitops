# Exercise 3 – Create Your First Argo CD Application

**Time:** ~20 minutes  
**Concepts:** Argo CD Application resource, Kustomize overlays, sync, health

---

## Background: the Application resource

In GitOps, an **Application** is a Kubernetes custom resource that tells Argo CD:

- **Where** to find the manifests (a Git repo + path)
- **Where** to deploy them (a cluster + namespace)
- **How** to sync (manually, or automatically)

The `Application` resource is itself a Kubernetes object — which means it can be stored in Git and managed via GitOps too.

---

## Step 3.1 – Create the target namespace

Before deploying anything, create the namespace where the app will live:

```bash
kubectl create namespace gitops-app
```

---

## Step 3.2 – Inspect the manifests that will be deployed

Look at the Kubernetes manifests in this repo:

```bash
# View the base manifests
ls k8s/base/

# Preview what Kustomize will render for the dev overlay
kubectl kustomize k8s/overlays/dev
```

You should see a `Deployment` and a `Service`. Note:
- The `Deployment` has `replicas: 1` (from the dev overlay patch)
- The `Service` type is `ClusterIP`
- The image tag is `1.0.0`

> **Reflection:** We're using **Kustomize** to manage environment-specific configuration. Compare this to using separate YAML files per environment, or using Helm values files. What are the trade-offs of each approach at scale?

---

## Step 3.3 – Create an Argo CD Application

You can create an Application via the UI, CLI, or by applying a YAML manifest. We'll use the CLI first, then look at the equivalent YAML.

**Via the CLI:**

```bash
argocd app create gitops-demo-dev \
  --repo https://github.com/bpp-sot/l7se-devops-gitops.git \
  --path k8s/overlays/dev \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace gitops-app \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

> **Note:** If you're working from a fork of this repo, replace the `--repo` URL with your fork's URL.

Check it was created:

```bash
argocd app list
```

---

## Step 3.4 – Watch the first sync

Argo CD will immediately begin syncing. Watch the status:

```bash
argocd app get gitops-demo-dev
```

Or in the UI: go to the **Applications** screen and click on `gitops-demo-dev`. You should see a visual graph of the resources being created.

Watch the pods come up:

```bash
kubectl get pods -n gitops-app --watch
```

Press `Ctrl+C` once they're `Running`.

---

## Step 3.5 – Access the deployed application

Port-forward to the app service:

```bash
kubectl port-forward svc/gitops-demo-app -n gitops-app 3000:80
```

Open the **Ports** tab and click the globe icon next to port `3000`. You should see the demo app showing version `1.0.0` in blue.

Press `Ctrl+C` to stop the port-forward when you're done.

---

## Step 3.6 – Inspect the Application as a Kubernetes resource

Behind the CLI command, Argo CD created a Kubernetes `Application` custom resource. View it:

```bash
kubectl get application -n argocd
kubectl describe application gitops-demo-dev -n argocd
```

A reference YAML version is provided in `exercises/solutions/argocd-application.yaml`. Compare it to what you see in the describe output — they represent the same configuration.

> **Reflection:** Because an `Application` is a Kubernetes resource, you could store it in Git and have Argo CD manage Argo CD's own Applications. This pattern is called **App of Apps**. What problems does it solve, and what risks does it introduce?

---

## Checkpoint

Before moving on, confirm:

- [ ] `argocd app list` shows `gitops-demo-dev` with status `Synced` and health `Healthy`
- [ ] `kubectl get pods -n gitops-app` shows 1 running pod
- [ ] You can see the app in your browser showing version `1.0.0`
- [ ] You can see the Application resource in the Argo CD UI as a visual graph

---

*Continue to [Exercise 4 →](exercise-04.md)*
