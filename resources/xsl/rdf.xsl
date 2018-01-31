<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pcat="http://perseus.tufts.edu/catalog-ns/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:efrbroo="http://erlangen-crm.org/efrbroo/" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:uuid="java:java.util.UUID" version="2.0" exclude-result-prefixes="xs xd">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p>
                <xd:b>Created on:</xd:b> Dec 20, 2017</xd:p>
            <xd:p>
                <xd:b>Author:</xd:b> cwulfman</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes"/>
    
    <xsl:template match="/">
        <rdf:RDF>
            <xsl:apply-templates/>
        </rdf:RDF>
    </xsl:template>
    
    <xsl:template match="author">
        <rdf:Description>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="id"/>
            </xsl:attribute>
        </rdf:Description>
        <rdfs:label>
            <xsl:apply-templates select="name/authorized"/>
        </rdfs:label>
        <xsl:apply-templates select="works"/>        
    </xsl:template>
    
    <xsl:template match="works">
        
    </xsl:template>
</xsl:stylesheet>