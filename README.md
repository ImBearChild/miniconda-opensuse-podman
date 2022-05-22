# Anaconda Podman image based on OpenSUSE

Podman container with a bootstrapped installation of Miniconda and JupyterLab that is ready to use.

## Usage

Start preinstalled JupyterLab server:

```
podman run -p 8888:8888 miniconda-opensuse:latest
```

Then you can access it with you browser on http://127.0.0.1:8888
