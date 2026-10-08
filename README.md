# netauto-repo

Ansible automation for building and checking Cisco Catalyst access switches.
Configuration is pushed over **NETCONF** (YANG) where the model allows it and
over **CLI** where it does not. Every deploy playbook also **validates** what it
pushed, and the results are written to a pass/fail report.

Tested on Catalyst 9000 (Cat9kv), IOS-XE 17.10.

## What's in the repo

```
ansible.cfg              Ansible settings for this repo
Dockerfile               Builds the control-node container (Ubuntu 24.04)
requirements.txt         Pinned Python packages (Ansible, pyATS, ncclient, ...)
requirements.yml         Pinned Ansible collections (cisco.ios, netcommon, utils)
inventories/<site>/      hosts.yaml, group_vars, host_vars, encrypted vault
playbooks/<model_ver>/   Playbooks tested on that platform, e.g. cat9kv_17.10
```

| Playbooks | Purpose |
|---|---|
| `deploy_*.yaml` | Configure one feature (NTP, AAA, banners, VLANs, ...) and check it |
| `gather.yaml` | Reads device facts once per run, for the report |
| `report.yaml` | Writes the pass/fail report to `validation/<timestamp>/` |
| `combined_playbook.yaml` | Runs gather, the deploy playbooks and report in order |
| `get_*.yaml` | Read-only data collection (inventory, port status, L3 interfaces, ...) to CSV in `get_reports/<timestamp>/` |

## Quick start

```bash
git clone https://github.com/mr-adheer/netauto-repo.git
cd netauto-repo
docker build -t netauto:latest .
docker run -dit --name netauto -v $HOME/netauto-repo:/netauto-repo netauto:latest
docker exec -it netauto bash

cd /netauto-repo
INV=inventories/base_line/hosts.yaml
PB=playbooks/cat9kv_17.10
```

Each switch needs SSH, NETCONF and a privilege-15 user configured by console
first (see the guide).

## Running playbooks

All deploy, gather and report tasks are tagged `never`, so **nothing runs
without a tag**:

| Command | What it does |
|---|---|
| `--tags validate` | Checks the switches, changes nothing |
| `--tags deploy` | Pushes configuration only |
| `--tags deploy,validate` | Pushes configuration, then checks it |

```bash
# Audit a whole site
ansible-playbook -i $INV $PB/combined_playbook.yaml --tags validate --ask-vault-pass

# Build one switch and check it
ansible-playbook -i $INV $PB/combined_playbook.yaml --tags deploy,validate \
  --limit blr-flr1-acc-sw01 --ask-vault-pass

# Collect a hardware inventory (get_ playbooks run without tags)
ansible-playbook -i $INV $PB/get_inventory.yaml --ask-vault-pass
```

## Notes

- Secrets live in an encrypted `vault.yaml`. Never commit the vault password.
- `validation/` and `get_reports/` are kept out of Git.
- Full details are in the guide: *Network Automation Playbook Guide - Layer 2
  Switch Deployments with Ansible and pyATS*.
