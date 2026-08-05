FROM python:3.8

# 1. 直接安装
RUN pip install devpi-server devpi-client devpi-web

# 2. 创建配置目录
RUN mkdir -p /root/.devpi/server/

# 3. 创建配置文件
RUN printf "[server]\n\
mirror_cache_expiry = 0\n\
\n\
[mirror:index]\n\
mirror_url = https://mirrors.aliyun.com/pypi/simple/\n\
timeout = 30\n" > /root/.devpi/server/server.ini

# 4. 初始化
RUN devpi-init --serverdir /root/.devpi/server/

EXPOSE 3141

# 当宿主机有代理时,确保 localhost/127.0.0.1 不走代理
ENV no_proxy=localhost,127.0.0.1
ENV NO_PROXY=localhost,127.0.0.1

ENTRYPOINT ["devpi-server", "--host", "0.0.0.0", "--port", "3141", "--serverdir", "/root/.devpi/server"]
