# Development

## Development Setup

Will be documented soon - until then if you have any questions please contact us (see [CONTRIBUTING](../CONTRIBUTING.md))

## Changes to the oer index (elasticsearch)

The currently used oer-index is called **oer_data_\<nr\>_\<timestamp\>** - the version is set in `{{ elasticsearch_oer_index_version }}` in [../ansible/group_vars/all.yml](../ansible/group_vars/all.yml) and the timestamp is generated automatically. **\<nr\>** indicates the current version of the index. There is an alias **oer_data** under which the index can be accessed. When you need to change the mapping (or configuration) of the current index, you need to perform the following steps:
* Adjust all your changes to the mapping
* Increase the version number of the current index in `{{ elasticsearch_oer_index_version }}` in [../ansible/group_vars/all.yml](../ansible/group_vars/all.yml)

During the next update/installation, the new index is automatically created and rebuilt via Logstash. Afterwards, the alias is removed from the old index and set to the new index - without downtime for the user. The old index is then deleted.
