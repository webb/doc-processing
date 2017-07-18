<?xml version="1.0" encoding="us-ascii"?>
<stylesheet 
   xmlns="http://www.w3.org/1999/XSL/Transform" 
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:doc="https://iead.ittl.gtri.org/wr24/doc/2011-09-30-2258"
   xmlns:doc-to-xhtml-fn="https://iead.ittl.gtri.org/wr24/document/functions/doc-to-xhtml/2013-08-12-1108" 
   xmlns:map="http://example.org/ns/map"
   version="2.0">

  <import href="doc-to-xhtml.xsl"/>

  <output method="xml" version="1.0" indent="yes"/>

  <template match="/">
    <map:map>
      <apply-templates/>
    </map:map>
  </template>
  
  <template match="doc:rule">
    <map:rule descriptiveID="{@id}" ruleID="{doc-to-xhtml-fn:get-id(.)}">
    </map:rule>
  </template>

  <template match="*">
    <apply-templates/>
  </template>

  <template match="text()"/>
  
</stylesheet>