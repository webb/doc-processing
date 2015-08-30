<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:h="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="h"
    version="2.0">

  <xsl:output method="html"
      doctype-public="-//W3C//DTD HTML 4.01//EN"
      doctype-system="http://www.w3.org/TR/html4/strict.dtd" 
      version="4.01" indent="no"/>

  <xsl:strip-space elements="h:body p ul li"/>

  <xsl:template match="h:*">
    <xsl:element name='{local-name()}'>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <!-- drop all elements not in the html namespace -->
  <xsl:template match="*"/>

  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
