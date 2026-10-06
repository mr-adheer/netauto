# Network Automation Repo

## Structure

```
inventories/<customer>/
  hosts.yml              # device list + groups + connection settings
  group_vars/
    all.yml               # settings shared by ALL of this customer's devices
    <role>.yml             # settings shared by devices in one role (e.g. access_switches)
  host_vars/
    <device>.yml            # settings unique to ONE device (VLANs, interfaces, IP, hostname)

templates/
  Only for CLI features with NO Cisco resource module equivalent.
  Keep these small, isolated, and lab-tested before use - a bug here
  affects every device that uses it.

playbooks/
  One playbook per deployment type (e.g. deploy_switch.yml).
  Prefer Cisco resource modules (cisco.ios.*) over raw templates
  wherever a module exists for the feature.

validation/
  testbeds/   pyATS testbed files describing the lab/device topology
  tests/      pre/post-change validation scripts (pyATS/Genie)
```

## Running a deployment

```bash
ansible-playbook -i inventories/customerA/hosts.yml playbooks/deploy_switch.yml
```

## Adding a new device

1. Add it to `inventories/<customer>/hosts.yml` under the right group.
2. Create `inventories/<customer>/host_vars/<device>.yml` with its VLANs,
   interfaces, hostname, and management IP.
3. Nothing else needs to change - it automatically inherits the shared
   `group_vars/all.yml` and role-level `group_vars/<role>.yml` settings.

## Rule of thumb

- Standard, common features (VLANs, interfaces, NTP, hostname, etc.) ->
  use a Cisco resource module. No template needed.
- A feature with no resource module -> small, isolated Jinja2 template
  in `templates/`, reviewed and lab-tested before use.
- Any logic beyond simple substitution (counters, multi-condition branching,
  calculations) -> belongs in a pre-processing Python script, not in YAML
  or Jinja2 directly.
