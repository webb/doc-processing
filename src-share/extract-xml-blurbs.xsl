<?xml version="1.0" encoding="UTF-8"?> <!-- -*-sgml-*- -->
<stylesheet 
   version="2.0"
   xmlns:doc="https://iead.ittl.gtri.org/wr24/doc/2011-09-30-2258"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns="http://www.w3.org/1999/XSL/Transform"
   xmlns:out="http://iead.ittl.gtri.org/wr24/doc/2012-07-31-1611/out">

  <output method="text"/>

  <template match="doc:xmlBlurb">
    <variable name="destinationFile" as="xs:string"
              select="concat('xmlBlurb/', @id, '.xml')"/>
    
    <result-document href="{resolve-uri($destinationFile, base-uri(.))}"
                     method="xml" version="1.0">
      <out:result>
        <copy-of select="comment()|node()"/>
      </out:result>
    </result-document>
  </template>

  <template match="doc:blurbSet">
    <variable name="destinationFile" as="xs:string"
              select="concat('blurbSet/', @id, '.xml')"/>
    <variable name="blurbSetId" select="@id" as="xs:string"/>
    
    <result-document href="{resolve-uri($destinationFile, base-uri(.))}"
                     method="xml" version="1.0">
      <out:result>
        <for-each select="//doc:xmlBlurb|//doc:textBlurb">
          <variable name="memberOf" as="xs:string*" 
                    select="tokenize(normalize-space(@memberOf), ' ')"/>
          <if test="$blurbSetId = $memberOf">
            <copy-of select="comment()|node()"/>
          </if>
        </for-each>
      </out:result>
    </result-document>
  </template>

  <template match="text()"/>
</stylesheet>



