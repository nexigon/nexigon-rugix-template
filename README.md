# Nexigon Rugix Quickstart Template 🚀

This repository provides a template for integrating [Nexigon](https://nexigon.dev) into a Rugix project for **seamless over-the-air (OTA) system updates and secure remote access** to your devices.

## Setup

Install [mise](https://mise.jdx.dev/), a container runtime supported by
Rugix Bakery, `jq`, and `xz`. Release publication also requires Nexigon CLI
with repository access. Nix is not required.
For a direct image build, run `./run-bakery bake image <system>` or
`mise run bakery -- bake image <system>`.

To set up the project, follow these steps:

1. Copy the `env.template` file to `.env`.
2. Fill in the following variables in your new `.env` file:
   - `NEXIGON_HUB_URL`: The URL of your Nexigon instance.
   - `NEXIGON_TOKEN`: The deployment token of the project.

If you want to use Nexigon for OTA updates, also fill in these variables:

- `NEXIGON_REPOSITORY`: The path name or ID of the Nexigon repository to use.
- `NEXIGON_PACKAGE`: The name of the Nexigon package to use.
- `NEXIGON_ORGANIZATION`: The ID of the organization that owns the repository, beginning with `org_`. The release tasks need it when Nexigon CLI authenticates with a user token. An organization API token selects its own organization.

## OTA Update Workflow

The release tasks share a pinned version in `.release-env` so builds and uploads
use the same version.

### 1. Prepare the release

```bash
mise run release:prepare
```

Generates a version identifier from the current timestamp and Git commit, creates the corresponding version in your Nexigon repository, and writes a `.release-env` file that pins the version for subsequent steps. The version is tagged with a locked build tag (e.g., `build-20260401120000-abc1234`) and a floating branch tag (e.g., `latest-build-main`).

### 2. Build the release

```bash
mise run build <system> [<system> ...]
```

Reads the pinned version from `.release-env` and builds system images and update bundles using the Rugix bakery with the matching `--release-version`. After building, the system image is compressed with `xz`. You can build multiple systems in one invocation:

```bash
mise run build customized-efi-amd64 customized-pi5
```

### 3. Upload the release

```bash
mise run release:upload
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
mise run release:stabilize
```

Tags the latest build of the current branch as `stable`, promoting it as the latest stable release for deployment.

### Notes

The scripts use `nexigon-cli` to interact with Nexigon. Make sure you have it installed and configured correctly.
To use Nexigon's software management functionality and OTA updates with Nexigon Cloud, you need to configure an S3 bucket within the repository's settings.

Nexigon Agent installs the updates. The template's `nexigon-system-updates` recipe enables the agent's [system updates](https://docs.nexigon.dev/agent/concepts/system-updates) for the `stable` tag of the package in `.env`.
Each device installs the update bundle of its system, so the same release process serves all device variants.
The device reports its progress in the `dev.nexigon.ota.status` property and as events.
The `dev.nexigon.ota.config` property of a device or its profile changes the release that it follows and adds policies, such as a maintenance window.
Without `NEXIGON_REPOSITORY` and `NEXIGON_PACKAGE`, devices wait for this property.

The agent can also manage [Rugix Apps](https://docs.nexigon.dev/agent/concepts/rugix-apps), which requires Rugix Ctrl 1.4 or later.
To enable it, add `[integrations.rugix.apps]` with `enabled = true` to the `extra_config` of `nexigon/nexigon-agent-config`.

## GitHub Actions Workflow

This template includes a GitHub Actions workflow that runs the same scripts described above. On pushes to `main` or `ci` and manual runs, the `prepare-release` job creates the version and uploads `.release-env` as an artifact. Parallel `build` jobs download it, build each system, and upload the results.

Pull requests build all four systems with placeholder configuration and a version derived from the tested commit. They do not require Nexigon credentials, create repository versions, or publish artifacts to Nexigon. These images are for build validation only.

Builds use Ubuntu 24.04 runners matching the image architecture: x86-64 for `customized-efi-amd64`, and ARM64 for `customized-efi-arm64`, `customized-pi5`, and `customized-pi4`. Native ARM64 runners avoid QEMU emulation during package installation.

To use it, you need to configure the following secrets in your GitHub repository:

- `NEXIGON_HUB_URL`: The URL of your Nexigon instance.
- `NEXIGON_DEPLOYMENT_TOKEN`: The deployment token of the project.
- `NEXIGON_TOKEN`: An organization API token with access to the repository.

In addition, you also need to configure the following variables:

- `NEXIGON_REPOSITORY`: The path name or ID of the Nexigon repository to use.
- `NEXIGON_PACKAGE`: The name of the Nexigon package to use.

## ⚖️ Licensing

This project is licensed under either [MIT](https://github.com/nexigon/nexigon-rugix-template/blob/main/LICENSE-MIT) or [Apache 2.0](https://github.com/nexigon/nexigon-rugix-template/blob/main/LICENSE-APACHE) at your opinion.

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in this project by you, as defined in the Apache 2.0 license, shall be dual licensed as above, without any additional terms or conditions.

---

Made with ❤️ by [Silitics](https://www.silitics.com)
