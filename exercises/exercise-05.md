# Exercise 5 – Self-Healing and Drift Detection

**Time:** ~20 minutes  
**Concepts:** Drift detection, self-healing, configuration drift, GitOps vs imperative operations

---

## Background

So far, changes have flowed in one direction: Git → cluster. But what happens when someone makes a change **directly to the cluster** — bypassing Git?

This is called **configuration drift**, and it's one of the most common sources of production incidents. A developer `kubectl edit`s a deployment to bump a replica count "temporarily". A month later, nobody remembers, the change isn't in Git, and the next deployment wipes it out.

GitOps with self-healing solves this problem automatically.

---

## Step 5.1 – Manually scale the deployment (bypassing Git)

Scale the deployment directly with `kubectl` — without touching Git:

```bash
kubectl scale deployment gitops-demo-app -n gitops-app --replicas=5
```

Verify the change took effect immediately:

```bash
kubectl get pods -n gitops-app
```

You should see 5 pods running.

---

## Step 5.2 – Watch Argo CD revert it

Because our Application has `selfHeal: true`, Argo CD will detect this drift and revert it within a short period. Watch what happens:

```bash
kubectl get pods -n gitops-app --watch
```

Within a minute or two, you should see pods terminating until the count returns to `1` (the replica count defined in the dev overlay). Press `Ctrl+C` when it stabilises.

Check the Argo CD UI — you should see a sync event was triggered automatically, labelled as a self-heal.

> **Reflection:** This behaviour is exactly why teams adopting GitOps must also change their operational habits. Engineers accustomed to `kubectl edit` as a quick fix must now commit to Git instead. What cultural challenges might this create in a team? How would you address them?

---

## Step 5.3 – Try editing a resource directly in the UI

Argo CD's UI allows you to view live resource state. Try editing something:

1. In the Argo CD UI, click on `gitops-demo-dev`
2. Click on the `Deployment` node in the graph
3. Click **Edit** (if available in your version, it may be read-only depending on RBAC settings)

Notice that even if you can edit via the UI, any change that conflicts with Git will be reverted on the next sync cycle.

---

## Step 5.4 – Observe drift detection without self-heal

Let's temporarily disable self-healing to observe the drift detection behaviour separately:

```bash
argocd app set gitops-demo-dev --self-heal=false
```

Now scale again:

```bash
kubectl scale deployment gitops-demo-app -n gitops-app --replicas=3
```

Trigger a refresh:

```bash
argocd app get gitops-demo-dev --refresh
```

Check the status:

```bash
argocd app get gitops-demo-dev
```

The status should now show `OutOfSync` — Argo CD has detected the drift but is not automatically correcting it because self-healing is off.

In the UI, you should see the application card marked as `OutOfSync` with a yellow indicator.

Re-enable self-healing:

```bash
argocd app set gitops-demo-dev --self-heal=true
```

Watch it reconcile back to 1 replica.

---

## Step 5.5 – Deploy the staging overlay

So far we've only used the `dev` overlay. Let's create a second Application for the staging environment to see how environment promotion works:

```bash
argocd app create gitops-demo-staging \
  --repo https://github.com/bpp-sot/l7se-devops-gitops.git \
  --path k8s/overlays/staging \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace gitops-app \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

Check both applications in the UI. Note:
- Dev: 1 replica, blue colour
- Staging: 2 replicas, amber colour

Both are managed from the same Git repository, with environment differences handled entirely through Kustomize overlays.

> **Reflection:** In a production GitOps workflow, promotion from dev to staging might be automated (triggered when a CI test suite passes) or manual (requiring a PR approval). What would the right promotion strategy look like for your organisation? What approvals would be needed before a change reached production?

---

## Step 5.6 – Level 7 synthesis

Consider the following questions for your summative assessment or wider reflection:

1. **GitOps vs traditional CI/CD:** Both can automate deployments. What is the fundamental architectural difference? Under what circumstances might traditional push-based CD be preferable?

2. **The two-repo pattern:** You've worked with a monorepo containing both app code and manifests. In production, these are often split. What are the specific advantages of separating them? What problems does it create?

3. **Secrets management:** You may have noticed we haven't dealt with secrets (database passwords, API keys, etc.). GitOps creates a challenge here — you can't store secrets in Git in plain text. Research Sealed Secrets, External Secrets Operator, or Vault integration with Argo CD. Which approach would be most appropriate in your organisation, and why?

4. **Compliance and audit:** Your organisation may be subject to SOC 2, ISO 27001, or PCI DSS. How does a GitOps approach support — or complicate — meeting these requirements? Consider the audit trail, access controls, and separation of duties.

---

## Checkpoint

Before finishing, confirm:

- [ ] You observed self-healing revert a manual `kubectl scale` operation
- [ ] You observed drift detection without self-heal (OutOfSync status)
- [ ] You successfully deployed a second environment (staging) from the same repo
- [ ] You have considered the Level 7 synthesis questions in relation to your own workplace

---

## Clean up

To reset the lab to a clean state for the next learner:

```bash
bash scripts/reset-lab.sh
```

---

## Further reading

- Argo CD documentation: [https://argo-cd.readthedocs.io](https://argo-cd.readthedocs.io)
- Weaveworks: *Guide to GitOps* — [https://www.weave.works/technologies/gitops/](https://www.weave.works/technologies/gitops/)
- CNCF: *GitOps Working Group* — [https://github.com/cncf/tag-app-delivery/tree/main/gitops-wg](https://github.com/cncf/tag-app-delivery/tree/main/gitops-wg)
- OpenGitOps principles: [https://opengitops.dev](https://opengitops.dev)

---

*You have completed the GitOps lab. Well done.*
