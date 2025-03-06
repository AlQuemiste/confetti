Docker
======

### Dockerfiles

```
docker build -t scg-debian-oldstable:latest -f ~/docker/Dockerfile.debian.oldstable .
```
# enter the container interactively:
```
docker run -it scg-debian-oldstable /bin/bash
```

-----------------------------------------------------------------------------------

# Docker info
docker info

# list all Docker images
docker image ls --all

# list running images
docker ps --all
docker ps -aq

# stop all running containers
docker stop $(docker ps -aq)

# remove all containers
docker rm $(docker ps -aq)

# kill all running Docker containers
docker kill $(docker ps -aq)

# list all stopped Docker containers
docker ps -a -f status=exited

# list all Docker containers and display their size
docker ps -a --size

# remove a Docker image
docker rmi <docker-image-name>

# remove unneeded containers (stopped)
docker container prune

# discard all unneeded stuff
docker system prune -a

# bypass the entrypoint
docker run --entrypoint /bin/bash -it <container-name-or-id>

# interact with a running Docker container
docker exec -it <container-name-or-id> /bin/bash

# inspect a Docker image
docker image inspect <image-name-or-id>

# copy a file from a container to the host
docker cp <container-name-or-id>:/container/file/path /host/file/path/

# save a snapshot of a container to a new Docker image
docker commit <container-name-or-id>  <repository-name>:<tag>

# bind mounts to modify files in a Docker container from the host:
docker run -v /path/on/host:/path/in/container -it <image-name>

# run a Docker container and automatically remove the container after exit
docker run --rm -it <image-name>
