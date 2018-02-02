xquery version "3.1";

module namespace api="http://perseus.tufts.edu/apps/PerseusCatalog/api";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://perseus.tufts.edu/apps/PerseusCatalog/config" at "config.xqm";
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace request = "http://exist-db.org/xquery/request";
import module namespace response = "http://exist-db.org/xquery/response";
import module namespace system = "http://exist-db.org/xquery/system";
import module namespace catalog="http://perseus.tufts.edu/apps/PerseusCatalog/catalog" at "catalog.xqm";
import module namespace cts="http://perseus.tufts.edu/apps/PerseusCatalog/cts" at "cts.xqm";


declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace http = "http://expath.org/ns/http-client"; 
declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/v2";
(::::::: Resource Functions :::::::)

declare
 %rest:GET
 %rest:path("/PerseusCatalog/ping")
 %output:method("json")
 %rest:produces("application/json")
function api:ping() {
    <rest:response>
        <http:response>
            <http:response status="200"/>
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>
};

declare
 %rest:GET
 %rest:path("/PerseusCatalog/authors")
 %rest:query-param("start", "{$start}", 0)
 %rest:query-param("rows", "{$rows}", 10)
 %output:method("json")
 %rest:produces("application/json")
function api:authors($start, $rows) {
    let $authors := catalog:authors()
    let $return_set :=
        if ($rows = 'all') then
            $authors
        else
            subsequence($authors, $start, $rows)
    let $base_uri := req:scheme() || "://" || 
                            req:header('Host') ||
                            req:uri()    
    return (
    <rest:response>
        <http:response>
            <http:response status="200"/>
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>,
    <result>
    <responseHeader>
        <status>0</status>
    </responseHeader>
    <response>
    <numfound>{count($authors)}</numfound>
    <start>{$start}</start>
    <links>
        <self>{ 
            if (req:query())
            then string-join(($base_uri, req:query()), '?')
            else $base_uri
        }
        </self>
        <first>{
            $base_uri || '?start=0&amp;rows=' || $rows
        } </first>
        <last>{
            $base_uri || '?start=' || count($authors) - xs:int($rows) || '&amp;rows=' || $rows
        }</last>
        <next>{ 
            if ($rows = 'all' or xs:int($start) + 1 > count($authors)) then ()
            else 
            $base_uri ||'?start=' || xs:int($start) + xs:int($rows) + 1 || '&amp;rows=' || $rows
            }</next>
        <previous>{
            if (xs:int($start) - xs:int($rows) <= 0)
            then ()
            else $base_uri || '?start=' || xs:int($start) - xs:int($rows) -1 || '&amp;rows=' || $rows
        }</previous>
    </links>
    {
        for $author in $return_set
        return
        <docs>
        <id>{ xs:string($author/mads:identifier[@type='citeurn']) }</id>
        </docs>
    }
    </response>
    </result>
    )
};

declare
 %rest:GET
 %rest:path("/PerseusCatalog/authors/{$authorid}")
 %output:method("json")
 %rest:produces("application/json")
function api:author($authorid) {
    let $author-rec := catalog:author($authorid)
    let $primary-author-id := xs:string(catalog:primary-author-id($author-rec))
    return (
    <rest:response>
        <http:response>
            <http:response status="200"/>
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>,
    <result>
        <responseHeader>
            <authorid>{ $primary-author-id }</authorid>
        </responseHeader>
        <response>
            { api:author-response($author-rec) }
        </response>
    </result>
    )
};

declare
 %rest:GET
 %rest:path("/PerseusCatalog/authors/{$authorid}")
 %output:method("xml")
 %rest:produces("application/rdf")
function api:author-rdf($authorid) {
    let $author-rec := catalog:author($authorid)
    let $primary-author-id := xs:string(catalog:primary-author-id($author-rec))
    let $xsl := doc($config:app-root || "/resources/xsl/rdf.xsl")
    return (
        <rest:response>
        <http:response>
            <http:response status="200"/>
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>,
    <result>{ api:author-response($author-rec) }</result>
    )
};


declare
 %rest:GET
 %rest:path("/PerseusCatalog/namespaces")
 %output:method("json")
 %rest:produces("application/json")
function api:namespaces() {
    let $namespaces := catalog:namespaces()
    return (
    <rest:response>
        <http:response>
            <http:response status="200"/>
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>,
    <result>
        <responseHeader>
            <count>{ count($namespaces) }</count>
        </responseHeader>
        <response> {
            for $namespace in $namespaces
            return <namespaces>{ $namespace }</namespaces>
        } </response>
    </result>
    )
};

declare
 %rest:GET
 %rest:path("/PerseusCatalog/namespaces/{$namespace}")
 %output:method("json")
 %rest:produces("application/json")
function api:namespace($namespace) {
    let $textgroups := catalog:textgroups-in($namespace)
    return (
    <rest:response>
        <http:response>
            <http:response status="200"/>
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>,
    <result>
        <responseHeader>
            <count>{ count($textgroups) }</count>
        </responseHeader>
        <response> {
            for $textgroup in $textgroups
            return <textgroups>{ $textgroup }</textgroups>
        } </response>
    </result>
    )
};

declare
 %rest:GET
 %rest:path("/PerseusCatalog/textgroups")
 %output:method("json")
 %rest:produces("application/json")
function api:textgroups() {
    let $textgroups := catalog:textgroups()
    return (
    <rest:response>
        <http:response>
            <http:response status="200"/>
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>,
    <result>
        <responseHeader>
            <count>{ count($textgroups) }</count>
        </responseHeader>
        <response> {
            for $textgroup in $textgroups
            return <textgroups>{ $textgroup }</textgroups>
        } </response>
    </result>
    )
};

declare
 %rest:GET
 %rest:path("/PerseusCatalog/textgroups/{$textgroup}")
 %output:method("json")
 %rest:produces("application/json")
function api:textgroup($textgroup) {
    let $works := catalog:works-in($textgroup)
    return (
    <rest:response>
        <http:response>
            <http:response status="200"/>
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>,
    <result>
        <responseHeader>
            <count>{ count($works) }</count>
        </responseHeader>
        <response> {
            for $work in $works
            return <works>{ $work }</works>
        } </response>
    </result>
    )
};


declare
 %rest:GET
 %rest:path("/PerseusCatalog/works")
 %output:method("json")
 %rest:produces("application/json")
 %rest:query-param("title", "{$title}")
 %rest:query-param("language", "{$language}")
function api:works-with-query($title, $language) as item()*
{
    let $work-set :=
        if ($language) then
            catalog:work-records()[.//mods:languageTerm=$language]
        else catalog:work-records()
    let $hits :=
        if ($title) then
            $work-set[ft:query(.//mods:title, $title)]
        else $work-set
    return (
        <rest:response>
            <http:response status="200">
                <http:header name="Access-Control-Allow-Origin" value="*"/>            
            </http:response>
        </rest:response>,
        <result>
            <responseHeader>
                <title-query>{ $title }</title-query>
                <language-query>{ $language }</language-query>
                <hit-count>{ count($hits) }</hit-count>
            </responseHeader>
            <response>
                {
                    for $hit in $hits
                    return
                        <works>{ xs:string($hit/mods:identifier[@type='ctsurn'][1]) }</works>
                }
            </response>
        </result>
        )
};

declare
 %rest:GET
 %rest:path("/PerseusCatalog/works/{$workid}")
 %output:method("json")
 %rest:produces("application/json")
function api:works($workid as xs:string) {
    let $primary-id := catalog:primary-work-id($workid)
    let $versions := catalog:versions-of($primary-id)
    return (
    <rest:response>
        <http:response>
            <http:response status="200"/>
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>,
    <result>
        <responseHeader>
            <primary-workid>{ $primary-id }</primary-workid>
            <version-count>{ count($versions) }</version-count>
        </responseHeader>
        <response> { api:work-response($primary-id) }</response>
    </result>
    )
};


declare
 %rest:GET
 %rest:path("/PerseusCatalog/versions/{$versionid}")
 %rest:produces("application/json")
 %output:method("json")
 function api:versions($versionid as xs:string) {
    let $response-body := api:version-info($versionid)
    return (
    <rest:response>
        <http:response>
            <http:response status="200"/>
            <http:header name="Access-Control-Allow-Origin" value="*"/>
        </http:response>
    </rest:response>,
    <result>
        <responseHeader>
        </responseHeader>
        <response> { $response-body }</response>
    </result>
    )
 };


declare function api:author-response($author-rec as item()) as item() {
           <author>
                <id>{ xs:string($author-rec/mads:identifier[@type='citeurn']) }</id>
                <name>
                    <authorized>{
                        if ($author-rec/mads:authority/mads:name) then
                          catalog:name-string($author-rec/mads:authority/mads:name) 
                        else "[unauthorized]"
                    }</authorized>
                    {
                        for $variant in $author-rec/mads:variant/mads:name
                        return <variants>{ catalog:name-string($variant) }</variants>
                    }
                </name>                
                {
                    for $url in $author-rec/mads:url
                    return
                        <links>
                            <label>{ xs:string($url/@displayLabel) }</label>
                            <url>{ xs:string($url) }</url>
                        </links>
                }
                {
                    for $id in $author-rec/mads:identifier
                    return
                        <ids>
                            <type>{ xs:string($id/@type) }</type>
                            <value>{ xs:string($id) }</value>
                        </ids>
                }
                {
                   catalog:works-by(xs:string($author-rec/mads:identifier[@type='citeurn']))
                }
                {
                    for $foa in $author-rec/mads:fieldOfActivity
                    return
                        <fieldsOfActivity>{ normalize-space($foa/text()) }</fieldsOfActivity>
                 }
            </author>    
};

declare function api:textgroup-response($textgroup-rec as item()) as item() {
    let $works := catalog:works-in(cts:textgroup(cts:object($textgroup-rec/textgroup)))
    return
        <textgroup>
            <ctsurn>{ xs:string($textgroup-rec/textgroup) }</ctsurn>
            <title>{ $textgroup-rec/groupname-eng }</title>,
            {
                for $work in $works
                let $work-id := catalog:primary-work-id($work)
                let $title := catalog:work-title($work-id)
                return <works>
                            <id>{ $work-id }</id>
                            <urn>{ $work }</urn>
                            <title>{ $title }</title>
                </works>
            }
        </textgroup>
};

declare function api:work-response($workid as xs:string) as item() {
    let $versions := catalog:versions-of($workid)
    return
        <work>
            <title>{ catalog:work-title($workid) }</title>
            {
                for $version in $versions
                return <versions>{ api:version-info($version) }</versions>
            }            
        </work>
};


declare function api:version-info($versionid as xs:string) as item() {
    let $mods-rec := 
        collection($config:data-root)//mods:identifier[. = $versionid]/ancestor::mods:mods
    let $xsl := doc($config:app-root || "/resources/xsl/version-info.xsl")
    return 
        transform:transform($mods-rec, $xsl, ())
};


declare function api:version-rec($versionid as xs:string) as item() {
    collection($config:data-root)//mods:identifier[. = $versionid]/ancestor::mods:mods
};
