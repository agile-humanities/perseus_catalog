xquery version "3.1";

module namespace app="http://perseus.tufts.edu/apps/PerseusCatalog/app";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://perseus.tufts.edu/apps/PerseusCatalog/config" at "config.xqm";
import module namespace catalog="http://perseus.tufts.edu/apps/PerseusCatalog/catalog" at "catalog.xqm";
import module namespace api="http://perseus.tufts.edu/apps/PerseusCatalog/api" at "api.xqm";
import module namespace rest = "http://exquery.org/ns/restxq";
import module namespace request = "http://exist-db.org/xquery/request";
import module namespace response = "http://exist-db.org/xquery/response";
import module namespace system = "http://exist-db.org/xquery/system";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace http = "http://expath.org/ns/http-client"; 
declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mads="http://www.loc.gov/mads/v2";

(:::::::::: App Functions ::::::::::)

(::::: Author functions :::::)

declare function app:author-index($node as node(), $model as map(*))
{
    let $hits := catalog:authors()
    return
    <div>
        <header>
            <h3>total count: {count($hits)}</h3>
        </header>
        <ul>
            {
                for $hit in $hits
                let $label := 
                    if (count($hit/mads:authority/mads:name) = 1) then
                      catalog:name-string($hit/mads:authority[1]/mads:name[1])
                    else if (count($hit/mads:authority/mads:name) = 0) then
                    "[no name]"
                    else "bad name"
                let $id := $hit/mads:identifier[@type='citeurn']
                order by $label
                return 
                    <li>
                        <a href="authors.html?id={$id}" title="{$id}">{ $label }</a>
                    </li>
            }          
        </ul>
    </div>
};

declare function app:authors-list($node as node(), $model as map(*), $q as xs:string?)
{
    let $hits :=
        if ($q) then
            collection($config:data-root)//mads:name[ft:query(., $q)]/ancestor::mads:mads
        else ()
    return
        if ($hits) then
        <ul>
            {
                for $hit in $hits
                let $label := 
                    if ($hit/mads:authority/mads:name) then
                      catalog:name-string($hit/mads:authority[1]/mads:name[1])
                    else "[no name]"
                let $id := $hit/mads:identifier[@type='citeurn']
                order by $label
                return 
                    <li>
                        <a href="authors.html?id={$id}">{ $label }</a>
                    </li>
            }
        </ul>
        else ()
};

declare
 %templates:wrap
function app:selected-author($node as node(), $model as map(*), $id as xs:string?)
{
    let $selected-author:=
        if ($id) then
            collection($config:data-root)//mads:identifier[@type='citeurn' and . = $id]/ancestor::mads:mads
        else ()
    return
        if ($selected-author) then
            let $xsl := doc($config:app-root || "/resources/xsl/author-chunk.xsl")
            return transform:transform(api:author-response($selected-author), $xsl, ())
        else ()
};

declare function app:get-authors($node as node(), $model as map(*), $id as xs:string?)
as map(*)
{
    let $selected-author:=
    if ($id) then
        collection($config:data-root)//mads:identifier[@type='citeurn' and . = $id]/ancestor::mads:mads
    else ()
    return map { 'authors' : catalog:authors(), 'selected-author' : $selected-author }
};


(::::: Work functions :::::)

declare function app:work-index($node as node(), $model as map(*))
{
    let $hits := doc('/db/PerseusCatalogData/cite/works.xml')/works/work
    return
        <div>
            <header>
                <h3>total count: {count($hits)}</h3>
            </header>
            <ul>
            {
                for $hit in $hits
                let $label := xs:string($hit/title-eng)
                let $id    := xs:string($hit/work)
                order by $label
                return
                        <li>
                            <a href="works.html?id={$id}" title="{$id}">{ $label }</a>
                        </li>
            }
            </ul>
            </div>
};

declare
 %templates:wrap
function app:selected-work($node as node(), $model as map(*), $id as xs:string?)
{
    let $xsl := doc($config:app-root || "/resources/xsl/work-chunk.xsl")
    let $hit :=
        if ($id) then
            doc('/db/PerseusCatalogData/cite/works.xml')//work[. = $id]/ancestor::work
        else ()
    return
        if ($hit) then
            transform:transform(api:work-response($hit/work), $xsl, ())
        else ()
};

declare function app:get-works($node as node(), $model as map(*), $id as xs:string?)
as map(*)
{
    let $work-cite-records := doc('/db/PerseusCatalogData/cite/works.xml')/works/work
    let $selected-work :=
        if ($id) then
            doc('/db/PerseusCatalogData/cite/works.xml')//work/work[. = $id]
        else ()
    return map {  'works' : $work-cite-records, 'selected-work' : $selected-work }
};

declare function app:works-list($node as node(), $model as map(*), $q as xs:string?)
{
    let $xsl := doc($config:app-root || "/resources/xsl/cite.xsl")
    let $hits := 
        if ($q) then
            doc('/db/PerseusCatalogData/cite/works.xml')//work[ft:query(title-eng, $q)]
        else ()
    return
        if ($hits) then
        <ul>
            {
                for $hit in $hits
                order by $hit/title-eng
                return transform:transform($hit, $xsl, ())
            }
        </ul>
        else ()
};


(::::: Textgroup functions :::::)


declare function app:textgroup-index($node as node(), $model as map(*))
{
    let $hits := doc('/db/PerseusCatalogData/cite/textgroups.xml')/textgroups/textgroup
    return
        <div>
            <header>
                <h3>total count: {count($hits)}</h3>
            </header>
            <ul>
            {
                for $hit in $hits
                let $label := 
                    if (string-length(normalize-space($hit/groupname-eng)) > 0) then
                       normalize-space($hit/groupname-eng)
                    else "[No Label]"
                let $id    := normalize-space(xs:string($hit/textgroup))
                order by $label
                return
                        <li>
                            <a href="textgroups.html?id={$id}" title="{$id}">{ $label }</a>
                        </li>
            }
            </ul>
            </div>
};


declare
 %templates:wrap
function app:selected-textgroup($node as node(), $model as map(*), $id as xs:string?)
{
    let $xsl := doc($config:app-root || "/resources/xsl/textgroup-chunk.xsl")
    let $hit :=
        if ($id) then
            doc('/db/PerseusCatalogData/cite/textgroups.xml')//textgroup[. = $id]/ancestor::textgroup
        else ()
    return
        if ($hit) then
            transform:transform(api:textgroup-response($hit), $xsl, ())
        else ()
};

declare function app:get-textgroups($node as node(), $model as map(*), $id as xs:string?)
as map(*)
{
    let $textgroup-cite-records := doc('/db/PerseusCatalogData/cite/textgroups.xml')/textgroups/textgroup
    let $hit :=
        if ($id) then
            doc('/db/PerseusCatalogData/cite/textgroups.xml')//textgroup[. = $id]/ancestor::textgroup
        else ()
    return map {  "textgroups" : $textgroup-cite-records, "textgroup" : $hit }
};

declare function app:textgroups-list($node as node(), $model as map(*), $q as xs:string?)
{
    let $xsl := doc($config:app-root || "/resources/xsl/cite.xsl")
    let $hits :=
        if ($q) then
            doc('/db/PerseusCatalogData/cite/textgroups.xml')//textgroup[ft:query(groupname-eng, $q)]
        else ()    
    return
        <ul>
            {
                for $hit in $hits
                order by $hit/groupname-eng
                return transform:transform($hit, $xsl, ())
            }
        </ul>
};


declare
 %templates:wrap
function app:filtered-textgroups($node as node(), $model as map(*), $q as xs:string?)
as map(*)
{
    let $hits :=
        if ($q) then
            doc('/db/PerseusCatalogData/cite/textgroups.xml')//textgroup[ft:query(groupname-eng, $q)]
        else ()
    return map { 'textgroups' : $hits }
};

(::::: version functions :::::)
declare function app:version-index($node as node(), $model as map(*))
{
    let $hits := catalog:work-records()
    return
    <div>
        <header>
            <h3>versions in the collection. Total count: {count($hits)}</h3>
        </header>
            {
                for $hit in $hits
                let $label := xs:string($hit/mods:titleInfo[1]/mods:title[1])               
                let $id := xs:string($hit/mods:identifier[@type='ctsurn'][1])
                order by $label
                return 
                    <li>
                        <a href="versions.html?id={$id}" title="{$id}">{ $label }</a>
                    </li>
            }
            </div>
};

(:::::::::: Local Functions ::::::::::)

declare function app:author-nav($node as node(), $model as map(*), $q as xs:string?)
{
    <div data-template="app:author-nav">
        <a href="author-index.html">Browse full list of authors</a>
        <form action="authors.html" method="get">
            <input class="form-control" id="q" name="q" placeholder="{ if ($q) then $q else 'terms' }"/>
            <br/>
            <button type="submit">Search</button>
        </form>
        <hr />
        { app:authors-list($node, $model, $q) }
    </div>    
};


declare function app:version-nav($node as node(), $model as map(*), $q as xs:string?)
{
    <div data-template="app:version-nav">
    <a href="version-index.html">Browse full list of versions</a>
        <form action="versions.html" method="get">
            <input class="form-control" id="q" name="q" placeholder="{ if ($q) then $q else 'terms' }"/>
            <br/>
            <button type="submit">Search</button>
        </form>
        { app:versions-list($node, $model, $q) }
    </div>    
};


declare function app:versions-list($node as node(), $model as map(*), $q as xs:string?)
{
    let $hits :=
        if ($q) then
            let $query := <query><term>{ $q }</term></query>
            return collection($config:data-root)//mods:identifier[ft:query(., $query)]/ancestor::mods:mods
        else ()
    return
        if ($hits) then
        <ul>
            {
                for $hit in $hits
                let $label := 
                    if ($hit/mods:titleInfo[@type='uniform']) then
                      xs:string($hit/mods:titleInfo[@type='uniform']/mods:title)
                    else if ($hit/mods:titleInfo) then
                      xs:string($hit/mods:titleInfo[1]/mods:title)
                    else "[no name]"
                let $id := $hit/mods:identifier[@type='ctsurn']
                order by $label
                return 
                    <li>
                        <a href="versions.html?id={$id}">{ $label }</a>
                    </li>
            }
        </ul>
        else ()
};

declare
 %templates:wrap
function app:selected-version($node as node(), $model as map(*), $id as xs:string?)
{
    let $xsl := doc($config:app-root || "/resources/xsl/mods.xsl")
    let $rec := if ($id) then api:version-rec($id) else ()
    return
        if ($rec) then
            transform:transform($rec, $xsl, ())
        else ()
};


declare
 %templates:wrap
function app:selected-version-brief($node as node(), $model as map(*), $id as xs:string?)
{
    let $xsl := doc($config:app-root || "/resources/xsl/work-chunk.xsl")
    return
        if ($id) then 
            transform:transform(api:version-info($id), $xsl, ()) 
        
        else ()
};

declare
 %templates:wrap
function app:index-language($node as node(), $model as map(*))
{
    let $language-terms := collection($config:data-root)//mods:languageTerm
    return
    <ul>
        { for $term in distinct-values($language-terms)
            let $count := count($language-terms[. = $term])
          order by $term
          return
            <li>{ $term } ({$count})</li>
        }
    </ul>
};

declare
 %templates:wrap
function app:index-foa($node as node(), $model as map(*))
{
    let $hits := collection($config:data-root)//mads:fieldOfActivity
    return
    <ul>
        { for $hit in distinct-values($hits)
            let $count := count($hits[. = $hit]) 
          order by $hit
          return
            <li><a href="browse.html?activity={$hit}">{ $hit } ({$count})</a></li>
        }
    </ul>
};


declare
 %templates:wrap
function app:index-subject-old($node as node(), $model as map(*))
{
    let $hits := collection($config:data-root)//mods:subject/mods:topic
    return
    <ul>
        { for $hit in distinct-values($hits)
            let $count := count($hits[. = $hit])
          order by $hit
          return
            <li><a href="browse.html?subject={$hit}">{ $hit } ({$count})</a></li>
        }
    </ul>
};

declare
 %templates:wrap
function app:index-topics($node as node(), $model as map(*))
{
    <ul>{
        for $topic in collection('/db/PerseusCatalogData/indexes/topics')//topic
        order by $topic
        return
            <li>
                <a href="browse.html?topic={$topic/label}">{$topic/label} ({xs:string($topic/@count)})</a>
            </li>
    }</ul>
};


declare
 %templates:wrap
function app:index-subjects($node as node(), $model as map(*))
{
    <ul>{
        for $subject in collection('/db/PerseusCatalogData/indexes/subjects')/subject
        order by $subject
        return
            <li>
                <a href="browse.html?subject={$subject/@key}">{$subject/label} ({xs:string($subject/@count)})</a>
            </li>
    }</ul>
};


declare
 %templates:wrap
function app:foa-selection($node as node(), $model as map(*), $activity as xs:string?)
{
    if ($activity)
    then
       let $hits := collection($config:data-root)//mads:fieldOfActivity[.=$activity]
       return
         if ($hits) then
            <ul>
                {
                    for $hit in $hits
                    let $rec := $hit/ancestor::mads:mads
                    return <li>{$rec/mads:identifier[@type='citeurn']}</li>
                }
            </ul>
         else ()
    else ()
};

declare function app:browse-topics($topic as xs:string)
{
    if ($topic) then
        let $s-index := collection($config:data-root)//topic[label=$topic]
        return
            if ($s-index) then
                <ul>
                    {
                        for $version in $s-index/version
                        order by $version/label
                        return
                            <li>
                                <a href="versions.html?id={$version/@id}">{$version/label}</a>
                            </li>
                    }
                </ul>
            else ()
    else ()
};


declare function app:browse-subjects($key as xs:string)
{
    if ($key) then
        let $s-index := collection('/db/PerseusCatalogData/indexes/subjects')/subject[@key = $key]
        return
            if ($s-index) then
                <ul>
                    {
                        for $version in $s-index/version
                        let $label := $version/label
                        group by $label
                        order by $label
                        return
                            <li>{ $label[1] } : 
                                <ul>
                                    {
                                      for $v in $version
                                      let $sublabel := xs:string($v/@id)
                                      order by $sublabel
                                      return
                                        <li>
                                         <a href="versions.html?id={$v/@id}">{$sublabel}</a>
                                        </li>
                                    }
                                </ul>
                            </li>
                    }
                </ul>
            else ()
    else ()
};



declare 
 %templates:wrap
function app:browse-set($node as node(), $model as map(*), $activity as xs:string?, $subject as xs:string?, $topic as xs:string?)
{
    if ($activity)
    then
       let $hits := collection($config:data-root)//mads:fieldOfActivity[.=$activity]
       return
         if ($hits) then
         <div>
            <header>
                <h2>Activity: {$activity}</h2>
                <p>{count($hits)} found</p>
            </header>
            <ul>
                {
                    for $hit in $hits
                    let $rec := $hit/ancestor::mads:mads
                    let $citeurn := $rec/mads:identifier[@type='citeurn']
                    let $id :=
                        if (count($citeurn) = 1) then
                            xs:string($citeurn)
                        else ()
                    let $label := if ($rec/mads:authority) then $rec/mads:authority else "No Label"
                    order by $label
                    return <li>
                            { if ($id) then
                                <a href="authors.html?id={$id}">{$label}</a>
                              else $label
                            }
                        </li>
                }
            </ul>
            </div>
         else ()
    else if ($topic) then
        app:browse-topics($topic)
        else if ($subject) then
        app:browse-subjects($subject)
    else ()
};

(:::::: Dashboard functions :::::)

declare function local:subject-index()
{
    let $collection := '/db/PerseusCatalogData/mods'
    let $subjects := collection($collection)//mods:subject
    let $index-recs :=
    for $subject in $subjects
      let $topicLabels := for $child in $subject/child::* return normalize-space($child)
      let $label := string-join($topicLabels, '--')
      let $key := $label
      group by $label
      order by $label
      return
      <subject count="{count($subject)}">
       <key>{ $key[1] }</key>
       <label>{ $label[1] }</label>
      
         { for $mods in $subject/ancestor::mods:mods
           let $label :=
                 if ($mods/mods:titleInfo[@type='uniform']) then
                     normalize-space($mods/mods:titleInfo[@type='uniform'][1])
                 else normalize-space($mods/mods:titleInfo[1])
           return
             <version id="{xs:string($mods/mods:identifier[@type='ctsurn'])}">
                 <label>{ $label }</label>
             </version> 
         }
      </subject>         
      
    return
        <subjects count="{count($index-recs)}">{ $index-recs }</subjects>      
};

declare function app:update-subject-index($node as node(), $model as map(*)) {

    xmldb:store('/db/PerseusCatalogData/indexes', 'subjects.xml',
                local:subject-index())
};