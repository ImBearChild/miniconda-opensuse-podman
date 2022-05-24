# podconda.sh

[中文](./README.zh.md)

A "one-click" script to set up and manage a podman container with a bootstrapped installation of Miniconda and JupyterLab.

## Usage

Before using, you need to have Podman on your computer, the installation tutorial can be found [here](https://podman.io/getting-started/installation).

Create a new container and start the preinstalled JupyterLab server.

````
podconda.sh init && podconda.sh start
````

If everything is OK, then you will see output similar to:

````
[Podconda] starting container
[Podconda] acquiring token
Currently running servers:
http://d7bbf6f346b3:8888/?token=704ca44b8b146fc8cd37d8e9b81a22ff69c1c4e0289fe471::/home/gecko
````

The following `http://XXXXXXXX:8888/?token=XXXXXX` is the address of your JupyterLab, copy it to the browser and open it.

You can also access the shell inside the container:

````
podconda.sh shell
````

Note that commands to access the shell can only be used while the container is running.

To destroy the current container, use:

````
podconda.sh clean
````