# 基于 openSUSE 的 Miniconda 镜像 

预装了 Miniconda 和 JupyterLab 的 Podman 镜像，开箱即用。

## 优势

与官方的 Miniconda3 镜像相比，本项目有以下特点：

* 开箱即用：自带 JupyterLab。
* 空格安全：容器内使用普通用户，空格通常带不走您的 `/usr`。（当然您也可以 `sudo`，root 帐户的密码是 `anaconda-opensuse` ）
* 基于SUSE：采用 openSUSE 官方镜像作为基底。

## 使用方法 

创建新容器，并启动预装的 JupyterLab 服务器。

```
podman run -p 8888:8888 --name conda miniconda-opensuse:latest 
```

然后可以在浏览器里通过 http://127.0.0.1:8888 访问。

在以后的使用中，不需要创建新容器，直接运行

```
podman start conda
```

### 安装语言包

在 JupyterLab 中打开终端，输入：

```
conda activate
pip install jupyterlab-language-pack-zh-CN
```

然后刷新浏览器页面，即可在菜单栏内看到语言选项。