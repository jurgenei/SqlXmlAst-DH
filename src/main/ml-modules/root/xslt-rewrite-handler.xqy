xquery version "1.0-ml";

(: Copyright 2002-2019 MarkLogic Corporation.  All Rights Reserved. :)

(:
16-Jan-2020 Jurgen
  fn:substring-after($path,"/styled/"), (: added / because uri in content db don't have leading / :)

:: Sample rewriter that maps XSLT URLs to a handler that invokes the
:: stylesheet with the appropriate parameters.
::
:: USAGE:
:: Copy this module and xslt-invoker.xqy to the same directory under your
:: application server root. 
:: Make modifications as desired to the mapping rules.
::
:: URLs of the form:
::   /styled/path/to/document.xml?stylesheet=example.xslt
:: get mapped to:
::   /example/xslt-invoker.xqy?doc=/path/to/document.xml&stylesheet=/my/example.xslt
:: which will cause /my/example.xslt to be invoked with the document
:: /path/to/document.xml as the context node.
::
:: If there is no stylesheet parameter, stylesheet=default.xslt will be added.
::
:: URLs of the form:
::   /other/path/to/example.xslt?doc=/my/example.xml
:: get mapped to:
::   xslt-invoker.xqy?doc=/my/example.xml&stylesheet=/other/path/to/example.xslt
:: which will cause /other/path/to/example.xslt to be invoked with the document
:: /my/example.xml as the context node.
::
:: If there is no doc parameter, doc=default.xml will be added.
:)

(:
:: Map an URL of the form: (starting with /styled/)
::    /styled/path/to/document.xml?args
:: to
::    /example/xslt-invoker.xqy?doc=/path/to/document.xml&args
::
:: where /example/ is the location of the rewrite handler.
::
:: If there is no stylesheet= parameter, add stylesheet=default.xslt
:)
declare function local:map-styled ( $url as xs:string ) as xs:string
{
  let $args := fn:substring-after($url,"?")
  let $args := 
    if (fn:contains($args,"stylesheet=")) then $args
    else fn:concat($args,"&amp;stylesheet=default.xslt")
  let $path := 
    if (fn:contains($url,"?")) 
    then fn:substring-before($url,"?")
    else $url
  let $resolved := 
    fn:resolve-uri("xslt-invoker.xqy",xdmp:get-url-rewriter-path())
  return 
    fn:concat($resolved,"?doc=",
      fn:substring-after($path,"/styled/"), (: added / because uri in content db don't have leading / :)
      "&amp;",$args)
};

(:
:: Map an URL of the form: (path to XSLT document)
::    /any/path/to/example.xslt?args
:: to
::    /example/xslt-invoker.xqy?stylesheet=/any/path/to/example.xslt&args
::
:: where /example/ is the location of the rewrite handler.
::
:: If there is no doc= parameter, add doc=default.xml
:)
declare function local:map-xslt ( $url as xs:string ) as xs:string
{
  let $args := fn:substring-after($url,"?")
  let $path := 
    if (fn:contains($url,"?")) 
    then fn:substring-before($url,"?")
    else $url
  let $doc-arg := 
    if (fn:contains($args,"doc=")) then ""
    else "&amp;doc=default.xml"
  let $resolved := 
    fn:resolve-uri("xslt-invoker.xqy",xdmp:get-url-rewriter-path())
  return 
    fn:concat($resolved,"?stylesheet=",$path,"&amp;",$args,$doc-arg)
};

let $url := xdmp:get-request-url()
let $new-url :=
  if (fn:matches($url,"^/styled/"))
  then local:map-styled($url)
  else if (xdmp:uri-content-type($url) = "application/xslt+xml")
  then local:map-xslt($url)
  else if (fn:contains($url,"?")) then
    if (xdmp:uri-content-type(fn:substring-before($url,"?")) = "application/xslt+xml")
      then local:map-xslt($url)
      else $url
  else $url
return $new-url
