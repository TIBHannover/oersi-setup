# Internationalization

## Multilingual Search

---

**Experimental / under development**

---

In the future, it will be possible to include translations of the OERSI keywords into other languages in the search. Then, for example, the results of a search for a German keyword will also include the results of the English/Spanish/French/... keyword.

A tool (tbd) provides the translations of the keywords. From these translations a synonym file for elasticsearch is generated, which can be included in the configuration. An example for such a synonym file can be found [here](../ansible/roles/elasticsearch/files/synonyms-example.txt).

The feature can be enabled or disabled via toggle (ansible-variable `oerindex_features_use_synonyms` in [all.yml](../ansible/group_vars/all.yml)). If you change this configuration, the mapping will be adjusted and the index will be reindexed automatically by the setup. The synonym file must be placed in the Elasticsearch configuration directory (usually `/etc/elasticsearch`) and have the filename `synonym.txt`. For testing purposes, the sample file can be used in the first phase of the feature development (set `elasticsearch_synonyms_file: "synonyms-example.txt"` and it will be copied by ansible). So, the following configuration will enable the feature using the example file:

```
oerindex_features_use_synonyms: true
elasticsearch_synonyms_file: "synonyms-example.txt"
```

The synonyms are included during the Elasticsearch search (not during indexing). If there are changes to the synonym file, then the search analyzers need to be reloaded so that the changes are taken into account in the search. This can be done with the help of the script `reload-search_analyzer.sh`.
