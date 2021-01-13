<?xml version="1.0" encoding="us-ascii"?>
<stylesheet 
   version="2.0"
   xmlns:common="https://iead.ittl.gtri.org/wr24/document/functions/common/2011-10-05-1029"
   xmlns:doc="https://iead.ittl.gtri.org/wr24/doc/2011-09-30-2258"
   xmlns:map="http://example.org/ns/map"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/XSL/Transform">

  <import href="common.xsl"/>

  <output method="xml" version="1.0" indent="yes"/>

  <template match="/">
    <map:map>
      <apply-templates/>
    </map:map>
  </template>
  
  <template match="doc:rule">
    <map:rule descriptiveID="{@id}" ruleID="{common:get-id(.)}">
    </map:rule>
  </template>

  <template match="*">
    <apply-templates/>
  </template>

  <template match="text()"/>
  
</stylesheet>
