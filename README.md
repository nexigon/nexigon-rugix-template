# Nexigon Rugix Quickstart Template

This repository provides a template for integrating Nexigon into a Rugix project for seamless over-the-air (OTA) updates and secure remote access to your devices.


## Setup

To set up the project, follow these steps:

1. Copy the `env.template` file to `.env`.
2. Fill in the following variables in your new `.env` file:
   - `NEXIGON_HUB_URL`: The URL of your Nexigon Hub instance.
   - `NEXIGON_TOKEN`: The deployment token of the project.

If you want to use Nexigon for OTA updates, also fill in these variables:

- `NEXIGON_REPOSITORY`: The name of the Nexigon repository to use.
- `NEXIGON_PACKAGE`: The name of the Nexigon package to use.

**Note:** To be able to use Nexigon's software management functionality and OTA updates with the public demo instance, you need to configure an S3 bucket within the repository's settings.


## OTA Update Workflow

The process for deploying a new update to your devices is straightforward.

1. **Build your release** using Rugix:
   ```bash
   ./run-bakery bake image <system>
   ./run-bakery bake bundle <system>
   ```
2. **Upload the release** to your Nexigon repository using the [`upload-release`](./scripts/upload-release.sh) script. This script will scan the `build` directory for the necessary artifacts, including images, update bundles, SBOMs, and build metadata, and uploads them to the repository. To this end, this script will create a new version of the specified package and adds the artifacts as assets to it. It will then also assign a floating tag of the form `latest-build-BRANCH` to the new version, to mark it as the latest build for the current branch.
3. **Mark the release as stable** using the [`stabilize-release`](./scripts/stabilize-release.sh) script. This tags the latest build of the current branch as `stable`, thereby promoting it as to the latest stable release for deployment to your devices.

This template includes the [`nexigon-rugix-ota`](https://github.com/nexigon/nexigon-rugix/tree/main/recipes/nexigon-rugix-ota) recipe from the [`nexigon-rugix`](https://github.com/nexigon/nexigon-rugix) repository.
This recipe will install a Systemd service that will periodically check for updates and fetch and install the latest stable release of the specified package, if an update is available.
The correct artifacts are automatically identified based on the system name, allowing you to use the same release process across multiple device variants.
Telemetry about the update process is sent to Nexigon in the form of events and device properties.


## ⚖️ Licensing

This project is licensed under either [MIT](https://github.com/nexigon/nexigon-rugix-template/blob/main/LICENSE-MIT) or [Apache 2.0](https://github.com/nexigon/nexigon-rugix-template/blob/main/LICENSE-APACHE) at your opinion.

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in this project by you, as defined in the Apache 2.0 license, shall be dual licensed as above, without any additional terms or conditions.

---

Made with ❤️ by [Silitics](https://www.silitics.com)
