# Install Aimstack in your pachyderm cluster.

```bash
helm install <release name> aimstack/ -f my-values.yaml
```

you only need to supply values to enable access to the gui using ingress or loadbalancer.

Otherwise you can use port forward:

```bash
kubectl port-forward svc/aim-pach 8080:8080
```
