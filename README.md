# Windows Ansible Playbook

## Installation

### Prepare your Windows host ⏲

Copy and paste the code below into your PowerShell terminal to get your Windows machine ready to work with Ansible.

```powershell
powershell.exe -ExecutionPolicy ByPass -File setup.ps1 -Verbose
```

### Ansible Control node 🕹

1. [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html):

   1. Upgrade Pip: `pip3 install --upgrade pip`
   2. Install Ansible: `pip3 install ansible`

2. Clone or download this repository to your local drive.
3. Run `ansible-galaxy install -r requirements.yml` inside this directory to install required Ansible collections.
4. Add the IP address and credentials of your Windows machine into the `inventory` file
5. Run `ansible-playbook main.yml` inside this directory.

### Running a specific set of tagged tasks

You can filter which part of the provisioning process to run by specifying a set of tags using `ansible-playbook` `--tags` flag. The tags available are `choco` , `debloat` , `desktop` , `explorer` , `fonts` , `hostname` , `mouse` , `power` , `sounds` , `start_menu` , `taskbar` , `updates` , `windows_features` , `wsl`, `winget`.

```sh
ansible-playbook main.yml --tags "choco,wsl"
```

## Author

This project was created by [Alexander Nabokikh](https://www.linkedin.com/in/nabokih/) (initially inspired by [geerlingguy/mac-dev-playbook](https://github.com/geerlingguy/mac-dev-playbook)).