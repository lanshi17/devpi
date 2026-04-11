# Podman Rootless Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace Docker-based startup and documentation with Podman-only rootless workflows using a user-level systemd service.

**Architecture:** Keep the project minimal by reusing the existing Dockerfile as the Podman build input, swapping Docker CLI usage to Podman in the startup script and service unit, and rewriting docs around a single rootless Podman path. Use the project-local data directory `/home/yangzs/devpi/data` everywhere so the script, service, and docs describe the same deployment shape.

**Tech Stack:** Dockerfile image build, Podman rootless containers, systemd user services, bash shell script, Markdown docs

---

### Task 1: Capture failing migration checks

**Files:**
- Modify: `start-devpi.sh`
- Modify: `devpi-container.service`
- Modify: `README.md`
- Modify: `README_zh.md`
- Modify: `setup_instructions.md`
- Test: repo-wide text checks from `/home/yangzs/devpi`

**Step 1: Write the failing test**

Create a checklist of migration expectations before editing:
- `start-devpi.sh` must not contain `docker`
- `devpi-container.service` must not mention `docker.service`
- docs must describe `podman` instead of `docker`
- docs must mention rootless Podman and `systemctl --user`
- all runtime paths must use `/home/yangzs/devpi/data`

**Step 2: Run test to verify it fails**

Run: `python - <<'PY'
from pathlib import Path
root = Path('/home/yangzs/devpi')
checks = {
    'start-devpi.sh_has_docker': 'docker' in (root/'start-devpi.sh').read_text(),
    'service_has_docker_service': 'docker.service' in (root/'devpi-container.service').read_text(),
    'readme_has_docker': 'docker ' in (root/'README.md').read_text().lower(),
    'readme_zh_has_docker': 'docker' in (root/'README_zh.md').read_text().lower(),
    'setup_has_docker': 'docker' in (root/'setup_instructions.md').read_text().lower(),
}
for name, value in checks.items():
    print(f'{name}={value}')
PY`
Expected: multiple `=True` lines proving the old Docker-based behavior still exists.

**Step 3: Write minimal implementation**

Do not change code yet. Use the failing output as the red baseline for the migration.

**Step 4: Run test to verify it passes**

Not applicable yet. This task is complete when the failing baseline is captured.

**Step 5: Commit**

Do not commit yet. Commit after a real file change task turns green.

### Task 2: Switch the startup script to Podman

**Files:**
- Modify: `start-devpi.sh`
- Test: `start-devpi.sh`

**Step 1: Write the failing test**

Define the exact expected behavior for `start-devpi.sh`:
- uses `podman stop`, `podman rm`, `podman run`, `podman ps`
- uses `DATA_DIR="/home/yangzs/devpi/data"`
- does not use `docker`
- keeps `CONTAINER_NAME="devpi-container"`, `IMAGE_NAME="devpi-image"`, `PORT="3141"`

**Step 2: Run test to verify it fails**

Run: `python - <<'PY'
from pathlib import Path
text = Path('/home/yangzs/devpi/start-devpi.sh').read_text()
assert 'podman run' in text, 'missing podman run'
assert 'DATA_DIR="/home/yangzs/devpi/data"' in text, 'wrong data dir'
assert 'docker' not in text, 'docker still present'
PY`
Expected: FAIL with at least `missing podman run` or `docker still present`.

**Step 3: Write minimal implementation**

Update `start-devpi.sh` to:
- replace every Docker CLI invocation with Podman
- set `DATA_DIR` to `/home/yangzs/devpi/data`
- keep the current stop/remove/recreate/status flow
- keep the script simple; do not add new flags or abstractions

**Step 4: Run test to verify it passes**

Run: `python - <<'PY'
from pathlib import Path
text = Path('/home/yangzs/devpi/start-devpi.sh').read_text()
assert 'podman stop' in text
assert 'podman rm' in text
assert 'podman run -d' in text
assert 'podman ps' in text
assert 'DATA_DIR="/home/yangzs/devpi/data"' in text
assert 'docker' not in text
PY`
Expected: PASS with no output.

**Step 5: Commit**

```bash
git add start-devpi.sh
git commit -m "refactor: run devpi with podman"
```

### Task 3: Convert the service unit to a user-level Podman service

**Files:**
- Modify: `devpi-container.service`
- Test: `devpi-container.service`

**Step 1: Write the failing test**

Define the expected service characteristics:
- no `After=... docker.service`
- no `Requires=docker.service`
- uses `ExecStartPre` and `ExecStart` with `podman`
- uses `/home/yangzs/devpi/data`
- keeps `Restart=always`
- suitable for `systemctl --user`

**Step 2: Run test to verify it fails**

Run: `python - <<'PY'
from pathlib import Path
text = Path('/home/yangzs/devpi/devpi-container.service').read_text()
assert 'docker.service' not in text, 'docker.service still present'
assert '/usr/bin/podman run' in text, 'podman run missing'
assert '/home/yangzs/devpi/data' in text, 'data dir not unified'
PY`
Expected: FAIL because Docker dependencies and commands are still present.

**Step 3: Write minimal implementation**

Update `devpi-container.service` to:
- remove Docker-specific dependencies
- keep a small `[Unit]` section appropriate for a user service
- use Podman commands in `ExecStartPre`, `ExecStart`, and `ExecStop`
- map port `3141:3141`
- mount `/home/yangzs/devpi/data:/root/.devpi/server:z`
- avoid `--restart=always` in `ExecStart`

**Step 4: Run test to verify it passes**

Run: `python - <<'PY'
from pathlib import Path
text = Path('/home/yangzs/devpi/devpi-container.service').read_text()
assert 'docker.service' not in text
assert '/usr/bin/podman stop devpi-container' in text
assert '/usr/bin/podman rm devpi-container' in text
assert '/usr/bin/podman run --name devpi-container' in text
assert '/home/yangzs/devpi/data:/root/.devpi/server:z' in text
assert '--restart=always' not in text
assert 'Restart=always' in text
PY`
Expected: PASS with no output.

**Step 5: Commit**

```bash
git add devpi-container.service
git commit -m "refactor: use podman user service for devpi"
```

### Task 4: Rewrite the English README for Podman-only usage

**Files:**
- Modify: `README.md`
- Test: `README.md`

**Step 1: Write the failing test**

Define the README expectations:
- all build/run/manage examples use `podman`
- no Docker badges or Docker wording in the quick start
- no host-network mode section
- includes a user-service section with `systemctl --user`
- includes `loginctl enable-linger <user>`

**Step 2: Run test to verify it fails**

Run: `python - <<'PY'
from pathlib import Path
text = Path('/home/yangzs/devpi/README.md').read_text().lower()
assert 'podman build' in text, 'podman build missing'
assert 'systemctl --user' in text, 'user service docs missing'
assert 'loginctl enable-linger' in text, 'linger docs missing'
assert 'docker build' not in text, 'docker build still present'
assert '--network host' not in text, 'host network docs still present'
PY`
Expected: FAIL on missing Podman/user-service guidance and existing Docker references.

**Step 3: Write minimal implementation**

Rewrite `README.md` so it:
- describes the project as Podman-based
- updates commands from Docker to Podman
- removes the host-network branch entirely
- adds a `systemd user service` section with install and management commands
- updates system requirements from Docker to Podman

**Step 4: Run test to verify it passes**

Run: `python - <<'PY'
from pathlib import Path
text = Path('/home/yangzs/devpi/README.md').read_text().lower()
for needle in ['podman build', 'podman run', 'podman exec', 'podman logs', 'systemctl --user', 'loginctl enable-linger']:
    assert needle in text, f'missing {needle}'
for forbidden in ['docker build', 'docker run', 'docker exec', 'docker logs', '--network host']:
    assert forbidden not in text, f'found {forbidden}'
assert '/home/yangzs/devpi/data' in Path('/home/yangzs/devpi/README.md').read_text()
PY`
Expected: PASS with no output.

**Step 5: Commit**

```bash
git add README.md
git commit -m "docs: migrate README to podman"
```

### Task 5: Rewrite the Chinese README for Podman-only usage

**Files:**
- Modify: `README_zh.md`
- Test: `README_zh.md`

**Step 1: Write the failing test**

Define the Chinese README expectations:
- commands use `podman`
- the text describes rootless Podman
- includes `systemctl --user`
- removes Docker and host-network guidance

**Step 2: Run test to verify it fails**

Run: `python - <<'PY'
from pathlib import Path
text = Path('/home/yangzs/devpi/README_zh.md').read_text().lower()
assert 'podman build' in text, 'podman build missing'
assert 'systemctl --user' in text, 'systemctl --user missing'
assert 'rootless' in text, 'rootless explanation missing'
assert 'docker' not in text, 'docker still present'
assert '--network host' not in text, 'host network docs still present'
PY`
Expected: FAIL because the document is still Docker-based.

**Step 3: Write minimal implementation**

Rewrite `README_zh.md` to mirror the English README changes in Chinese:
- Podman-only commands
- rootless/user-service guidance
- no Docker badge-led positioning
- no host-network discussion
- data directory examples use `/home/yangzs/devpi/data`

**Step 4: Run test to verify it passes**

Run: `python - <<'PY'
from pathlib import Path
text = Path('/home/yangzs/devpi/README_zh.md').read_text().lower()
for needle in ['podman build', 'podman run', 'podman logs', 'systemctl --user', 'loginctl enable-linger', 'rootless']:
    assert needle in text, f'missing {needle}'
for forbidden in ['docker', '--network host']:
    assert forbidden not in text, f'found {forbidden}'
assert '/home/yangzs/devpi/data' in Path('/home/yangzs/devpi/README_zh.md').read_text()
PY`
Expected: PASS with no output.

**Step 5: Commit**

```bash
git add README_zh.md
git commit -m "docs: migrate Chinese README to podman"
```

### Task 6: Rewrite setup instructions for Podman user services

**Files:**
- Modify: `setup_instructions.md`
- Test: `setup_instructions.md`

**Step 1: Write the failing test**

Define the setup guide expectations:
- build steps use `podman build`
- service installation uses `~/.config/systemd/user/`
- service management uses `systemctl --user`
- manual startup uses `podman run`
- troubleshooting uses `podman logs`
- no `sudo systemctl` or Docker commands remain

**Step 2: Run test to verify it fails**

Run: `python - <<'PY'
from pathlib import Path
text = Path('/home/yangzs/devpi/setup_instructions.md').read_text().lower()
assert 'podman build' in text, 'podman build missing'
assert '~/.config/systemd/user/' in text, 'user service path missing'
assert 'systemctl --user' in text, 'user systemctl missing'
assert 'sudo systemctl' not in text, 'sudo systemctl still present'
assert 'docker' not in text, 'docker still present'
PY`
Expected: FAIL because the setup guide still documents Docker and system-level service installation.

**Step 3: Write minimal implementation**

Rewrite `setup_instructions.md` so it:
- starts with Podman build/setup steps
- installs the service into `~/.config/systemd/user/`
- uses `systemctl --user` commands throughout
- documents `loginctl enable-linger <user>`
- uses `podman run` as the manual fallback path
- updates troubleshooting commands to Podman

**Step 4: Run test to verify it passes**

Run: `python - <<'PY'
from pathlib import Path
text = Path('/home/yangzs/devpi/setup_instructions.md').read_text().lower()
for needle in ['podman build', '~/.config/systemd/user/', 'systemctl --user', 'loginctl enable-linger', 'podman run', 'podman logs']:
    assert needle in text, f'missing {needle}'
for forbidden in ['docker', 'sudo systemctl']:
    assert forbidden not in text, f'found {forbidden}'
assert '/home/yangzs/devpi/data' in Path('/home/yangzs/devpi/setup_instructions.md').read_text()
PY`
Expected: PASS with no output.

**Step 5: Commit**

```bash
git add setup_instructions.md
git commit -m "docs: update podman setup instructions"
```

### Task 7: Run final repo-wide verification

**Files:**
- Modify: none
- Test: `start-devpi.sh`, `devpi-container.service`, `README.md`, `README_zh.md`, `setup_instructions.md`

**Step 1: Write the failing test**

Define the final acceptance checks:
- no remaining `docker` references in the migrated files
- no remaining `--network host` references in docs
- all five files mention Podman where appropriate
- all docs include the intended user-service flow

**Step 2: Run test to verify it fails**

Run before the final edits are complete: `python - <<'PY'
from pathlib import Path
files = [
    Path('/home/yangzs/devpi/start-devpi.sh'),
    Path('/home/yangzs/devpi/devpi-container.service'),
    Path('/home/yangzs/devpi/README.md'),
    Path('/home/yangzs/devpi/README_zh.md'),
    Path('/home/yangzs/devpi/setup_instructions.md'),
]
text = '\n'.join(p.read_text() for p in files)
assert 'docker' not in text.lower(), 'docker references remain'
assert '--network host' not in text.lower(), 'host network references remain'
assert text.lower().count('podman') >= 8, 'too few podman references'
assert 'systemctl --user' in text, 'missing user service docs'
PY`
Expected: FAIL until all migrations are done.

**Step 3: Write minimal implementation**

If any check still fails, make the smallest possible edit in the affected file and rerun the final verification.

**Step 4: Run test to verify it passes**

Run: `python - <<'PY'
from pathlib import Path
files = [
    Path('/home/yangzs/devpi/start-devpi.sh'),
    Path('/home/yangzs/devpi/devpi-container.service'),
    Path('/home/yangzs/devpi/README.md'),
    Path('/home/yangzs/devpi/README_zh.md'),
    Path('/home/yangzs/devpi/setup_instructions.md'),
]
text = '\n'.join(p.read_text() for p in files)
assert 'docker' not in text.lower()
assert '--network host' not in text.lower()
assert text.lower().count('podman') >= 8
assert 'systemctl --user' in text
assert '/home/yangzs/devpi/data' in text
PY`
Expected: PASS with no output.

**Step 5: Commit**

```bash
git add start-devpi.sh devpi-container.service README.md README_zh.md setup_instructions.md
git commit -m "refactor: migrate devpi startup to podman"
```
