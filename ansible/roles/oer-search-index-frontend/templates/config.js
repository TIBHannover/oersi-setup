window['runTimeConfig'] = {
  ELASTIC_SEARCH: {
    URL: "{{ oerindex_backend_searchapi_url }}",
    CREDENTIALS: "",
    APP_NAME: "{{ elasticsearch_oer_index_internal_alias_name }}"
  },
  GENERAL_CONFIGURATION: {
    PUBLIC_URL: "{{ oerindex_public_base_url }}{{ oerindex_public_base_path }}",
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
    I18N_DEBUG: {{ oerindex_frontend_i18n_debug }},
    TRACK_TOTAL_HITS: {{ oerindex_frontend_track_total_hits }}, // track number of total hits from elasticsearch - see https://www.elastic.co/guide/en/elasticsearch/reference/7.10/search-your-data.html#track-total-hits
    FEATURES: {
      EMBED_OER: {{ oerindex_frontend_features_embed_oer }}, // feature toggle: use "embed-oer" button
      SCROLL_TOP_BUTTON: {{ oerindex_frontend_features_scroll_top_button }}, // feature toggle: use "scroll-to-top" button
      USE_RESOURCE_PAGE: {{ oerindex_frontend_features_use_resource_page }} // feature toggle: use a single html-page per resource
    }
  }
}
