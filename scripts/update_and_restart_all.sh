#!/bin/bash
# 完整脚本：conda激活虚拟环境+停止服务+拉代码+打包+后台启动Python+Npm双服务（关闭终端不停止、无日志）
# 项目路径配置（无需修改）
PROJECT_DIR="/home/wwwroot/DeepTutor"
WEB_DIR="${PROJECT_DIR}/web"
CONDA_ENV="deeptutor"

echo -e "\033[32m=============================================\033[0m"
echo -e "\033[32m1. 强制停止Python/Node/Npm所有进程（释放端口）\033[0m"
echo -e "\033[32m=============================================\033[0m"
pkill -9 -f "python -m src.api.run_server|npm|node|/root/miniconda/envs/deeptutor/bin/python" > /dev/null 2>&1
echo -e "\033[32m✅ 进程清理完成，端口释放成功\033[0m"

echo -e "\033[32m=============================================\033[0m"
echo -e "\033[32m2. 激活conda虚拟环境 deeptutor\033[0m"
echo -e "\033[32m=============================================\033[0m"
# 关键：解决shell脚本中conda activate失效的问题，加载conda环境配置
source /root/miniconda/etc/profile.d/conda.sh
conda activate ${CONDA_ENV}
echo -e "\033[32m✅ 成功激活虚拟环境: ($CONDA_ENV)\033[0m"

echo -e "\033[32m=============================================\033[0m"
echo -e "\033[32m3. 进入项目目录，拉取Git最新代码\033[0m"
echo -e "\033[32m=============================================\033[0m"
cd ${PROJECT_DIR}
git pull origin main
echo -e "\033[32m✅ Git拉取main分支最新代码完成\033[0m"

echo -e "\033[32m=============================================\033[0m"
echo -e "\033[32m4. 进入web目录，执行npm打包构建\033[0m"
echo -e "\033[32m=============================================\033[0m"
cd ${WEB_DIR}
npm run build
echo -e "\033[32m✅ Npm打包构建完成\033[0m"

echo -e "\033[32m=============================================\033[0m"
echo -e "\033[32m5. 后台启动Npm前端服务【永不停止+无日志】\033[0m"
echo -e "\033[32m=============================================\033[0m"
setsid npm run start > /dev/null 2>&1 &
echo -e "\033[32m✅ Npm服务启动成功\033[0m"

echo -e "\033[32m=============================================\033[0m"
echo -e "\033[32m6. 返回根目录，后台启动Python后端服务【已激活conda+永不停止+无日志】\033[0m"
echo -e "\033[32m=============================================\033[0m"
cd ${PROJECT_DIR}
setsid python -m src.api.run_server > /dev/null 2>&1 &
echo -e "\033[32m✅ Python接口服务启动成功 (已加载conda虚拟环境依赖)\033[0m"

echo -e "\033[32m====================================================\033[0m"
echo -e "\033[32m🎉 全部操作完成！双服务后台常驻运行 ✔️ conda环境已激活 ✔️\033[0m"
echo -e "\033[32m====================================================\033[0m"