<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" exclude-result-prefixes="xs xd">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Dec 1, 2017</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:template match="mods:mods">
        <version>
            <titles>
                <xsl:apply-templates select="mods:titleInfo"/>
            </titles>
            <ctsurn>
                <xsl:apply-templates select="mods:identifier[@type = 'ctsurn']"/>
            </ctsurn>
            
            <xsl:apply-templates select="mods:name"/>
            <xsl:apply-templates select="mods:relatedItem[@type = 'host']"/>
            <xsl:apply-templates select="//mods:location"/>
            <xsl:apply-templates select="//mods:originInfo[1]"/>
            <xsl:apply-templates select="mods:language"/>
        </version>
    </xsl:template>

    <xsl:template match="mods:titleInfo">
        <title>
            <xsl:if test="@type">
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>
            </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </title>
    </xsl:template>

    <xsl:template match="mods:relatedItem[@type = 'host']">
        <host>
            <xsl:apply-templates select="mods:titleInfo[1]"/>
            <xsl:apply-templates select="mods:name"/>
        </host>
    </xsl:template>

    <xsl:template match="mods:name">
        <xsl:for-each select="mods:role">
            <name>
                <role>
                    <xsl:value-of select="current()/mods:roleTerm"/>
                </role>
                <string>
                    <xsl:apply-templates select="ancestor::mods:name/mods:namePart[empty(@type)]"/>
                </string>
            </name>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="mods:location">
        <links>
            <xsl:variable name="label">
                <xsl:choose>
                    <xsl:when test="@displayLabel">
                        <xsl:value-of select="@displayLabel"/>
                    </xsl:when>
                    <xsl:when test="mods:url/@displayLabel">
                        <xsl:value-of select="mods:url/@displayLabel"/>
                    </xsl:when>
                    <xsl:otherwise>[no label]</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <label>
                <xsl:value-of select="$label"/>
            </label>
            <url>
                <xsl:apply-templates select="mods:url"/>
            </url>
        </links>
    </xsl:template>

    <xsl:template match="mods:originInfo">
        <xsl:for-each select="mods:place[@type='text']">
            <pubPlace>
                <xsl:apply-templates select="current()"/>
            </pubPlace>
        </xsl:for-each>
        <xsl:for-each select="mods:publisher">
            <publisher>
                <xsl:apply-templates select="current()"/>
            </publisher>
        </xsl:for-each>
        <xsl:for-each select="mods:edition">
            <edition>
                <xsl:apply-templates select="current()"/>
            </edition>
        </xsl:for-each>
        <xsl:for-each select="mods:dateModified">
            <dateModified>
                <xsl:apply-templates select="current()"/>
            </dateModified>
        </xsl:for-each>
        <pubDate>
            <xsl:value-of select="mods:dateIssued[1]"/>
        </pubDate>
    </xsl:template>

    <xsl:template match="mods:language">
        <language>
            <xsl:apply-templates/>
        </language>
    </xsl:template>

</xsl:stylesheet>