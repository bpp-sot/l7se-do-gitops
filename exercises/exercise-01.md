# Exercise 1 – Orient: Explore the Cluster

**Time:** ~15 minutes  
**Concepts:** Kubernetes namespaces, pods, Argo CD architecture

---

## Before you begin

Your Codespace has already run the setup script, which:
- Started a Minikube cluster inside Docker
- Installed Argo CD into the `argocd` namespace

If you've just opened the Codespace for the first time, wait until the setup script finishes — you'll see the success message in the terminal.

---

## Step 1.1 – Verify the cluster is running

```bash
kubectl cluster-info
```

You should see the Kubernetes control plane URL. Now check what nodes are available:

```bash
kubectl get nodes
```

> **Reflection:** In a production GitOps environment, this cluster might be AKS, EKS, or GKE — managed by a cloud provider. Minikube gives us the same API surface locally. What are the trade-offs of using a managed cluster vs self-hosted for a GitOps workflow?

---

## Step 1.2 – Explore what's already running

Kubernetes organises resources into **namespaces**. List them:

```bash
kubectl get namespaces
```

You should see at minimum: `default`, `kube-system`, and `argocd`.

Now look at what's running in the `argocd` namespace:

```bash
kubectl get pods -n argocd
```

Wait until all pods show `Running` or `Completed`. You can watch them come up with:

```bash
kubectl get pods -n argocd --watch
```

Press `Ctrl+C` to stop watching.

---

## Step 1.3 – Understand Argo CD's components

Argo CD is itself a set of microservices running on Kubernetes. Describe one of the pods to see its configuration:

```bash
kubectl describe pod -n argocd -l app.kubernetes.io/name=argocd-server
```

The key components you should see running are:

| Component | Purpose |
|---|---|
| `argocd-server` | API server and web UI |
| `argocd-repo-server` | Clones Git repos and renders manifests |
| `argocd-application-controller` | Watches cluster state and reconciles with Git |
| `argocd-redis` | Caches rendered manifests |

> **Reflection:** Notice that Argo CD itself is deployed on Kubernetes using Kubernetes manifests. Could you manage Argo CD's own configuration using GitOps? This is sometimes called "bootstrapping" — what challenges might it introduce?

---

## Step 1.4 – Check the Argo CD service

```bash
kubectl get services -n argocd
```

Note that `argocd-server` is of type `ClusterIP`. This means it's not accessible from outside the cluster directly — you'll need to use `kubectl port-forward` to reach the UI, which you'll do in Exercise 2.

> **Important Codespaces note:** Because we're running inside GitHub Codespaces, the cluster's node IP is not reachable from your browser. Port-forwarding bypasses this by tunnelling through `kubectl` directly to the pod. This is the same pattern you saw in the Kubernetes topic.

---

## Checkpoint

Before moving on, confirm:

- [ ] `kubectl get nodes` shows a `Ready` node
- [ ] All pods in `argocd` namespace are `Running`
- [ ] You can see the `argocd-server` service listed

---

*Continue to [Exercise 2 →](exercise-02.md)*
