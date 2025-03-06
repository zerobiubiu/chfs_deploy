# chfs_deploy

> 一键部署 Linux 下的文件服务器

本程序依赖于 [chfs](http://iscute.cn/chfs) 提供 Linux 下的一键部署脚本，更多详情请参考 chfs 官网。

## 前提条件
- 确保您的系统已连接到互联网。
- 您的系统需要安装 `curl` 或 `wget` 工具。
- 您需要有 `sudo` 权限来执行安装脚本。

## 安装脚本

您可以选择以下几种方式来运行安装脚本：

| 安装方式 | 命令 | 说明 |
| ---- | ---- | ---- |
| CURL | `curl -o- https://cdn.jsdelivr.net/gh/zerobiubiu/chfs_deploy@main/install.sh | sh` | 通过 `curl` 下载脚本并直接执行 |
| WGET | `wget -qO- https://cdn.jsdelivr.net/gh/zerobiubiu/chfs_deploy@main/install.sh | sh` | 通过 `wget` 下载脚本并直接执行 |
| 手动下载 | 1. 下载脚本：`wget https://cdn.jsdelivr.net/gh/zerobiubiu/chfs_deploy@main/install.sh`<br>2. 赋予执行权限：`chmod +x install.sh`<br>3. 运行脚本：`sudo ./install.sh` | 手动下载脚本，设置执行权限后运行 |

## 注意事项
- 如果网络不稳定，您可以手动将仓库克隆至 `/tmp/chfs_deploy/` 目录下，并确保目录格式为 `/tmp/chfs_deploy/仓库内容` 而非 `/tmp/chfs_deploy/chfs_deploy/仓库内容`，否则程序将无法执行。
- 在安装过程中，脚本会对 `/opt` 目录作出修改并且会增加系统服务，请确保您了解这些操作可能带来的影响。