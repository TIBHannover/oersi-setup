"https://www.oerbw.de/edu-sharing/eduservlet/sitemap?from=0"
| open-http
| oersi.SitemapReader(wait="1000",limit="100",urlPattern=".*/components/.*",findAndReplace="https://uni-tuebingen.oerbw.de/edu-sharing/components/render/(.*)`https://uni-tuebingen.oerbw.de/edu-sharing/rest/node/v1/nodes/-home-/$1/metadata?propertyFilter=-all-")
| open-http(accept="application/json")
| as-lines
| decode-json
| org.metafacture.metamorph.Metafix("

/* Set up the context, TODO: include from separate file */
add_field('@context.id','@id')
add_field('@context.type','@type')
add_field('@context.@vocab','http://schema.org/')

/* Map/pick standard edu-sharing fields, TODO: include from separate file */
map(node.title, name)
map(node.description, description)
map(node.preview.url, image)

replace_all('node.properties.cclom:location[].1','ccrep://.*?de/(.+)', 'https://www.oerbw.de/edu-sharing/components/render/$1')
map('@node.properties.cclom:location[].1', id)

/* Take the contentUrl as default: */
map(node.contentUrl, mainEntityOfPage.id)
/* But overwrite with ID (contentUrl has session ID, expires). TODO: node.downloadUrl or node.properties.ccm:wwwurl[].1, but without session ID? */
map('@node.properties.cclom:location[].1', mainEntityOfPage.id)

/* Build pseudo hochschulfaechersystematik URIs, TODO: implement mapping to hochschulfaechersystematik */
replace_all('node.properties.ccm:taxonid[].1', '(^$)|(\\\\d+)', 'https://w3id.org/kim/hochschulfaechersystematik/$0')
map('@node.properties.ccm:taxonid[].1', 'about[]..id')
/* TODO: with mapping mentioned above, use labels from hochschulfaechersystematik */
map('node.properties.ccm:taxonid_DISPLAYNAME[].1', 'about[]..preflabel.de')

do combine('@fullName', '${first} ${last}')
  map(node.createdBy.firstName,first)
  map(node.createdBy.lastName,last)
end
map('@fullName','creator[]..name')

/* Use institution information available via the API for testing. TODO: support both Person and Organization */
add_field('creator[]..type', 'Organization')
map('node.properties.ccm:university[].1', 'creator[]..name')

replace_all('node.properties.virtual:licenseurl[].1', '/deed.*$', '')
map('@node.properties.virtual:licenseurl[].1', license)

/* TODO: also handle empty language field, currently skips records */
replace_all('node.properties.cclom:general_language[].1', '_..$', '')
map('@node.properties.cclom:general_language[].1', inLanguage)

lookup('node.properties.ccm:educationallearningresourcetype[].1',
/* TODO: support lookup in CSV file */
Kurs: 'https://w3id.org/kim/hcrt/course',
course: 'https://w3id.org/kim/hcrt/course',
image: 'https://w3id.org/kim/hcrt/image',
video: 'https://w3id.org/kim/hcrt/video',
reference: 'https://w3id.org/kim/hcrt/index',
presentation: 'https://w3id.org/kim/hcrt/slide',
schoolbook: 'https://w3id.org/kim/hcrt/text',
script: 'https://w3id.org/kim/hcrt/script',
worksheet: 'https://w3id.org/kim/hcrt/worksheet',
__default: 'https://w3id.org/kim/hcrt/other')

map('@node.properties.ccm:educationallearningresourcetype[].1', learningResourceType.id)

/* Enable to see what is available via the API: */
/* map(_else) */

")
| encode-json
| oersi.FieldMerger
| oersi.JsonValidator("https://dini-ag-kim.github.io/lrmi-profile/draft/schemas/schema.json")
| object-tee | {
    write(FLUX_DIR + "oerbw-metadata.json", header="[\n", footer="\n]", separator=",\n")
  }{
    oersi.OersiWriter("{{ oerindex_backend_metadataapi_url }}",
      user="{{ oerindex_backend_oermetadata_manage_user }}", pass="{{ oerindex_backend_oermetadata_manage_password }}", log=FLUX_DIR + "oerbw-responses.json")
};
;