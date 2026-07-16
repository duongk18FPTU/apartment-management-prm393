# Contributing to Apartment Building Management System

Thank you for contributing! This guide helps our team maintain a consistent and efficient workflow.

---

## 📌 Table of Contents

- [Git Workflow](#git-workflow)
- [Branch Naming Convention](#branch-naming-convention)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)
- [Code Review Guidelines](#code-review-guidelines)
- [Coding Standards](#coding-standards)

---

## Git Workflow

We follow the **GitFlow** branching strategy:

```
main          ← Production-ready code (protected)
  └── develop ← Integration branch (protected)
        ├── feature/*   ← New features
        ├── bugfix/*    ← Bug fixes
        ├── hotfix/*    ← Urgent production fixes
        └── release/*   ← Release preparation
```

### Workflow Steps

1. **Pull latest** from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   ```

2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make changes**, commit frequently with clear messages.

4. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request** on GitHub:
   - Base: `develop`
   - Compare: `feature/your-feature-name`
   - Request at least 1 reviewer

6. **After approval**, the reviewer or author merges the PR.

7. **Delete the feature branch** after merging.

---

## Branch Naming Convention

| Type | Format | Example |
|------|--------|---------|
| Feature | `feature/<short-description>` | `feature/login-screen` |
| Bug fix | `bugfix/<short-description>` | `bugfix/fix-payment-crash` |
| Hotfix | `hotfix/<short-description>` | `hotfix/critical-auth-bug` |
| Release | `release/<version>` | `release/1.0.0` |

**Rules:**
- Use **lowercase** and **hyphens** (`-`) as separators
- Keep names **short but descriptive**
- Use English only

---

## Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only changes |
| `style` | Code style (formatting, missing semicolons, etc.) |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or fixing tests |
| `chore` | Build process, dependencies, CI/CD changes |

### Examples

```bash
feat(auth): add login screen with email/password
fix(payment): resolve crash when amount is zero
docs(readme): update getting started section
style(dashboard): fix indentation in dashboard widget
refactor(models): extract base model class
chore(deps): upgrade flutter_bloc to v9.0.0
```

---

## Pull Request Process

### Before Creating a PR

- [ ] Code builds without errors: `flutter build apk --debug`
- [ ] No analyzer warnings: `flutter analyze`
- [ ] Tests pass (if applicable): `flutter test`
- [ ] Self-reviewed your code changes
- [ ] Updated relevant documentation

### PR Template

When creating a PR, include:

```markdown
## What does this PR do?
Brief description of the changes.

## Type of change
- [ ] New feature
- [ ] Bug fix
- [ ] Refactoring
- [ ] Documentation

## Screenshots (if UI changes)
Add screenshots here.

## Checklist
- [ ] Code builds without errors
- [ ] No analyzer warnings
- [ ] Self-reviewed
```

### Merge Rules

- **`develop`** ← requires 1 approval
- **`main`** ← requires 1 approval + all checks pass

---

## Code Review Guidelines

### As a Reviewer

- Review within **24 hours** of being requested
- Be constructive and respectful
- Check for:
  - Code correctness and logic
  - Naming conventions
  - Potential bugs or edge cases
  - Code duplication
  - Performance concerns

### As an Author

- Keep PRs **small and focused** (< 400 lines ideally)
- Write clear PR descriptions
- Respond to feedback promptly
- Don't take reviews personally

---

## Coding Standards

### Dart / Flutter

- Follow [Effective Dart](https://dart.dev/effective-dart) guidelines
- Use `flutter analyze` to check for issues
- Format code with `dart format .`
- Use `const` constructors where possible
- Prefer named parameters for widgets
- Keep widgets small — extract into separate files when > 100 lines

### File Organization

```
lib/
├── main.dart
├── app/                   # App-level configuration
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── models/                # Data models
├── screens/               # Full-page screens
│   └── feature_name/
│       ├── feature_screen.dart
│       └── widgets/       # Screen-specific widgets
├── widgets/               # Shared/reusable widgets
├── services/              # API calls, business logic
├── providers/             # State management
└── utils/                 # Constants, helpers, extensions
```

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files | `snake_case` | `login_screen.dart` |
| Classes | `PascalCase` | `LoginScreen` |
| Variables | `camelCase` | `userName` |
| Constants | `camelCase` | `maxRetryCount` |
| Private members | `_camelCase` | `_isLoading` |
| Enums | `PascalCase` | `PaymentStatus.pending` |

---

<p align="center">
  Thank you for keeping our codebase clean and consistent! 🚀
</p>
