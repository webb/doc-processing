<stylesheet 
    version="2.0"
    xmlns:out="http://www.w3.org/1999/XSL/Transform/out"
    xmlns:private="http://ittl.gtri.gatech.edu/wr24/2009-03-23-1736/xsl-extension/private"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:xe="http://ittl.gtri.gatech.edu/wr24/2009-03-23-1736/xsl-extension"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/XSL/Transform">

  <namespace-alias stylesheet-prefix="out" result-prefix="xsl"/>

  <!-- we want the resultant XSL files to work whether or not Saxon is licensed. -->
  <function name="private:put-location" as="element()+">
    <param name="context" as="xs:string"/>
    <out:value-of 
       use-when="function-available('saxon:line-number')"
       select="concat(tokenize(base-uri({$context}), '/')[last()], ':', saxon:line-number({$context}), ':')"/>
    <out:value-of 
       use-when="not(function-available('saxon:line-number'))"
       select="concat(tokenize(base-uri({$context}), '/')[last()], ':')"/>
  </function>

  <function name="private:get-location" as="xs:string">
    <param name="context"/>
    <value-of use-when="function-available('saxon:line-number')" 
              select="concat(tokenize(base-uri($context),'/')[last()], ':', saxon:line-number($context), ':')"/>
    <value-of use-when="not(function-available('saxon:line-number'))"
              select="concat(tokenize(base-uri($context),'/')[last()], ':')"/>
  </function>

  <!-- 
    Used for inlining a template. Define a template like this:

    <template name="local:subtitle">
      <para name="contents" as="item()*" required="yes"/>
      <fo:block 
         font-size="1.5em" 
         font-weight="bold" 
         text-align="center" 
         space-after="1em">
        <sequence select="$contents"/>
      </fo:block>
    </template>

    And then you can call it like this:

      <xe:call-template-with-contents name="local:subtitle">
        <apply-templates select="doc:author/node()"/>
      </xe:call-template-with-contents>

    Instead of calling it like this:

      <call-template name="local:subtitle">
        <with-param name="contents">
          <apply-templates select="doc:author/node()"/>
        </with-param>
      </call-template>

  -->
  <template match="xe:call-template-with-contents">
    <if test="exists(with-param)">
      <message>xsl-extension:call-template-with-contents must not be called with with-param parameters.</message>
      <value-of select="error()"/>
    </if>
    <out:call-template>
      <copy-of select="attribute()"/>
      <out:with-param name="contents">
        <sequence select="node()"/>
      </out:with-param>
    </out:call-template>
  </template>

  <!-- in-line asserts that render error messages correctly -->
  <!-- use as:
       <xe:assert
           test=" ... boolean expression ... "
           context=" ... node where the error occurred ... "
         > ... message resulting from the error ... </xe:assert>
    -->
  <template match="xe:assert">
    <comment><value-of select="private:get-location(.)"/></comment>
    <if test="empty(@test)">
      <message><value-of select="private:get-location(.)"/>: xe:assert must have @test</message>
      <value-of select="error()"/>
    </if>
    <out:if test="not({@test})">
      <choose>
        <when test="exists(@context)">
          <out:message xmlns:saxon="http://saxon.sf.net/">
            <sequence select="private:put-location(@context)"/>
            <apply-templates/>
          </out:message>
          <out:value-of select="error()"/>
        </when>
        <otherwise>
          <out:message>
            <apply-templates/>
          </out:message>
        </otherwise>
      </choose>
      <out:value-of select="error()"/>
    </out:if>
  </template>

  <!-- additional comment structure that can be NESTED! -->
  <!-- make transparent with the attribute include='true' -->
  <template match="xe:comment">
    <choose>
      <when test="empty(@include) or @include='false'"/>
      <when test="@include='true'">
 	<apply-templates select="node()"/>
      </when>
      <otherwise>
        <message><value-of select="private:get-location(.)"/>: ERROR (xe:comment): @include must be true or false.  @include=&quot;<value-of select="@include"/>&quot;.</message>
        <value-of select="error()"/>
      </otherwise>
    </choose>
  </template>

  <!-- double-check template modes -->
  <template match="xe:mode">
    <apply-templates select="node()"/>
  </template>

  <!-- process templates.  
       double-check template modes. -->
  <template match="xsl:template">
    <!-- check modes -->
    <if test="exists(parent::xe:mode)">
      <variable name="modeEl" as="element(xe:mode)" select="parent::xe:mode"/>
      <choose>
        <when test="exists($modeEl/@mode)">
          <variable name="mode" as="xs:string" select="$modeEl/@mode"/>
          <if test="empty(@mode)">
            <message><value-of select="private:get-location(.)"/>: ERROR (xe:mode): template must have @mode=<value-of select="$mode"/>.  Has no @mode.</message>
            <value-of select="error()"/>
          </if>
          <if test="@mode != $mode">
            <message><value-of select="private:get-location(.)"/>: ERROR (xe:mode): template must have @mode=<value-of select="$mode"/>.  Has @mode=<value-of select="@mode"/>.</message>
            <value-of select="error()"/>
          </if>
        </when>
        <otherwise>
          <if test="exists(@mode)">
            <message><value-of select="private:get-location(.)"/>: ERROR (xe:mode): template must not have @mode.  Has @mode=<value-of select="@mode"/>.</message>
            <value-of select="error()"/>
          </if>
        </otherwise>
      </choose>
    </if>
    <!-- check sorting of templates -->
    <if test="exists(@name)">
      <variable name="name" select="@name" as="xs:string"/>
      <!-- parentheses in the select make the result in document order, so
           this should pick the first occurrence in the doc -->
      <variable name="sorted-wrong" as="element()*"
                select="(preceding-sibling::xsl:template[
                           exists(@name) 
                           and compare(lower-case(@name), lower-case($name)) = 1
                           ])[1]"/>
      <if test="exists($sorted-wrong)">
        <message><value-of select="private:get-location(.)"/> WARNING: template <value-of select="@name"/> appears after template <value-of select="$sorted-wrong/@name"/>.</message>
      </if>
    </if>
    <call-template name="mark-location"/>
    <copy>
      <apply-templates select="@*|node()"/>
    </copy>
  </template>

  <template match="xsl:function">
    <call-template name="mark-location"/>
    <!-- check sorting of functions -->
    <variable name="name" select="@name" as="xs:string"/>
    <!-- parentheses in the select make result in document order, so this should pick the first occurrence in the doc -->
    <variable name="sorted-wrong" as="element()*"
              select="(preceding-sibling::xsl:function[compare(lower-case(@name), lower-case($name)) = 1])[1]"/>
    <if test="exists($sorted-wrong)">
      <message><value-of select="private:get-location(.)"/> WARNING: function <value-of select="@name"/> appears after function <value-of select="$sorted-wrong/@name"/>.</message>
    </if>
    <!-- use the second one when you want tracing turned on -->
    <copy>
      <apply-templates select="@*|node()"/>
    </copy>
  </template>

  <template match="@*">
    <copy/>
  </template>

  <template match="node()" priority="-1">
    <copy>
      <apply-templates select="@*"/>
      <call-template name="mark-location"/>
      <apply-templates select="node()"/>
    </copy>
  </template>

  <template name="mark-location">
    <!--
    <comment><value-of select="private:get-location(.)"/></comment>
    -->
  </template>

</stylesheet>
