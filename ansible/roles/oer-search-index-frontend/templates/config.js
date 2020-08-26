window['runTimeConfig'] = {
  ELASTIC_SEARCH: {
    URL: "{{ oerindex_backend_searchapi_url }}",
    CREDENCIAL: "",
    APP_NAME: "{{ elasticsearch_oer_index_alias_name }}"
  },
  LANGUAGE: "{{ oerindex_frontend_lang }}",
  GENERAL_CONFIGURATION: {
    MULTI_SELECT: {{oerindex_frontend_multi_select  | lower}},  // for multiple choice set false
    RESULT_PAGE_SIZE_OPTIONS: {{oerindex_frontend_page_size}},  // page size options configuration    
    NR_OF_RESULT_PER_PAGE: {{oerindex_frontend_nr_result_page_default}},  //  number of results to show per view. Defaults to 10.   
  }
}