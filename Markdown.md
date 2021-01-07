# Markdown format

The package's output Markdown is designed to be friendly with pandoc. It is intended for production of Microsoft Word-formatted documents.

# Pandoc flags

Suggested flags for pandoc:

from Markdown: `--from=markdown+backtick_code_blocks+definition_lists+superscript+footnotes+fenced_divs`

to Word docx: `--to=docx --reference-doc=reference.docx --table-of-contents --toc-depth=1`

A good sample doc is at `~/r/niem/internationalization/ntac-perspective/writeup/NIEM-Internationalization.md`

# Styles

The Markdown-to-docx convert seems unable to create nested styles:

   * No nested paragraphs. I can't make a "box" that surrounds a set of paragraphs.
   
      * If I put a style on a div, the local formatting (e.g., block quote) overrides whatever the span's style is.
   
   * No nested character styles, so you can't nest a bold thing inside an italic thing.
   
   * No custom styles on preformatted content: I can't figure out how to make preformatted content come out as anything other than style "Source Code". Also a problem: span code content also gets styled as "Source Code".
   
     If I put a custom style on a fenced block, the style gets generated in the output docx, but it's not applied to that fenced block.
   

# numbered lists

I don't know how to restart numbered lists using styles.

# Fake preformatted sections

fake preformatted sections with "line blocks", extension "line_blocks", like this:

Use extension `-smart` to prevent it from converting straight quotes to curly open & close quotes.

::: {custom-style="doc.figure.pre"}
| &lt;xs:complexType name="PersonType">
|   ...
|     and different whitespace &amp;gt; ok?
| &lt;/xs:complexType>
:::


# Fenced divs to put named anchors on things other than headers

Use `--from=+fenced_divs` to support hrefs to paragraphs:

```
::: {#rfc4627}

blah blah

:::
```

# Bracketed spans to add custom styles to links

`[[this is a link](https://example.org)]{custom-style="Style1"}`

Style1 will show up as a style in the resulting Word doc.

If you don't wrap the link in the extra set of brackets, the custom style will not show up in Word, even though an attribute will show up in the XHTML version.

# Fence links

In .docx output, all links are being styled "Hyperlink" regardless of what I put in the Markdown. I'd like for literal <link/> tags to be code. So:

```
[`https://example.org`](https://example.org)
```

# Issues

