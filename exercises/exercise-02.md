# Exercise 2 – Explore the Argo CD UI

**Time:** ~15 minutes  
**Concepts:** Argo CD projects, applications, sync status, health status

---

## Step 2.1 – Expose the Argo CD dashboard

Open a **new terminal** (click the `+` in the terminal panel) and run:

```bash
bash scripts/start-argocd-ui.sh
```

Leave this terminal running — it's holding the port-forward open. Switch back to your original terminal for the remaining steps.

**Access the UI in your browser:**

In GitHub Codespaces, open the **Ports** tab at the bottom of VS Code. Find port `8080` and click the **globe icon** 🌐 to open it in your browser.

> If you don't see port 8080 in the Ports tab, try running `bash scripts/start-argocd-ui.sh` again and wait a few seconds.

---

## Step 2.2 – Log in to Argo CD

**Get the initial admin password:**

```bash
bash scripts/get-argocd-password.sh
```

Copy the password shown. In the Argo CD UI, log in with:
- **Username:** `admin`
- **Password:** (the value you just copied)

---

## Step 2.3 – Explore the UI

You'll land on the **Applications** screen — currently empty, because we haven't told Argo CD to manage anything yet.

Explore the navigation:

**Settings → Repositories**  
This is where you connect Argo CD to Git repositories. It supports HTTPS (with optional credentials) and SSH.

**Settings → Projects**  
Argo CD uses Projects to group and govern Applications. The `default` project has no restrictions. In production, projects are used to control which repos, clusters, and namespaces an application can deploy to.

**Settings → Clusters**  
By default, Argo CD can deploy to the cluster it's installed on (`in-cluster`). You can add additional clusters here.

> **Reflection:** Argo CD's RBAC model separates concerns between platform teams (who manage Argo CD itself) and application teams (who create Applications within a Project). How does this compare to how deployments are governed in your organisation?

---

## Step 2.4 – Log in via the CLI

As well as the web UI, Argo CD has a full CLI. In your terminal:

```bash
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)

argocd login localhost:8080 \
  --insecure \
  --username admin \
  --password "$ARGOCD_PASSWORD"
```

Now try some CLI commands:

```bash
# List connected clusters
argocd cluster list

# List applications (empty for now)
argocd app list
```

> **Reflection:** The Argo CD CLI makes it straightforward to integrate GitOps operations into CI pipelines — for example, triggering a sync after a container image is built. What are the security implications of giving a CI pipeline credentials to Argo CD?

---

## Step 2.5 – Understand the GitOps model

Before creating your first Application, it's worth being precise about what Argo CD does:

```
Git repository              Argo CD                    Kubernetes cluster
(source of truth)    →   (reconciliation loop)   →    (desired state)
                                  ↑
                          watches for drift
                                  |
                          cluster actual state
```

Argo CD continuously compares:
- **Desired state:** the Kubernetes manifests in Git
- **Actual state:** what's currently running in the cluster

When there's a difference (called **drift**), Argo CD can either alert you or automatically reconcile — depending on how you configure the `syncPolicy`.

---

## Checkpoint

Before moving on, confirm:

- [ ] You can see the Argo CD UI in your browser
- [ ] You are logged in as `admin`
- [ ] `argocd app list` runs without error (returns empty list)
- [ ] You understand the difference between desired state and actual state

---

*Continue to [Exercise 3 →](exercise-03.md)*
