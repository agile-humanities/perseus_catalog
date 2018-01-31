<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Dec 2, 2017</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:template match="textgroup">
        <section>
            <header>
                <h2>
                    <xsl:apply-templates select="title"/>
                </h2>
                <p>
                    <xsl:apply-templates select="ctsurn"/>
                </p>
            </header>
        </section>
        <div>
            <header>
                <h3>works in text group</h3>
                <p>
                    <text>number of works: </text>
                    <xsl:value-of select="count(works)"/>
                </p>
            </header>
            <ul>
                <xsl:apply-templates select="works"/>
            </ul>
        </div>
    </xsl:template>
    
    <xsl:template match="works">
        <li>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('works.html?id=',id)"/>
                </xsl:attribute>
                <xsl:attribute name="title">
                    <xsl:value-of select="urn"/>
                </xsl:attribute>
                <xsl:apply-templates select="title"/>
            </a>
            
        </li>
    </xsl:template>

</xsl:stylesheet>