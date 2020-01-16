xquery version "1.0-ml";

(: Copyright 2002-2019 MarkLogic Corporation.  All Rights Reserved. :)
(:
:: Sample XSLT invoker that accepts the following parameters:
:: stylesheet    the URI of the stylesheet (in modules DB)
:: doc           the URI of the context node (in DB)
:: template      name of initial template
:: mode          name of initial mode
:: 
:: stylesheet is required, and either doc or template is required.
::
:: Other request parameters are bound to stylesheet parameters (no namespace)
::
:: USAGE:
:: Copy this module to your application server root.
:)

let $stylesheet-uri := xdmp:get-request-field("stylesheet")
let $node := fn:doc(xdmp:get-request-field("doc"))
let $variables := map:map()
let $putvars := 
  for $fn in xdmp:get-request-field-names()
  where fn:not($fn = ("stylesheet","doc","template","mode"))
  return map:put($variables, fn:concat("{}",$fn), xdmp:get-request-field($fn))
let $initial-template := fn:string(xdmp:get-request-field("template"))
let $initial-mode := fn:string(xdmp:get-request-field("mode"))
let $options := 
  <opt:options xmlns:opt="xdmp:eval">
    {if ($initial-mode="") then () 
     else <opt:mode>{$initial-mode}</opt:mode>,
     if ($initial-template="") then () 
     else <opt:template>{$initial-template}</opt:template>}
  </opt:options>
return
   xdmp:xslt-invoke($stylesheet-uri, $node, $variables, $options)
