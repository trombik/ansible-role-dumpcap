# `trombik.dumpcap`

[![Build Status](https://travis-ci.com/trombik/ansible-role-dumpcap.svg?branch=master)](https://travis-ci.com/trombik/ansible-role-dumpcap)

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


## OpenBSD

| Variable | Default |
|----------|---------|
| `__dumpcap_service` | `dumpcap` |
| `__dumpcap_package` | `tshark` |
| `__dumpcap_user` | `root` |
| `__dumpcap_group` | `_wireshark` |

# Dependencies

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - role: trombik.freebsd_pkg_repo
      when: ansible_os_family == 'FreeBSD'
    - role: ansible-role-dumpcap
  pre_tasks:
    - name: Dump all hostvars
      debug:
        var: hostvars[inventory_hostname]
  post_tasks:
    - name: List all services (systemd)
      # workaround ansible-lint: [303] service used in place of service module
      shell: "echo; systemctl list-units --type service"
      changed_when: false
      when:
        - ansible_os_family == 'RedHat' or ansible_os_family == 'Debian'
    - name: list all services (FreeBSD service)
      # workaround ansible-lint: [303] service used in place of service module
      shell: "echo; service -l"
      changed_when: false
      when:
        - ansible_os_family == 'FreeBSD'
  vars:
    os_dumpcap_flags:
      # translation: write output to files with ring buffer mode, 10 files,
      # 60 sec per file. capture filiter is `ip`. the output files should be
      # group-readable. do not display the continuous count of packets.
      # output file name is `/var/log/dumpcap/dumpcap_00001_20190714120117
      OpenBSD: "-b interval:60 -b files:10 -f ip -g -i {{ ansible_default_ipv4['device'] | default(omit) }} -q -w {{ dumpcap_log_dir }}/dumpcap"
      FreeBSD: |
        dumpcap_user='{{ dumpcap_user }}'
        dumpcap_args='-b interval:60 -b files:10 -f ip -g -i {{ ansible_default_ipv4['device'] | default(omit) }} -q -w {{ dumpcap_log_dir }}/dumpcap'
      Debian: |
        DUMPCAP_FLAGS='-b interval:60 -b files:10 -f ip -g -i {{ ansible_default_ipv4['interface'] | default(omit) }} -q -w {{ dumpcap_log_dir }}/dumpcap'
      RedHat: ""
    dumpcap_flags: "{{ os_dumpcap_flags[ansible_os_family] }}"
    freebsd_pkg_repo:
      # disable the default package repository, which currently has issues
      FreeBSD:
        enabled: "false"
        state: present
      FreeBSD_latest:
        enabled: "true"
        state: present
        url: pkg+https://pkg.FreeBSD.org/${ABI}/latest
        mirror_type: srv
        signature_type: fingerprints
        fingerprints: /usr/share/keys/pkg
        priority: 100
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
