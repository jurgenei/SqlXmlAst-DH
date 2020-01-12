<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        version="2.0">
    <xsl:output method="xml" version="1.0"
                encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        <xsl:variable name="list" as="node()*">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:variable name="undup" as="node()*">
            <xsl:for-each-group select="$list" group-by=".">
                <xsl:value-of select="current-grouping-key()"/>
            </xsl:for-each-group>
        </xsl:variable>
        <table>
            <tr>
                <th>readers</th>
                <th>writers</th>
            </tr>
            <tr>
                <td>
                    <ul>
                        <xsl:for-each select="$undup">
                            <xsl:if test="starts-with(.,'r-')">
                                <li>
                                    <xsl:value-of select="replace(.,'r-','')"/>
                                </li>
                            </xsl:if>
                        </xsl:for-each>
                    </ul>
                </td>
                <td>
                    <ul>
                        <xsl:for-each select="$undup">
                            <xsl:if test="starts-with(.,'w-')">
                                <li>
                                    <xsl:value-of select="replace(.,'w-','')"/>
                                </li>
                            </xsl:if>
                        </xsl:for-each>
                    </ul>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- oracle -->
    <xsl:template match="from-clause/table-ref-list//regular-id/t">
        <xsl:value-of select="string-join(('r',.),'-')"/>
    </xsl:template>
    <xsl:template match="insert-into-clause/general-table-ref//regular-id/t">
        <xsl:value-of select="string-join(('w',.),'-')"/>
    </xsl:template>
    <xsl:template match="join-clause/regular-id//t">
        <xsl:value-of select="string-join(('r',.),'-')"/>
    </xsl:template>
    <xsl:template match="text()"/>
    <!-- sybase -->
    <xsl:template match="table-sources//table-name">
        <xsl:value-of select="string-join(('r',.),'-')"/>
    </xsl:template>
    <xsl:template match="insert-statement/ddl-object/table-name">
        <xsl:value-of select="string-join(('w',.),'-')"/>
    </xsl:template>
    <xsl:template match="update-statement/table-name">
        <xsl:value-of select="string-join(('w',.),'-')"/>
    </xsl:template>

</xsl:stylesheet>