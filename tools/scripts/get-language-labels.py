import requests, sys, json

# usage:
# python get-language-labels.py en
# => to get all english labels for iso639-1 codes

query = '''
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX p: <http://www.wikidata.org/prop/>
PREFIX pq: <http://www.wikidata.org/prop/qualifier/>

SELECT DISTINCT ?code ?label WHERE {
  ?item p:%s ?codeStatement .
  ?codeStatement ps:%s ?code .
  FILTER NOT EXISTS { ?codeStatement pq:P582 ?end . }
  ?item rdfs:label ?label .
  FILTER (LANG(?label) = "%s")
} ORDER BY ASC(?code)
''' % ("P218", "P218", sys.argv[1])

url = 'https://query.wikidata.org/bigdata/namespace/wdq/sparql'
data = requests.get(url, params={'query': query, 'format': 'json'}).json()

result = {}
for binding in data["results"]["bindings"]:
    result[u".".join(binding["code"]["value"].split("-")).strip()] = binding["label"]["value"].strip()

print(json.dumps(result, sort_keys=True, indent=2, ensure_ascii=False).encode('utf8'))
