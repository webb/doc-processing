doc-processing
=====

This package generates documents from a custom XML format

See [Markdown.md](Markdown.md) for notes about the Markdown that this package generates.

# Hints

When you're droppping an name anchor in text, don't wrap the anchor around the
contained text; just make the anchor a point (a content-free element). For
example, don't do this:

```xml
<p>This is a <a name="blah1">very nested <a name="blah2">thing</a>
that might have</a> problems.</p>
```

Instead, do this:

```xml
<p>This is a <a name="blah1"/>very nested <a name="blah2"/>thing
that might have problems.</p>
```

# Caveats for Microsft Word (.docx) outputs

There will be lots of styles; make sure your reference.docx file covers all the style you use.

The styles for ordered lists (`doc:ol`) do not restart numbering. In the style menu, look for styles containing `.ol.li-first` (in the Styles Pane, click on the style's menu arrow, and click "Select All"), and manually restart numbering where appropriate. Sorry.

I don't know how to apply styles to tables, so those will have to be tweaked manually.

Images get a style, but I don't now how to make that style size the images appropriately.

