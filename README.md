# Nexigon Rugix Quickstart Template 🚀

This repository provides a template for integrating [Nexigon](https://nexigon.dev) into a Rugix project for **seamless over-the-air (OTA) system updates and secure remote access** to your devices.

## Setup

To set up the project, follow these steps:

1. Copy the `env.template` file to `.env`.
2. Fill in the following variables in your new `.env` file:
   - `NEXIGON_HUB_URL`: The URL of your Nexigon instance.
   - `NEXIGON_TOKEN`: The deployment token of the project.

If you want to use Nexigon for OTA updates, also fill in these variables:

- `NEXIGON_REPOSITORY`: The ID of the Nexigon repository to use.
- `NEXIGON_PACKAGE`: The name of the Nexigon package to use.

## OTA Update Workflow

The release workflow consists of three scripts that share state through a `.release-env` file. This ensures the version is generated once and stays consistent across all steps — both locally and in CI.

### 1. Prepare the release

```bash
./scripts/prepare-release.sh
```

Generates a version identifier from the current timestamp and Git commit, creates the corresponding version in your Nexigon repository, and writes a `.release-env` file that pins the version for subsequent steps. The version is tagged with a locked build tag (e.g., `build-20260401120000-abc1234`) and a floating branch tag (e.g., `latest-build-main`).

### 2. Build the release

```bash
./scripts/build-release.sh <system> [<system> ...]
```

Reads the pinned version from `.release-env` and builds system images and update bundles using the Rugix bakery with the matching `--release-version`. After building, the system image is compressed with `xz`. You can build multiple systems in one invocation:

```bash
./scripts/build-release.sh customized-efi-amd64 customized-pi5
```

### 3. Upload the release

```bash
./scripts/upload-release.sh
```

Reads `.release-env`, verifies that each build's baked version matches the pinned version (to catch stale builds), and uploads all artifacts to the Nexigon repository. Uploaded artifacts include:

- **System image** (`.img.xz`) — with metadata linking to its SBOM
- **Update bundle** (`.rugixb`) — with the bundle hash and SBOM link in metadata
- **Bundle hash** (`.rugixb-hash`) — for backwards compatibility
- **SBOM** (`.spdx.json`)
- **Build info** (`.build-info.json`)

Asset metadata is attached during upload, e.g., the bundle asset carries `{"rugix": {"bundleHash": "..."}, "relations": {"sbom": [...]}}`.

### 4. Stabilize the release

```bash
./scripts/stabilize-release.sh
```

Tags the latest build of the current branch as `stable`, promoting it as the latest stable release for deployment.

### Notes

The scripts use `nexigon-cli` to interact with Nexigon. Make sure you have it installed and configured correctly.
To use Nexigon's software management functionality and OTA updates with Nexigon Cloud, you need to configure an S3 bucket within the repository's settings.

This template includes the [`nexigon-rugix-ota`](https://github.com/nexigon/nexigon-rugix/tree/main/recipes/nexigon-rugix-ota) recipe from the [`nexigon-rugix`](https://github.com/nexigon/nexigon-rugix) repository.
This recipe installs a Systemd service that will periodically check for updates and install the latest stable release of the specified package, if its version deviates from the current one.
The correct artifacts are automatically identified based on the system name, allowing you to use the same release process across multiple device variants.
Telemetry about the update process is sent to Nexigon in the form of events and device properties.

To manually check for and install updates, run `nexigon-rugix-ota` as root.

If you need a more complex update workflow, e.g., display the available update to a user and wait for their explicit confirmation, copy the `nexigon-rugix-ota` recipe and modify the [update script](https://github.com/nexigon/nexigon-rugix/tree/main/recipes/nexigon-rugix-ota/files/nexigon-rugix-ota). Nexigon follows a [primitives-first architecture](https://nexigon.cloud/blog/2026-02-19-primitives-first-architecture/) giving you all the flexibility to customize the update process according to your requirements.

## GitHub Actions Workflow

This template includes a GitHub Actions workflow that runs the same scripts described above. The `prepare-release` job creates the version and uploads `.release-env` as an artifact. Parallel `build` jobs download it, build each system, and upload the results.

To use it, you need to configure the following secrets in your GitHub repository:

- `NEXIGON_HUB_URL`: The URL of your Nexigon instance.
- `NEXIGON_DEPLOYMENT_TOKEN`: The deployment token of the project.
- `NEXIGON_USER_TOKEN`: The user token to access the repository.

In addition, you also need to configure the following variables:

- `NEXIGON_REPOSITORY`: The name of the Nexigon repository to use.
- `NEXIGON_PACKAGE`: The name of the Nexigon package to use.

## ⚖️ Licensing

This project is licensed under either [MIT](https://github.com/nexigon/nexigon-rugix-template/blob/main/LICENSE-MIT) or [Apache 2.0](https://github.com/nexigon/nexigon-rugix-template/blob/main/LICENSE-APACHE) at your opinion.

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in this project by you, as defined in the Apache 2.0 license, shall be dual licensed as above, without any additional terms or conditions.

---

Made with ❤️ by [Silitics](https://www.silitics.com)
