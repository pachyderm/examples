# Install Aimstack in your pachyderm cluster

## How to install


```bash
helm install <release name> aimstack/ -f my-values.yaml
```

you only need to supply values to enable access to the gui using ingress or loadbalancer.

Otherwise you can use port forward:

```bash
kubectl port-forward svc/aim-pach 8080:8080
```


## Quick example of using Aim with mnist

1. Edit the `pipeline.json` to update the `AIM_ENDPOINT` to match the one from the helm install output. 
2. Create the pipeline with the folloing command:
```bash
pachctl create pipeline -f mnist-example/pipeline.json
```
> This pipeline is a cron with an unrunnable date (Feburary 31st). We can trigger it whenever we want with `pachctl cron run`.
3. Run the pipeline with `pachctl cron run aim-mnist`
4. Port forward the aim interfact with `kubectl port-forward svc/aim-pach 8080:8080`. you might need to add `-n <namespace>` if its in a different namepsace
5. you can open the Aim interface [here.](http://localhost:8080)
