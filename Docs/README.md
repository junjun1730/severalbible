# Docs/ — One Message Project Documentation & GitHub Pages

**Last Updated**: 2026-03-15

This folder serves two purposes:
1. **GitHub Pages hosting** — `index.html`, `privacy_policy.html`, `terms_of_service.html` are served at `https://junjun1730.github.io/severalbible/`
2. **Project documentation** — organized subdirectories for architecture decisions, archived docs, and developer guides

> **macOS Note**: This directory is `Docs/` (GitHub Pages source). On case-insensitive filesystems, `docs/` and `Docs/` resolve to the same folder.

---

## Directory Structure

```
docs/
├── archive/          Deprecated docs kept for historical reference
├── architecture/     Architecture decisions and ADRs
├── changelog/        CHANGELOG.md and release notes
├── features/         Per-feature documentation
├── guides/           Developer guides and operational runbooks
└── README.md         This index file
```

---

## archive/

Documents for cancelled or superseded features. Do not use for active development.

| File | Reason Archived |
|------|----------------|
| `FEATURE_FLAG_GUIDE.md` | Phase 6 cancelled 2026-03-15 (ad-based pivot) |
| `phase6-feature-flag-system.md` | Phase 6 TDD checklist — cancelled |
| `phase6-quick-reference.md` | Phase 6 quick reference — cancelled |

---

## guides/

Operational guides for launch and deployment.

| File | Description |
|------|-------------|
| `LAUNCH_STATUS.md` | App Store launch status and pre-submission checklist |

---

## Notes

- `CLAUDE.md`, `PLANNER.md`, and `README.md` remain in the project root.
- Active phase checklists remain in `checklist/`.
- The `Docs/` folder (capital D) is the GitHub Pages hosting folder — do not confuse with this `docs/` folder.
- Subscription/IAP model was removed 2026-03-15. All references to it in archived docs are historical.
