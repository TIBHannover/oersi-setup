> **_DEPRECATED:_** This page has been moved to our documentation
>
> Please use the following link instead: https://oersi.org/resources/pages/en/docs/

# Internationalization

## Add new language

For adding a new language to the OERSI, we need to extend the frontend-labels, the vocabularies and the multilingual search. Please create a new Issue in [oersi-frontend](https://gitlab.com/oersi/oersi-frontend/-/issues/new?issuable_template=add-translation) for this with title `Add translation into <YOUR-LANGUAGE>`

### Frontend-Labels

* Create a new folder for the [ISO-639-1 code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) of the new language under https://gitlab.com/oersi/oersi-frontend/-/tree/master/public/locales
* Create a `translation.json` inside of the new folder and translate all the labels in this file (except `HEADER` and `META` labels). Template for this may be [public/locales/en/translation.json](https://gitlab.com/oersi/oersi-frontend/-/blob/master/public/locales/en/translation.json)

**OERSI-internal**:
* Create a `language.json` inside of the new folder. Can be created via [get-language-labels.py](../tools/scripts/get-language-labels.py) (uses Wikidata).
* In all existing `translation.json`: add `HEADER.CHANGE_LANGUAGE`-entry for the new language. Please use the new language as label for all existing files.

### Vocabularies

The `ttl`-files of all vocabularies used by OERSI needs to be extended: there needs to be an additional entry in the `skos:prefLabel` for the new language for _every_ `skos:Concept`-entry.

Example:
```
skos:prefLabel "Softwareanwendung"@de, "Software Application"@en, "TRANSLATE ME"@<YOUR-NEW-ISO639-1-CODE> .
```

Vocabularies:
* https://raw.githubusercontent.com/acka47/lrmi-audience-role/master/educationalAudienceRole.ttl
* https://raw.githubusercontent.com/dini-ag-kim/hcrt/master/hcrt.ttl
* https://raw.githubusercontent.com/dini-ag-kim/hochschulfaechersystematik/master/hochschulfaechersystematik.ttl
* https://raw.githubusercontent.com/dini-ag-kim/value-lists/main/conditionsOfAccess.ttl

**external contributers:** Please attach these files to your Merge-Request/issue.

**OERSI-internal**: Please create a PullRequest directly in the corresponding github-repositories.

### Synonyms for Multilingual Search

**OERSI-internal**: we need to add the new language to the Synonyms-process (example-file and/or automatic-process). For this: add the new language code to the ansible-variable `internationalization_tool_oersi_output_languages`.

## Multilingual Search

---

**Experimental / under development**

---

We implemented a first, experimental feature to include translations of the OERSI keywords into other languages in the search. It can be activated via config in oersi-setup. Then, for example, the results of a search for a German keyword will also include the results of the English/Spanish/French/... keyword.

A tool ([internationalization-tool](https://gitlab.com/oersi/internationalization-tool)) provides the translations of the keywords (based on Wikidata-translations). From these translations a synonym file for elasticsearch is generated, which can be included in the configuration. An example for such a synonym file can be found [here](../ansible/roles/elasticsearch/files/synonyms-example.txt).

The feature can be enabled or disabled via toggle (ansible-variable `oerindex_features_use_synonyms` in [all.yml](../ansible/group_vars/all.yml)). If you change this configuration, the mapping will be adjusted and the index will be reindexed automatically by the setup. The synonym file will be placed in the OERSI configuration directory (usually `~/conf`) and have the filename `synonym.txt` (this will be linked into the Elasticsearch-config-dir by the setup). For testing purposes, the sample file can be used in the first phase of the feature development (set `elasticsearch_synonyms_file: "synonyms-example.txt"` and it will be copied by ansible). So, the following configuration will enable the feature using the example file:

```
oerindex_features_use_synonyms: true
elasticsearch_synonyms_file: "synonyms-example.txt"
```

For now, the tool has to be activated separately. So, the following configuration will enable the feature using automatic keyword-translations via the translation-tool:

```
oerindex_features_use_synonyms: true
internationalization_tool_install: "{{ oerindex_features_use_synonyms }}"
```

The synonyms are included during the Elasticsearch search (not during indexing). If there are changes to the synonym file, then the search analyzers need to be reloaded so that the changes are taken into account in the search. This can be done with the help of the script `reload-search_analyzer.sh`.
