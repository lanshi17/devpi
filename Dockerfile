FROM python:3.8

# Pin the toolchain so rebuilds stay reproducible.
ARG DEVPI_SERVER_VERSION=6.15.0
ARG DEVPI_CLIENT_VERSION=7.2.1
ARG DEVPI_WEB_VERSION=4.3.0

RUN pip install --no-cache-dir \
    "devpi-server==${DEVPI_SERVER_VERSION}" \
    "devpi-client==${DEVPI_CLIENT_VERSION}" \
    "devpi-web==${DEVPI_WEB_VERSION}"

RUN mkdir -p /root/.devpi/server/ \
    && devpi-init --serverdir /root/.devpi/server/

EXPOSE 3141

# Ensure localhost traffic bypasses the host proxy.
ENV no_proxy=localhost,127.0.0.1
ENV NO_PROXY=localhost,127.0.0.1

# Serving threads: devpi-server defaults to 50, which is wasteful for a
# private mirror (each thread holds stack + request state). 8 threads is
# plenty for pip installs; the connection limit bounds queued clients.
#
# Upstream mirror is NOT configured here: in devpi-server 6.x it is per-index
# config stored in the server DB, e.g.
#   devpi index root/pypi mirror_url=https://pypi.tuna.tsinghua.edu.cn/simple/
# (server.ini does not exist in 6.x; the config file is devpi-server.yml).
ENTRYPOINT ["devpi-server", \
    "--host=0.0.0.0", \
    "--port=3141", \
    "--serverdir=/root/.devpi/server", \
    "--threads=8", \
    "--connection-limit=20"]
