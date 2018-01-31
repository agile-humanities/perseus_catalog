xquery version "3.1";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://perseus.tufts.edu/apps/PerseusCatalog/config" at "config.xqm";
import module namespace catalog="http://perseus.tufts.edu/apps/PerseusCatalog/catalog" at "catalog.xqm";
import module namespace api="http://perseus.tufts.edu/apps/PerseusCatalog/api" at "api.xqm";
import module namespace cts="http://perseus.tufts.edu/apps/PerseusCatalog/cts" at "cts.xqm";
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace request = "http://exist-db.org/xquery/request";
import module namespace response = "http://exist-db.org/xquery/response";
import module namespace system = "http://exist-db.org/xquery/system";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace http = "http://expath.org/ns/http-client"; 
declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/v2";

declare function local:name-label($name as element()) as xs:string {
    if ($name/mads:namePart[@type='termsOfAddress'])
        then string-join(($name/mads:namePart[empty(@type)][1], $name/mads:namePart[@type='termsOfAddress']), ' ')
    else xs:string($name/mads:namePart[empty(@type)][1])
};

declare function local:version-label($urn as xs:string) as xs:string {
    let $mods := collection($config:data-root)//mods:identifier[@type='ctsurn' and .= $urn][1]/ancestor::mods:mods
    return $mods/mods:titleInfo[1]/mods:title[1]
};

declare function local:work-label($urn as xs:string) as xs:string {
    let $cite-entry := doc('/db/PerseusCatalogData/cite/works.xml')//work[. = $urn]/ancestor::work
    return
        if ($cite-entry) then
            $cite-entry[1]/title-eng[1]
        else "[No Title]"
};

<data> {
for $author in collection($config:data-root)//mads:mads
let $citeurn := xs:string($author/mads:identifier[@type='citeurn'][1])
let $label := if ($author/mads:authority/mads:name) then
                 local:name-label($author/mads:authority/mads:name[1])
              else "[no name]"
              
let $related-work-ids := $author/mads:extension/mads:identifier
let $workurns := 
    for $rid in $related-work-ids
    for $id in collection('/db/PerseusCatalogData/mods')//mods:identifier[. = $rid]/ancestor::mods:mods/mods:identifier[@type='ctsurn']
    return xs:string($id)

return
    <author citeurn="{ $citeurn }">
        <label>{ $label }</label>
        <works> { 
           for $urns in distinct-values($workurns)
           let $workid := cts:full-work-id(cts:object($urns))
           let $work-label := local:work-label($workid)
           group by $workid
           return
            <work ctsurn="{$workid}">
                <label>{ $work-label[1] }</label>
                { for $urn in $urns
                  let $label := local:version-label($urn)
                  return 
                    <edition ctsurn="{ $urn }">
                        <label>{ $label }</label>
                    </edition>  
                }
            </work>
        } </works>
    </author>
}</data>