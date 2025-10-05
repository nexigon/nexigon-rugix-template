# Nexigon Rugix Quickstart Template 🚀

This repository provides a template for integrating [Nexigon](https://nexigon.dev) into a Rugix project for **seamless over-the-air (OTA) system updates and secure remote access** to your devices.


## Setup

To set up the project, follow these steps:

1. Copy the `env.template` file to `.env`.
2. Fill in the following variables in your new `.env` file:
   - `NEXIGON_HUB_URL`: The URL of your Nexigon Hub instance.
   - `NEXIGON_TOKEN`: The deployment token of the project.

If you want to use Nexigon for OTA updates, also fill in these variables:

- `NEXIGON_REPOSITORY`: The name of the Nexigon repository to use.
- `NEXIGON_PACKAGE`: The name of the Nexigon package to use.


## OTA Update Workflow

The process for deploying a new update to your devices is straightforward.

1. **Build your release** using Rugix:
   ```bash
   ./run-bakery bake image <system>
   ./run-bakery bake bundle <system>
   ```
2. **Upload the release** to your Nexigon repository using the [`upload-release`](./scripts/upload-release.sh) script. This script will scan the `build` directory for the necessary artifacts, including images, update bundles, SBOMs, and build metadata, and upload them to the repository. To this end, this script will create a new version of the specified package and add the artifacts as assets to it. It will then also assign a floating tag of the form `latest-build-BRANCH` to the new version, to mark it as the latest build for the current Git branch.
3. **Mark the release as stable** using the [`stabilize-release`](./scripts/stabilize-release.sh) script. This tags the latest build of the current branch as `stable`, thereby promoting it as to the latest stable release for deployment.

**Note:** The scripts will use `nexigon-cli` to interact with Nexigon. Make sure you have it installed and configured correctly.
To be able to use Nexigon's software management functionality and OTA updates with the public demo instance, you need to configure an S3 bucket within the repository's settings.

This template includes the [`nexigon-rugix-ota`](https://github.com/nexigon/nexigon-rugix/tree/main/recipes/nexigon-rugix-ota) recipe from the [`nexigon-rugix`](https://github.com/nexigon/nexigon-rugix) repository.
This recipe installs a Systemd service that will periodically check for updates and fetch and install the latest stable release of the specified package, if its version deviates from teh current one.
The correct artifacts are automatically identified based on the system name, allowing you to use the same release process across multiple device variants.
Telemetry about the update process is sent to Nexigon in the form of events and device properties.


## GitHub Actions Workflow

This template includes a GitHub Actions workflow for building and uploading releases to Nexigon.
To use it, you need to configure the following secrets in your GitHub repository:

- `NEXIGON_HUB_URL`: The URL of your Nexigon Hub instance.
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
