# Nexus3 Docker container with OpenWrt base image

A Dockerfile for Sonatype Nexus Repository Manager 3, based on mcreations/openwrt-x64.

To run, binding the exposed port 8081 to the host.

```
$ docker run -d -p 8081:8081 --name nexus mcreations/nexus3
```

To test:

```
$ curl -u admin:admin123 http://localhost:8081/service/metrics/ping
```

## Notes

* Default credentials are: `admin` / `admin123`; please change them
  immediately after the first login

* It can take some time (2-3 minutes) for the service to launch in a
new container.  You can tail the log to determine once Nexus is ready:

```
$ docker logs -f nexus
```

* Installation of Nexus is to `/opt/nexus`.  

* A persistent directory, `/data/nexus-work`, is used for
  configuration, logs, and storage. This directory needs to be
  writable by the Nexus process, which runs by default as UID 200.
  
* It is possible to change the UID/GID of the nexus user with the
  environment variables `NEXUS_UID` and `NEXUS_GID`.  If you do so
  after the first start, the uid/gid of the files in `/opt/nexus` and
  `/data/nexus-work` have to be changed, which might take some time.

* Three environment variables can be used to control the JVM arguments

  * `JAVA_MAX_MEM`, passed as -Xmx.  Defaults to `1200m`.

  * `JAVA_MIN_MEM`, passed as -Xms.  Defaults to `1200m`.

  * `EXTRA_JAVA_OPTS`.  Additional options can be passed to the JVM via
  this variable.

  These can be used supplied at runtime to control the JVM:

  ```
  $ docker run -d -p 8081:8081 --name nexus -e JAVA_MAX_HEAP=768m mcreations/nexus
  ```

### Persistent Data

There are two general approaches to handling persistent storage requirements
with Docker. See [Managing Data in Containers](https://docs.docker.com/userguide/dockervolumes/)
for additional information.

  1. *Use a data volume container*.  Since data volumes are persistent
  until no containers use them, a container can created specifically for 
  this purpose.  This is the recommended approach.  

  ```
  $ docker run -d --name nexus-data mcreations/nexus echo "data-only container for Nexus"
  $ docker run -d -p 8081:8081 --name nexus --volumes-from nexus-data mcreations/nexus
  ```

  2. *Mount a host directory as the volume*.  This is not portable, as it
  relies on the directory existing with correct permissions on the host.
  However it can be useful in certain situations where this volume needs
  to be assigned to certain specific underlying storage.  

  ```
  $ mkdir /some/dir/nexus-data && chown -R 200 /some/dir/nexus-data
  $ docker run -d -p 8081:8081 --name nexus -v /some/dir/nexus-data:/nexus-data mcreations/nexus
  ```

## Credits

Many thanks to sonatype, as this image (including this README) is
based on their
[Nexus3 Docker image](https://github.com/sonatype/docker-nexus3).

