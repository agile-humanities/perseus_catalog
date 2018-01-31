<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Nov 30, 2017</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:template match="work">
        <div>
            <header>
                <h2>
                    <xsl:apply-templates select="title"/>
                </h2>
            </header>
            <xsl:apply-templates select="versions"/>
        </div>

    </xsl:template>

    <xsl:template match="versions">
        <ul>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="version">
        <li>
            <dl>
                <xsl:apply-templates select="titles"/>
                
                <dt>ctsurn</dt>
                <dd>
                    <xsl:apply-templates select="ctsurn"/>
                </dd>

                <xsl:apply-templates select="name"/>

                <dt>published</dt>
                <dd>
                    <xsl:apply-templates select="pubDate"/>
                </dd>

                <xsl:if test="language">
                    <dt>language(s)</dt>
                    <xsl:apply-templates select="language"/>
                </xsl:if>

                <xsl:if test="host">
                    <dt>hosted by</dt>
                    <dd>
                        <xsl:apply-templates select="host"/>
                    </dd>
                </xsl:if>

                <xsl:if test="links">
                    <dt>links</dt>
                    <dd>
                        <ul>
                            <xsl:apply-templates select="links"/>
                        </ul>
                    </dd>
                </xsl:if>
                <dt>full record</dt>
                <dd>
                    <a href="versions.html?id={ctsurn}">full record</a>
                </dd>
            </dl>
        </li>
    </xsl:template>

    <xsl:template match="name">
        <dt>
            <xsl:apply-templates select="role"/>
        </dt>
        <dd>
            <xsl:apply-templates select="string"/>
        </dd>
    </xsl:template>
    
    <xsl:template match="titles">
        <xsl:if test="title[@type='uniform']">
            <dt>uniform title</dt>
            <dd>
                <xsl:apply-templates select="title[@type='uniform']"/>
            </dd>
        </xsl:if>
        <xsl:if test="title[not(@type='uniform')]">
        <dt>other titles</dt>
        <xsl:for-each select="title[not(@type = 'uniform')]">
            <dd>
                    <xsl:apply-templates select="current()"/>
                </dd>
        </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="host">
        <xsl:apply-templates select="title"/>
    </xsl:template>

    <xsl:template match="links">
        <li>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="url"/>
                </xsl:attribute>
                <xsl:value-of select="label"/>
            </a>
        </li>
    </xsl:template>

    <xsl:template match="language">
        <dd>
            <xsl:apply-templates/>
        </dd>
    </xsl:template>

</xsl:stylesheet>