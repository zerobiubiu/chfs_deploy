#!/bin/sh

printf "安装程序将会对 /opt 目录作出修改并且会增加系统服务。请确保当前用户具有 sudo 权限，以防止出现意外情况或对系统造成不良影响。\n"
printf "拒绝请使用 Ctrl-C 。同意请按 Enter 键继续。。。"
# read

if which git >/dev/null; then
    echo "即将克隆 github.com/zerobiubiu/chfs_deploy.git 仓库，请确保网络通常，如网络不稳定请 Ctrl-C 结束本程序并手动将该仓库克隆至 /tmp/chfs_deploy/ 目录下，并确保目录格式为 /tmp/chfs_deploy/仓库内容 而非 /tmp/chfs_deploy/chfs_deploy/仓库内容 如不严格按照目录格式程序将无法执行。"

    while true; do
        read -p "输入（y/yes）将继续执行克隆，输入（n/no）将跳过克隆: (y)" input

        if [ "$input" = "y" ] || [ "$input" = "yes" ] || [ -z "$input" ]; then
            sudo chmod 777 /tmp
            git clone --depth 1 https://github.com/zerobiubiu/chfs_deploy.git /tmp/chfs_deploy/
            break
        elif [ "$input" = "n" ] || [ "$input" = "no" ]; then
            if [ -d "/tmp/chfs_deploy/" ]; then
                if [ -d "/tmp/chfs_deploy/chfs/" ]; then
                    if [ -d "/tmp/chfs_deploy/chfs/bin/" ]; then
                        if [ -d "/tmp/chfs_deploy/chfs/config/" ]; then
                            if [ -d "/tmp/chfs_deploy/chfs/log" ]; then
                                if [ -d "/tmp/chfs_deploy/chfs/resource/" ]; then

                                else

                                fi
                            else

                            fi
                        else

                        fi
                    else

                    fi

                else

                fi

            else

            fi
            break
        else
            echo "输入错误，请重新输入"
        fi
    done

else
    echo "请安装 Git 后继续。"
fi
