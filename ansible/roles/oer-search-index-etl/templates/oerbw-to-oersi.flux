"https://www.oerbw.de/edu-sharing/eduservlet/sitemap?from=0"
| open-http
| oersi.SitemapReader(wait="500",urlPattern=".*/components/.*",findAndReplace="https://uni-tuebingen.oerbw.de/edu-sharing/components/render/(.*)`https://uni-tuebingen.oerbw.de/edu-sharing/rest/node/v1/nodes/-home-/$1/metadata?propertyFilter=-all-")
| open-http(accept="application/json")
| as-lines
| decode-json
| org.metafacture.metamorph.Metafix("

/* Set up the context, TODO: include from separate file */
do array('@context')
 add_field('','https://w3id.org/kim/lrmi-profile/draft/context.jsonld')
 do entity('')
  add_field('@language', 'de')
 end
end

/* Map/pick standard edu-sharing fields, TODO: include from separate file */
map(node.title, name)
map(node.preview.url, image)

do map(node.description, description)
  not_equals('')
end

/* Default ID: */
do map('node.ref.id', id)
  prepend('https://www.oerbw.de/edu-sharing/components/render/')
end

/* Replace default ID if we have a ccm:wwwurl */
map('node.properties.ccm:wwwurl[].1', id)

do array('mainEntityOfPage')
  do entity('')
    do map('node.ref.id', id)
      prepend('https://www.oerbw.de/edu-sharing/components/render/')
    end
    /* Add creation/modification date, converting dateTime (e.g. 2019-07-23T09:26:00Z) to date (2019-07-23) */
    do map('node.modifiedAt', 'dateModified')
      replace_all('T.+Z', '')
    end
    do map('node.createdAt', 'dateCreated')
      replace_all('T.+Z', '')
    end
    /* Add provider/source information to each resource description */
    do entity('provider')
      add_field('id','https://oerworldmap.org/resource/urn:uuid:4062c64d-b0ac-4941-95c2-8116f137326d')
      add_field('type','Service')
      add_field('name','ZOERR')
    end
  end
end

do array('about')
 do entity('')
  /* Build pseudo hochschulfaechersystematik URIs, TODO: implement mapping to hochschulfaechersystematik */
  do map('node.properties.ccm:taxonid[].1', 'id')
    not_equals('')
    replace_all('(^$)|(\\\\d+)', 'https://w3id.org/kim/hochschulfaechersystematik/$0')
  end
  /* TODO: with mapping mentioned above, use labels from hochschulfaechersystematik */
  do map('node.properties.ccm:taxonid_DISPLAYNAME[].1', 'prefLabel.de')
    not_equals('')
  end
 end
end

do array('creator')
 do entity('')
  add_field('type', 'Person')
  map('node.properties.ccm:lifecyclecontributer_authorFN[].1',name)
 end
end

do array('sourceOrganization')
 do entity('')
  add_field('type', 'Organization')
  do map('node.properties.ccm:university_DISPLAYNAME[].1', 'name')
    not_equals('')
  end
 end
end

do map('node.properties.virtual:licenseurl[].1', license)
  replace_all('/deed.*$', '')
end

do map('node.properties.cclom:general_language[].1', inLanguage)
  replace_all('_..$', '') /* remove country suffixes eg. _DE */
  replace_all('^$', 'de') /* empty strings default to 'de' */
  replace_all('unknown', 'de')
end

do map('node.properties.ccm:educationallearningresourcetype[].1', learningResourceType.id)
  lookup(
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
end

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