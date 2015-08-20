<?xml version="1.0" encoding="UTF-8"?>
<schema 
   queryBinding="xslt2"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://purl.oclc.org/dsdl/schematron">

<title>Assertions about IEAD DOC XML format</title>

<ns prefix="doc" uri="https://iead.ittl.gtri.org/wr24/doc/2011-09-30-2258"/>

<ns prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/>
<ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>

<pattern>
  <rule context="/">
    <assert test="exists(doc:document)"
      >Document element must be doc:document.</assert>
  </rule>
  <rule context="doc:appendix">
    <assert test="exists(parent::doc:document)"
      >doc:appendix must be an immediate child of doc:document.</assert>
  </rule>
</pattern>

<pattern>
  <rule context="doc:section">
    <assert test="empty(ancestor::doc:section)
                  or exists(parent::doc:section)
                  or exists(parent::doc:comment)"
      >A doc:section must be either a root doc:section, or must be a child of a doc:section, or must be in a comment</assert>
    <assert test="if (@isAppendix) then empty(ancestor::doc:section) else true()"
            >isAppendix MUST only appear on a root section.</assert>
  </rule>
</pattern>

<pattern>
  <rule context="doc:image">
    <assert test="starts-with(@src, 'img/')"
            >doc:image/@src must start with &quot;img/&quot;</assert>
    <assert test="ends-with(@src, '.png')"
            >doc:image/@ref must end in &quot;.png&quot;</assert>
    <assert test="matches(@src, '^img/[^/]+$')"
            >doc:image/@ref must be a filename in directory img/. Was &quot;<value-of select="@src"/>&quot;.</assert>
  </rule>
</pattern>

<pattern>
  <rule context="doc:termRef">
    <let name="term" value="normalize-space(if (exists(@term)) 
                                              then string(@term)
                                              else string(.))"/>
    <let name="termCount" value="count(//doc:definition[normalize-space(@term) = $term])"/>
    <assert test="$termCount = 1"
            >There must exist exactly one doc:definition for every doc:termRef. (Term is &quot;<value-of select="$term"/>&quot;; found <value-of select="$termCount"/> occurrences)</assert>
  </rule>
</pattern>

<pattern>
  <rule context="doc:ruleSection">
    <assert test="count(doc:rule) = 1"
            >A ruleSection MUST have 1 child element rule.</assert>
  </rule>
</pattern>

<pattern>
  <rule context="doc:definition">
    <let name="term" value="@term"/>
    <let name="termCount" value="count(//doc:definition[@term = $term])"/>
    <assert test="$termCount = 1"
            >There must exist exactly one doc:definition with a given term. (Term is &quot;<value-of select="$term"/>; found <value-of select="$termCount"/> occurrences)</assert>
  </rule>
</pattern>

<pattern>
  <rule context="doc:a">
    <assert test="exists(@href)">A doc:a must have @href.</assert>
  </rule>
</pattern>

<pattern>
  <rule context="doc:qName[empty(ancestor::doc:comment)]">
    <assert test="not(xs:anyURI('https://iead.ittl.gtri.org/wr24/doc/2011-09-30-2258') 
                      = namespace-uri-from-QName(
                          resolve-QName(string-join(text(), ''), .)))"
      >A qName must not have a namespace that's the doc namespace. That's sloppy.</assert>
  </rule>
</pattern>

<pattern>
  <rule context="doc:namespace-uri-for-prefix">
    <let name="uri" value="namespace-uri-for-prefix(string-join(text(), ''), .)"/>
    <assert test="count($uri) = 1">A prefix in namespace-uri-for-prefix must be bound.</assert>
    <assert test="not($uri = (xs:anyURI(''),
                              xs:anyURI('https://iead.ittl.gtri.org/wr24/doc/2011-09-30-2258')))"
      >A namespace prefix in namespace-uri-for-prefix must not be bound to the blank namespace or the doc namespace.</assert>
  </rule>
</pattern>

<pattern>
  <rule context="doc:reference">
    <assert test="exists(*[1][self::doc:p])"
            >doc:reference must have a first child element doc:p.</assert>
  </rule>
</pattern>


</schema>
<!-- 
  Local Variables:
  mode: sgml
  indent-tabs-mode: nil
  fill-column: 9999
  End:
-->
