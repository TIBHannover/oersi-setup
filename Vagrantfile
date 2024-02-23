vm_host = "192.168.98.115"

$set_environment_variables = <<SCRIPT
tee "/etc/profile.d/myvars.sh" > "/dev/null" <<EOF
export ANSIBLE_COLLECTIONS_PATH=/vagrant/collections
EOF
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.define "oerindex-vm" do |srv|
    srv.vm.box = "debian/bullseye64"
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
    ansible.pip_install_cmd = "sudo apt-get install -y python3-distutils && curl -s https://bootstrap.pypa.io/get-pip.py | sudo python3"
    ansible.pip_args = "ansible-core==2.13.7"
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
