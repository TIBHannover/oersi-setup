window['runTimeConfig'] = {
  ELASTIC_SEARCH: {
    URL: "{{ oerindex_backend_searchapi_url }}",
    CREDENTIALS: "",
    APP_NAME: "{{ elasticsearch_oer_index_internal_alias_name }}"
  },
  GENERAL_CONFIGURATION: {
    RESULT_PAGE_SIZE_OPTIONS: {{oerindex_frontend_page_size}},  // page size options configuration    
    NR_OF_RESULT_PER_PAGE: {{oerindex_frontend_nr_result_page_default}},  //  number of results to show per view. Defaults to 10.
    /**
     * Accept a list of objects 
     * example:
     * {'path': 'public/{folderName}/{languageCode}/{fileName}.html', 'language': '{languageCode}'}
     * 
     */
    PRIVACY_POLICY_LINK: {{oerindex_frontend_custom_cookie_links | default([], true) | to_json(ensure_ascii=False,indent=0) }},
    I18N_CACHE_EXPIRATION: {{ oerindex_frontend_i18n_cache_expiration }}, // expiration time of the i18n translation cache storage
    TRACK_TOTAL_HITS: {{ oerindex_frontend_track_total_hits }}, // track number of total hits from elasticsearch - see https://www.elastic.co/guide/en/elasticsearch/reference/7.10/search-your-data.html#track-total-hits
    FEATURES: {
      EMBED_OER: {{ oerindex_frontend_features_embed_oer }} // feature toggle: use "embed-oer" button
    },
    EMBED_MEDIA_MAPPING: [ // mappings from source url to embedding-code for media
{% for mapping in oerindex_frontend_embed_media_mapping %}      {
        regex: "{{ mapping.regex }}",
        html: (match) => `{{ mapping.html }}`
      }{{ "," if not loop.last else "" }}
{% endfor %}
    ]
  }
}
