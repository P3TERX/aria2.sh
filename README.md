# Aria2 一键安装管理脚本

[![GitHub](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square)](https://github.com/P3TERX/aria2.sh/blob/master/LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/P3TERX/aria2.sh.svg?style=flat-square&label=Stars)](https://github.com/P3TERX/aria2.sh/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/P3TERX/aria2.sh.svg?style=flat-square&label=Fork)](https://github.com/P3TERX/aria2.sh/fork)

## 系统要求

CentOS 6+ / Debian 6+ / Ubuntu 14.04+

## 下载安装

执行下面的代码下载并运行脚本，出现脚本操作菜单输入 `1` 开始安装。

```
wget -N https://git.io/aria2.sh && chmod +x aria2.sh && bash aria2.sh
```

## 使用说明

* 进入下载脚本的目录并运行脚本
  
  ```
  ./aria2.sh
  ```

* 选择你要执行的选项
  
  ```
  Aria2 一键安装管理脚本 [v2.0.5]
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

令牌密匙：随机生成（可以自己修改 7. 修改 配置文件）

默认下载目录：`/root/Download`

## 附加功能

整合了 [Aria2 完美配置](https://github.com/P3TERX/aria2_perfect_config)，在安装 Aria2 的过程中会下载这套配置方案，包含了配置文件、附加功能脚本等文件，用于实现 Aria2 功能的增强和扩展。

增强功能：

* 提升BT下载率和下载速度
* 下载完成删除残留的`.aria2`后缀名文件
* 下载错误或取消下载删除未完成的文件

扩展功能：

* [OneDrive、Google Drive 等网盘离线下载](https://p3terx.com/archives/offline-download-of-onedrive-gdrive.html)
* [百度网盘转存到 OneDrive 、Google Drive 等其他网盘](https://p3terx.com/archives/baidunetdisk-transfer-to-onedrive-and-google-drive.html)

## 更新日志

### 2019-10-12

- 修复 Aria2 版本更新时因未获取 CPU 架构导致版本下载错误且无法启动的 bug

<details>
<summary>历史记录</summary>

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
