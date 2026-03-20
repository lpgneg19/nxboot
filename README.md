# NXBoot

This application enables provisioning a Tegra X1 powered device with early boot code using an iOS or macOS device. For example, you may use this application to start the Hekate Bootloader or the Lakka Linux Distrobution (RetroArch) on a supported Nintendo Switch.

**Disclaimer:** Early boot code has full access to the device it runs on and can damage it. No boot code is shipped with this application. Responsibility for consequences of using this application and executing boot code remains with the user.

## Features

* **Native macOS App**: A modern SwiftUI interface designed for macOS 14+.
* **Real-time Monitoring**: Automatically detects Nintendo Switch in RCM mode via USB.
* **Payload Management**: Store, manage, and easily switch between multiple payloads.
* **Hekate Integration**: Deep integration with Hekate, allowing dynamic configuration of boot targets and UMS modes directly from the GUI.
* **Auto-Injection**: Enable "Auto-Boot" to immediately inject a pre-selected payload upon device connection.
* **Live Logs**: View both application system logs and real-time serial (EP1) logs from your Switch.
* **CLI Power**: Embedded `nxboot` command-line tool with a built-in system-wide installer (`/usr/local/bin/nxboot`).
* **Multilingual Support**: Fully localized in English and Simplified Chinese.

## Prerequisites

* A Mac running macOS 14.0 or later.
* A USB-C to USB-C or USB-A to USB-C cable compatible with data transfer.
* A Nintendo Switch capable of entering RCM mode (Tegra X1 based).

## Installation

You can build the application from source using the provided scripts:

1. Clone the repository.
2. Run `xcodegen generate` to create the Xcode project.
3. Open `NXBoot.xcodeproj` or run `xcodebuild` via `build.sh`.

For the command-line tool, you can use the **Install CLI Tool** button within the App's "About" screen to set it up system-wide.

## Components

* **NXBoot (App)**: The primary native macOS SwiftUI application.
* **NXBootCmd**: High-performance C-based command-line tool for payload injection.
* **NXBootKit**: The core framework providing USB monitoring and injection logic.

## License
 
Copyright (C) 2018-2024 Oliver Kuckertz
Copyright (C) 2026 SteveShi
 
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

## Attribution and Prior Work

CVE-2018-6242 was discovered by Kate Temkin (@ktemkin) and fail0verflow (@fail0verflow). Fusée Gelée was implemented by @ktemkin; ShofEL2 was implemented by @fail0verflow.

Special thanks to the original authors and the Switch homebrew community for their groundbreaking work.
