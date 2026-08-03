vm_host = "192.168.98.115"

$set_environment_variables = <<SCRIPT
tee "/etc/profile.d/myvars.sh" > "/dev/null" <<EOF
export ANSIBLE_COLLECTIONS_PATH=/vagrant/collections
sudo chsh -s /bin/bash vagrant
sed -i "s/#alias ll='ls -l'/alias ll='ls -lAh'/g" /home/vagrant/.bashrc
EOF
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.define "oerindex-vm" do |srv|
    srv.vm.box = "cloud-image/debian-13"
    srv.vm.synced_folder ".", "/vagrant"
    srv.ssh.insert_key = false
    srv.vm.hostname = "oerindex.box"
    srv.vm.network :private_network, ip: vm_host

    srv.vm.provider :virtualbox do |vb|
      vb.name = "oerindex"
      vb.memory = 6072
      vb.cpus = 2
    end
  end

  config.vm.provision "shell", inline: $set_environment_variables
  config.vm.provision "ansible_local" do |ansible|
    ansible.install = true
    ansible.compatibility_mode = "2.0"
    ansible.install_mode = "pip"
    ansible.pip_install_cmd = "sudo apt update && sudo apt install python3-pip -y"
    ansible.pip_args = "ansible-core==2.19.2 --break-system-packages"
    ansible.playbook = "playbook.yml"
    ansible.galaxy_command = "ansible-galaxy collection install -r %{role_file} -p ./collections --force"
    ansible.galaxy_role_file = "requirements.yml"
    ansible.extra_vars = "default-config.yml"
    ansible.verbose = "true"
    ansible.host_vars = {
      "oerindex-vm" => {
        "search_index_host" => vm_host,
        "timezone" => "Europe/Berlin"
      }
    }
  end
end
