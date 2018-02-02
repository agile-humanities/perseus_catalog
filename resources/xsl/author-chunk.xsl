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
                <h1>
                    <xsl:apply-templates select="name/authorized"/>
                </h1>
            </header>
            <div>
                <header>
                    <h2>Identifiers</h2>
                </header>
                <dl>
                    <xsl:apply-templates select="ids"/>
                </dl>
            </div>
            <div>
                <header>
                    <h2>Fields of Activity</h2>
                </header>
                <ul>
                    <xsl:apply-templates select="fieldsOfActivity"/>
                </ul>
            </div>

            <div>
                <h2>Links</h2>
                <ul>
                    <xsl:apply-templates select="links"/>
                </ul>
            </div>
            <div>
                <h2>Works</h2>
                <ul>
                    <xsl:for-each select="worksby/work">
                        <xsl:sort select="label"/>
                        <li>
                            <a href="works.html?id={@ctsurn}">
                                <xsl:apply-templates select="label"/>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
            <div>
                <h2>Variant Names</h2>
                <ul>
                    <xsl:apply-templates select="name/variants"/>
                </ul>
            </div>
        </section>
    </xsl:template>



    <xsl:template match="relatedWork">
        <xsl:apply-templates select="grouping[@relation = 'primary']"/>
    </xsl:template>

    <xsl:template match="grouping">
        <div class="grouping">
            <header>
                <h4>
                    <xsl:apply-templates select="relation"/>
                </h4>
            </header>
            <xsl:apply-templates select="work"/>
        </div>
    </xsl:template>

    <xsl:template match="work">
        <div class="work">
            <header>
                <h5>
                    <xsl:apply-templates select="label"/>
                </h5>
            </header>
            <ul>
                <xsl:for-each select="expression">
                    <li>
                        <xsl:apply-templates select="current()"/>
                    </li>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>

    <xsl:template match="expression">
        <a href="versions.html?id={@ctsurn}">
            <xsl:value-of select="@ctsurn"/>
        </a>
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