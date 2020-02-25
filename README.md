# Basic Rails App (for testing)

Building docker image:

```sh
docker build . -t goyalmunish/basic-rails-app:latest
docker push goyalmunish/basic-rails-app:latest
```

Running the image:

```sh
docker run -it --name basic-rails-app goyalmunish/basic-rails-app:latest
# docker run -it --network host --name basic-rails-app goyalmunish/basic-rails-app:latest
```
