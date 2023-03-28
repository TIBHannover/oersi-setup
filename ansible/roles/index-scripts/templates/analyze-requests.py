import functools
import json
import logging
import logging.config
import netrc
import requests
import urllib
import sys


logging.basicConfig(format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",level=logging.INFO)
es_url = "http://{{ elasticsearch_host }}:{{ elasticsearch_port }}"
netrc_file = "{{ base_dir }}/conf/oer_index_access"
netrc_auth = netrc.netrc(netrc_file).authenticators("{{ elasticsearch_host }}")
es_auth = (netrc_auth[0], netrc_auth[2])


def flatten(l):
    if len(l) == 0:
        return l
    if isinstance(l[0], list):
        return flatten(l[0]) + flatten(l[1:])
    return l[:1] + flatten(l[1:])


def get_all_from_json(json, field):
    if json is None:
        return None
    fields = field.split(".")
    if isinstance(json, list):
        return flatten(list(filter(None, map(lambda x: get_all_from_json(x, field), json))))
    if fields[0] in json:
        value = json[fields[0]]
        if len(fields) > 1:
            return get_all_from_json(value, ".".join(fields[1:]))
        else:
            return [value]
    return None


def analyze_record(record):
    request_analysis = {
        "searchTerms": determine_search_terms(record)
    }
    if request_analysis["searchTerms"]:
        update_request_analysis(record, request_analysis)


def determine_search_terms(record):
    search_terms = []
    if "urlRequestQueryString" in record["_source"]:
        params = urllib.parse.parse_qs(record["_source"]["urlRequestQueryString"])
        if "q" in params and params["q"] is not None:
            search_terms += params["q"]
    if "body" in record["_source"]:
        body_json = json.loads(record["_source"]["body"])
        t = get_all_from_json(body_json, "query.bool.must.bool.must.bool.should.multi_match.query")
        search_terms += t if t is not None else []
    return list(set(filter(None, search_terms)))


def update_request_analysis(record, request_analysis):
    query = {
        "doc": {
            "requestAnalysis": request_analysis
        }
    }
    requests.post(es_url + "/" + record["_index"] + "/_update/" + record["_id"], auth=es_auth, json=query)


def analyze_requests(index_name="oersi_backend_elasticsearch_request_log"):
    logging.info("Starting request log analysis for index %s", index_name)
    pit_response = requests.post(es_url + "/" + index_name + "/_pit?keep_alive=1m", auth=es_auth)
    if pit_response.status_code != 200:
        logging.info("Unable to create PIT for %s - does the index exist?", index_name)
        return
    pit_id = pit_response.json()["id"]
    pit_clause = { "id": pit_id, "keep_alive": "1m"}

    counter = 0
    items_per_request = 50
    last_sort = None
    while True:
        search_query = {"size": items_per_request, "sort": [{"timestamp": "asc"}, {"_id":"asc"}], "pit": pit_clause}
        if last_sort:
            search_query["search_after"] = last_sort
        search_response = requests.post(es_url + "/_search", json=search_query, auth=es_auth)
        search_hits = search_response.json()["hits"]["hits"]
        if not search_hits:
            break
        for r in search_hits:
            analyze_record(r)
            counter += 1
        last_sort = search_hits[-1]["sort"]

    requests.delete(es_url + "/_pit", json={"id": pit_id}, auth=es_auth)
    logging.info("Finished request log analysis. #analyzed records: %s", counter)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        analysis_date = sys.argv[1]
        analyze_requests(index_name="oersi_backend_elasticsearch_request_log-" + analysis_date)
    else:
        #analyze_requests(es_auth)
        logging.info("Please specify the date for which to process the request-analysis (format YYYY-mm-DD)")
