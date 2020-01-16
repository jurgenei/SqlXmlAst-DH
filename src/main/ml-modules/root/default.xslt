<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <!-- default is identity transform -->

    <!-- By default, copy everything unchanged -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Add a comment to the top of the doc -->
    <xsl:template match="/">
        <xsl:comment>Rendered by SqlXmlPub</xsl:comment>
        <xsl:next-match/>
    </xsl:template>

</xsl:stylesheet>
