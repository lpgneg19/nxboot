# Changelog

## [2.1.0] - 2026-03-20

### Added
- **Modern SwiftUI UI**: Complete rewrite of the macOS application with a premium, native look and feel.
- **Hekate Logic**: Deep integration with Hekate, supporting dynamic boot targets (Menu, UMS, ID, Index) and UMS mount points.
- **Serial Logs (EP1)**: Support for real-time asynchronous serial log monitoring from Switch USB EP1.
- **CLI Installer**: Built-in system installer for the `nxboot` command-line tool (`/usr/local/bin/nxboot`).
- **Native About Menu**: Custom menu bar "About" integration presenting the feature-rich AboutView.
- **CI/CD Pipeline**: GitHub Actions workflow for automated DMG and ZIP releases on version tags.

### Changed
- **Branding**: Unified application name to **NXBoot**.
- **Refinement**: Polished UI alignment across all views (Dashboard, Payloads, Hekate, Logs).
- **Security**: Secure CLI installation path using AppleScript for authenticated privilege escalation.
- **Compliance**: Fully updated to **GPLv3** license and updated project attribution.

### Removed
- **Legacy Components**: Stripped out non-functional AppCenter SDK and legacy iOS-specific code to streamline the macOS experience.
