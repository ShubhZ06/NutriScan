# Security Policy

## Supported Security Model

This project is open source and uses contributor-owned cloud credentials for local development.
No production secrets should be stored in this repository.

## What Must Never Be Committed

- API keys (Gemini, third-party services)
- Firebase service config files with real project data
- Signing keys and keystores
- Any token, password, or private endpoint intended to stay private

## Safe Local Secret Handling

- Store runtime defines in local ignored files (for example `.env.local`).
- Use `flutter run --dart-define-from-file=.env.local`.
- Keep platform config files local (`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`).

## If You Accidentally Expose a Secret

1. Revoke/rotate the secret immediately.
2. Remove it from tracked files in a follow-up commit.
3. Notify maintainers privately with impact details.

## Reporting a Vulnerability

Please report privately by opening a private security advisory in GitHub (preferred),
or contact the maintainer directly and include:

- Affected area
- Reproduction steps
- Potential impact
- Suggested remediation (if known)

Please avoid public disclosure until a fix is available.
