# Exercise 4 – The GitOps Loop

**Time:** ~25 minutes  
**Concepts:** Git as source of truth, declarative updates, automated reconciliation, image tags

---

## Background

This exercise is the core of GitOps: making a change by **editing a file in Git**, rather than running a `kubectl` command directly. Argo CD detects the change and reconciles the cluster to match.

The loop looks like this:

```
1. Edit manifest in Git  →  2. Commit & push
                                    ↓
4. Cluster updated       ←  3. Argo CD detects change & syncs
```

---

## Step 4.1 – Simulate a version bump

Open `k8s/base/deployment.yaml` in the VS Code editor (click the file in the Explorer panel on the left).

Find this section:

```yaml
env:
  - name: APP_VERSION
    value: "1.0.0"
```

Change the value to `"2.0.0"`:

```yaml
env:
  - name: APP_VERSION
    value: "2.0.0"
```

Save the file (`Ctrl+S`).

> **Note:** In a real GitOps workflow, this version bump would be done automatically by a CI pipeline after building and pushing a new container image. We're doing it manually here to focus on the GitOps reconciliation loop itself.

---

## Step 4.2 – Commit and push the change

```bash
git add k8s/base/deployment.yaml
git commit -m "chore: bump app version to 2.0.0"
git push
```

> **If you don't have write access to the repo:** Your tutor may have set up a fork for you to use, or you can observe this step as a demonstration and continue from Step 4.3 using a manual sync trigger.

---

## Step 4.3 – Watch Argo CD detect the change

By default, Argo CD polls Git every **3 minutes**. For the lab, trigger a manual refresh instead:

```bash
argocd app get gitops-demo-dev --refresh
```

Watch the sync happen:

```bash
argocd app get gitops-demo-dev
```

Look for the status to move through `OutOfSync` → syncing → `Synced`.

In the UI, you can also click **Refresh** on the application card, then watch the visual graph update in real time.

---

## Step 4.4 – Verify the update reached the cluster

```bash
kubectl get pods -n gitops-app
```

You should see the old pod terminating and a new pod starting (Kubernetes rolling update). Once the new pod is `Running`, port-forward to it:

```bash
kubectl port-forward svc/gitops-demo-app -n gitops-app 3000:80
```

Open the app in your browser. The version number on the card should now show `2.0.0`.

Press `Ctrl+C` when done.

---

## Step 4.5 – Change the environment colour

Let's make a more visually obvious change. In `k8s/overlays/dev/kustomization.yaml`, find the colour patch:

```yaml
- op: replace
  path: /spec/template/spec/containers/0/env/2/value
  value: "#0ea5e9"
```

Change the colour to something different — for example orange `#f97316` or green `#22c55e`:

```yaml
- op: replace
  path: /spec/template/spec/containers/0/env/2/value
  value: "#f97316"
```

Save, commit, and push:

```bash
git add k8s/overlays/dev/kustomization.yaml
git commit -m "feat: change dev environment colour to orange"
git push
```

Trigger a refresh and watch the sync, then port-forward to verify the colour has changed.

---

## Step 4.6 – Explore the sync history

```bash
argocd app history gitops-demo-dev
```

You should see the two sync operations recorded, each tied to a Git commit SHA.

> **Reflection:** The sync history gives you a complete audit trail of every change made to the cluster, tied directly to a Git commit. Compare this to a team making changes with `kubectl apply` directly. What governance and compliance implications does the GitOps approach have? Think about your own organisation's audit requirements.

---

## Step 4.7 – Roll back

One of GitOps' most powerful properties is that rolling back is just reverting a Git commit. Try it:

```bash
# Revert the last commit
git revert HEAD --no-edit
git push
```

Trigger a refresh and watch Argo CD re-sync to the previous state. Verify the colour has reverted in your browser.

> **Reflection:** Compare this rollback mechanism to a traditional deployment rollback (e.g. re-running a previous pipeline, restoring a snapshot, or manually applying an earlier manifest). What makes the GitOps approach more or less reliable?

---

## Checkpoint

Before moving on, confirm:

- [ ] You successfully triggered a sync by pushing a Git commit
- [ ] The change was reflected in the running application
- [ ] You can see the sync history tied to Git commit SHAs
- [ ] You performed a rollback via `git revert`

---

*Continue to [Exercise 5 →](exercise-05.md)*
