#!/usr/bin/env bash
#=============================================================
# https://github.com/P3TERX/aria2.sh
# Description: Aria2 One-click installation management script
# System Required: CentOS/Debian/Ubuntu
# Version: 2.2.0
# Author: Toyo
# Maintainer: P3TERX
# Blog: https://p3terx.com
#=============================================================

sh_ver="2.2.0"
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
file="/root/.aria2"
download_path="/root/Download"
aria2_conf="/root/.aria2/aria2.conf"
aria2_log="/root/.aria2/aria2.log"
aria2c="/usr/local/bin/aria2c"
Crontab_file="/usr/bin/crontab"
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
Info="[${Green_font_prefix}信息${Font_color_suffix}]"
Error="[${Red_font_prefix}错误${Font_color_suffix}]"
Tip="[${Green_font_prefix}注意${Font_color_suffix}]"

check_root(){
    [[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}
#检查系统
check_sys(){
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
    elif cat /etc/issue | grep -q -E -i "debian"; then
        release="debian"
    elif cat /etc/issue | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    elif cat /proc/version | grep -q -E -i "debian"; then
        release="debian"
    elif cat /proc/version | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    fi
    ARCH=`uname -m`
    [ $(command -v dpkg) ] && dpkgARCH=$(dpkg --print-architecture | awk -F- '{ print $NF }')
}
check_installed_status(){
    [[ ! -e ${aria2c} ]] && echo -e "${Error} Aria2 没有安装，请检查 !" && exit 1
    [[ ! -e ${aria2_conf} ]] && echo -e "${Error} Aria2 配置文件不存在，请检查 !" && [[ $1 != "un" ]] && exit 1
}
check_crontab_installed_status(){
    if [[ ! -e ${Crontab_file} ]]; then
        echo -e "${Error} Crontab 没有安装，开始安装..."
        if [[ ${release} == "centos" ]]; then
            yum install crond -y
        else
            apt-get install cron -y
        fi
        if [[ ! -e ${Crontab_file} ]]; then
            echo -e "${Error} Crontab 安装失败，请检查！" && exit 1
        else
            echo -e "${Info} Crontab 安装成功！"
        fi
    fi
}
check_pid(){
    PID=`ps -ef| grep "aria2c"| grep -v grep| grep -v "aria2.sh"| grep -v "init.d"| grep -v "service"| awk '{print $2}'`
}
check_new_ver(){
    echo -e "${Info} 请输入 Aria2 版本号，格式如：[ 1.35.0 ]，获取地址：[ https://github.com/P3TERX/aria2-builder/releases ]"
    read -e -p "默认回车自动获取最新版本号:" aria2_new_ver
    if [[ -z ${aria2_new_ver} ]]; then
        aria2_new_ver=$(wget -qO- https://api.github.com/repos/P3TERX/aria2-builder/releases | grep -o '"tag_name": ".*"' | head -n 1 | sed 's/"//g' | sed 's/tag_name: //g')
        if [[ -z ${aria2_new_ver} ]]; then
            echo -e "${Error} Aria2 最新版本获取失败，请手动获取最新版本号[ https://github.com/P3TERX/aria2-builder/releases ]"
            read -e -p "请输入版本号 [ 格式如 1.35.0 ] :" aria2_new_ver
            [[ -z "${aria2_new_ver}" ]] && echo "取消..." && exit 1
        else
            echo -e "${Info} 检测到 Aria2 最新版本为 [ ${aria2_new_ver} ]"
        fi
    else
        echo -e "${Info} 即将准备下载 Aria2 版本为 [ ${aria2_new_ver} ]"
    fi
}
check_ver_comparison(){
    aria2_now_ver=$(${aria2c} -v|head -n 1|awk '{print $3}')
    [[ -z ${aria2_now_ver} ]] && echo -e "${Error} Aria2 当前版本获取失败 !" && exit 1
    if [[ "${aria2_now_ver}" != "${aria2_new_ver}" ]]; then
        echo -e "${Info} 发现 Aria2 已有新版本 [ ${aria2_new_ver} ](当前版本：${aria2_now_ver})"
        read -e -p "是否更新(会中断当前下载任务，请注意) ? [Y/n] :" yn
        [[ -z "${yn}" ]] && yn="y"
        if [[ $yn == [Yy] ]]; then
            check_pid
            [[ ! -z $PID ]] && kill -9 ${PID}
            check_sys
            Download_aria2 "update"
            Start_aria2
        fi
    else
        echo -e "${Info} 当前 Aria2 已是最新版本 [ ${aria2_new_ver} ]" && exit 1
    fi
}
Download_aria2(){
    update_dl=$1
    if [[ $ARCH == i*86 || $dpkgARCH == i*86 ]]; then
        ARCH="i386"
    elif [[ $ARCH == "x86_64" || $dpkgARCH == "amd64" ]]; then
        ARCH="amd64"
    elif [[ $ARCH == "aarch64" || $dpkgARCH == "arm64" ]]; then
        ARCH="arm64"
    elif [[ $ARCH == "armv7l" || $dpkgARCH == "armhf" ]]; then
        ARCH="armhf"
    else
        echo -e "${Error} 不支持此 CPU 架构。"
        exit 1
    fi
    wget -O- "https://github.com/P3TERX/aria2-builder/releases/download/${aria2_new_ver}/aria2-${aria2_new_ver}-static-linux-${ARCH}.tar.gz" | tar -zxC .
    [[ ! -s "aria2c" ]] && echo -e "${Error} Aria2 下载失败 !" && exit 1
    [[ ${update_dl} = "update" ]] && rm -f "${aria2c}"
    mv aria2c /usr/local/bin
    [[ ! -e ${aria2c} ]] && echo -e "${Error} Aria2 主程序安装失败！" && exit 1
    chmod +x ${aria2c}
    echo -e "${Info} Aria2 主程序安装完成！"
}
Download_aria2_conf(){
    mkdir -p "${file}" && cd "${file}"
    wget -N "https://raw.githubusercontent.com/P3TERX/aria2.conf/master/aria2.conf"
    [[ ! -s "aria2.conf" ]] && echo -e "${Error} Aria2 配置文件下载失败 !" && rm -rf "${file}" && exit 1
    wget -N "https://raw.githubusercontent.com/P3TERX/aria2.conf/master/autoupload.sh"
    [[ ! -s "autoupload.sh" ]] && echo -e "${Error} 附加功能脚本[autoupload.sh]下载失败 !" && rm -rf "${file}" && exit 1
    wget -N "https://raw.githubusercontent.com/P3TERX/aria2.conf/master/delete.aria2.sh"
    [[ ! -s "delete.aria2.sh" ]] && echo -e "${Error} 附加功能脚本[delete.aria2.sh]下载失败 !" && rm -rf "${file}" && exit 1
    wget -N "https://raw.githubusercontent.com/P3TERX/aria2.conf/master/delete.sh"
    [[ ! -s "delete.sh" ]] && echo -e "${Error} 附加功能脚本[delete.sh]下载失败 !" && rm -rf "${file}" && exit 1
    wget -N "https://raw.githubusercontent.com/P3TERX/aria2.conf/master/info.sh"
    [[ ! -s "info.sh" ]] && echo -e "${Error} 附加功能脚本[info.sh]下载失败 !" && rm -rf "${file}" && exit 1
    wget -N "https://raw.githubusercontent.com/P3TERX/aria2.conf/master/dht.dat"
    [[ ! -s "dht.dat" ]] && echo -e "${Error} Aria2 DHT（IPv4）文件下载失败 !" && rm -rf "${file}" && exit 1
    wget -N "https://raw.githubusercontent.com/P3TERX/aria2.conf/master/dht6.dat"
    [[ ! -s "dht6.dat" ]] && echo -e "${Error} Aria2 DHT（IPv6）文件下载失败 !" && rm -rf "${file}" && exit 1
    touch aria2.session
    chmod +x *.sh
    sed -i "/^downloadpath=/c\downloadpath='${download_path}'" ${file}/*.sh
    sed -i "/^DOWNLOAD_PATH=/c\DOWNLOAD_PATH='${download_path}'" ${file}/*.sh
    sed -i 's/^rpc-secret=P3TERX/rpc-secret='$(date +%s%N | md5sum | head -c 20)'/g' ${aria2_conf}
    echo -e "${Info} Aria2 完美配置下载完成！"
}
Service_aria2(){
    if [[ ${release} = "centos" ]]; then
        if ! wget https://raw.githubusercontent.com/P3TERX/aria2.sh/master/service/aria2_centos -O /etc/init.d/aria2; then
            echo -e "${Error} Aria2服务 管理脚本下载失败 !" && exit 1
        fi
        chmod +x /etc/init.d/aria2
        chkconfig --add aria2
        chkconfig aria2 on
    else
        if ! wget https://raw.githubusercontent.com/P3TERX/aria2.sh/master/service/aria2_debian -O /etc/init.d/aria2; then
            echo -e "${Error} Aria2服务 管理脚本下载失败 !" && exit 1
        fi
        chmod +x /etc/init.d/aria2
        update-rc.d -f aria2 defaults
    fi
    echo -e "${Info} Aria2服务 管理脚本下载完成 !"
}
Installation_dependency(){
    if [[ ${release} = "centos" ]]; then
        yum update
        yum install nano ca-certificates findutils tar gzip dpkg -y
    else
        apt-get update
        apt-get install nano ca-certificates findutils tar gzip dpkg -y
    fi
    wget -qO- git.io/ca-certificates.sh | bash
}
Install_aria2(){
    check_root
    [[ -e ${aria2c} ]] && echo -e "${Error} Aria2 已安装，请检查 !" && exit 1
    check_sys
    echo -e "${Info} 开始安装/配置 依赖..."
    Installation_dependency
    echo -e "${Info} 开始下载/安装 主程序..."
    check_new_ver
    Download_aria2
    echo -e "${Info} 开始下载/安装 Aria2 完美配置..."
    Download_aria2_conf
    echo -e "${Info} 开始下载/安装 服务脚本(init)..."
    Service_aria2
    Read_config
    aria2_RPC_port=${aria2_port}
    echo -e "${Info} 开始设置 iptables防火墙..."
    Set_iptables
    echo -e "${Info} 开始添加 iptables防火墙规则..."
    Add_iptables
    echo -e "${Info} 开始保存 iptables防火墙规则..."
    Save_iptables
    echo -e "${Info} 开始创建 下载目录..."
    mkdir -p ${download_path}
    echo -e "${Info} 所有步骤 安装完毕，开始启动..."
    Start_aria2
}
Start_aria2(){
    check_installed_status
    check_pid
    [[ ! -z ${PID} ]] && echo -e "${Error} Aria2 正在运行，请检查 !" && exit 1
    /etc/init.d/aria2 start
}
Stop_aria2(){
    check_installed_status
    check_pid
    [[ -z ${PID} ]] && echo -e "${Error} Aria2 没有运行，请检查 !" && exit 1
    /etc/init.d/aria2 stop
}
Restart_aria2(){
    check_installed_status
    check_pid
    [[ ! -z ${PID} ]] && /etc/init.d/aria2 stop
    /etc/init.d/aria2 start
}
Set_aria2(){
    check_installed_status
    echo && echo -e "你要做什么？
 ${Green_font_prefix}1.${Font_color_suffix}  修改 Aria2 RPC 密钥
 ${Green_font_prefix}2.${Font_color_suffix}  修改 Aria2 RPC 端口
 ${Green_font_prefix}3.${Font_color_suffix}  修改 Aria2 文件下载位置
 ${Green_font_prefix}4.${Font_color_suffix}  修改 Aria2 密钥 + 端口 + 文件下载位置
 ${Green_font_prefix}5.${Font_color_suffix}  手动 打开配置文件修改
 ————————————
 ${Green_font_prefix}0.${Font_color_suffix}  重置/更新 Aria2 完美配置" && echo
    read -e -p "(默认: 取消):" aria2_modify
    [[ -z "${aria2_modify}" ]] && echo "已取消..." && exit 1
    if [[ ${aria2_modify} == "1" ]]; then
        Set_aria2_RPC_passwd
    elif [[ ${aria2_modify} == "2" ]]; then
        Set_aria2_RPC_port
    elif [[ ${aria2_modify} == "3" ]]; then
        Set_aria2_RPC_dir
    elif [[ ${aria2_modify} == "4" ]]; then
        Set_aria2_RPC_passwd_port_dir
    elif [[ ${aria2_modify} == "5" ]]; then
        Set_aria2_vim_conf
    elif [[ ${aria2_modify} == "0" ]]; then
        Reset_aria2_conf
    else
        echo -e "${Error} 请输入正确的数字(0-5)" && exit 1
    fi
}
Set_aria2_RPC_passwd(){
    read_123=$1
    if [[ ${read_123} != "1" ]]; then
        Read_config
    fi
    if [[ -z "${aria2_passwd}" ]]; then
        aria2_passwd_1="空(没有检测到配置，可能手动删除或注释了)"
    else
        aria2_passwd_1=${aria2_passwd}
    fi
    echo -e "请输入要设置的 Aria2 RPC 密钥(旧密钥为：${Green_font_prefix}${aria2_passwd_1}${Font_color_suffix})"
    read -e -p "(默认密钥: 随机生成 密钥请不要包含等号 = 和井号 #):" aria2_RPC_passwd
    echo
    [[ -z "${aria2_RPC_passwd}" ]] && aria2_RPC_passwd=$(date +%s%N | md5sum | head -c 20)
    if [[ "${aria2_passwd}" != "${aria2_RPC_passwd}" ]]; then
        if [[ -z "${aria2_passwd}" ]]; then
            echo -e "\nrpc-secret=${aria2_RPC_passwd}" >> ${aria2_conf}
            if [[ $? -eq 0 ]];then
                echo -e "${Info} 密钥修改成功！新密钥为：${Green_font_prefix}${aria2_RPC_passwd}${Font_color_suffix}(因为找不到旧配置参数，所以自动加入配置文件底部)"
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else 
                echo -e "${Error} 密钥修改失败！旧密钥为：${Green_font_prefix}${aria2_passwd}${Font_color_suffix}"
            fi
        else
            sed -i 's/^rpc-secret='${aria2_passwd}'/rpc-secret='${aria2_RPC_passwd}'/g' ${aria2_conf}
            if [[ $? -eq 0 ]];then
                echo -e "${Info} 密钥修改成功！新密钥为：${Green_font_prefix}${aria2_RPC_passwd}${Font_color_suffix}"
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else 
                echo -e "${Error} 密钥修改失败！旧密钥为：${Green_font_prefix}${aria2_passwd}${Font_color_suffix}"
            fi
        fi
    else
        echo -e "${Error} 新密钥与旧密钥一致，取消..."
    fi
}
Set_aria2_RPC_port(){
    read_123=$1
    if [[ ${read_123} != "1" ]]; then
        Read_config
    fi
    if [[ -z "${aria2_port}" ]]; then
        aria2_port_1="空(没有检测到配置，可能手动删除或注释了)"
    else
        aria2_port_1=${aria2_port}
    fi
    echo -e "请输入要设置的 Aria2 RPC 端口(旧端口为：${Green_font_prefix}${aria2_port_1}${Font_color_suffix})"
    read -e -p "(默认端口: 6800):" aria2_RPC_port
    echo
    [[ -z "${aria2_RPC_port}" ]] && aria2_RPC_port="6800"
    if [[ "${aria2_port}" != "${aria2_RPC_port}" ]]; then
        if [[ -z "${aria2_port}" ]]; then
            echo -e "\nrpc-listen-port=${aria2_RPC_port}" >> ${aria2_conf}
            if [[ $? -eq 0 ]];then
                echo -e "${Info} 端口修改成功！新端口为：${Green_font_prefix}${aria2_RPC_port}${Font_color_suffix}(因为找不到旧配置参数，所以自动加入配置文件底部)"
                Del_iptables
                Add_iptables
                Save_iptables
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else 
                echo -e "${Error} 端口修改失败！旧端口为：${Green_font_prefix}${aria2_port}${Font_color_suffix}"
            fi
        else
            sed -i 's/^rpc-listen-port='${aria2_port}'/rpc-listen-port='${aria2_RPC_port}'/g' ${aria2_conf}
            if [[ $? -eq 0 ]];then
                echo -e "${Info} 端口修改成功！新密钥为：${Green_font_prefix}${aria2_RPC_port}${Font_color_suffix}"
                Del_iptables
                Add_iptables
                Save_iptables
                if [[ ${read_123} != "1" ]]; then
                    Restart_aria2
                fi
            else 
                echo -e "${Error} 端口修改失败！旧密钥为：${Green_font_prefix}${aria2_port}${Font_color_suffix}"
            fi
        fi
    else
        echo -e "${Error} 新端口与旧端口一致，取消..."
    fi
}
Set_aria2_RPC_dir(){
    read_123=$1
    if [[ ${read_123} != "1" ]]; then
        Read_config
    fi
    if [[ -z "${aria2_dir}" ]]; then
        aria2_dir_1="空(没有检测到配置，可能手动删除或注释了)"
    else
        aria2_dir_1=${aria2_dir}
    fi
    echo -e "请输入要设置的 Aria2 文件下载位置(旧位置为：${Green_font_prefix}${aria2_dir_1}${Font_color_suffix})"
    read -e -p "(默认位置: ${download_path}):" aria2_RPC_dir
    [[ -z "${aria2_RPC_dir}" ]] && aria2_RPC_dir="${download_path}"
    mkdir -p ${aria2_RPC_dir}
    echo
    if [[ -d "${aria2_RPC_dir}" ]]; then
        if [[ "${aria2_dir}" != "${aria2_RPC_dir}" ]]; then
            if [[ -z "${aria2_dir}" ]]; then
                echo -e "\ndir=${aria2_RPC_dir}" >> ${aria2_conf}
                if [[ $? -eq 0 ]];then
                    echo -e "${Info} 位置修改成功！新位置为：${Green_font_prefix}${aria2_RPC_dir}${Font_color_suffix}(因为找不到旧配置参数，所以自动加入配置文件底部)"
                    if [[ ${read_123} != "1" ]]; then
                        Restart_aria2
                    fi
                else 
                    echo -e "${Error} 位置修改失败！旧位置为：${Green_font_prefix}${aria2_dir}${Font_color_suffix}"
                fi
            else
                aria2_dir_2=$(echo "${aria2_dir}"|sed 's/\//\\\//g')
                aria2_RPC_dir_2=$(echo "${aria2_RPC_dir}"|sed 's/\//\\\//g')
                sed -i 's/^dir='${aria2_dir_2}'/dir='${aria2_RPC_dir_2}'/g' ${aria2_conf}
                sed -i "/^downloadpath=/c\downloadpath='${aria2_RPC_dir_2}'" ${file}/*.sh
                sed -i "/^DOWNLOAD_PATH=/c\DOWNLOAD_PATH='${aria2_RPC_dir_2}'" ${file}/*.sh
                if [[ $? -eq 0 ]];then
                    echo -e "${Info} 位置修改成功！新位置为：${Green_font_prefix}${aria2_RPC_dir}${Font_color_suffix}"
                    if [[ ${read_123} != "1" ]]; then
                        Restart_aria2
                    fi
                else 
                    echo -e "${Error} 位置修改失败！旧位置为：${Green_font_prefix}${aria2_dir}${Font_color_suffix}"
                fi
            fi
        else
            echo -e "${Error} 新位置与旧位置一致，取消..."
        fi
    else
        echo -e "${Error} 新位置文件夹不存在，请检查！新位置为：${Green_font_prefix}${aria2_RPC_dir}${Font_color_suffix}"
    fi
}
Set_aria2_RPC_passwd_port_dir(){
    Read_config
    Set_aria2_RPC_passwd "1"
    Set_aria2_RPC_port "1"
    Set_aria2_RPC_dir "1"
    Restart_aria2
}
Set_aria2_vim_conf(){
    Read_config
    aria2_port_old=${aria2_port}
    aria2_dir_old=${aria2_dir}
    echo -e "${Tip} 手动修改配置文件须知（nano 文本编辑器使用教程：https://p3terx.com/archives/linux-nano-tutorial.html）：
${Green_font_prefix}1.${Font_color_suffix} 配置文件中含有中文注释，如果你的 服务器系统 或 SSH工具 不支持中文显示，将会乱码(请本地编辑)。
${Green_font_prefix}2.${Font_color_suffix} 一会自动打开配置文件后，就可以开始手动编辑文件了。
${Green_font_prefix}3.${Font_color_suffix} 如果要退出并保存文件，那么按 ${Green_font_prefix}Ctrl+X键${Font_color_suffix} 后，输入 ${Green_font_prefix}y${Font_color_suffix} 后，再按一下 ${Green_font_prefix}回车键${Font_color_suffix} 即可。
${Green_font_prefix}4.${Font_color_suffix} 如果要退出并不保存文件，那么按 ${Green_font_prefix}Ctrl+X键${Font_color_suffix} 后，输入 ${Green_font_prefix}n${Font_color_suffix} 即可。
${Green_font_prefix}5.${Font_color_suffix} 如果你想在本地编辑配置文件，那么配置文件位置： ${Green_font_prefix}/root/.aria2/aria2.conf${Font_color_suffix} (注意是隐藏目录) 。" && echo
    read -e -p "如果已经理解 nano 使用方法，请按任意键继续，如要取消请使用 Ctrl+C 。" var
    nano "${aria2_conf}"
    Read_config
    if [[ ${aria2_port_old} != ${aria2_port} ]]; then
        aria2_RPC_port=${aria2_port}
        aria2_port=${aria2_port_old}
        Del_iptables
        Add_iptables
        Save_iptables
    fi
    if [[ ${aria2_dir_old} != ${aria2_dir} ]]; then
        mkdir -p ${aria2_dir}
        aria2_dir_2=$(echo "${aria2_dir}"|sed 's/\//\\\//g')
        aria2_dir_old_2=$(echo "${aria2_dir_old}"|sed 's/\//\\\//g')
        sed -i "/^downloadpath=/c\downloadpath='${aria2_RPC_dir_2}'" ${file}/*.sh
        sed -i "/^DOWNLOAD_PATH=/c\DOWNLOAD_PATH='${aria2_RPC_dir_2}'" ${file}/*.sh
    fi
    Restart_aria2
}
Reset_aria2_conf(){
    Read_config
    aria2_port_old=${aria2_port}
    echo -e "${Tip} 此操作会重新下载 Aria2 完美配置，覆盖现有的配置文件及附加功能脚本。" && echo
    read -e -p "按任意键继续，如要取消请使用 Ctrl+C 。" var
    Download_aria2_conf
    Read_config
    if [[ ${aria2_port_old} != ${aria2_port} ]]; then
        aria2_RPC_port=${aria2_port}
        aria2_port=${aria2_port_old}
        Del_iptables
        Add_iptables
        Save_iptables
    fi
    Restart_aria2
}
Read_config(){
    status_type=$1
    if [[ ! -e ${aria2_conf} ]]; then
        if [[ ${status_type} != "un" ]]; then
            echo -e "${Error} Aria2 配置文件不存在 !" && exit 1
        fi
    else
        conf_text=$(cat ${aria2_conf}|grep -v '#')
        aria2_dir=$(echo -e "${conf_text}"|grep "dir="|awk -F "=" '{print $NF}')
        aria2_port=$(echo -e "${conf_text}"|grep "rpc-listen-port="|awk -F "=" '{print $NF}')
        aria2_passwd=$(echo -e "${conf_text}"|grep "rpc-secret="|awk -F "=" '{print $NF}')
    fi
    
}
View_Aria2(){
    check_installed_status
    Read_config
    ip=$(wget -qO- -t1 -T2 ipinfo.io/ip)
    if [[ -z "${ip}" ]]; then
        ip=$(wget -qO- -t1 -T2 api.ip.sb/ip)
        if [[ -z "${ip}" ]]; then
            ip=$(wget -qO- -t1 -T2 members.3322.org/dyndns/getip)
            if [[ -z "${ip}" ]]; then
                ip="VPS_IP(外网IP检测失败)"
            fi
        fi
    fi
    [[ -z "${aria2_dir}" ]] && aria2_dir="找不到配置参数"
    [[ -z "${aria2_port}" ]] && aria2_port="找不到配置参数"
    [[ -z "${aria2_passwd}" ]] && aria2_passwd="找不到配置参数(或无密钥)"
    clear
    echo -e "\nAria2 简单配置信息：\n
 地址\t: ${Green_font_prefix}${ip}${Font_color_suffix}
 端口\t: ${Green_font_prefix}${aria2_port}${Font_color_suffix}
 密钥\t: ${Green_font_prefix}${aria2_passwd}${Font_color_suffix}
 目录\t: ${Green_font_prefix}${aria2_dir}${Font_color_suffix}\n"
}
View_Log(){
    [[ ! -e ${aria2_log} ]] && echo -e "${Error} Aria2 日志文件不存在 !" && exit 1
    echo && echo -e "${Tip} 按 ${Red_font_prefix}Ctrl+C${Font_color_suffix} 终止查看日志" && echo -e "如果需要查看完整日志内容，请用 ${Red_font_prefix}cat ${aria2_log}${Font_color_suffix} 命令。" && echo
    tail -f ${aria2_log}
}
Clean_Log(){
    [[ ! -e ${aria2_log} ]] && echo -e "${Error} Aria2 日志文件不存在 !" && exit 1
    > ${aria2_log}
    echo -e "${Info} Aria2 日志已清空 !"
}
Update_bt_tracker_cron(){
    check_installed_status
    check_crontab_installed_status
    crontab_update_status=$(crontab -l|grep "bash <(wget -qO- git.io/tracker.sh) ${aria2_conf}")
    if [[ -z "${crontab_update_status}" ]]; then
        echo && echo -e "当前自动更新模式: ${Red_font_prefix}未开启${Font_color_suffix}" && echo
        echo -e "确定要开启 ${Green_font_prefix}Aria2 自动更新 BT-Tracker${Font_color_suffix} 功能吗？(一般情况下会加强BT下载效果)[Y/n]"
        read -e -p "注意：该功能会定时重启 Aria2！(默认: y):" crontab_update_status_ny
        [[ -z "${crontab_update_status_ny}" ]] && crontab_update_status_ny="y"
        if [[ ${crontab_update_status_ny} == [Yy] ]]; then
            crontab_update_start
        else
            echo && echo "	已取消..." && echo
        fi
    else
        echo && echo -e "当前自动更新模式: ${Green_font_prefix}已开启${Font_color_suffix}" && echo
        echo -e "确定要关闭 ${Red_font_prefix}Aria2 自动更新 BT-Tracker${Font_color_suffix} 功能吗？(一般情况下会加强BT下载效果)[y/N]"
        read -e -p "注意：该功能会定时重启 Aria2！(默认: n):" crontab_update_status_ny
        [[ -z "${crontab_update_status_ny}" ]] && crontab_update_status_ny="n"
        if [[ ${crontab_update_status_ny} == [Yy] ]]; then
            crontab_update_stop
        else
            echo && echo "	已取消..." && echo
        fi
    fi
}
crontab_update_start(){
    crontab -l > "/tmp/crontab.bak"
    sed -i "/aria2.sh update-bt-tracker/d" "/tmp/crontab.bak"
    echo -e "\n0 3 * * 1 /bin/bash <(wget -qO- git.io/tracker.sh) ${aria2_conf}" >> "/tmp/crontab.bak"
    crontab "/tmp/crontab.bak"
    rm -f "/tmp/crontab.bak"
    cron_config=$(crontab -l | grep "bash <(wget -qO- git.io/tracker.sh) ${aria2_conf}")
    if [[ -z ${cron_config} ]]; then
        echo -e "${Error} Aria2 自动更新 BT-Tracker 开启失败 !" && exit 1
    else
        bash <(wget -qO- git.io/tracker.sh) ${aria2_conf}
        echo -e "${Info} Aria2 自动更新 BT-Tracker 开启成功 !"
    fi
}
crontab_update_stop(){
    crontab -l > "/tmp/crontab.bak"
    sed -i "/aria2.sh update-bt-tracker/d" "/tmp/crontab.bak"
    sed -i "/tracker.sh/d" "/tmp/crontab.bak"
    crontab "/tmp/crontab.bak"
    rm -f "/tmp/crontab.bak"
    cron_config=$(crontab -l | grep "bash <(wget -qO- git.io/tracker.sh) ${aria2_conf}")
    if [[ ! -z ${cron_config} ]]; then
        echo -e "${Error} Aria2 自动更新 BT-Tracker 停止失败 !" && exit 1
    else
        echo -e "${Info} Aria2 自动更新 BT-Tracker 停止成功 !"
    fi
}
Update_bt_tracker(){
    check_installed_status
    check_pid
    [[ ! -z ${PID} ]] && /etc/init.d/aria2 stop
    bash <(wget -qO- git.io/tracker.sh) ${aria2_conf}
    /etc/init.d/aria2 start
}
Update_aria2(){
    check_installed_status
    check_new_ver
    check_ver_comparison
}
Uninstall_aria2(){
    check_installed_status "un"
    echo "确定要卸载 Aria2 ? (y/N)"
    echo
    read -e -p "(默认: n):" unyn
    [[ -z ${unyn} ]] && unyn="n"
    if [[ ${unyn} == [Yy] ]]; then
        crontab -l > "/tmp/crontab.bak"
        sed -i "/aria2.sh/d" "/tmp/crontab.bak"
        sed -i "/tracker.sh/d" "/tmp/crontab.bak"
        crontab "/tmp/crontab.bak"
        rm -f "/tmp/crontab.bak"
        check_pid
        [[ ! -z $PID ]] && kill -9 ${PID}
        Read_config "un"
        Del_iptables
        Save_iptables
        rm -rf "${aria2c}"
        rm -rf "${file}"
        if [[ ${release} = "centos" ]]; then
            chkconfig --del aria2
        else
            update-rc.d -f aria2 remove
        fi
        rm -rf "/etc/init.d/aria2"
        echo && echo "Aria2 卸载完成 !" && echo
    else
        echo && echo "卸载已取消..." && echo
    fi
}
Add_iptables(){
    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${aria2_RPC_port} -j ACCEPT
    iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${aria2_RPC_port} -j ACCEPT
}
Del_iptables(){
    iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport ${aria2_port} -j ACCEPT
    iptables -D INPUT -m state --state NEW -m udp -p udp --dport ${aria2_port} -j ACCEPT
}
Save_iptables(){
    if [[ ${release} == "centos" ]]; then
        service iptables save
    else
        iptables-save > /etc/iptables.up.rules
    fi
}
Set_iptables(){
    if [[ ${release} == "centos" ]]; then
        service iptables save
        chkconfig --level 2345 iptables on
    else
        iptables-save > /etc/iptables.up.rules
        echo -e '#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules' > /etc/network/if-pre-up.d/iptables
        chmod +x /etc/network/if-pre-up.d/iptables
    fi
}
Update_Shell(){
    sh_new_ver=$(wget -qO- -t1 -T3 "https://raw.githubusercontent.com/P3TERX/aria2.sh/master/aria2.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
    [[ -z ${sh_new_ver} ]] && echo -e "${Error} 无法链接到 Github !" && exit 0
    if [[ -e "/etc/init.d/aria2" ]]; then
        rm -rf /etc/init.d/aria2
        Service_aria2
    fi
    wget -N "https://raw.githubusercontent.com/P3TERX/aria2.sh/master/aria2.sh" && chmod +x aria2.sh
    echo -e "脚本已更新为最新版本[ ${sh_new_ver} ] !(注意：因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可)" && exit 0
}

echo && echo -e " Aria2 一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- \033[1;35mP3TERX.COM\033[0m --
  
 ${Green_font_prefix} 0.${Font_color_suffix} 升级脚本
————————————
 ${Green_font_prefix} 1.${Font_color_suffix} 安装 Aria2
 ${Green_font_prefix} 2.${Font_color_suffix} 更新 Aria2
 ${Green_font_prefix} 3.${Font_color_suffix} 卸载 Aria2
————————————
 ${Green_font_prefix} 4.${Font_color_suffix} 启动 Aria2
 ${Green_font_prefix} 5.${Font_color_suffix} 停止 Aria2
 ${Green_font_prefix} 6.${Font_color_suffix} 重启 Aria2
————————————
 ${Green_font_prefix} 7.${Font_color_suffix} 修改 配置
 ${Green_font_prefix} 8.${Font_color_suffix} 查看 配置
 ${Green_font_prefix} 9.${Font_color_suffix} 查看 日志
 ${Green_font_prefix}10.${Font_color_suffix} 清空 日志
————————————
 ${Green_font_prefix}11.${Font_color_suffix} 手动更新 BT-Tracker
 ${Green_font_prefix}12.${Font_color_suffix} 自动更新 BT-Tracker
————————————" && echo
if [[ -e ${aria2c} ]]; then
    check_pid
    if [[ ! -z "${PID}" ]]; then
        echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
    else
        echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
    fi
else
    echo -e " 当前状态: ${Red_font_prefix}未安装${Font_color_suffix}"
fi
echo
read -e -p " 请输入数字 [0-12]:" num
case "$num" in
    0)
    Update_Shell
    ;;
    1)
    Install_aria2
    ;;
    2)
    Update_aria2
    ;;
    3)
    Uninstall_aria2
    ;;
    4)
    Start_aria2
    ;;
    5)
    Stop_aria2
    ;;
    6)
    Restart_aria2
    ;;
    7)
    Set_aria2
    ;;
    8)
    View_Aria2
    ;;
    9)
    View_Log
    ;;
    10)
    Clean_Log
    ;;
    11)
    Update_bt_tracker
    ;;
    12)
    Update_bt_tracker_cron
    ;;
    *)
    echo "请输入正确数字 [0-12]"
    ;;
esac
