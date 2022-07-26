require 'yaml'
settings = YAML.load_file 'ansible/group_vars/all.yml'

Vagrant.configure("2") do |config|

  config.vm.define "oerindex-vm" do |srv|
    srv.vm.box = "debian/buster64"
    srv.ssh.insert_key = false
    srv.vm.hostname = "oerindex.box"
    srv.vm.network :private_network, ip: settings['oerindex_host']

    srv.vm.provider :virtualbox do |vb|
      vb.name = "oerindex"
      vb.memory = 6072
      vb.cpus = 2
    end
  end

  config.vm.provision "ansible_local" do |ansible|
    ansible.install = true
    ansible.compatibility_mode = "2.0"
    ansible.install_mode = "pip"
    ansible.pip_install_cmd = "sudo apt-get install -y python3-distutils && curl -s https://bootstrap.pypa.io/get-pip.py | sudo python3"
    ansible.version = "2.9.27"
    ansible.playbook = "ansible/system.yml"
    ansible.galaxy_role_file = "requirements.yml"
    ansible.verbose = "true"
    ansible.groups = {
      "oerindex" => ["oerindex-vm"],
      "all:vars" => {
        "timezone" => "Europe/Berlin"
      }
    }
  end
end
