# deploy

## Summary
Manifests and Scripts to deploy the books-server and deploy the app in various environments

## Create project in firebase and integrate login in the app
<TBD>

## How to deploy the books-server in a Kubernetes Cluster
Following are steps to deploy the books server in a Kubernetes Cluster, we will deploy in a local KIND cluster,
it will be same for any cluster.

1. Build a kind cluster, run [./kind-with-registry.sh](kind-with-registry.sh). This will create a KIND
kubernetes cluster on your local machine along with a docker registry.

2. Install NGINX Ingress Controller
```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# wait for processes to start
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

4. Follow the [Build and deploy in KIND Kubernetes cluster](../books-server/README.md) step to build the docker image, 
push it to the local kind registry and deploy in KIND kubernetes cluster.

5. See the next section to start the application.

6. To cleanup simply run following command. Don't execute this unless you want to really cleanup.
```shell
kind delete cluster
```

## Start mobile application in iOS simulator locally

1. Assuming you have followed the steps above to deploy the `books-server` in a KIND cluster

2. Edit `booksServerHost` value to `localhost` and run app in iOS simulator

3. Now your app will run against this server deployed in kubernetes cluster.