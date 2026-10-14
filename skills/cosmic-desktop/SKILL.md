---
name: cosmic-desktop
description: >-
  Configure and troubleshoot POP!_OS 24.04, CachyOS Linux, COSMIC desktop, Wayland windows, application
  launchers, dock icons, .desktop overrides, and Arch package management. Load when working on local
  Linux system administration, desktop launchers, Wayland app_id debugging, or package installation.
---
# COSMIC desktop and Linux environment

- Detect POP!_OS 24.04 or CachyOS Linux, and assume COSMIC desktop, Wayland, and `bash`.
- On Arch-based systems, install and manage packages with `paru` rather than `yay`.
- Fix an application's launcher, dock icon, or startup environment by creating a user-level `.desktop` override in `~/.local/share/applications/`, leaving the packaged `.desktop` file untouched.
- Read a window's Wayland `app_id` by launching the application with `WAYLAND_DEBUG=1` and searching the log for `set_app_id`.
