import json
import rdflib

# helper script that loads remote preLabels for initial, manual creation


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

    print(json.dumps(output, sort_keys=True, indent=2, ensure_ascii=False))


#format_labels('https://raw.githubusercontent.com/dini-ag-kim/hochschulfaechersystematik/master/hochschulfaechersystematik.ttl')
#format_labels('https://raw.githubusercontent.com/acka47/lrmi-audience-role/master/educationalAudienceRole.ttl')
#format_labels('https://raw.githubusercontent.com/dini-ag-kim/hcrt/master/hcrt.ttl')
format_labels('https://raw.githubusercontent.com/dini-ag-kim/value-lists/main/conditionsOfAccess.ttl')
