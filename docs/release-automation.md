# Android build and release automation

GitHub Actions generates Android builds on GitHub-hosted Ubuntu runners. The
repository uses only standard Linux runners so the workflow remains within the
GitHub Free allowance. Do not configure a larger runner.

## Trigger and output map

| Event | Workflow | Output |
| --- | --- | --- |
| Pull request to `develop` or `main` | `Android CI` | Formatting, analysis, tests, and a debug preview APK verification build. No artifact is retained and no secret is available. |
| Push to `develop` after a merge | `Android preview` | A one-day installable debug preview APK workflow artifact. When signing is configured, a signed preview APK/AAB and checksums are also published in a GitHub Pre-Release. |
| Push of `vX.Y.Z` tag on `main` | `Android release` | A signed production APK/AAB, checksums, and a normal GitHub Release. |

The preview application ID is `dev.mari0g.macroadvisor.preview`; production is
`dev.mari0g.macroadvisor`. This lets both builds be installed together.

Stable tags must exactly match the `major.minor.patch` part of the `version` in
`pubspec.yaml` and point to a commit that is reachable from `main`. For example,
`version: 0.2.0+17` requires tag `v0.2.0`.

## Signing setup

Before publishing a signed preview or any stable release, add these **repository
Actions secrets** in GitHub:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Base64 encoding of the release keystore file, as one line. |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password. |
| `ANDROID_KEY_ALIAS` | Signing key alias. |
| `ANDROID_KEY_PASSWORD` | Signing key password. |

Create the keystore once and store its original file and passwords in a secure
password manager. Never commit it. A suitable command is:

```text
keytool -genkeypair -v -keystore macroadvisor-release.jks -alias macroadvisor -keyalg RSA -keysize 4096 -validity 10000
```

On PowerShell, produce the secret value without writing the keystore to the
repository:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes('C:\secure\macroadvisor-release.jks'))
```

`android/key.properties` is ignored by Git. The workflows recreate it only in
the ephemeral GitHub runner and never print secret values. A stable-release job
fails before publishing if any signing secret is absent; it will not publish a
debug-signed production package.

## Free-tier guardrails

This private repository has GitHub Free's 2,000 standard-runner minutes per
month, 500 MB shared Actions artifact storage, and 10 GB separate cache storage.
Keep the preview workflow artifact retention at one day, use GitHub Release
assets for retained packages, and leave Actions spending at zero with usage set
to stop at the budget limit. If the free runner allowance is exhausted, builds
pause rather than incurring a charge.

## Releasing

1. Merge a version-bumped release pull request from `develop` to `main`.
2. Create and push the matching annotated tag, for example `v0.2.0`.
3. Watch the `Android release` workflow. It creates or updates the GitHub
   Release with the APK, AAB, and `SHA256SUMS.txt`.

Google Play publication remains deliberately separate from this automation.
