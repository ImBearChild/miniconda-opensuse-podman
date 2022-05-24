# podconda.sh

[English](./README.md)

配置与管理预装了 Miniconda 和 JupyterLab 的 Podman 容器。换言之，本脚本可以帮助用户快速设置一个隔离的 Miniconda 环境。

## 为何

使用或者不使用某个软件不需要理由，但我还是给出一些可能让用户使用本脚本的“借口”。

* 容器化环境。`conda` 只是隔离了不同软件的运行环境，而容器化则隔离的更加彻底，几乎所有错误与损失都会被限制在容器内，而且容器内的数据可以被随意的快照与复原。也许您想要运行的代码并不出自您自己的手，而您又没有时间仔细检查它们。您的文档与资料可以安全的存放在容器外，不会被粗心的代码给毁坏或带走。
* 自动配置。
* 默认使用 [conda-forge](https://conda-forge.org/) 软件源，而非 Anaconda 公司的软件源。Anaconda 软件源内的软件包比 `conda-forge` 更少，而且有更严格的使用限制。

## 使用方法 

在使用前，您的电脑上需要有 Podman, 安装教程参见[此处](https://podman.io/getting-started/installation)。

创建新容器，并启动预装的 JupyterLab 服务器。

```
podconda.sh init && podconda.sh start
```

如果一切OK，那么你会看到类似输出：

```
[Podconda] starting container
[Podconda] acquiring token
Currently running servers:
http://d7bbf6f346b3:8888/?token=704ca44b8b146fc8cd37d8e9b81a22ff69c1c4e0289fe471 :: /home/gecko
```

下面 `http://XXXXXXXX:8888/?token=XXXXXX` 的就是你的 JupyterLab 的地址，复制到浏览器然后打开即可。

您也可以访问容器内的Shell，以便于在您不方便打开 JupyterLab 页面时的操作：

```
podconda.sh shell
```

注意，访问 shell 的命令只能在容器运行的时候使用。

要销毁当前容器，使用：

```
podconda.sh clean
```

### 安装语言包

在 JupyterLab 中打开终端，输入：

```
conda activate
pip install jupyterlab-language-pack-zh-CN
```

然后刷新浏览器页面，即可在菜单栏内看到语言选项。

### 容器内部

