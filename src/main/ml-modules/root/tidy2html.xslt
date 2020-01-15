<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://ing.com/vortex/sql/grammar" xmlns:c="http://ing.com/vortex/sql/comments"
    xmlns:f="http://ing.com/vortex/sql/functions" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
    <!-- 
        parameters 
    -->
    <xsl:param name="xref" as="node()*"/>
    <!-- 
        procesing options 
    -->
    <xsl:output method="html" version="4.0" encoding="UTF-8" indent="no"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="c:c"/>
    <!-- 
        remove top level tag 
    -->
    <xsl:template match="/">
        <xsl:apply-templates select="g:envelope/g:sql"/>
    </xsl:template>
    <xsl:template match="g:sql">
        <h1>
            <xsl:value-of select="@path"/>
        </h1>
        <xsl:variable name="comp" select="fn:count(tokenize(@path, '/')[position() gt 2])"/>

        <xsl:variable name="base" select="substring-before(@path, '/')"/>

        <xsl:variable name="pn" select="fn:lower-case(.//g:create-procedure-body/g:procedure-name)"/>
        <xsl:variable name="tn" select="fn:lower-case(.//g:create-table/g:id[position() = last()])"/>


        <xsl:variable name="lookup" select="$xref//g:procedures/g:procedure[@name = $pn]"
            as="node()*"/>
        <xsl:variable name="lookupt" select="$xref//g:tables/g:table[@name = $tn]" as="node()*"/>
        <xsl:variable name="procs" select="$lookupt/g:procedure" as="node()*"/>
        <!--
        <div class="debug">
            <table>
                <tr>
                    <td>base</td>
                    <td>
                        <xsl:value-of select="$base"/>
                    </td>
                </tr> 
                <tr>
                    <td>procedure count</td>
                    <td>
                        <xsl:value-of select="count($xref//g:procedures/g:procedure)"/>
                    </td>
                </tr>
                <tr>
                    <td>table count</td>
                    <td>
                        <xsl:value-of select="count($xref//g:tables/g:table)"/>
                    </td>
                </tr>                
                <tr>
                    <td>g:toc</td>
                    <td>
                        <xsl:value-of select="count($xref//g:toc)"/>
                    </td>
                </tr>
                <tr>
                    <td>pn</td>
                    <td>
                        <xsl:value-of select="$pn"/>
                    </td>
                </tr>
                <tr>
                    <td>tn</td>
                    <td>
                        <xsl:value-of select="$tn"/>
                    </td>
                </tr>
                <tr>
                    <td>lookup proc</td>
                    <td>
                        <xsl:value-of select="fn:count($lookup/g:*)"/>
                    </td>
                </tr>
                <tr>
                    <td>lookup tab</td>
                    <td>
                        <xsl:value-of select="fn:count($lookupt/g:*)"/>
                    </td>
                </tr>
            </table>
        </div>
-->
        <xsl:choose>
            <xsl:when test="$lookup">
                <xsl:variable name="callees" select="$lookup//g:callee"/>
                <xsl:variable name="calls" select="$lookup//g:calls[not(@pkg)]/g:call"/>
                <xsl:variable name="tables" select="$lookup//g:table"/>
                <xsl:variable name="i" select="$lookup//g:table[@use = 'select']"/>
                <xsl:variable name="x" select="$lookup//g:table[not(@use = 'select')]"/>
                <div class="header">
                    <xsl:if test="$callees or $calls or $tables">
                        <table>
                            <xsl:if test="$callees or $calls">
                                <tr>
                                    <td>
                                        <xsl:if test="$callees">
                                            <span class="t">called by: </span>
                                            <xsl:for-each select="$callees">
                                                <xsl:sequence
                                                  select="f:get-procedure-path(@name, .)"/>
                                                <xsl:if test="not(position() = last())">
                                                  <xsl:value-of select="', '"/>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </td>
                                    <td>
                                        <xsl:if test="$calls">
                                            <span class="t">calls: </span>
                                            <xsl:for-each
                                                select="$lookup//g:calls[not(@pkg)]/g:call">
                                                <xsl:sequence
                                                  select="f:get-procedure-path(@name, .)"/>
                                                <xsl:if test="not(position() = last())">
                                                  <xsl:value-of select="', '"/>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </td>
                                </tr>
                            </xsl:if>
                            <xsl:if test="$tables">
                                <tr>
                                    <td>
                                        <xsl:if test="$i">
                                            <span class="t">input: </span>
                                            <xsl:for-each select="$i">
                                                <xsl:sequence select="f:get-table-path(@name, $base)"/>
                                                <xsl:if test="not(position() = last())">
                                                  <xsl:value-of select="', '"/>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </td>
                                    <td>
                                        <xsl:if test="$x">
                                            <span class="t">input/output: </span>
                                            <xsl:for-each select="$x">
                                                <xsl:sequence select="f:get-table-path(@name, $base)"/>
                                                <xsl:if test="not(position() = last())">
                                                  <xsl:value-of select="', '"/>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </td>
                                </tr>
                            </xsl:if>
                        </table>
                    </xsl:if>
                </div>
            </xsl:when>
            <xsl:when test="$lookupt">
                <div class="header">
                    <xsl:if test="$procs">
                        <span class="t">procedures using <xsl:value-of select="$tn"/>: </span>
                        <xsl:for-each select="$procs">
                            <xsl:sequence select="f:get-procedure-path(@name, $xref)"/>
                            <xsl:if test="not(position() = last())">
                                <xsl:value-of select="', '"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </div>
            </xsl:when>
        </xsl:choose>
        <div class="sql-body">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="g:*[@object]">
        <span class="{local-name(.)}-{@object}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="g:t">
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="g:*">
        <span class="{local-name(.)}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="c:*">
        <xsl:choose>
            <xsl:when test=". = ' '">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <span class="comment">
                    <xsl:value-of select="."/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- 
        functions 
    -->
    <xsl:function name="f:get-procedure-path">
        <xsl:param name="name"/>
        <xsl:param name="node"/>
        <xsl:variable name="path">
            <xsl:choose>
                <xsl:when test="$node/@path">
                    <xsl:value-of select="$node/@path"/>
                </xsl:when>
                <xsl:when test="$node/ancestor::g:procedures/g:procedure[@name = $name]/@path">
                    <xsl:value-of select="$node/ancestor::g:procedures/g:procedure[@name = $name]/@path"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="$xref//g:procedures/g:procedure[@name = $name]/@path"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$path">
                <a href="/search.xqy?docurl={replace($path, '\.sql', '.xml')}">
                    <xsl:value-of select="$name"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:get-table-path">
        <xsl:param name="name"/>
        <xsl:param name="base"/>
        <a href="/search.xqy?docurl={$base}/tables/{$name}.xml">
            <xsl:value-of select="$name"/>
        </a>
    </xsl:function>
</xsl:stylesheet>
