<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mads="http://www.loc.gov/mads/v2" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" exclude-result-prefixes="xs xd mads">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 30, 2017</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:output method="xhtml"/>

    <xsl:template match="mads:mads">
        <li>
            <a href="authors.html?id={mads:identifier[@type='citeurn']}">
                <xsl:value-of select="mads:authority/mads:name/mads:namePart[empty(@type)]"/>
            </a>
        </li>
    </xsl:template>

</xsl:stylesheet>