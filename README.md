# **Under Development**

first draft

# OER Search Index Setup

The search index offers the possibility to search quickly in various oer sources.

With this project you can set up all components that are necessary to run the index. The process uses [ansible](https://docs.ansible.com/) to install the components.

Currently some parts of this project are based on the prototypes [oerhoernchen20](https://github.com/programmieraffe/oerhoernchen20) made by [Matthias Andrasch](https://twitter.com/m_andrasch) and [Docker-Hoernchen 2.0](https://github.com/sroertgen/oerhoernchen20_docker) made by [Steffen Rörtgen (im Rahmen des Projektes JOINTLY)](https://github.com/sroertgen).

## installation

* install ansible galaxy roles:
     * ```ansible-galaxy install geerlingguy.elasticsearch,4.1.0``` 
     * ```ansible-galaxy install geerlingguy.logstash,5.0.2``` 
* create config.yml (see config-example.yml)
* ```ansible-playbook -v -i config.yml ansible/system.yml```

## Run it locally 

Set up an oer-search-index in a virtual machine with minimal effort.

Prerequisites
* [Git](https://git-scm.com/downloads) (tested with 2.17.1)
* [Vagrant](https://www.vagrantup.com/downloads.html) (tested with 2.0.2)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (tested with 5.2.34_Ubuntu)

Perform the following steps in the terminal (Linux / macOS) or in the GitBash (Windows).
```
git clone https://gitlab.com/TIBHannover/oer/oersi-setup.git
cd oersi-setup
vagrant up
```
When the installation is complete (a few minutes, depending on the download speed), the index can be opened in the browser

<http://192.168.98.115/>

You can stop the virtual machine with
```
vagrant halt
```
... and start again with
```
vagrant up
```
If you want to reload the configuration (including the import from the oer sources), perform
```
vagrant reload --provision
```

## Technologies

- **Scrapy**: First OER repositories are crawled using [Scrapy](http://scrapy.org/) -> just for the first prototype; a general, robust approach has to be developed (see https://gitlab.com/oersi/oersi-metadata-harvester)
- **MariaDB**: Used to store the results of Scrapy.
- **Logstash**: Logstash is regulary checking the MariaDB database, if any new items are added or changes are made to existing entries.
- **Elasticsearch**: Elasticsearch is the search engine and indexes the input it gets from Logstash.
- **Backend**: The backend is the interface for read/write access to the index, see https://gitlab.com/oersi/oersi-backend
- **Frontend**: The frontend is used from https://gitlab.com/oersi/oersi-frontend
