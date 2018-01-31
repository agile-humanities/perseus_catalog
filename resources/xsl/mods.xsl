<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Jan 31, 2018</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:output encoding="UTF-8" method="xhtml"/>

    <xsl:template match="mods:mods">
        <section class="mods-record">
            <header>
                <xsl:call-template name="section-header"/>
            </header>
            <xsl:call-template name="item-div"/>
        </section>
    </xsl:template>

    <xsl:template name="section-header">
        <xsl:choose>
            <xsl:when test="mods:titleInfo[@type = 'uniform']">
                <h1>
                    <xsl:apply-templates select="mods:titleInfo[@type = 'uniform']"/>
                </h1>
            </xsl:when>
            <xsl:when test="mods:titleInfo[not(@type = 'uniform')]">
                <h1>
                    <xsl:apply-templates select="mods:titleInfo[1]"/>
                </h1>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="item-div">
        <div class="item">
            <xsl:call-template name="titles-div"/>
            <xsl:call-template name="names-div"/>
            <xsl:call-template name="origin-div"/>
            <xsl:call-template name="identifiers-div"/>
            <xsl:call-template name="subjects-div"/>
            <xsl:call-template name="locations-div"/>
            <xsl:call-template name="notes-div"/>
            <xsl:call-template name="relatedItems-div"/>
        </div>
    </xsl:template>

    <xsl:template name="titles-div">
        <xsl:if test="mods:titleInfo">
            <div class="titles">
                <header>
                    <h2>Titles</h2>
                </header>
                <ul>
                    <xsl:for-each select="mods:titleInfo">
                        <li>
                            <xsl:apply-templates select="current()"/>
                        </li>
                    </xsl:for-each>
                </ul>
                <xsl:if test="mods:part">
                    <dl>
                        <xsl:apply-templates select="mods:part"/>
                    </dl>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="names-div">
        <xsl:if test="mods:name">
            <div class="names">
                <header>
                    <h2>Names</h2>
                </header>
                <dl>
                    <xsl:for-each-group select="mods:name" group-by="mods:role/mods:roleTerm">
                        <dt>
                            <xsl:value-of select="current-grouping-key()"/>
                        </dt>
                        <dd>
                            
                                <xsl:apply-templates select="current()"/>
                            
                        </dd>
                    </xsl:for-each-group>
                </dl>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="origin-div">
        <xsl:if test="mods:originInfo">
            <div class="originInfo">
                <header>
                    <h2>Publication Information</h2>
                </header>
                <dl>
                    <xsl:apply-templates select="mods:originInfo"/>
                </dl>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="identifiers-div">
        <xsl:if test="mods:identifier">
            <div class="identifiers">
                <header>
                    <h2>Identifiers</h2>
                    <dl>
                        <xsl:apply-templates select="mods:identifier"/>
                    </dl>
                </header>
            </div>
        </xsl:if>        
    </xsl:template>

    <xsl:template name="subjects-div">
        <xsl:if test="mods:subject">
            <div class="subjects">
                <header>
                    <h2>Subjects</h2>
                    <ul>
                        <xsl:for-each select="mods:subject">
                            <li>
                                <xsl:apply-templates/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </header>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="locations-div">
        <xsl:if test="mods:location">
            <div class="locations">
                <header>
                    <h2>Locations</h2>
                </header>
                <dl>
                    <xsl:apply-templates select="mods:location"/>
                </dl>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="notes-div">
        <xsl:if test="mods:note">
            <div class="notes">
                <header>
                    <h2>Notes</h2>
                    <ul>
                        <xsl:for-each select="mods:note">
                            <li>
                                <xsl:apply-templates/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </header>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="relatedItems-div">
        <xsl:if test="mods:relatedItem">
            <div class="relatedItems">
                <header>
                    <h2>Related Items</h2>
                </header>
                <xsl:for-each-group select="mods:relatedItem" group-by="@type">
                    <div class="relatedItem {current-grouping-key()}">
                        <header>
                            <h2>
                                <xsl:value-of select="current-grouping-key()"/>
                            </h2>
                        </header>
                        <ul>
                            <xsl:for-each select="current-group()">
                                <li>
                                    <xsl:apply-templates select="current()"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </xsl:for-each-group>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="mods:titleInfo">
        <div class="titleInfo">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="mods:title | mods:subTitle | mods:partNumber | mods:partName">
        <span class="{local-name()}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- elements in originInfo -->
    <xsl:template match="mods:place | mods:publisher | mods:dateIssued | mods:issuance">
        <dt>
            <xsl:value-of select="local-name()"/>
        </dt>
        <dd>
            <xsl:apply-templates/>
        </dd>
    </xsl:template>

    <xsl:template match="mods:location">
        <dt>
            <xsl:value-of select="@displayLabel"/>
        </dt>
        <dd>
            <xsl:apply-templates/>
        </dd>
    </xsl:template>

    <xsl:template match="mods:relatedItem">
        <div class="relatedItem">
            <xsl:call-template name="item-div"/>
        </div>
    </xsl:template>
    
    <xsl:template match="mods:url">
        <xsl:variable name="theURL">
            <xsl:value-of select="."/>
        </xsl:variable>
        <a href="{$theURL}">
            <xsl:value-of select="."/>
        </a>
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

    <!-- Don't output role elements -->
    <xsl:template match="mods:role"/>
    
</xsl:stylesheet>