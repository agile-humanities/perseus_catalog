xquery version "3.1";

module namespace catalog="http://perseus.tufts.edu/apps/PerseusCatalog/catalog";

(:
 : Module Name: Catalog Module
 :)
import module namespace config="http://perseus.tufts.edu/apps/PerseusCatalog/config" at "config.xqm";
import module namespace cts="http://perseus.tufts.edu/apps/PerseusCatalog/cts" at "cts.xqm";
declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/v2";


declare function catalog:work-records() {
    collection($config:data-root)//mods:mods
};

declare function local:cts-urns()
{
    let $hits := catalog:work-records()//mods:identifier[@type='ctsurn']
    for $hit in distinct-values($hits)
    return normalize-space($hit)
};


declare function local:bibrecord($ctsurn as xs:string) {
    collection($config:data-root)/mods:mods[mods:identifier[@type='ctsurn'] = $ctsurn]
};


declare function local:trim($arg as xs:string?) as xs:string
{
 replace(replace($arg,'\s+$',''),'^\s+','')
};


declare function catalog:name-string($name as element())
as xs:string
{
    let $primary := local:trim($name/mads:namePart[not(@type)][1])
    let $secondary := local:trim($name/mads:namePart[@type='termsOfAddress'][1])
    return 
        if ($secondary) then string-join(($primary, $secondary), ' ')
        else $primary
};


(: isolate access to the cite tables; they will be replaced. :)
declare function catalog:primary-work-id($group-work-id as xs:string)
as xs:string
{
    let $id :=
    xs:string(doc('/db/PerseusCatalogData/cite/works.xml')/works/work/work[cts:work-id(cts:object(.)) = $group-work-id])
    return
        if ($id) then $id
        else error((), "no primary-work-id found for |" || $group-work-id || '|')
};

declare function catalog:work-title($work-id as xs:string) {
    let $title := doc('/db/PerseusCatalogData/cite/works.xml')//work[work=$work-id]/title-eng
    return local:trim($title)
};

declare function catalog:works-by($authorid as xs:string) as element()? {
    collection($config:indexes)//worksby[@authorid = $authorid]
};

declare function catalog:works-by-old($authorid as xs:string) as element()* {
    let $rec := collection($config:data-root)//mads:identifier[.=$authorid]/ancestor::mads:mads
    let $related-work-ids := $rec/mads:extension/mads:identifier
    return
    <relatedWorks>{
    for $id in $related-work-ids
     let $modsids := collection($config:data-root)//mods:identifier[@type=$id/@type and . = $id]
    return 
        <relatedWork id="{$id}" type="{$id/@type}">
        {
          for $ids in $modsids
           let $group := normalize-space($ids/@displayLabel)
           group by $group
             return
              <grouping relation="{ if ($group) then $group else "primary"}">
              <relation>{$group}</relation>
              {
            for $id in $ids
             let $uniformTitle := normalize-space(xs:string($id/ancestor::mods:mods/mods:titleInfo[@type='uniform']))
             let $ctsurn := $id/ancestor::mods:mods/mods:identifier[@type='ctsurn']
             group by $uniformTitle              
              return
                <work id="{$id[1]/text()}" type="{$id[1]/@type}">
                 <label>{$uniformTitle}</label>
                     { for $urn in $ctsurn return
                        <expression ctsurn="{$urn}">
                          <label>{ $id/ancestor::mods:mods/mods:titleInfo[not(@type='uniform')][1]/mods:title/text()}</label>
                        </expression>
                     }
                </work>
              }
              </grouping>
        }
        </relatedWork>
        }</relatedWorks>
};

declare function catalog:works-by-older($authorid as xs:string) as element()* {
    let $rec := collection('/db/PerseusCatalogData/mads')//mads:identifier[.=$authorid]/ancestor::mads:mads
    let $work-ids :=
     for $id in $rec/mads:extension/mads:identifier
      let $matching-mods-ids := collection('/db/PerseusCatalogData/mods')//mods:identifier[. = $id]
       for $id in $matching-mods-ids/ancestor::mods:mods/mods:identifier[@type='ctsurn']
         let $ctso := cts:object($id)
       return cts:full-work-id($ctso)
      for $wid in distinct-values($work-ids)
      order by $wid
        return <work>{ $wid }</work>
};


declare function catalog:namespaces() {
    let $mods-namespaces := 
        for $id in collection($config:data-root)//mods:mods/mods:identifier[@type='ctsurn']
        return cts:namespace(cts:object($id))
    return distinct-values($mods-namespaces)
};

declare function catalog:authors() 
as element()+
{
    let $hits := collection($config:data-root)//mads:mads
    return $hits
};


declare function catalog:textgroups() 
as xs:string+
{
    let $hits :=
        for $urn in local:cts-urns()
        return cts:textgroup(cts:object($urn))
    return distinct-values($hits)
};



declare function catalog:author($authorid as xs:string)
as element()
{
    let $mads-rec := collection($config:data-root)//mads:identifier[. = $authorid]/ancestor::mads:mads
    let $mads-rec :=
        if (not($mads-rec))
        then 
            let $cite-rec-urn := doc('/db/PerseusCatalogData/cite/authors.xml')//author[canonical-id=$authorid]/urn
            return collection($config:data-root)//mads:identifier[. = $cite-rec-urn]/ancestor::mads:mads
        else $mads-rec
    return $mads-rec
};

declare function catalog:primary-author-id($mads-rec) {
    $mads-rec/mads:identifier[@type='citeurn']
};


declare function catalog:textgroups-in($namespace as xs:string) {
    let $hits :=
        for $urn in local:cts-urns()
        where cts:namespace(cts:object($urn)) = $namespace
        return cts:textgroup(cts:object($urn))
    return distinct-values($hits)    
};

declare function catalog:works-in($textgroup as xs:string) {
    let $hits :=
        for $urn in local:cts-urns()
        where cts:textgroup(cts:object($urn)) = $textgroup
        return cts:work-id(cts:object($urn))
    return distinct-values($hits)
};

declare function catalog:versions-of($ctsurn as xs:string) {
    let $work-cts-urn := cts:object($ctsurn)
    let $hits :=
        for $urn in local:cts-urns()
        let $cts-object := cts:object($urn)
        where cts:work-id($cts-object) = cts:work-id($work-cts-urn)
        return $urn
    return distinct-values($hits)
};
