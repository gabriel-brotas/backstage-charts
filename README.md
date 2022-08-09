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

> Temporary: substitute `AUTH_GITHUB_CLIENT_ID` and `AUTH_GITHUB_CLIENT_SECRET` in the create secrets command.  TODO need to decide which secret strategy we want to use.

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm dependencies build ./charts/backstage
kubectl create secret generic backstage-secrets --from-literal=AUTH_GITHUB_CLIENT_ID=<VALUE> --from-literal=AUTH_GITHUB_CLIENT_SECRET=<VALUE>
```

Installation with a local, external postgres database (e.g., [postgresapp](https://postgresapp.com/)); this is most similar to the production install:

> Temporary: substitute `pg-host`, `pg-user`, and `pg-password` in the create secrets command for your local configuration.  TODO need to decide which secret strategy we want to use.

```
kubectl create secret generic postgres-secrets --from-literal=pg-host=<value> --from-literal=pg-user=<value> --from-literal=pg-password=<value>
helm install dev ./charts/backstage
```

> Tip: You can use `host.minikube.internal` for `pg-host` if postgres is running on the cluster's host machine.

Set up local port-forwarding to connect to the cluster:
```
kubectl port-forward --namespace=default svc/backstage 7007:7007
```
Now you can view the app at [localhost:7007](http://localhost:7007/).

Cleanup:
```sh
helm uninstall dev
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

## Secrets
```bash
cd charts
# md5 phrase = deada0533f5704f36373162e898d0ec2

export NAMESPACE="argocd"
export SOPS_PGP_FP="B327B20333401246E933FFDC3BD9A05BE89D04D0"

gpg --armor --export-secret-keys "${SOPS_PGP_FP}" > key.asc
kubectl create namespace $NAMESPACE
kubectl create secret generic helm-secrets-private-keys --from-file=key.asc -n $NAMESPACE
kubectl get secrets -n $NAMESPACE

### 
## Setup custom ArgoCD
###

helm install argocd -n $NAMESPACE ./argo-cd

# verify if argocd-repo-server can retrieve secrets
kubectl auth can-i get secrets --namespace $NAMESPACE --as "system:serviceaccount:${NAMESPACE}:argocd-repo-server"
# the output should be yes

kubectl patch svc argocd-server -n $NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}'
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
kubectl port-forward svc/argocd-server -n argocd 8080:443

###
## Encrypt secrets
###
# KMS --
cd backstage
helm secrets enc ./templates/secrets.yaml

helm secrets view ./templates/secrets.yaml


#Encrypting a file
aws kms encrypt \
    --key-id arn:aws:kms:us-east-1:158199044084:key/ed488c04-9be7-4371-8ab5-5e823d84c34b \
    --plaintext fileb://backstage/secrets/gh-secrets.yaml \
     --output text --query CiphertextBlob --region us-east-1 > Encrypteddatafile.yaml

# Decoding base64 file to binary file
cat Encrypteddatafile.base64 | base64 --decode > Encrypteddatafile


### 
## Setup Backstage
###

# gpg --full-generate-key --rfc4880

# 1.1 verify secrets
# gpg --export-secret-keys --armor "${SOPS_PGP_FP}"  # private key
gpg --list-secret-keys # verify secrets

# encrypt secret
sops --encrypt --pgp "${SOPS_PGP_FP}" ./backstage/secrets/gh-secrets.yaml > ./backstage/secrets.yaml

# 3. verify decrypted value
sops --decrypt ./backstage/secrets.yaml --pgp "${SOPS_PGP_FP}"

##################
###
## Troubleshooting
###
# GPG_TTY=$(tty)
# export GPG_TTY
###################

# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm dependencies build ./backstage
# helm install -n $NAMESPACE my-backstage backstage/

kubectl apply -f ./backstage/application.yaml -n $NAMESPACE
```


# TODO
- backstage-backend and postgres secrets (csi secrets? sealed secrets? sops? manual?)
- add ingress resource
- add to ci/cd
- add repo requirements