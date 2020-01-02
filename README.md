# `trombik.dumpcap`

[![Build Status](https://travis-ci.com/trombik/trombik.dumpcap.svg?branch=master)](https://travis-ci.com/trombik/trombik.dumpcap)

`ansible` role for `dumpcap(1)` in `wireshark`. The role configures and runs
`dumpcap(1)` in the background. Output files are under `dumpcap_log_dir`.

The role creates startup scripts for `dumpcap` because no package provides
one.

# Requirements

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `dumpcap_package` | Package name of `dumpcap` | `{{ __dumpcap_package }}` |
| `dumpcap_service` | Service name of `dumpcap` | `{{ __dumpcap_service }}` |
| `dumpcap_extra_packages` | A list of extra packages to install | `[]` |
| `dumpcap_user` | User name of `dumpcap` | `{{ __dumpcap_user }}` |
| `dumpcap_group` | Group of `dumpcap` | `{{ __dumpcap_group }}` |
| `dumpcap_log_dir` | Directory to save captured files | `/var/log/dumpcap` |
| `dumpcap_flags` | See below | `""` |

## `dumpcap_flags`

This variable is used for overriding defaults for startup scripts. In Debian
variants, the value is the content of
[`/etc/default/dumpcap`](templates/Debian.default.j2). In RedHat variants, it
is the content of [`/etc/sysconfig/dumpcap`](templates/RedHat.sysconfig.j2).
In FreeBSD, it is the content of
[`/etc/rc.conf.d/dumpcap`](templates/FreeBSD.rcd.j2). In OpenBSD, the value is
passed to `rcctl set dumpcap`.

## Debian

| Variable | Default |
|----------|---------|
| `__dumpcap_service` | `dumpcap` |
| `__dumpcap_package` | `wireshark-common` |
| `__dumpcap_user` | `root` |
| `__dumpcap_group` | `wireshark` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__dumpcap_service` | `dumpcap` |
| `__dumpcap_package` | `net/wireshark-lite` |
| `__dumpcap_user` | `root` |
| `__dumpcap_group` | `network` |

# Dependencies

# Example Playbook

```yaml
```

# License

```
Copyright (c) 2020 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>
