import logging
import logging.config
import netrc
import requests


logging.basicConfig(format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",level=logging.INFO)
es_url = "http://{{ elasticsearch_host }}:{{ elasticsearch_port }}"
netrc_file = "{{ base_dir }}/conf/oer_index_access"
netrc_auth = netrc.netrc(netrc_file).authenticators("{{ elasticsearch_host }}")
es_auth = (netrc_auth[0], netrc_auth[2])
cleanup_limit = 100


def has_valid_http_status_code(url):
    try:
        resp = requests.head(url)
        return resp.ok
    except Exception as err:
        return False


def remove_resource(elasticsearch_id):
    requests.delete(es_url + "/{{ elasticsearch_oer_index_alias_name }}/_doc/" + elasticsearch_id, auth=es_auth)
    requests.delete(es_url + "/{{ elasticsearch_oer_index_internal_alias_name }}/_doc/" + elasticsearch_id, auth=es_auth)


def cleanup_inaccessible_oersi_resources():
    oersi_query_params = {"query":{"match_all":{}}, "size": cleanup_limit, "_source": "id"}
    oersi_data_resp = requests.post(es_url + "/{{ elasticsearch_oer_index_internal_alias_name }}/_search", json=oersi_query_params, auth=es_auth)
    for data in oersi_data_resp.json()["hits"]["hits"]:
        resource_url = data["_source"]["id"]
        if has_valid_http_status_code(resource_url):
            logging.info("Resource ok: " + resource_url)
        else:
            logging.info("Resource not accessible -> removing: " + resource_url)
            remove_resource(data["_id"])


if __name__ == "__main__":
    cleanup_inaccessible_oersi_resources()
