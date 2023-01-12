# Jupyter Hub

This is an example of the jupyter extension running with the JupyterHub notebook runner.]

_Note_: Not for production use

## Instructions

Prerequisites

- Helm
- A Kubernetes cluster to talk to
- A running Pachyderm cluster
- Working knowledge of Kubernetes (connecting to services, etc)

Add the Jupyter helm chart repository

```
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
```

```

helm install jupyter jupyterhub/jupyterhub --values values.yaml

```

Note: Change the version numbers noted in the values.yaml to match the version of Pachyderm
you are using for the best experiece.
