#!/bin/bash

# 函数：验证用户输入是否为 y/yes/n/no
validate_yes_no_input() {
    local input=$1
    if [ "$input" = "y" ] || [ "$input" = "yes" ] || [ -z "$input" ]; then
        return 0
    elif [ "$input" = "n" ] || [ "$input" = "no" ]; then
        return 1
    else
        echo "输入错误，请重新输入"
        return 2
    fi
}

# 函数：检查仓库目录和文件是否完整
check_repo_integrity() {
    local dirs=("/tmp/chfs_deploy/" "/tmp/chfs_deploy/chfs/" "/tmp/chfs_deploy/chfs/bin/" "/tmp/chfs_deploy/chfs/config/" "/tmp/chfs_deploy/chfs/log" "/tmp/chfs_deploy/chfs/resource/")
    local files=("/tmp/chfs_deploy/install.sh" "/tmp/chfs_deploy/chfs/start.sh")

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "仓库未部署，请重新配置"
            return 1
        fi
    done

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            echo "仓库未部署，请重新配置"
            return 1
        fi
    done

    return 0
}

# 函数：向配置文件写入内容
write_to_config() {
    local key=$1
    local value=$2
    local comment=$3
    echo "# $comment" >> /opt/chfs/config/conf.ini
    echo "$key=$value" >> /opt/chfs/config/conf.ini
}

printf "安装程序将会对 /opt 目录作出修改并且会增加系统服务。请确保当前用户具有 sudo 权限，以防止出现意外情况或对系统造成不良影响。\n"
printf "拒绝请使用 Ctrl-C 。同意请按 Enter 键继续。。。"

read

echo "即将克隆 github.com/zerobiubiu/chfs_deploy.git 仓库，请确保网络通常，如网络不稳定请 Ctrl-C 结束本程序并手动将该仓库克隆至 /tmp/chfs_deploy/ 目录下，并确保目录格式为 /tmp/chfs_deploy/仓库内容 而非 /tmp/chfs_deploy/chfs_deploy/仓库内容 如不严格按照目录格式程序将无法执行。"

while true; do
    read -p "输入（y/yes）将继续执行克隆，输入（n/no）将跳过克隆: (y)" input
    validate_yes_no_input "$input"
    case $? in
        0)
            if which git >/dev/null; then
                # 根据实际需求设置更合理的权限
                sudo chmod 755 /tmp
                git clone --depth 1 https://github.com/zerobiubiu/chfs_deploy.git /tmp/chfs_deploy/
                break
            else
                echo "请安装 Git 后继续。"
                exit 1
            fi
            ;;
        1)
            if [ -d "/tmp/chfs_deploy/" ]; then
                check_repo_integrity
                if [ $? -eq 0 ]; then
                    break
                fi
            else
                echo "仓库未部署，请重新配置"
            fi
            ;;
        2)
            continue
            ;;
    esac
done

sudo cp -rf /tmp/chfs_deploy/chfs /opt/
if [ -f "/opt/chfs/log/.tmp" ]; then
    sudo rm -rf /opt/chfs/log/.tmp
fi
if [ -f "/opt/chfs/resource/.tmp" ]; then
    sudo rm -rf /opt/chfs/resource/.tmp
fi

text=$(
    cat <<EOF
[Unit]
Description=chfs
After=network.target

[Service]
Type=simple
ExecStart=/opt/chfs/start.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF
)
output_dir="/etc/systemd/system/"
output_file="$output_dir/chfs.service"
mkdir -p "$output_dir"

echo "$text" | sudo tee "$output_file" > /dev/null

read -p "设置服务器启动端口（0-65535）: （44380）" input
if [[ $input =~ ^[0-9]+$ && $input -ge 0 && $input -le 65535 ]]; then
    write_to_config "port" "$input" "端口设置"
    echo "已设置服务器端口为 $input"
elif [[ -z $input ]]; then
    write_to_config "port" "44380" "端口设置"
    echo "已设置服务器端口为 44380"
else
    write_to_config "port" "44380" "端口设置"
    echo "输入无效，不是一个 0-65535 的数字。"
    echo "已设置服务器端口为 44380"
fi

read -p "请设置匿名用户权限（R=读，W=写，D=删（输入对应字母及对应权限，如 RWD））: （无权）" input
input=$(echo "$input" | tr '[:lower:]' '[:upper:]')
if [[ $input =~ ^[RWD]{1,3}$ ]]; then
    write_to_config "rule" "::$input" "匿名用户设置"
    echo "已设置匿名用户权限为 $input"
elif [[ -z $input ]]; then
    write_to_config "rule" "::" "匿名用户设置"
    echo "已设置匿名用户无权限"
else
    write_to_config "rule" "::" "匿名用户设置"
    echo "输入无效，不是一个合法权限。"
    echo "已设置匿名用户无权限"
fi

read -p "请输入用户名（留空将使用默认用户名 user）：" input
if [[ -z $input ]]; then
    username="user"
else
    username=$input
fi

read -p "请输入用户密码（留空将使用默认密码 passwd）：" input
if [[ -z $input ]]; then
    password="passwd"
else
    password=$input
fi

read -p "请设置用户权限（R=读，W=写，D=删（输入对应字母及对应权限，如 RWD））: （RWD）" input
input=$(echo "$input" | tr '[:lower:]' '[:upper:]')
if [[ $input =~ ^[RWD]{1,3}$ ]]; then
    power=$input
elif [[ -z $input ]]; then
    power="RWD"
else
    echo "输入无效，不是一个合法权限。"
    echo "已设置用户权限为 RWD"
fi

write_to_config "rule" "$username:$password:$power" "用户设置"

write_to_config "html.title" "$username 的文件服务器" "服务器标题设置"

sudo systemctl daemon-reload
if [ $? -eq 0 ]; then
    echo "服务重载成功。。。"
fi
sudo systemctl start chfs.service
if [ $? -eq 0 ]; then
    echo "服务启动成功。。。"
fi
sudo systemctl enable chfs.service
if [ $? -eq 0 ]; then
    echo "服务已设置为开机自启动。"
fi
sudo systemctl status chfs.service

echo "服务器已安装完成，如需再进行进一步配置请修改 /opt/chfs/config/conf.ini"
echo "并执行 sudo systemctl restart chfs.service 重启服务"