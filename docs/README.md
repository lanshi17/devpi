# Documentation Index

## Directory Structure

```
docs/
├── README.md          # Index & classification rules
├── archive/           # Completed work
│   ├── plans/
│   └── codereview/
├── active/            # Currently in progress
├── planned/           # Not started yet
├── codereview/        # Active code reviews
└── templates/         # Document templates (plan.md, codereview.md)
```

## Classification Rules

| Status | Destination |
|---|---|
| completed | `archive/plans/` or `archive/codereview/` |
| in-progress | `active/` |
| planned | `planned/` |
| active review | `codereview/` |

Every plan document carries a `**Status:**` field (planned | in-progress | completed)
plus `Created` / `Completed` / `PR` fields. Git history (merge commits, implementation
commits) takes precedence over the header when they disagree.

## Naming Convention

`YYYY-MM-DD-<kebab-case-description>.md`

## Archive Index

### Completed Plans

| date | title | status/PR |
|---|---|---|
| 2026-04-10 | [Podman rootless migration design](archive/plans/2026-04-10-podman-rootless-design.md) | merged |
| 2026-04-10 | [Podman rootless migration implementation](archive/plans/2026-04-10-podman-rootless-migration.md) | merged |
