<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" version="2.0" exclude-result-prefixes="xs xd mods">
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

    <xsl:template match="mods:mods">
        <section>
            <header>
                <xsl:choose>
                    <xsl:when test="mods:titleInfo[@type = 'uniform']">
                        <h2>
                            <xsl:apply-templates select="mods:titleInfo[@type = 'uniform']"/>
                        </h2>
                    </xsl:when>
                    <xsl:when test="mods:titleInfo[not(@type = 'uniform')]">
                        <h2>
                            <xsl:apply-templates select="mods:titleInfo[1]"/>
                        </h2>
                    </xsl:when>
                </xsl:choose>
                <p>
                    <xsl:apply-templates select="mods:identifier[@type = 'ctsurn']"/>
                </p>
            </header>
            <div>
                <header>
                    <h3>Titles</h3>
                </header>
                <dl>
                    <xsl:if test="mods:titleInfo[@type = 'uniform']">
                        <dt>uniform title</dt>
                        <dd>
                            <xsl:apply-templates select="mods:titleInfo[@type = 'uniform']"/>
                        </dd>
                    </xsl:if>
                    <xsl:if test="mods:titleInfo[not(@type = 'uniform')]">
                        <xsl:for-each select="mods:titleInfo[not(@type = 'uniform')]">
                            <dt>
                                <xsl:value-of select="@displayLabel"/>
                            </dt>
                            <dd>
                                <xsl:apply-templates select="current()"/>
                            </dd>
                        </xsl:for-each>
                    </xsl:if>
                </dl>
            </div>

            <div>
                <header>
                    <h3>Names</h3>
                </header>
                <dl>
                    <xsl:apply-templates select="mods:name"/>
                </dl>
            </div>

            <xsl:if test="mods:language">
                <div>
                    <header>
                        <h3>Language(s)</h3>
                    </header>
                    <dl>
                        <xsl:apply-templates select="mods:language"/>
                    </dl>
                </div>
            </xsl:if>
            <xsl:if test="mods:part/mods:extent">
                <div>
                    <header>
                        <h3>Extents</h3>
                    </header>
                    <dl>
                        <xsl:apply-templates select="mods:part/mods:extent"/>
                    </dl>
                </div>
            </xsl:if>

            <xsl:if test="mods:location">
                <div>
                    <header>
                        <h3>Links</h3>
                    </header>
                    <ul>
                        <xsl:for-each select="mods:location">
                            <li>
                                <xsl:apply-templates select="current()"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>

            <xsl:if test="mods:identifier">
                <div>
                    <header>
                        <h3>Identifiers</h3>
                    </header>
                    <dl>
                        <xsl:apply-templates select="mods:identifier"/>
                    </dl>
                </div>
            </xsl:if>

            <xsl:if test="mods:originInfo">
                <div>
                    <header>
                        <h2>publication information</h2>
                        <xsl:apply-templates select="mods:originInfo"/>
                    </header>
                </div>
            </xsl:if>

            <xsl:if test="mods:relatedItem[@type = 'host']">
                <div>
                    <header>
                        <h3>Hosted by</h3>
                    </header>
                    <xsl:for-each select="mods:relatedItem[@type = 'host']">
                        <xsl:apply-templates select="current()"/>
                    </xsl:for-each>
                </div>
            </xsl:if>

            <xsl:if test="mods:relatedItem[@type = 'constituent']">
                <dt>constituents</dt>
                <xsl:for-each select="mods:relatedItem[@type = 'constituent']">
                    <dd>
                        <xsl:apply-templates select="current()"/>
                    </dd>
                </xsl:for-each>
            </xsl:if>
        </section>
    </xsl:template>


    <xsl:template match="mods:relatedItem[@type = 'constituent'] | mods:relatedItem[@type = 'host']">
        <xsl:variable name="titlelabel">
            <xsl:choose>
                <xsl:when test="mods:titleInfo[@type = 'uniform']">
                    <xsl:apply-templates select="mods:titleInfo[@type = 'uniform']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="mods:titleInfo[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div class="relatedItem">
            <header>
                <h4>
                    <xsl:value-of select="$titlelabel"/>
                    <xsl:if test="mods:part">
                        <xsl:text>: </xsl:text>
                        <xsl:apply-templates select="mods:part"/>
                    </xsl:if>
                </h4>
            </header>

            
            <xsl:apply-templates select="mods:identifier"/>
            <xsl:apply-templates select="mods:originInfo"/>
        </div>
    </xsl:template>

    <xsl:template match="mods:name">
        <xsl:for-each select="mods:role">
            <dt>
                <xsl:apply-templates select="current()/mods:roleTerm"/>
            </dt>
            <dd>
                <xsl:apply-templates select="current()/ancestor::mods:name/mods:namePart"/>
            </dd>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="mods:identifier">
        <dt>
            <xsl:choose>
                <xsl:when test="@displayLabel">
                    <xsl:value-of select="@displayLabel"/>
                </xsl:when>
                <xsl:when test="@type">
                    <xsl:value-of select="@type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>identifier</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </dt>
        <dd>
            <xsl:apply-templates/>
        </dd>
    </xsl:template>

    <xsl:template match="mods:location">
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
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mods:url"/>
            </xsl:attribute>
            <xsl:value-of select="$label"/>
        </a>
    </xsl:template>

    <xsl:template match="mods:originInfo">
        <dl>
            <dt>place(s)</dt>
            <dd>
                <xsl:for-each select="mods:place[mods:placeTerm[not(@type = 'code')]]">
                    <xsl:apply-templates select="."/>
                    <xsl:if test="position() != last()">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:for-each>

            </dd>
            <dt>date(s)</dt>
            <dd>
                <xsl:for-each select="mods:dateIssued">
                    <xsl:apply-templates select="."/>
                    <xsl:if test="position() != last()">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </dd>

            <xsl:if test="mods:dateModified">

                <dt>modified</dt>
                <dd>
                    <xsl:for-each select="mods:dateModified">
                        <xsl:apply-templates select="."/>
                        <xsl:if test="position() != last()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>

                </dd>
            </xsl:if>

            <xsl:if test="mods:publisher">
                <dt>publisher(s)</dt>
                <dd>
                    <xsl:for-each select="mods:publisher">
                        <xsl:apply-templates select="."/>
                        <xsl:if test="position() != last()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>

                </dd>
            </xsl:if>
            <xsl:if test="mods:edition">
                <dt>edition(s)</dt>
                <dd>
                    <xsl:for-each select="mods:edition">
                        <xsl:apply-templates select="."/>
                        <xsl:if test="position() != last()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>

                </dd>
            </xsl:if>
        </dl>
    </xsl:template>

    <xsl:template match="mods:extent[@unit = 'words']">
        <dt>words</dt>
        <dd>
            <xsl:apply-templates/>
        </dd>
    </xsl:template>

    <xsl:template match="mods:extent[@unit = 'pages']">
        <dt>pages</dt>
        <dd>
            <xsl:value-of select="mods:start"/>—<xsl:value-of select="mods:end"/>
        </dd>

    </xsl:template>

    <xsl:template match="mods:language">
        <dt>language
            <xsl:choose>
                <xsl:when test="@objectPart">
                    of <xsl:value-of select="@objectPart"/>
                </xsl:when>
            </xsl:choose>
        </dt>
        <dd>
            <xsl:apply-templates/>
        </dd>
    </xsl:template>
</xsl:stylesheet>