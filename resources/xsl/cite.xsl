<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" exclude-result-prefixes="xs xd">
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

    <xsl:template match="work">
        <li>
            <a href="works.html?id={work}">
                <xsl:apply-templates select="title-eng"/>
            </a>
        </li>
    </xsl:template>
    
    <xsl:template match="textgroup">
        <li>
            <a href="textgroups.html?id={textgroup}">
                <xsl:apply-templates select="groupname-eng"/>
            </a>
        </li>
    </xsl:template>
</xsl:stylesheet>