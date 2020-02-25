# Basic Rails App (for testing)

## Building docker image

```sh
docker build . -t goyalmunish/basic-rails-app:latest
docker push goyalmunish/basic-rails-app:latest
```

## Running the image

```sh
docker run -it --name basic-rails-app goyalmunish/basic-rails-app:latest
# docker run -it --network host --name basic-rails-app goyalmunish/basic-rails-app:latest
```

## Running service on Kubernetes

Generate K8s manifest as:

```sh
# set namespace (default namespace is 'default')
export KUBE_NAMESPACE=spod-mugoyal

# generate manifest
. ./kubernetes/scripts/generate
```

Then, you can check manifests generated in `kubernetes/generated` directory.

If everythin looks file, you can apply them as:

```sh
kubernetes apply -f kubernetes/generated
```

or using script as:

```sh
. ./kubernetes/scripts/run
```

which generated the manifests, deletes existing objects, and creates objects as per new definition.
