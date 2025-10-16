#!/bin/bash

# 欢迎语
echo "欢迎使用 fn-docker 脚本！"
echo "本脚本用于补全FNOS Docker的延时启动功能"
echo "请根据脚本指引进行配置"
# 主菜单
function main_menu {
    echo "请选择操作："
    echo "1. 创建新服务"
    echo "2. 删除 start_docker 服务"
    echo "3. 退出"
    read -p "请输入选项（1/2/3）: " choice

    case $choice in
        1) create_service ;;
        2) delete_service ;;
        3) exit 0 ;;
        *) echo "无效的选项，请重新选择。" ; main_menu ;;
    esac
}

# 创建新服务
function create_service {
    echo "创建新服务"
    read -p "请输入即将生成的脚本文件存放位置（默认/vol1/1000/config）: " script_path
    script_path=${script_path:-/vol1/1000/config}

    # 创建目录（如果不存在）
    mkdir -p "$script_path"

    # 列出所有容器名称并编号
    containers=($(docker ps -a --format "{{.Names}}"))
    if [ ${#containers[@]} -eq 0 ]; then
        echo "没有找到正在运行的容器。"
        main_menu
    fi

    echo "请选择你要延时启动的容器："
    for i in "${!containers[@]}"; do
        echo "$((i+1)). ${containers[i]}"
    done

    read -p "请输入容器编号（多个编号用空格分隔）: " container_indices
    IFS=' ' read -r -a indices <<< "$container_indices"

    # 获取用户选择的容器名称
    selected_containers=()
    for i in "${indices[@]}"; do
        if [ $i -ge 1 ] && [ $i -le ${#containers[@]} ]; then
            selected_containers+=("${containers[$((i-1))]}")
        else
            echo "无效的编号：$i"
        fi
    done

    if [ ${#selected_containers[@]} -eq 0 ]; then
        echo "没有选择有效的容器。"
        main_menu
    fi

    # 设置总的延时时间和容器间间隔
    read -p "请输入系统启动后多久开始启动第一个容器（秒）: " initial_delay_time
    read -p "请输入容器之间的启动间隔时间（秒）: " interval_time

    # 生成 start_docker.sh 脚本
    script_file="$script_path/start_docker.sh"
    echo "#!/bin/bash" > "$script_file"
    echo "sleep $initial_delay_time" >> "$script_file"
    for container in "${selected_containers[@]}"; do
        echo "docker start $container" >> "$script_file"
        echo "sleep $interval_time" >> "$script_file"
    done

    chmod +x "$script_file"
    echo "脚本已生成：$script_file"

    # 询问是否生成服务
    read -p "是否生成 start_docker.service 服务文件？(y/n): " generate_service
    if [ "$generate_service" = "y" ] || [ "$generate_service" = "Y" ]; then
        # 生成 start_docker.service
        service_file="/etc/systemd/system/start_docker.service"
        echo "[Unit]" > "$service_file"
        echo "Description=Start Docker containers after system startup" >> "$service_file"
        echo "After=docker.service" >> "$service_file"
        echo "Wants=docker.service" >> "$service_file"
        echo "" >> "$service_file"
        echo "[Service]" >> "$service_file"
        echo "Type=oneshot" >> "$service_file"
        echo "ExecStart=$script_file" >> "$service_file"
        echo "RemainAfterExit=true" >> "$service_file"
        echo "" >> "$service_file"
        echo "[Install]" >> "$service_file"
        echo "WantedBy=multi-user.target" >> "$service_file"

        systemctl daemon-reload
        systemctl enable start_docker.service
        echo "服务已生成并启用：$service_file"
    else
        echo "不生成服务文件。"
    fi

    main_menu
}

# 删除 start_docker 服务
function delete_service {
    echo "删除 start_docker 服务"
    if systemctl list-unit-files | grep -q "start_docker.service"; then
        read -p "确定要删除 start_docker 服务吗？(y/n): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            systemctl stop start_docker.service
            systemctl disable start_docker.service
            rm /etc/systemd/system/start_docker.service
            systemctl daemon-reload
            echo "start_docker 服务已删除。"
        else
            echo "取消删除。"
        fi
    else
        echo "start_docker 服务不存在。"
    fi
    main_menu
}

# 主程序入口
main_menu
