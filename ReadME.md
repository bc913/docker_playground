
## Commands
### Image
- List images
```console
$ docker images
```

- [Pull an image](https://docs.docker.com/engine/reference/commandline/pull/)
```console
$ docker pull <options> <name>:<tag>
```

- Delete image (if the container is running, stop it before deleting)
```console
$ docker rmi <image_tag>
$ docker rmi <image_id>
```

### Container
- List containers
```console
$ docker ps
```
- List all running and stopped containers
```console
$ docker ps -a
```

-  Creates a writeable container layer over the specified image and prepares it for running the specified command
```bash
$ docker create --name <container_name> <image_tag> [<command>]
# returns the container id
```
- Start one or more stopped or newly created containers
```console
$ docker start <container_name_or_id>
```

- Creates(pulls) and start together
```bash
$ docker run --name <container_name> -it <image_tag>
# Delete container when the process is stopped
$ docker run --name <container_name> -it --rm <image_tag>
# run as deattached
$ docker run -d --name <container_name> <image_tag>
# run with specified ports
$ docker run -p<host_port>:<container_port> --name <container_name> <image_tag>
```

- Stop container
```console
$ docker stop <container_name>
```

- Delete container
```console
$ docker rm <docker_name>
```

### Logging & debugging
- Logs produced by a container
```console
$ docker logs <container_name_or_id>
```

### Run a command in a running container

```bash
$ docker exec -it <container_id_or_name> /bin/bash
# At this point, you are inside the container
ls
pwd
cd / # go to root
env # check environment variables

# To exit
exit
```

## Dockerize the app
### Create Dockerfile
Dockerfile has the instructions to create the container image.

#### w/o build & publish
To exclude build and publish process out of Dockerfile, first build and publish the app as explained before and then run the following Dockerfile:

```dockerfile
# Runtime base image
# No need for sdk base image since this excludes the build and publish process
FROM mcr.microsoft.com/dotnet/core/runtime:3.1
# Copy files from filesystem to app
COPY publish/ app/
# Navigate to app
WORKDIR /app
# Entry point to run the app in the container
ENTRYPOINT ["dotnet", "ConsoleApp.dll"]
```

or

```dockerfile
# Runtime base image
# No need for sdk base image since this excludes the build and publish process
FROM mcr.microsoft.com/dotnet/core/runtime:3.1
# Navigate to app
WORKDIR /app
# Copy files from filesystem to app
COPY publish/ ./
# Entry point to run the app in the container
ENTRYPOINT ["dotnet", "ConsoleApp.dll"]
```

#### w/ build & publish process
```dockerfile
# Build and publish first
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /app
COPY . ./
RUN dotnet publish ConsoleApp/ConsoleApp.csproj -c Release -o out
# This layer will be removed

#Generate run time image
FROM mcr.microsoft.com/dotnet/core/runtime:3.1
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "ConsoleApp.dll"]