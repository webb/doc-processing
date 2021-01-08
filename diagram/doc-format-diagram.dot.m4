m4_changequote([[[,]]])m4_dnl
m4_changecom(,)m4_dnl
m4_dnl
m4_dnl call: M_label_table( title, row, row, row ... )
m4_dnl
m4_define([[[M_label_table]]],[[[
  m4_ifelse($#,0,[[[m4_errprint([[[
      M_label_table needs at least 1 arg]]])
      m4_exit]]],
    [[[label=<<TABLE BORDER="1" CELLBORDER="0" CELLPADDING="1" CELLSPACING="0" COLOR="BLACK">
      <TR>
        <TD ALIGN="LEFT" PORT="top"><B>$1</B></TD>
      </TR>
      m4_define([[[M_odd_row]]],1)
      m4_ifelse($#,1,,[[[
          <HR/>
          M_label_table_rows(m4_shift($@))
        ]]])
    </TABLE>>
  ]]])]]])m4_dnl
m4_dnl
m4_dnl M_label_table_rows( $row, $row, ... )
m4_dnl only called by M_label_table.
m4_dnl
m4_define([[[M_label_table_rows]]],[[[
  m4_ifelse($#,0,[[[
      m4_errprint([[[M_label_table_rows needs at least 1 arg]]])
      m4_exit
    ]]],
    [[[
      $1
      m4_ifelse($#,1,,
        [[[M_label_table_rows(m4_shift($@))]]])
    ]]])
  ]]])m4_dnl
m4_dnl
m4_dnl M_row( $1 = element name, $2 = type?, $3 = cardinality?, $4 = port name? )
m4_dnl set port name to '=' if the port name is the same as the element name
m4_dnl
m4_define([[[M_row]]],[[[
  <TR>
    <TD ALIGN="LEFT"m4_dnl
m4_ifelse($4,,,
  $4,=,[[[ PORT="$1"]]],
  [[[ PORT="$4"]]])m4_dnl
m4_ifelse(M_odd_row,1,[[[ BGCOLOR="gray92"[[[]]]m4_dnl
    m4_define([[[M_odd_row]]],0)m4_dnl
  ]]],
  [[[m4_define([[[M_odd_row]]],1)]]])m4_dnl
>$1[[[]]]m4_dnl
m4_ifelse($2,,,[[[: $2]]])[[[]]]m4_dnl
m4_ifelse($3,,,[[[ [$3][[[]]]]]])m4_dnl
</TD>
  </TR>
]]])m4_dnl
m4_dnl
m4_dnl call: M_fail(message...)
m4_dnl
m4_define([[[M_fail]]],[[[
  m4_errprint($*)
  m4_exit(1)
]]])m4_dnl
m4_dnl
m4_dnl M_subst(substitution group / slot, substituable element)
m4_dnl
m4_define([[[M_subst]]],[[[$1 -> $2 [dir=back, label=subst][[[]]]]]])m4_dnl
m4_dnl
m4_dnl M_type(substitution group / slot, substituable element)
m4_dnl for an element / attribute / port's type
m4_dnl
m4_define([[[M_type]]],[[[$1 -> $2:top [label=type][[[]]]]]])m4_dnl
m4_dnl
m4_dnl M_is(local element, global element)
m4_dnl for identifying that an element in a type is the same as a top-level element
m4_dnl
m4_define([[[M_is]]],[[[$1 -> $2 [label=is][[[]]]]]])m4_dnl
m4_dnl
m4_dnl
m4_dnl
digraph graphic {
edge [fontname = "Helvetica", fontsize=12, dir = forward];
node [fontname = "Helvetica", fontsize=12, shape = plain];
rankdir=LR;

m4_dnl =============================================================================

document [M_label_table(\N,
  M_row(title,textType,,title),
  M_row(version,textType,,),
  M_row(date,xs:date,,),
  M_row(author,textType,,),
  M_row(blurbSet,,0-n,),
  M_row(flowStructureAbstract,,0-n,=)
  )];
M_type(document:title, textType);
M_subst(document:flowStructureAbstract, flowStructureAbstract);


m4_dnl =============================================================================

textType [M_label_table(\N: mixed,
  M_row(@memberOf,IDREFS,?,),
  M_row(textAbstract,,0-n,=))];
m4_dnl
M_subst(textType:textAbstract,textAbstract:top);

m4_dnl =============================================================================

textAbstract [M_label_table(Substitution group \N,
  M_row(xmlBlurb,,,=),
  M_row(textBlurb,,,=),
  M_row(todo,no type),
  M_row(issue,...),
  M_row(code,textType),
  M_row(em,textType),
  M_row(q,textType),
  M_row(strong,textType),
  M_row(termDef,textType),
  M_row(var,textType),
  M_row(qName,xs:QName),
  M_row(local-name,xs:NCName),
  M_row(namespace-uri-for-prefix,xs:string),
  M_row(conformance-target,,,conformanceTarget),
  M_row(link,hrefType,,=),
  M_row(a,hrefType),
  M_row(termRef,,,=),
  M_row(xe,...),
  M_row(char,,,=),
  M_row(ref,,,=),
  M_row(include-text,,,includeText))];
M_is(textAbstract:xmlBlurb,xmlBlurb:top);
M_is(textAbstract:textBlurb,textBlurb:top);
M_is(textAbstract:conformanceTarget,conformanceTarget:top);
M_type(textAbstract:link,hrefType);
M_is(textAbstract:termRef,termRef:top);
M_is(textAbstract:char,char:top);
M_is(textAbstract:ref,ref:top);
M_is(textAbstract:includeText,includeText:top);

m4_dnl =============================================================================

flowStructureAbstract [M_label_table(Substitution group \N,
  M_row(flowAbstract,,,=),
  M_row(section,,,=),
  M_row(comment,,,=)
  M_row(ruleSection))];
M_subst(flowStructureAbstract:flowAbstract, flowAbstract:top);
M_type(flowStructureAbstract:section, sectionType);
M_is(flowStructureAbstract:comment, comment:top);

m4_dnl =============================================================================

flowAbstract [M_label_table(Substitution group \N,
  M_row(subsection,,,=),
  M_row(sub,flowType,,=),
  M_row(image,,,=),
  M_row(p,textType,,=),
  M_row(listOfSections,emptyType,,=),
  M_row(p-todo,textType,,=),
  M_row(pre,textType,,=),
  M_row(reference,,,=),
  M_row(ul,listType,,=),
  M_row(ol,listType),
  M_row(tableOfContents),
  M_row(tableOfFigures),
  M_row(tableOfTables),
  M_row(index),
  M_row(indexOfDefinitions),
  M_row(indexOfRules),
  M_row(table),
  M_row(blockQuote),
  M_row(bogusDefinition),
  M_row(definition),
  M_row(bogusPrinciple),
  M_row(principle),
  M_row(bogusRule),
  M_row(rule),
  M_row(figure),
  M_row(meta)
)];
M_type(flowAbstract:subsection, subsectionType);
M_is(flowAbstract:reference,reference:top);
M_is(flowAbstract:image,image);
M_type(flowAbstract:sub,flowType);
M_type(flowAbstract:ul,listType);

m4_dnl =============================================================================

listType [M_label_table(\N,
  M_row(li,flowType,1-n,=))];

m4_dnl =============================================================================

image [M_label_table(image,
  M_row(src,xs:anyURI,?))];

m4_dnl =============================================================================

reference [M_label_table(reference,
  M_row(@label,xs:string,?),
  M_row(@id,xs:ID,1),
  M_row(flowAbstract,,+,=))];

m4_dnl =============================================================================

subsectionType [M_label_table(\N,
  M_row(@id,ID,?,),
  M_row(title,textType,,=),
  M_row(flowAbstract,,0-n,=))];

m4_dnl =============================================================================

sectionType [M_label_table(\N,
  M_row(@id,ID,?,),
  M_row(@isAppendix,boolean,?,),
  M_row(title,textType,,=),
  M_row(flowStructureAbstract,,0-n,=))];

m4_dnl =============================================================================

comment [M_label_table(\N: mixed,
  M_row(any element,,0-n,))];

m4_dnl =============================================================================

flowType [M_label_table(\N,
  M_row(flowAbstract,,0-n))];

m4_dnl =============================================================================

xmlBlurb [M_label_table(\N,
  M_row(@memberOf,xs:IDREFS,?),
  M_row(@id,xs:ID),
  M_row(any element (strict),,0-n))];

m4_dnl =============================================================================

textBlurb [M_label_table(\N,
  M_row(extends xs:string),
  M_row(@memberOf,xs:IDREFS,?),
  M_row(@id,xs:ID))];

m4_dnl =============================================================================

conformanceTarget [M_label_table(conformance-target,
  M_row(extends xs:string),
  M_row(@id,xs:ID))];

m4_dnl =============================================================================

hrefType [M_label_table(\N,
  M_row(extends textType),
  M_row(@href,xs:anyURI))];

m4_dnl =============================================================================

termRef [M_label_table(\N,
  M_row(mixed extends textType),
  M_row(@term,xs:string))];

m4_dnl =============================================================================

char [M_label_table(\N,
  M_row(@name,,1,name))];
M_is(char:name,char_name);

char_name [M_label_table(attribute name,
  M_row(enumeration restricts xs:token),
  M_row(aacute: latin small letter a with acute),
  M_row(ccedil: latin small letter c with cedilla),
  M_row(eacute: latin small letter e with acute),
  M_row(hellip: horizontal ellipsis (= three dot leader)),
  M_row(mdash: em dash),
  M_row(middot: middle dot, AKA interpunct),
  M_row(nbsp: non-breaking space),
  M_row(ndash: n dash),
  M_row(ocirc: latin small letter o with circumflex),
  M_row(ouml: latin small letter o with diaeresis),
  M_row(rarr: rightwards arrow),
  M_row(rsquo: Right single quotation mark; used as an apostrophe),
  M_row(sect: Section mark))];

m4_dnl =============================================================================

ref [M_label_table(\N,
  M_row(@idref,xs:IDREF,1))];

m4_dnl =============================================================================

includeText [M_label_table(\N,
  M_row(@href,xs:anyURI,1))];


}


m4_dnl Local Variables:
m4_dnl mode: indented-text
m4_dnl indent-tabs-mode: nil
m4_dnl fill-column: 9999
m4_dnl End:
