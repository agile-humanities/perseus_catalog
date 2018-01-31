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
        <edition>
            <xsl:apply-templates select="mods:titleInfo[1]"/>
            <ctsurn>
                <xsl:apply-templates select="mods:identifier[@type='ctsurn']"/>
            </ctsurn>
            <xsl:apply-templates select="mods:name"/>
            <xsl:apply-templates select="mods:relatedItem[@type='host']"/>
            <xsl:apply-templates select="//mods:location"/>
        </edition>
    </xsl:template>
    
    <xsl:template match="mods:titleInfo">
        <title>
            <xsl:apply-templates select="mods:title"/>
        </title>
    </xsl:template>
    
    <xsl:template match="mods:relatedItem[@type='host']">
        <host>
            <xsl:apply-templates select="mods:titleInfo[1]"/>
            <xsl:apply-templates select="mods:name"/>
        </host>
    </xsl:template>
    
    <xsl:template match="mods:name">
        <name>
            <role>
                <xsl:value-of select="mods:role/mods:roleTerm"/>
            </role>
            <string>
            <xsl:apply-templates select="mods:namePart[empty(@type)]"/>
            </string>
        </name>
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
    
</xsl:stylesheet>