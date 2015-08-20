<?xml version="1.0" encoding="US-ASCII"?>
<stylesheet 
   version="1.0"
   xmlns:doc="https://iead.ittl.gtri.org/wr24/doc/2011-09-30-2258"
   xmlns:NodeInfo="org.apache.xalan.lib.NodeInfo"
   xmlns="http://www.w3.org/1999/XSL/Transform">

  <output method="text"/>

  <param name="source-file">UNSET</param>
  <param name="source-dir">UNSET</param>
  <param name="prefix">DOC</param>

  <template match="/">

    <if test="'UNSET' = $source-file">
      <message terminate="yes">param &quot;source-file&quot; is unset.</message>
    </if>

    <if test="'UNSET' = $source-dir">
      <message terminate="yes">param &quot;source-file&quot; is unset.</message>
    </if>

    <!-- =8<================================================================= -->
    <!-- declarations -->

    <text>&#10;</text>

    <variable name="var-images-base64" select="concat($prefix, '_IMAGES_BASE64')"/>
    <variable name="var-xml-blurbs-text" select="concat($prefix, '_XMLBLURBS_TXT')"/>
    <variable name="var-include-texts" select="concat($prefix, '_INCLUDE_TEXTS')"/>

    <value-of select="concat($prefix, '_HTML_REQUIRED_FILES')"/>
    <text> = $(</text>
    <value-of select="$var-images-base64"/>
    <text>) $(</text>
    <value-of select="$var-xml-blurbs-text"/>
    <text>) $(</text>
    <value-of select="$var-include-texts"/>
    <text>)&#10;&#10;</text>

    <value-of select="concat($prefix, '_TEXT_REQUIRED_FILES')"/>
    <text> = $(</text>
    <value-of select="$var-xml-blurbs-text"/>
    <text>) $(</text>
    <value-of select="$var-include-texts"/>
    <text>)&#10;&#10;</text>

    <value-of select="$var-images-base64"/>
    <text> =</text>
    <for-each select="//doc:image">
      <text> </text>
      <call-template name="from-image-src-get-temp">
        <with-param name="src" select="@src"/>
      </call-template>
      <text> </text>
      <value-of select="concat($source-dir, '/', @src, '.width.txt')"/>
    </for-each>
    <text>&#10;&#10;</text>

    <value-of select="$var-xml-blurbs-text"/>
    <text> =</text>
    <for-each select="//doc:xmlBlurb">
      <text> </text>
      <call-template name="from-xml-blurb-id-get-text">
        <with-param name="id" select="@id"/>
      </call-template>
    </for-each>
    <text>&#10;&#10;</text>

    <value-of select="$var-include-texts"/>
    <text> =</text>
    <for-each select="//doc:include-text">
      <value-of select="concat(' ', $source-dir, '/', @href)"/>
    </for-each>
    <text>&#10;&#10;</text>

    <apply-templates/>
  </template>

  <!-- ==8<=============================================================== -->
  <!-- rules -->

  <template match="doc:xmlBlurb">
    <call-template name="from-xml-blurb-id-get-text">
      <with-param name="id" select="@id"/>
    </call-template>
    <text>: </text>
    <value-of select="$source-file"/>
    <text>&#10;</text>
    <text>&#9;CONFIG_RM -f $@&#10;</text>
    <text>&#9;CONFIG_MKDIR_COMMAND -p $(dir $@)&#10;</text>
    <text>&#9;CONFIG_SED_COMMAND -e '</text>
    <for-each select="text()[1]">
      <value-of select="NodeInfo:lineNumber()"/>
    </for-each>
    <text>,</text>
    <for-each select="text()[last()]">
      <value-of select="NodeInfo:lineNumber() - 1"/>
    </for-each>
    <text>p;d' $&lt; | CONFIG_HEAD_COMMAND -c -1 > $@&#10;&#10;</text>
  </template>

  <template match="doc:image">
    <call-template name="from-image-src-get-temp">
      <with-param name="src" select="@src"/>
    </call-template>
    <text>: </text>
    <value-of select="concat($source-dir, '/', @src)"/>
    <text>&#10;</text>
    <text>&#9;'CONFIG_MKDIR_COMMAND' -p $(dir $@)&#10;</text>
    <text>&#9;'CONFIG_BASE64_COMMAND' --wrap=0 $&lt; &gt; $@&#10;&#10;</text>
  </template>

  <template match="text()"/>

  <template name="from-image-src-get-temp">
    <param name="src"/>
    <value-of select="concat($source-dir, '/', $src, '.base64')"/>
  </template>

  <template name="from-xml-blurb-id-get-text">
    <param name="id"/>
    <value-of select="concat($source-dir, '/xmlBlurb/', $id, '.txt')"/>
  </template>

</stylesheet>
<!-- 
  Local Variables:
  mode: sgml
  indent-tabs-mode: nil
  fill-column: 9999
  End:
-->
