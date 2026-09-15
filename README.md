# infennon_labs_home

## Deployment Policy

This project is a source repository only. It is not an independent public deployment target.

- Local Flutter development, analysis, tests, and local previews are allowed.
- Direct public deployment is forbidden from this repository. Do not run repo-local `wrangler deploy`, GitHub Pages publishing, or other public-host deployment commands here.
- Public deployment for this app must be triggered from the central workspace root using the target `home`.
- The workspace-root deployment script is the only approved public deployment path.

Approved commands from the workspace root:

```bash
cd /Users/adaminferrera/Documents/.workspace-copilot
./scripts/review_and_deploy_learning.sh --channel dev --targets home --release-note "home dev deploy"
```

```bash
cd /Users/adaminferrera/Documents/.workspace-copilot
./scripts/review_and_deploy_learning.sh --channel stable --targets home --confirm-stable DEPLOY_STABLE --release-note "home stable deploy"
```

The homepage is published through the centralized workspace target `home`; this repo does not have its own public deployment flow.

## Getting Started

This project is a Flutter app for local development and validation. Use the standard Flutter workflow in this repository, but keep all public releases centralized through the workspace root target `home`.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
