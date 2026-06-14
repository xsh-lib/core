[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors)

[![GitHub tag](https://img.shields.io/github/v/tag/xsh-lib/core?sort=date)](https://github.com/xsh-lib/core/tags)
[![GitHub](https://img.shields.io/github/license/xsh-lib/core.svg?style=flat-square)](https://github.com/xsh-lib/core/)
[![GitHub last commit](https://img.shields.io/github/last-commit/xsh-lib/core.svg?style=flat-square)](https://github.com/xsh-lib/core/commits/master)

[![CI](https://github.com/xsh-lib/core/actions/workflows/ci.yml/badge.svg)](https://github.com/xsh-lib/core/actions/workflows/ci.yml)
[![GitHub issues](https://img.shields.io/github/issues/xsh-lib/core.svg?style=flat-square)](https://github.com/xsh-lib/core/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/xsh-lib/core.svg?style=flat-square)](https://github.com/xsh-lib/core/pulls)

# xsh-lib/core

xsh Library - core.

This repo is the core library of xsh.

About xsh and its libraries, check out [xsh document](https://github.com/alexzhangs/xsh)

## Requirements

`xsh-lib/core` is tested in CI ([GitHub Actions](https://github.com/xsh-lib/core/actions/workflows/ci.yml)) on every push and pull request, across the following shell/OS combinations:

| Shell | Version | OS                    | Tested |
|-------|---------|-----------------------|:------:|
| bash  | 3.2     | macOS                 | ✅     |
| bash  | 4.4     | Linux (rockylinux:8)  | ✅     |
| bash  | 5.x     | Linux (ubuntu-latest) | ✅     |
| bash  | 5.x     | macOS (Homebrew)      | ✅     |
| zsh   | 5.x     | Linux (ubuntu-latest) | ✅     |
| zsh   | 5.x     | macOS                 | ✅     |

zsh utilities run under xsh's ksh emulation and require **xsh ≥ 0.7.0**.

This project is still at version 0.x, and should be considered immature.

## Installation

Assume [xsh](https://github.com/alexzhangs/xsh) is already installed at your local.

To load this library into `xsh` issue below command:

```bash
xsh load xsh-lib/core
```

The loaded library can be referred as name `x`.

## Usage

List available utilities for this library:

```bash
xsh list x
```
