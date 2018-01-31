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

    <xsl:template match="author">
        <section>
            <header>
                <h2>
                    <xsl:apply-templates select="name/authorized"/>
                </h2>
            </header>
            <div>
                <header>
                    <h3>Identifiers</h3>
                </header>
                <dl>
                    <xsl:apply-templates select="ids"/>
                </dl>
            </div>
            <div>
                <header>
                    <h3>Fields of Activity</h3>
                </header>
                <ul>
                    <xsl:apply-templates select="fieldsOfActivity"/>
                </ul>
            </div>
            
            <div>
                <h3>Links</h3>
                <ul>
                    <xsl:apply-templates select="links"/>
                </ul>
            </div>
            <div>
                <h3>Works</h3>
                <ul>
                    <xsl:apply-templates select="works"/>
                </ul>
            </div>
            <div>
                <h3>Variant Names</h3>
                <ul>
                    <xsl:apply-templates select="name/variants"/>
                </ul>
            </div>
        </section>
    </xsl:template>

    <xsl:template match="works">
        <li>
            <a href="works.html?id={id}">
                <xsl:apply-templates select="label"/>
            </a>
        </li>
    </xsl:template>

    <xsl:template match="links">
        <li>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="./url"/>
                </xsl:attribute>
                <xsl:value-of select="./label"/>
            </a>
        </li>
    </xsl:template>
    
    <xsl:template match="variants">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    
    <xsl:template match="fieldsOfActivity">
        <li>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('browse.html?activity=', .)"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </a>
        </li>
    </xsl:template>
    
    <xsl:template match="ids">
        <dt>
            <xsl:apply-templates select="type"/>
        </dt>
        <dd>
            <xsl:apply-templates select="value"/>
        </dd>
    </xsl:template>

</xsl:stylesheet>