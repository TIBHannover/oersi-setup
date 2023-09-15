window['runTimeConfig'] = {
  BACKEND_API: {
    BASE_URL: "{{ oerindex_public_base_url }}",
    PATH_CONTACT: "{{ oerindex_backend_contactapi_root_path }}",
    PATH_LABEL: "{{ oerindex_backend_labelapi_root_path }}",
    PATH_SEARCH: "{{ oerindex_backend_searchapi_root_path }}"
  },
  ELASTIC_SEARCH_INDEX_NAME: "{{ elasticsearch_oer_index_internal_alias_name }}",
  GENERAL_CONFIGURATION: {
    AVAILABLE_LANGUAGES: {{ oerindex_frontend_available_languages  | default([], true) | to_json(ensure_ascii=False) }},
    PUBLIC_URL: "{{ oerindex_public_base_url }}{{ oerindex_public_base_path }}",
    RESULT_PAGE_SIZE_OPTIONS: {{ oerindex_frontend_page_size  | default([], true) | to_json(ensure_ascii=False) }},
    NR_OF_RESULT_PER_PAGE: {{oerindex_frontend_nr_result_page_default}},
    HEADER_LOGO_URL: "{{ oerindex_frontend_header_logo_url }}",
    THEME_COLORS: {{ oerindex_frontend_theme_colors }},
    THEME_COLORS_DARK: {{ oerindex_frontend_theme_colors_dark }},
    PRIVACY_POLICY_LINK: {{oerindex_frontend_custom_cookie_links | default([], true) | to_json(ensure_ascii=False,indent=0) }},
    EXTERNAL_INFO_LINK: {{oerindex_frontend_custom_info_links| default({}, true) | to_json(ensure_ascii=False,indent=0) }},
    I18N_CACHE_EXPIRATION: {{ oerindex_frontend_i18n_cache_expiration }},
    I18N_DEBUG: {{ oerindex_frontend_i18n_debug }},
    TRACK_TOTAL_HITS: {{ oerindex_frontend_track_total_hits }},
    ENABLED_FILTERS: {{oerindex_frontend_enabled_filters | default([], true) | to_json(ensure_ascii=False) }},
    HIERARCHICAL_FILTERS: [
{% for filter_conf in (oerindex_frontend_hierarchical_vocab_filters | default([], true)) %}
      {componentId: "{{ filter_conf.filterId }}", schemeParentMap: "/vocabs/{{ filter_conf.vocabName }}-parentMap.json"}{{ ", " if not loop.last else "" }}
{% endfor %}
    ],
    AGGREGATION_SEARCH_COMPONENTS: {{ oerindex_frontend_aggregation_search_components | default([], true) | to_json(ensure_ascii=False) }},
    AGGREGATION_SEARCH_DEBOUNCE: {{ oerindex_frontend_aggregation_search_debounce }},
    AGGREGATION_SEARCH_MIN_LENGTH: {{ oerindex_frontend_aggregation_search_min_length }},
    FEATURES: {
      DARK_MODE: {{ oerindex_frontend_features_dark_mode }},
      CHANGE_FONTSIZE: {{ oerindex_frontend_features_change_font_size }},
      EMBED_OER: {{ oerindex_frontend_features_embed_oer }},
      OERSI_THUMBNAILS: {{ oerindex_frontend_features_oersi_thumbnails }},
      SCROLL_TOP_BUTTON: {{ oerindex_frontend_features_scroll_top_button }},
      SHOW_ENCODING_DOWNLOADS: {{ oerindex_frontend_features_show_encoding_downloads }},
      SHOW_RATING: {{ oerindex_frontend_features_show_rating }},
      SHOW_VERSIONS: {{ oerindex_frontend_features_show_versions }}
    }
  }
}
