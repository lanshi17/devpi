# DevPI Private PyPI Mirror

A minimal private PyPI mirror built with `devpi-server`, packaged with the included image build file, and deployed with rootless Podman.

## Features

- Minimal image build from the included image build file
- Rootless Podman runtime with a fixed data directory at `/home/yangzs/devpi/data`
- User-level systemd service managed with `systemctl --user`
- USTC upstream mirror for faster package downloads in China
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

- Podman 4+
- systemd user services
- `loginctl` available for linger configuration
- At least 1 GB free disk space for cached packages

## Quick Start

### 1. Build the image

```bash
podman build -t devpi-image .
```

### 2. Prepare the data directory

```bash
mkdir -p /home/yangzs/devpi/data
```

### 3. Run the container manually

```bash
podman run -d \
  --name devpi-container \
  -p 3141:3141 \
  -v /home/yangzs/devpi/data:/root/.devpi/server:z \
  devpi-image
```

### 4. Verify the service

```bash
curl http://localhost:3141
```

## Rootless Podman systemd user service

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
podman exec -it devpi-container bash
```

View logs:

```bash
podman logs devpi-container
```

Stop and remove the container:

```bash
podman stop devpi-container
podman rm devpi-container
```

## Configuration Details

- Mirror URL: `https://pypi.mirrors.ustc.edu.cn/simple/`
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
podman logs devpi-container
podman ps -a --filter name=devpi-container
```

If package installs fail, verify the mirror endpoint and local server:

```bash
curl -I https://pypi.mirrors.ustc.edu.cn/simple/
curl http://localhost:3141
```

## References

- [DevPI Documentation](https://devpi.net/)
- [USTC PyPI Mirror](https://mirrors.ustc.edu.cn/help/pypi.html)
