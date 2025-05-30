#!/bin/bash
# 设置 PATH，确保 cron 运行时可以找到所需命令
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 指定 SSH 私钥，确保在非交互环境下能使用
export GIT_SSH_COMMAND='ssh -i /home/zjm/.ssh/id_ed25519 -o IdentitiesOnly=yes'

# 切换到 Git 仓库目录
cd /home/zjm/gym_data_repo || exit

# 执行 Python 脚本更新 CSV 数据
python3 scrape.py

# 配置 Git 用户信息（如果没有全局配置）
git config user.name "Auto-data-update Robot"
git config user.email "zhan2374@msu.edu"

# 拉取远程仓库的更新，确保本地和远程保持同步
git pull --rebase --autostash origin main

# 检查 docs/data/today_data.csv 是否有改动（避免提交空 commit）
if ! git diff --quiet data/today_data.csv; then
    git add /home/zjm/gym_data_repo/data/today_data.csv /home/zjm/gym_data_repo/data/circle.csv /home/zjm/gym_data_repo/data/east.csv /home/zjm/gym_data_repo/data/west.csv 
    if ! git diff --quiet data/total_detailed_data.csv; then
        git add /home/zjm/gym_data_repo/data/total_detailed_data.csv
    else
        echo "No changes in total_detailed_data.csv, skipping commit."
    fi
    git commit -m "Update today_data.csv on $(date +'%Y-%m-%d %H:%M:%S')"
    # 推送到远程仓库
    git push origin main
else
    echo "No changes in today_data.csv, skipping commit."
fi

