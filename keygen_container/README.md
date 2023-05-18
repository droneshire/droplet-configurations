# CREATING KEYS OUTSIDE THE CONTAINER

The following Dockerfile does instead create the key once the container is started, and it may be used to create the key outside the container's file system

```
FROM ubuntu:latest
RUN apt update
RUN apt -y install openssh-client
CMD ssh-keygen -q -t rsa -N '' -f /keys/id_rsa
```

First, build the container with the following command:
```
docker build -t keygen-container .
```
Starting the container using
```
docker run -v /tmp/:/keys keygen-container
```

will create a key on the host in /tmp.

This can be easily mapped into another container by using Docker VOLUMES; and you'd simply mount a volume holding keys/containers into the Docker container when launching it.

To mount the keys as a volume in the second container instead of copying them directly, you can modify the second Dockerfile as follows:

Dockerfile2
```
# Dockerfile2
FROM ubuntu:latest
# Copy any other necessary files or commands
VOLUME /path/to/destination
```

In this modified Dockerfile, the VOLUME instruction declares that the /path/to/destination directory inside the container should be used as a volume. When you run the container based on this image, you can mount the keys from the first container into the specified volume path.

To achieve this, you need to start a container from the first image (key-generator) and mount the generated keys into the second container when running it. Here's an example command to accomplish that:

bash
```
docker run -v $(pwd)/keys:/path/to/destination --name key-volume key-generator
```

In this command, the -v flag binds the $(pwd)/keys directory on the host to the /path/to/destination directory inside the container, effectively mounting the keys into the specified volume path. The --name key-volume option assigns a name (key-volume) to the first container.

Now, when you start the second container, you can reference the mounted volume to access the keys:

bash
```
docker run -v /path/to/destination:/desired/mount/point your-second-image
```

Replace /path/to/destination with the path you specified in the second Dockerfile (/path/to/destination) and /desired/mount/point with the path inside the second container where you want the keys to be mounted.

By doing this, the keys generated in the first container will be mounted as a volume in the second container without being copied directly into it.

The /path/to/destination in the second Dockerfile is a path inside the container. It specifies the directory inside the second container where the volume will be mounted.

When using the docker run command to start the container, you can specify the actual path on the host machine that you want to bind/mount to /path/to/destination inside the container.

For example, if you want to mount the keys to a directory called /host/keys on your host machine, the docker run command would be:

bash
```
docker run -v /host/keys:/path/to/destination your-second-image
```
In this case, /host/keys is the path outside the container, on your host machine, that you want to use as the volume. And /path/to/destination is the path inside the container where this volume will be mounted.

So, to clarify, /path/to/destination is a path inside the container, and you can choose any suitable path on your host machine to mount as the volume when starting the container.
