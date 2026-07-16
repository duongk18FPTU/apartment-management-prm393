# AGENTS.md — AI Coding Agent Rules

This file defines rules and conventions for AI coding agents working on this project.

---

## Project Context

- **Project**: Apartment Building Management System
- **Framework**: Flutter (Dart)
- **Target**: Android & iOS mobile app
- **Architecture**: TBD (will be defined as project evolves)

---

## General Rules

1. **Language**: All code, comments, and variable names MUST be in **English**.
2. **Preserve existing code**: Do NOT remove or modify existing comments, docstrings, or code that is unrelated to the current task.
3. **Follow Dart conventions**: Use `snake_case` for files, `PascalCase` for classes, `camelCase` for variables.
4. **Use `const` constructors** wherever possible for better performance.
5. **Prefer named parameters** for widget constructors.

---

## File Organization

```
lib/
├── main.dart              # Entry point — do NOT add business logic here
├── app/                   # App config (theme, routes, app widget)
├── models/                # Data models / entities
├── screens/               # Full-page screens, organized by feature
│   └── <feature>/
│       ├── <feature>_screen.dart
│       └── widgets/       # Screen-specific widgets
├── widgets/               # Shared reusable widgets
├── services/              # API calls, external services
├── providers/             # State management
└── utils/                 # Constants, helpers, extensions
```

---

## Coding Standards

- Run `flutter analyze` before suggesting any code — ensure zero warnings.
- Run `dart format .` to format all code.
- Keep widgets under 100 lines — extract sub-widgets into separate files.
- Use `ThemeData` and `ColorScheme` for styling — do NOT hardcode colors.
- Handle loading, error, and empty states for all async operations.

---

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## Dependencies

- Do NOT add new dependencies without team discussion.
- Prefer well-maintained packages with high pub.dev scores.
- Always specify version constraints in `pubspec.yaml`.

---

## Testing

- Write widget tests for critical UI components.
- Write unit tests for business logic in `services/` and `models/`.
- Test files go in `test/` with matching directory structure.

---

## What NOT To Do

- ❌ Do NOT use `print()` for debugging — use `debugPrint()` or a logger.
- ❌ Do NOT commit `.env`, API keys, or secrets.
- ❌ Do NOT push directly to `main` or `develop` branches.
- ❌ Do NOT ignore analyzer warnings.
- ❌ Do NOT hardcode strings — use constants or localization.
