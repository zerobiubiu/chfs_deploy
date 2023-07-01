#!/bin/sh

printf "安装程序将会对 /opt 目录作出修改并且会增加系统服务。请确保当前用户具有 sudo 权限，以防止出现意外情况或对系统造成不良影响。\n"
printf "拒绝请使用 Ctrl-C 。同意请按 Enter 键继续。。。"
# read

echo "即将克隆 github.com/zerobiubiu/chfs_deploy.git 仓库，请确保网络通常，如网络不稳定请 Ctrl-C 结束本程序并手动将该仓库克隆至 /tmp/chfs_deploy/ 目录下，并确保目录格式为 /tmp/chfs_deploy/仓库内容 而非 /tmp/chfs_deploy/chfs_deploy/仓库内容 如不严格按照目录格式程序将无法执行。"

while true; do
    read -p "输入（y/yes）将继续执行克隆，输入（n/no）将跳过克隆: (y)" input

    if [ "$input" = "y" ] || [ "$input" = "yes" ] || [ -z "$input" ]; then
        if which git >/dev/null; then
            sudo chmod 777 /tmp
            git clone --depth 1 https://github.com/zerobiubiu/chfs_deploy.git /tmp/chfs_deploy/
            break
        else
            echo "请安装 Git 后继续。"
            exit(1)
        fi
    elif [ "$input" = "n" ] || [ "$input" = "no" ]; then
        if [ -d "/tmp/chfs_deploy/" ]; then
            if [ -d "/tmp/chfs_deploy/chfs/" ]; then
                if [ -d "/tmp/chfs_deploy/chfs/bin/" ]; then
                    if [ -d "/tmp/chfs_deploy/chfs/config/" ]; then
                        if [ -d "/tmp/chfs_deploy/chfs/log" ]; then
                            if [ -d "/tmp/chfs_deploy/chfs/resource/" ]; then
                                if [ -f "/tmp/chfs_deploy/install.sh" ]; then
                                    if [ -f "/tmp/chfs_deploy/chfs/start.sh" ]; then
                                        break
                                    else
                                        echo "仓库未部署，请重新配置"
                                    fi
                                else
                                    echo "仓库未部署，请重新配置"
                                fi
                            else
                                echo "仓库未部署，请重新配置"
                            fi
                        else
                            echo "仓库未部署，请重新配置"
                        fi
                    else
                        echo "仓库未部署，请重新配置"
                    fi
                else
                    echo "仓库未部署，请重新配置"
                fi
            else
                echo "仓库未部署，请重新配置"
            fi
        else
            echo "仓库未部署，请重新配置"
        fi
    else
        echo "输入错误，请重新输入"
    fi
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

sudo echo "$text" >"$output_file"

read -p "设置服务器启动端口（0-65535）: （44380）" input

# 判断输入是否匹配正则表达式
if [[ $input =~ ^[0-9]+$ && $input -ge 0 && $input -le 65535 ]]; then
    echo "# 端口设置" >>/opt/chfs/config/conf.ini
    echo "port=$input" >>/opt/chfs/config/conf.ini
    echo "已设置服务器端口为 $input"
elif [[ -z $input ]]; then
    echo "已设置服务器端口为 44380"
    echo "# 端口设置" >>/opt/chfs/config/conf.ini
    echo "port=44380" >>/opt/chfs/config/conf.ini
else
    echo "输入无效，不是一个 0-65535 的数字。"
    echo "已设置服务器端口为 44380"
    echo "# 端口设置" >>/opt/chfs/config/conf.ini
    echo "port=44380" >>/opt/chfs/config/conf.ini
fi

read -p "请设置匿名用户权限（R=读，W=写，D=删（输入对应字母及对应权限，如 RWD））: （无权）" input
input=$(echo "$input" | tr '[:lower:]' '[:upper:]')
if [[ $input =~ ^[RWD]{1,3}$ ]]; then
    echo "# 匿名用户设置" >>/opt/chfs/config/conf.ini
    echo "rule=::$input" >>/opt/chfs/config/conf.ini
    echo "已设置匿名用户权限为 $input"
elif [[ -z $input ]]; then
    echo "# 匿名用户设置" >>/opt/chfs/config/conf.ini
    echo "rule=::" >>/opt/chfs/config/conf.ini
    echo "已设置匿名用户无权限"
else
    echo "输入无效，不是一个合法权限。"
    echo "# 匿名用户设置" >>/opt/chfs/config/conf.ini
    echo "rule=::" >>/opt/chfs/config/conf.ini
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
    password="passwd）："
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

echo "# 用户设置" >>/opt/chfs/config/conf.ini
echo "rule=$username:$password:$power" >>/opt/chfs/config/conf.ini

echo "# 服务器标题设置" >>/opt/chfs/config/conf.ini
echo "html.title="$username 的文件服务器"" >>/opt/chfs/config/conf.ini

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
