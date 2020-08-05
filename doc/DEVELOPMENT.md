# Development

## Changes to the oer index (elasticsearch)

The currently used oer-index is called **oer_data_\<nr\>** - this is set in `{{ elasticsearch_oer_index_name }}` in [../ansible/group_vars/all.yml](../ansible/group_vars/all.yml). **\<nr\>** indicates the current version of the index. There is an alias **oer_data** under which the index can be accessed. When you need to change the mapping (or configuration) of the current index, you need to perform the following steps:
* Mark the current index as "outdated": add to the `outdated_indices`-list in [../ansible/roles/elasticsearch-updates/tasks/main.yml](../ansible/roles/elasticsearch-updates/tasks/main.yml)
* Adjust all your changes to the mapping
* Increase the version number of the current index (**oer_data_\<nr + 1\>**) and set the new name in `{{ elasticsearch_oer_index_name }}` in [../ansible/group_vars/all.yml](../ansible/group_vars/all.yml)

The old index is then deleted, and Logstash is forced to reinsert all data during the next Logstash run into the new index.
