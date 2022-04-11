import json
import rdflib

# helper script that loads remote preLabels for initial, manual creation


def get_json_from_file(file):
    with open(file) as json_file:
        return json.load(json_file)


def format_labels(url):
    g = rdflib.Graph()
    g.parse(url, format="turtle")
    label_pred = rdflib.URIRef('http://www.w3.org/2004/02/skos/core#prefLabel')
    output = {}

    for s in sorted(set(g.subjects(label_pred, None))):
        labels = {}
        for x in g.preferredLabel(s):
            l = x.__getitem__(1)
            language = l.language.replace("en-US", "en")
            labels[language] = str(l)
        output[str(s)] = labels

    return output


#format_labels('https://raw.githubusercontent.com/dini-ag-kim/hochschulfaechersystematik/master/hochschulfaechersystematik.ttl')
#format_labels('https://raw.githubusercontent.com/acka47/lrmi-audience-role/master/educationalAudienceRole.ttl')
#format_labels('https://raw.githubusercontent.com/dini-ag-kim/hcrt/master/hcrt.ttl')
#format_labels('https://raw.githubusercontent.com/dini-ag-kim/value-lists/main/conditionsOfAccess.ttl')
json_labels = get_json_from_file('labels-hochschulfaechersystematik.json')
data = format_labels('https://raw.githubusercontent.com/dini-ag-kim/hochschulfaechersystematik/21-ukrainische-label-hinzuf%C3%BCgen/hochschulfaechersystematik.ttl')

for key in json_labels:
    if key not in data:
        data[key] = json_labels[key]
    else:
        for lng in json_labels[key]:
            if lng not in data[key]:
                data[key][lng] = json_labels[key][lng]

print(json.dumps(data, sort_keys=True, indent=2, ensure_ascii=False))
