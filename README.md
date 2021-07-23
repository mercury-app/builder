### Build the docker image
```
docker build . -t mercury
```

### Run the docker image
```
docker run  -v /var/run/docker.sock:/var/run/docker.sock -it  mercury
```