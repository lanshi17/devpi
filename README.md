# DevPI Private PyPI Mirror

A minimal private PyPI mirror built with `devpi-server`, packaged with the included image build file, and deployed with Docker.

## Features

- Minimal image build from the included image build file
- Docker runtime with a fixed data directory at `/home/yangzs/devpi/data`
- User-level systemd service managed with `systemctl --user`
- Upstream mirror configured per index in the devpi DB (currently `https://pypi.org/simple/`)
- Tuned runtime: 8 serving threads, bounded connection limit, rotated container logs
- Local package caching for repeat installs

## Project Structure

```text
devpi/
├── image-build-file
├── devpi-container.service
├── start-devpi.sh
├── setup_instructions.md
├── README.md
└── README_zh.md
```

## Requirements

- Docker 24+
- systemd user services
- `loginctl` available for linger configuration
- At least 1 GB free disk space for cached packages

## Quick Start

### 1. Build the image

```bash
docker build -t devpi-image .
```

### 2. Prepare the data directory

```bash
mkdir -p /home/yangzs/devpi/data
```

### 3. Run the container manually

```bash
docker run -d \
  --name devpi-container \
  -p 3141:3141 \
  -v /home/yangzs/devpi/data:/root/.devpi/server \
  devpi-image
```

### 4. Verify the service

```bash
curl http://localhost:3141
```

## Docker systemd user service

Enable linger so the user service can survive logout:

```bash
loginctl enable-linger <user>
```

Install and start the service:

```bash
mkdir -p ~/.config/systemd/user/
cp devpi-container.service ~/.config/systemd/user/devpi-container.service
systemctl --user daemon-reload
systemctl --user enable --now devpi-container.service
```

Common management commands:

```bash
systemctl --user status devpi-container.service
systemctl --user restart devpi-container.service
systemctl --user stop devpi-container.service
journalctl --user -u devpi-container.service -n 50
```

## Usage

Install packages temporarily:

```bash
pip install -i http://localhost:3141/root/pypi/ <package_name> --trusted-host localhost
```

Configure pip permanently:

```bash
pip config set global.index-url http://localhost:3141/root/pypi/
pip config set global.trusted-host localhost
```

Revert to default PyPI:

```bash
pip config unset global.index-url
pip config unset global.trusted-host
```

## Management Commands

Enter the running container:

```bash
docker exec -it devpi-container bash
```

View logs:

```bash
docker logs devpi-container
```

Stop and remove the container:

```bash
docker stop devpi-container
docker rm devpi-container
```

## Configuration Details

- Mirror URL: `https://pypi.org/simple/` (stored per index; change with `devpi index root/pypi mirror_url=...`)
- Serving: `--threads=8 --connection-limit=20` (baked into the image ENTRYPOINT)
- Default user: `root`
- Default index: `root/pypi`
- Data directory: `/home/yangzs/devpi/data`
- Service management: `systemctl --user`

## Troubleshooting

If the user service does not start:

```bash
systemctl --user status devpi-container.service
journalctl --user -u devpi-container.service -n 100
```

If the container exits unexpectedly:

```bash
docker logs devpi-container
docker ps -a --filter name=devpi-container
```

If package installs fail, verify the mirror endpoint and local server:

```bash
curl -I https://pypi.org/simple/
curl http://localhost:3141
```

### devpi not working with a proxy enabled

When a network proxy is active, localhost traffic may be routed through the proxy, causing pip to fail when connecting to local devpi.
Fix: ensure `no_proxy` includes localhost:

```bash
# Temporary
export no_proxy=localhost,127.0.0.1
export NO_PROXY=localhost,127.0.0.1

# Permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export no_proxy=localhost,127.0.0.1' >> ~/.bashrc
```

The container's devpi-server also needs localhost excluded from proxy (already set in Dockerfile).
To pass custom proxy settings when starting the container:

```bash
docker run -d \
  --name devpi-container \
  -p 3141:3141 \
  -v /home/yangzs/devpi/data:/root/.devpi/server \
  -e no_proxy=localhost,127.0.0.1 \
  -e HTTP_PROXY=http://your-proxy:port \
  -e HTTPS_PROXY=http://your-proxy:port \
  devpi-image
```

## References

- [DevPI Documentation](https://devpi.net/)
- [PyPI Simple Index](https://pypi.org/simple/)
