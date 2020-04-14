# Aria2 一键安装管理脚本 增强版

[![LICENSE](https://img.shields.io/github/license/P3TERX/aria2.sh?style=flat-square)](https://github.com/P3TERX/aria2.sh/blob/master/LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/P3TERX/aria2.sh.svg?style=flat-square&label=Stars&logo=github)](https://github.com/P3TERX/aria2.sh/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/P3TERX/aria2.sh.svg?style=flat-square&label=Forks&logo=github)](https://github.com/P3TERX/aria2.sh/fork)

Aria2 是一个功能非常强大且齐全的下载工具，它支持 BT、磁力、HTTP、FTP 等下载协议，常用做离线下载的服务端。Aria2 一键安装管理脚本是 Toyo (逗比) 大佬最为知名的脚本作品之一，2018年11月14日逗比大佬因未知原因突然失联。由于博主非常喜欢 Aria2 所以自2018年12月7日起开始接手这个项目并进行了大量的功能与细节优化，一直持续维护至今。增强版脚本整合了 [Aria2 完美配置](https://github.com/P3TERX/aria2.conf)，在安装 Aria2 的过程中会下载这套配置方案，这套方案包含了配置文件、附加功能脚本等文件，用于实现 Aria2 功能的增强和扩展，提升 Aria2 的使用体验，解决 Aria2 在使用中遇到的 BT 下载无速度、文件残留占用磁盘空间、任务丢失、重复下载等问题。

## 功能特性

- 使用 [Aria2 完美配置](https://github.com/P3TERX/aria2.conf)方案
    - 提升 BT 下载率和下载速度
    - 重启后不丢失任务进度、不重复下载
    - 下载错误或取消下载自动删除未完成的文件防止磁盘空间占用
    - 下载完成自动清除`.aria2`后缀名文件
    - 更好的 PT 下载支持
    - 防版权投诉、防迅雷吸血优化

- 使用 [aria2-builder](https://github.com/P3TERX/aria2-builder) 项目最新静态编译二进制文件
    - 多平台：`amd64`, `i386`, `arm64`, `armhf`
    - 全功能：`Async DNS`, `BitTorrent`, `Firefox3 Cookie`, `GZip`, `HTTPS`, `Message Digest`, `Metalink`, `XML-RPC`, `SFTP`
    - 最新依赖库，提供更安全、稳定、快速的下载体验
    - 通过 CI 服务持续更新最新版本

- 支持与 [RCLONE](https://rclone.org/) 联动，更多扩展功能与玩法：
    - [OneDrive、Google Drive 等网盘离线下载](https://p3terx.com/archives/offline-download-of-onedrive-gdrive.html)
    - [百度网盘转存到 OneDrive 、Google Drive 等其他网盘](https://p3terx.com/archives/baidunetdisk-transfer-to-onedrive-and-google-drive.html)

- 支持新一代互联网协议 IPv6
- 定时自动更新 BT tracker 列表（无需重启）

## 项目地址

https://github.com/P3TERX/aria2.sh

支持项目请随手点个`star`，让更多的人发现、使用并受益。

## 系统要求

CentOS 6+ / Debian 6+ / Ubuntu 14.04+

## 架构支持

x86_64 / i386 / ARM64 / ARM32v7 / ARM32v6

## 使用说明

* 为了确保能正常使用，请先安装基础组件`wget`、`curl`、`ca-certificates`，以 Debian 为例子：
```
apt install wget curl ca-certificates
```

* 执行下面的代码运行脚本
```
bash <(wget -qO- git.io/aria2.sh)
```

* 选择你要执行的选项
```
  Aria2 一键安装管理脚本 [v2.2.1]
  -- P3TERX.COM --
  
  0. 升级脚本
  ————————————
  1. 安装 Aria2
  2. 更新 Aria2
  3. 卸载 Aria2
  ————————————
  4. 启动 Aria2
  5. 停止 Aria2
  6. 重启 Aria2
  ————————————
  7. 修改 配置
  8. 查看 配置
  9. 查看 日志
  10. 清空 日志
  ————————————
  11. 手动更新 BT-Tracker
  12. 自动更新 BT-Tracker
  ————————————
  
  当前状态: 已安装 并 已启动
  
  请输入数字 [0-12]:
```

## 其他操作

启动：`/etc/init.d/aria2 start`

停止：`/etc/init.d/aria2 stop`

重启：`/etc/init.d/aria2 restart`

查看状态：`/etc/init.d/aria2 status`

配置文件：`/root/.aria2/aria2.conf` （配置文件包含中文注释，但是一些系统可能不支持显示中文）

令牌密钥：随机生成（可以自己修改 7. 修改 配置文件）

默认下载目录：`/root/Download`

## 更新日志

> **TIPS:** 如果正在使用 v2.1.0 前的版本，请卸载后再升级，否则会导致功能异常。

### 2020-04-14 v2.2.1

- 优化 BT Tracker 列表更新策略，以无重启方式进行（**自动更新 BT Tracker** 功能需重新进行设置）
- 优化代码细节，修复部分历史遗留 bug

### 2020-02-18 v2.2.0

- 更换静态编译二进制文件下载来源（[P3TERX/aria2-builder](https://github.com/P3TERX/aria2-builder)）
- 适配 ARM64、ARM32v7、ARM32v6 架构。
- 优化文案细节。

### 2020-02-17 v2.1.0

- 适配新版 [Aria2 完美配置](https://github.com/P3TERX/aria2.conf)
- 分离 trackers 更新功能
- 优化功能，完善细节，修复若干 bug

<details>
<summary>历史记录</summary>

### 2019-11-23 v2.0.8

- 修改 Trackers 来源([XIU2/TrackersListCollection](https://github.com/XIU2/TrackersListCollection))

### 2019-10-12 v2.0.7

- 修复 Aria2 版本更新时因未获取 CPU 架构导致版本下载错误且无法启动的 bug

### 2019-09-30 v2.0.6

- 获取 DHT（IPv6）文件

### 2019-06-08 v2.0.5

- 增加 清空日志 功能
- 调整 部分文案

### 2018-12-25 v2.0.4

- 优化调整

### 2018-12-24 v2.0.3

- 增加 重置/更新 Aria2 完美配置 选项
- 优化 修改配置文件下载路径时同步修改附加功能脚本中的下载路径

### 2018-12-8 v2.0.2

- 修复 附加功能脚本没有执行权限的 bug

### 2018-12-7 v2.0.1

- 修复 设置下载文件夹提示不存在的 bug
- 解锁 更新 BT-Tracker服务器 选项

### 2018-12-7 v2.0.0α

- 整合 [Aria2 完美配置](https://github.com/P3TERX/aria2_perfect_config)

### 2018-10-18 v1.1.10

- 取自[一个逗比写的逗比脚本](https://github.com/P3TERX/doubi_backup)
- 感谢 Toyo 大佬

</details>

## Lisence
[MIT](https://github.com/P3TERX/aria2.sh/blob/master/LICENSE) © Toyo x P3TERX
