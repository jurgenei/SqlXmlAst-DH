xquery version "1.0-ml";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";

declare namespace g = "http://ing.com/vortex/sql/grammar";
declare namespace c = "http://ing.com/vortex/sql/comments";

declare variable $start := xdmp:get-request-field('start', '1');
declare variable $amount := xdmp:get-request-field('amount', '20');
declare variable $search := xdmp:get-request-field('search', '');
declare variable $docurl := xdmp:get-request-field('docurl', '');

declare function local:results($search, $start, $amount) {
    <dl>
        {
            for $x in search:search(
            $search
            , <options
                xmlns="http://marklogic.com/appservices/search">
                <return-results>true</return-results>
                <return-facets>true</return-facets>
            </options>
            , xs:int($start)
            , xs:int($amount)
            )/search:result
            for $item in $x/search:snippet
            let $first := $item/search:match[1]
            let $docuri := replace($first/@path, 'fn:doc\("(.*?)"\).*', '$1')
            let $content := $first/node()
            return
                <div>
                    <dt><a
                            href="/search.xqy?search={$search}&amp;amount={$amount}&amp;start={xs:int($start)}&amp;docurl={$docuri}">{$docuri}</a></dt>
                    <dd>{
                            for $e in $content
                            let $v := string($e)
                            return
                                if (local-name($e) = 'highlight') then
                                    <b>{$v}</b>
                                else
                                    $v
                        }</dd>
                </div>
        }</dl>
};

declare function local:gettotal($search) {
    for $x in search:search(
    $search
    , <options
        xmlns="http://marklogic.com/appservices/search">
        <return-results>true</return-results>
        <return-facets>true</return-facets>
    </options>
    )
    return
        data($x/@total)
};

xdmp:set-response-content-type("text/html"),
('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "https://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
<html
    xmlns="https://www.w3.org/1999/xhtml"
    xml:lang="en">
    <head>
        <title>Search</title>
        <link
            rel="stylesheet"
            href="style.css"/>
    </head>
    <body>
        <div>
            <form
                action="/search.xqy"
                method="get">
                <input
                    type="text"
                    placeholder="Search.."
                    name="search"/>
                <button
                    type="submit">Search</button>
                <input
                    type="hidden"
                    name="start"
                    value="{$start}"/>
                <input
                    type="hidden"
                    name="amount"
                    value="{$amount}"/>
                {
                    if ($docurl eq "")
                    then
                        (
                        <input
                            type="hidden"
                            name="docurl"
                            value="{$docurl}"/>
                        )
                    else
                        (
                        <a
                            href="/search.xqy?search={$search}&amp;amount={$amount}&amp;start={xs:int($start)}">Back to search results</a>
                        )
                }
            </form>
        </div>
        <div>
            {
                if ($docurl ne "")
                then
                    (
                    let $tocurl := string-join((substring-before($docurl, '/'), 'xref.xml'), '/')
                    let $params := map:map()
                    let $_put := map:put($params, "xref", doc($tocurl))
                    return
                        xdmp:xslt-invoke("/tidy2html.xslt", doc($docurl), $params)
                    )
                else
                    (
                    
                    if ($search ne "")
                    then
                        (
                        local:results($search, $start, $amount)
                        )
                    else
                        (
                        ''
                        )
                    )
            }
        
        </div>
        <div>
            {
                if ($docurl ne "")
                then
                    (
                    <a
                        href="/search.xqy?search={$search}&amp;amount={$amount}&amp;start={xs:int($start)}">Back to search results</a>
                    )
                else
                    (
                    ''
                    )
            }
            {
                if ($search ne "" and xs:int($start) > 1)
                then
                    (
                    <a
                        href="/search.xqy?search={$search}&amp;amount={$amount}&amp;start={xs:int($start) - xs:int($amount)}">previous {$amount}&nbsp;&nbsp;&nbsp;</a>
                    )
                else
                    (
                    ''
                    )
            }
            {
                if ($search ne "" and xs:int(local:gettotal($search)) > (xs:int($start)) + xs:int($amount))
                then
                    (
                    <a
                        href="/search.xqy?search={$search}&amp;amount={$amount}&amp;start={xs:int($start) + xs:int($amount)}">next {$amount}</a>
                    )
                else
                    (
                    ''
                    )
            
            }
        </div>
    </body>
</html>)
