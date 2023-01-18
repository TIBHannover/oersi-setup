require 'yaml'
settings = YAML.load_file 'ansible/group_vars/all.yml'

Vagrant.configure("2") do |config|

  config.vm.define "oerindex-vm" do |srv|
    # Update to bullseye, because buster has bugs with vagrant & ansible currently - see https://github.com/hashicorp/vagrant/issues/13016
    #srv.vm.box = "debian/buster64"
    srv.vm.box = "debian/bullseye64"
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
    ansible.pip_args = "ansible-core==2.13.7"
    #ansible.version = "2.13.7"
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
