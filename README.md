# Ludus Cyber Ranges
## Description

This repo contains custom ludus cyber ranges that serve as a Active Directory pentest environment. The purpose of these labs is to give pentesters a vulnerable Active Directory environment ready to use to practice usual attack techniques.

### Available Labs

- NHA: A lab with 5 vms and 2 domains:
  - MSSQL
  - RBCD
  - Credenital Dumping
  - ADCS
  - Forest Trust Attacks

- PUPPET: A lab with 3 vms and 1 domain, where you learn to operate with the Sliver C2 framework:
  - RBCD
  - Service Hijacking
  - DACL Permission
  - DevOps Infrastructure

## Building Templates

```bash
$ ludus templates list
+------------------------------------+-------+
|              TEMPLATE              | BUILT |
+------------------------------------+-------+
| debian-11-x64-server-template      | FALSE |
| debian-12-x64-server-template      | FALSE |
| kali-x64-desktop-template          | FALSE |
| win11-22h2-x64-enterprise-template | FALSE |
| win2022-server-x64-template        | FALSE |
+------------------------------------+-------+

$ ludus templates add -d <TEMPLATE_DIRECTORY>
$ ludus tamplates build -n win-2025-server-x64-tpm-template
```

## Range Deployment

```bash
$ ludus range config get > ludus-range-default.yml
$ ludus range config set -f ludus-range-default.yml
$ ludus range deploy --user <USER>
```

## Ansible Provisioning

Example command to run the playbook for the NHA lab:

```bash
$ cd ansible
$ ansible-playbook -i ../ad/NHA/data/inventory -i ../ad/NHA/providers/ludus/inventory -i ../globalsettings.ini nha-main.yml
```

## Snapshot and start hacking
```
$ ludus --user <USER> snapshot create clean-setup -d "Clean range setup after ansible run"

$ ludus --user <USER> power on -n all
[INFO]  Full range power on in progress
```
