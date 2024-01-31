#!/bin/bash
# 检查CPU使用率的命令，若CPU使用率连续3分钟大于95%，则重启php-fpm-74.service，避免WordPress网站占用系统资源
# 初始化计数器
count=0

while true; do
    # 获取 CPU 使用率。'top -bn1' 运行 top 命令一次，不进入交互模式。
    # 'grep "Cpu(s)"' 从输出中获取 CPU 行。
    # 'awk '{print $2}' 获取使用率值（假设它位于第二列，这可能因系统而异）。
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d '.' -f1)

    # 检查 CPU 使用率是否大于 95%
    if [ "$cpu_usage" -gt 95 ]; then
        # 增加计数器
        count=$((count+1))
    else
        # 如果 CPU 使用率低于 95%，重置计数器
        count=0
    fi

    # 检查是否已连续 3 次（即 3 分钟，因为睡眠间隔为 1 分钟）CPU 使用率超过 95%
    if [ "$count" -ge 3 ]; then
        # 重启 php-fpm-74.service
        sudo systemctl restart php-fpm-74.service

        # 重置计数器
        count=0
    fi

    # 等待 1 分钟
    sleep 60
done

# 设置后台运行
# nohup ./php_cpu_monitor.sh &
