xquery version "3.1";

module namespace cts="http://perseus.tufts.edu/apps/PerseusCatalog/cts";



(: abstraction for CTS objects. :)

declare function cts:object($cts-urn as xs:string)
as element()
{
    let $regex := "^urn:cts:([^:]+):([^.]*)\.?([^.]*)?\.?(.*?)?$"
    let $result := fn:analyze-string($cts-urn, $regex)
    return 
        if ($result/fn:match) then
            $result/fn:match
        else
            error((), "not a cts urn: |" || $cts-urn ||'|')
};

declare function cts:valid-cts-urn-p($str as xs:string)
{
    let $regex := "^urn:cts:([^:]+):([^.]*)\.([^.]*)\.?(.*?)?$"
    let $result := fn:analyze-string($cts-urn, $regex)/fn:match
    return not(empty($result/fn:group[@nr=1]) or empty($result/fn:group[@nr=2]) or empty($result/fn:group[@nr=3]))
};


(: accessors :)

declare function cts:namespace($cts-object as element())
as xs:string
{
    xs:string($cts-object/fn:group[@nr=1])
};

declare function cts:textgroup($cts-object as element())
as xs:string
{
    xs:string($cts-object/fn:group[@nr=2])
};

declare function cts:work($cts-object as element())
as xs:string
{
        xs:string($cts-object/fn:group[@nr=3])
};

declare function cts:edition($cts-object as element())
as xs:string
{
    xs:string($cts-object/fn:group[@nr=4])
};

declare function cts:version($cts-object as element())
as xs:string
{
    xs:string($cts-object/fn:group[@nr=4])
};

declare function cts:work-id($cts-object as element())
as xs:string
{
    string-join((cts:textgroup($cts-object),
                        cts:work($cts-object)), '.')
};

declare function cts:full-work-id($cts-object as element())
as xs:string
{
    string-join(('urn', 'cts', cts:namespace($cts-object), cts:work-id($cts-object)), ':')
};

declare function cts:object-old($cts-urn as xs:string)
as map()
{
    let $tokens := tokenize($cts-urn, ':')
    let $ctsnamespace := $tokens[3]
    let $workid := xs:string($tokens[4])
    let $tokens2 := tokenize($workid, '\.')
    let $textgroup := $tokens2[1]
    let $work2 := $tokens2[2]
    let $edition := $tokens2[3]
    return map {
        "ctsnamespace": $ctsnamespace,
        "workid": map {
            "textgroup": $textgroup,
            "work": $work2,
            "edition": $edition
        }
    }
};


declare function cts:valid-cts-urn-p-old($str as xs:string)
{
    let $tokens := tokenize($str, ':')
    let $ctsnamespace := $tokens[3]
    let $workid := xs:string($tokens[4])
    let $tokens2 := tokenize($workid, '\.')
    let $textgroup := $tokens2[1]
    let $work2 := $tokens2[2]
    let $edition := $tokens2[3]
    
    return if (empty($ctsnamespace) or empty($workid) or empty($tokens2)) then false()
    else true()
};


(: accessors :)
declare function cts:namespace-old($cts-object as map())
as xs:string
{
    $cts-object('ctsnamespace')
};

declare function cts:textgroup-old($cts-object as map())
as xs:string
{
    let $tg := $cts-object('workid')('textgroup')
    return
    if ($tg) then
        $tg
    else
        error((), "cts:textgroup failed", $cts-object)
};

declare function cts:work-old($cts-object as map())
as xs:string
{
    $cts-object('workid')('work')
};

declare function cts:edition-old($cts-object as map())
as xs:string
{
    $cts-object('workid')('edition')
};

declare function cts:work-id-old($cts-object as map())
as xs:string
{
    string-join((cts:textgroup($cts-object),
                        cts:work($cts-object)), '.')
};
