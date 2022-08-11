# Backstage Helm Charts

> Work in progress

Backstage helm charts.

## Local setup
Precondition: [minikube](https://minikube.sigs.k8s.io/docs/) and [helm](https://helm.sh/) are installed.

Start a local kubernetes cluster:
```sh
minikube start
```

In `global-backstage` repo (branch 22-helm-charts):
```sh
eval $(minikube docker-env)
yarn build-app
yarn build-image --tag global-backstage:1.0.0
```
Note: the `eval` command sets up environment variables for the current session so kubernetes will pull from the local docker registry.  Be sure to run the yarn commands in the same session.

In `global-backstage-helmcharts` repo:

1. deploy the age key responsible to encrypt/decrypt secrets
```sh
cd charts

export NAMESPACE="argocd"

# age-keygen -o key.txt # generate age key or get the key from an administrator

kubectl create namespace $NAMESPACE
kubectl create secret generic helm-secrets-private-keys --from-file=key.txt -n $NAMESPACE # deploy key.txt on secrets

kubectl get secrets -n $NAMESPACE # verify
```

2. deploy custom argocd image
```bash

helm install argocd -n $NAMESPACE ./argo-cd

# verify if argocd-repo-server has access to secrets
kubectl auth can-i get secrets --namespace $NAMESPACE --as "system:serviceaccount:${NAMESPACE}:argocd-repo-server" # the output should be yes
kubectl auth can-i get secrets --namespace $NAMESPACE --as "system:serviceaccount:${NAMESPACE}:argocd-repo-server" # the output should be yes

kubectl patch svc argocd-server -n $NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}'

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo # get argocd password

kubectl get svc -n $NAMESPACE # get alb url
```

3. encrypt secrets with sops age
```bash
# get the key.txt from an administrator
export SOPS_PUBLIC_KEY="age12dr7uermh42nt7099jt0xlz0e65wy0vj5gf6h002v5x6esvkcd9qq9kglv"
export SOPS_AGE_KEY_FILE="${PWD}/key.txt"
export SOPS_AGE_RECIPIENTS="public-key"
    
cd backstage
    
sops --encrypt -i --age "${SOPS_PUBLIC_KEY}" secrets.yaml 

sops --decrypt --age "${SOPS_PUBLIC_KEY}" secrets.yaml
```
> the secrets values must be in base64 format

mandatory secrets for backstage
```yaml
GH_DOCKER_ACCESS_TOKEN: 
AUTH_GITHUB_CLIENT_ID: 
AUTH_GITHUB_CLIENT_SECRET: 
PG_HOST: 
PG_USER: 
PG_PASSWORD: 
```
> Tip: You can use `host.minikube.internal` for `pg-host` if postgres is running on the cluster's host machine.

4. deploy backstage
```bash
cd backstage

helm repo add bitnami https://charts.bitnami.com/bitnami
helm dependencies build .

kubectl apply -f ./application.yaml -n $NAMESPACE
```

## Using the postgres helm chart
In production Backstage would use a managed Postgres service.  If you want to deploy postgres in your local kubernetes cluster, follow the steps below.

Follow the [Local setup](#local-setup) steps above, but replace the `install` command with (the `postgres-secrets` resource is no longer needed):
```
helm install dev --set postgresql.enabled=true ./charts/backstage
```

Cleanup: the PVC is not deleted when you run `helm uninstall <release>`.  Subsequent changes to the postgres configuration will not take effect until the PVC is deleted and recreated.
```
kubectl delete pvc data-dev-postgresql-0 
```

# TODO
- backstage-backend and postgres secrets (csi secrets? sealed secrets? sops? manual?)
- add ingress resource
- add to ci/cd
- add repo requirements