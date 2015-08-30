doc-processing
=====

This package generates documents from a custom XML format

Copyright 2014-2015 Georgia Tech Research Corporation (GTRC). All rights
reserved.

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



