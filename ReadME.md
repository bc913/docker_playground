# Docker Playground

## Dockerfile and Image
Dockerfiles contains the required instructions to build an image. The Dockerfile consists of layered instructions that defines the image. The resulted image might have the following features but not limited to:
- Environment variables
- Server
- Security settings

### Dockerfile syntax
```dockerfile
# Each instruction represents a layer

# Base image
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
# Metadata <Optional>
LABEL author="Bc913"
# Environment variable
ENV NODE_ENV=production
ENV PORT=3000
# Working directory where your application binary/code lives
# and navigate to that directory within the container
WORKDIR /app
# Copy required files from the filesystem into the container
COPY . ./
# Run commands <optional>
# Prepare the environment, install package dependencies etc.
# Can be any command i.e. package restore
RUN dotnet publish src/ConsoleApp/ConsoleApp.csproj -c Release -o out

# The port number that this container will listen to
EXPOSE 3000
# or use environment variable
# EXPOSE $PORT

# Entrypoint to the container/app
# First arg: command to start the app
# Second arg: arguments passed to the commands
ENTRYPOINT ["dotnet", "ConsoleApp.dll"]
```

#### COPY
- Copy all files and subdirs from where Dockerfile lives to the working dir
```dockerfile
WORKDIR /app
# First dot represents source: all files/subdirs within the directory where Dockerfile exists
# Second dot represents destination: WORKDIR
COPY . . 
```

### Build image
The image is built with the following command.
```bash
docker build -t <image_name> .
```
> Argument `.` stands for the build context which corresponds to relative location of the Dockerfile from where you run this command.

- Registry based naming convention is more appropriate if you want to push your image to a public or private registry.
```bash
docker build -t <registry>/<image_name>:<tag> .
```

### Image features
- Images are immutable.

## Pushing images
One can push the images to a public or private repositories. If you are not logged in, do:
```bash
$ docker login
```
> Make sure you adjust accordingly based on your authentication settings.

## Running containerized apps
After one build/push the image, the corresponding image can be transformed into a container and run using the following command:

```bash
# Option 1:
# Pulls the image from remote registry or locally and transforms into a container
# and then runs it. If the image does not exists, it first builds it.

$ docker run --name <container_name> -it <image_tag_name_or_id>
# Delete container when the process is stopped
$ docker run --name <container_name> -it --rm <image_tag_name_or_id>
# run as deattached
$ docker run -d --name <container_name> <image_tag_name_or_id>
# run with specified ports
# <container(internal)_port> is defined in Dockerfile through EXPOSE
# accessing to this containerized app is possible through accessing the external ports which maps to internal port.
$ docker run -p<host(external)_port>:<container(internal)_port> --name <container_name> <image_tag_name_or_id>

# Option 2
# Start an existing and stopped container
$ docker start <container_name_or_id> 
```

## Persisting data
The data lives in the container has the same lifetime with the container so when container is removed, the data will also be lost with it. To achieve persistence logic, Docker has the concept of `Volumes`.

### Volumes
It is the area of persistent storage that is located outside of the container's filesystem. It can be located on:
- Container host: `Volumes` are the mounts located in the container host (`/mnt/`) and the following command(s):

```bash

$ docker run -p <external_port>:<internal_port> -v /app/logs <image_to_run>
# To control where to store the data in the container host
$ docker run -p <external_port>:<internal_port> -v <destination_in_container_host_to_write_to>:<data_source_in_container_to_write_from> <image_to_run>

```
correspond to: ` The data in /app/logs directory should be stored/written on the container host.`
How does container access data? Docker mounts the storage area into the container during the life of the container.
- Network
- Cloud storage

#### Features
- Docker uses plugin system to implement Volumes. i.e. mounts, Local network file sharing, 
#### Volume Types:
- **Tmpfs mounts**: It is a temporary storage for sensitive data during the execution of the containerized app. Mounts a storage location in the host memory onto a destination in the container's filesystem.
- **Named or anonymous volume**: Designated area of storage on the host that lives within protected area which is control under Docker. Managed using Docker CLI.
    - Pros:
        1. It is managed object.
        2. Isolated from other host activity.
        3. Convenient for backup and identifying
        4. Better performance when used with Docker desktop
    - Cons:
        - Owned by the root user. Security issue.

- **Bind mounts**: Arbitrary directory on the host is mounted onto arbitrary target location inside the container when the container is invoked. Changes in the container are reflected to the host and vice versa. Dir paths must be absolute paths rather than relative paths.

```bash
$ docker run -v </path/on/host>:</path/in/container> <image_to_run>
```

> File Changes in the source (host) can be also be reflected with restarting & w/o rebuilding the container by activating hot reloading argument

```bash
# last arg to activate hot reloading
$ docker run -itd -p 3000:3000 -v $(pwd):/app some_image:1.0 <hot_reload_utility_command> <path_to_file_to_track_changes>
```

#### How to create/use?
```bash
# Create
## Direct approach
$ docker volume create <volume_name>

## Implicit approach
## Bind mount
$ docker run -p <external_port>:<internal_port> -v <destination_in_container_host_to_write_to>:<data_source_in_container_to_write_from> <image_to_run>

# List
$ docker volume ls

# Inspect
$ docker volume inspect

# Remove
$ docker volume rm <volume_name>
```
- Direct approach
```bash

```

- Implicit approach
```bash

```

- List


#### Possible scenarios
1. Write the data in /app/logs to $(pwd) in the container host
```bash
# Linux/Mac
$ docker run -p <external_port>:<internal_port> -v $(pwd):/app/logs <image_to_run>
# Windows
$ docker run -p <external_port>:<internal_port> -v ${PWD}:/app/logs <image_to_run>
```

> Docker supports volumes that store data in other locations as well.

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
# <container(internal)_port> is defined in Dockerfile as EXPOSE.
$ docker run -p<host(external)_port>:<container(internal)_port> --name <container_name> <image_tag>
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
```

## Multi-Stage docker build
- Enable BuildKit
```bash
# Build an image for the last unnamed stage
$ docker build -t <some_image_name>:<some_version> .
# Build an image for a specific stage
$ docker build -t <some_image_name>:<some_version> --target <stage_name_from_dockerfile> . 
```

## App and Container configuration
It is always better practice to seperate the source code from the configuration code. The app/source code should not be able to access sensitive/critical configuration values directly so environment variables come to the rescue to be used by both the container and the app being containerized.

- Definition:
```dockerfile
ENV REDIS_HOST="redis_server" \
    REDIS_PORT=6379 \
    VERSION="1.0.18" \
    URL="some_url"
```
- Usage in the same Dockerfile
```dockerfile
RUN wget -q "${URL}/nginx-${VERSION}.tar.gz"
```
- Usage in container
```bash
$ docker run --rm <some_image_name> printenv REDIS_HOST
```
### Defer definition and usage of a varible until the docker build time
`ARG` values can only be used during Docker build time. Their scope starts from where they are defined and they are not visible during inspection. They can be consumed through Docker CLI.

> They can not exist or be accessed during application run within the container.
```dockerfile
ARG VERSION="1.2.34"
# or
ARG VERSION
```
```bash
$ docker build --build-arg VERSION="1.34.452" ...
```

`ENV` are persisting variables within the image AND visible in image's configuration so can be identified during inspection. `ENV` has the precedence over `ARG` so if ENV is defined after where `ARG` is defined for the same name, the variable will have to value what `ENV` dictates.

### Defer the definition and usage of a variable until the docker run time
```bash
# Usage 1
## If same env variables are defined before (i.e. DockerFile), they are overriden here.
$ docker run --rm --env REDIS_HOST=redis_server --env REDIS_PORT=6379 <image_name>
# Usage 2
$ export REDIS_HOST=redis_server REDIS_PORT=6379
$ docker run --rm --env REDIS_HOST --env REDIS_PORT <image_name>
# Usage 3
## redis.env file
VERSION
REDIS_HOST=redis_server
REDIS_PORT=6379
## Docker CLI
$ docker run --rm --env-file $(pwd)/redis.env <image_name> printenv REDIS_HOST
```

> **NOTE**: An `ARG` or `ENV` defined in a base image is also available in child images.

## Logging & Debugging
By defeault, Docker directs the logs to `STDOUT` and `STDERR` streams. It is NOT a good practice to alter this so writing errors/logs to file within the container is BAD. In that case Docker will not be able to capture the logs.

> HACK: If that is the case for you and you have to write the logs and errors to files, you can still direct them to streams with the `ln` command
```dockerfile
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
```

### [Logging drivers](https://git.io/JOPzr)
The driver setup can be done in daemon.json
- json-file: Default driver that stores logs locally in JSON format
- local: Flexible and more performant file-based logging solution
- journald: Logs sent to journald service running on the Docker host

```bash
$ docker run -it --name todo --log-driver local --log-opt max-file=3
# How to inspect what logging driver is being used
$ docker inspect --format '{{.HostConfig.LogConfig.Type}}' todo
```