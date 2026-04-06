# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`xkbswitch-macosx` is a minimal console keyboard layout switcher for macOS, primarily used for Vim integration (e.g., with vim-barbaric or vim-xkbswitch to auto-switch input sources on mode change).

## Build

```sh
make          # Produces universal binary (x86_64 + arm64) via lipo
```

Intermediate targets: `xkbswitch-x86` (x86_64, macOS 10.9+) and `xkbswitch-arm` (arm64, macOS 11+).

There are no tests.

## Usage

```sh
xkbswitch -l               # List all input source IDs
xkbswitch -g               # Get current input source ID
xkbswitch -s <id>          # Set input source by ID
xkbswitch -g -e            # Get current input source localized name
```

## Architecture

Two independent Objective-C source files — neither depends on the other:

- **`xkbswitch.m`** — The actual CLI binary. Parses `-g`/`-s`/`-l` flags (and `-n`/`-e` for ID vs. localized name mode) and calls the macOS Carbon `TIS*` (TextInputSource) API directly.
- **`InputSourceSelector.m`** — A separate reference/alternative implementation with richer commands (`list`, `list-enabled`, `current`, `current-layout`, `enable`, `disable`, `select`, `deselect`). Not built by the Makefile.

Both files use `NSAutoreleasePool` (manual memory management, no ARC). Frameworks used: `Carbon` (TextInputSource API) and `Foundation` (Objective-C runtime).
