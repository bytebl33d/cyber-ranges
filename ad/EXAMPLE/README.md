# EXAMPLE

This is an example template for creating labs with ansible.

## Ansible Provisioning

Change the inventory to reflect the correct IP addresses and run the ansible playbooks:

```bash
# install the required collections
$ ansible-galaxy collection install ansible.windows
$ ansible-galaxy collection install community.general
$ ansible-galaxy collection install community.windows

$ cd ansible
$ ansible-playbook -i ../ad/EXAMPLE/data/inventory -i ../ad/EXAMPLE/providers/vmware/inventory -i ../globalsettings.ini main.yml
```
