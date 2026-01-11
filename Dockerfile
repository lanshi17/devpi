FROM python:3.8

# Try with official PyPI first, then fallback to mirrors if needed
RUN pip install devpi-server devpi-client devpi-web

# Create configuration directory
RUN mkdir -p /root/.devpi/server/

# Create configuration file: specify upstream as USTC mirror (this will be used at runtime)
RUN cat > /root/.devpi/server/server.ini << 'EOF'
[server]
mirror_cache_expiry = 0

[mirror:index]
mirror_url = https://pypi.mirrors.ustc.edu.cn/simple/
timeout = 30
EOF

# Initialize devpi server
RUN devpi-init --serverdir /root/.devpi/server/

EXPOSE 3141

ENTRYPOINT ["devpi-server", "--host", "0.0.0.0", "--port", "3141", "--serverdir", "/root/.devpi/server"]