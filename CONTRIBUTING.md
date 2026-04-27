# Contributing to NutriScan

Thanks for contributing.

## Ground Rules

- Keep PRs focused and small.
- Discuss large changes with an issue first.
- Do not commit secrets, API keys, Firebase configs, or signing files.
- Follow existing architecture and naming patterns.

## Development Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Add your own Firebase config:
- Android: `android/app/google-services.json`
- iOS (if you run iOS): `ios/Runner/GoogleService-Info.plist`

3. Create a local define file (example):

```env
GEMINI_API_KEY=your_gemini_api_key
GEMINI_MODEL=gemini-2.5-flash
```

4. Run app:

```bash
flutter run --dart-define-from-file=.env.local
```

## Code Quality Checklist

Before opening a PR, run:

```bash
flutter analyze
flutter test
```

If you changed build or platform behavior, also test your target platform locally.

## Branch and Commit Guidance

- Branch naming: `feature/<short-name>`, `fix/<short-name>`, `docs/<short-name>`
- Commit style (recommended): `feat: ...`, `fix: ...`, `docs: ...`, `refactor: ...`, `test: ...`

## Pull Request Checklist

- [ ] No secrets or private files included
- [ ] Docs updated if behavior changed
- [ ] Analyzer and tests pass
- [ ] PR description explains what changed and why

## Reporting Bugs

Please include:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Platform/device details
- Logs/error output (redact secrets)

## Security Issues

Do not open public issues for vulnerabilities or exposed keys.
Use the process in `SECURITY.md`.
