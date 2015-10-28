m4_define([[[COLOR_FG]]],[[[#000]]])m4_dnl
m4_define([[[COLOR_BG]]],[[[#FFF]]])m4_dnl
m4_define([[[COLOR_HILIT_FG]]],[[[#000]]])m4_dnl
m4_define([[[COLOR_HILIT_BG]]],[[[#F9FAD4]]])m4_dnl
m4_define([[[COLOR_ISSUE_BG]]],[[[#FCC]]])m4_dnl
m4_define([[[COLOR_FILL]]],[[[#EEE]]])m4_dnl
m4_define([[[CODE_FONTS]]], [[["Courier New", Courier, monospace]]])m4_dnl
m4_define([[[CODE_SIZE]]], [[[80%]]])m4_dnl Courier looks big. Fix that.
m4_define([[[INDENT1]]], [[[2em]]])m4_dnl
m4_define([[[INDENT2]]], [[[4em]]])m4_dnl
body {
m4_dnl    font-family: Helvetica, Arial, "sans serif";
    font-family: "Times New Roman", Times, serif;
    background-color: COLOR_BG;
    color: COLOR_FG;
    margin: 3em;
}
p.todo {
  color: COLOR_FG;
  background-color: COLOR_ISSUE_BG;
}
a {
    text-decoration: none;
    color: COLOR_FG;
    background-color: COLOR_BG;
}
span.issue, span.issue a {
    color: COLOR_FG;
    background-color: COLOR_ISSUE_BG;
}
a[href]:hover {
    color: COLOR_HILIT_FG;
    background-color: COLOR_HILIT_BG;
}
a.url {
    font-family: CODE_FONTS;
    font-size: CODE_SIZE;
}
a.ref, span.ref {
    font-weight: bold;
}
span.termRef::before { content: "·"; }
span.termRef::after { content: "·"; }
div.img {
    width: 100%;
    text-align: center;
}	
img {
    width: 100%;
}
div.table {
}
div.table > table {
    margin: auto;
}
div.title {
    font-size: 200%;
    font-weight: bold;
    margin: 1em 5em;
    text-align: center;
}
div.subtitle {
    font-size: 150%;
    font-weight: bold;
    margin: 1em 5em;
    text-align: center;
}
div.heading {
    font-size: 125%;
    font-weight: bold;
    margin-top: 1em;
    margin-bottom: 1em;
    page-break-after: avoid;
    page-break-inside: avoid;
}
div.rule-section > div.heading {
    font-size: 100%;
}
div.section, div.rule-section {
    margin-left: INDENT1;
}
div.section div.section {
    margin-left: 0;
}
div.section div.heading {
    margin-left: -INDENT1;
}
div.meta {
    width: 33%;
    float: right;
    clear: right;
}
div.meta > p {
    padding: 0;
    margin: 0;
}
div.box, div.meta {
    background-color: COLOR_FILL;
    color: COLOR_FG;
    border: solid black 1px;
    padding: 1.0em;
}
div.box a, div.meta a {
    background-color: COLOR_FILL;
    color: COLOR_FG;
}
div.box a:hover, div.meta a:hover {
    background-color: COLOR_HILIT_BG;
    color: COLOR_HILIT_FG;
}
div.box + div.box, div.figure + div.box {
    margin-top: 1em;
}
div.normativeHead {
    font-weight: bold;
    margin-bottom: 1em;
}
dfn {
    font-style: normal;
    font-weight: bold;
}
div.sub {
    margin-left: INDENT1;
}
div.sub > *:last-child {
    margin-bottom: 0;
}
td,th {
    border: solid black 1px;
}
th {
   color: COLOR_FG;
   background-color: COLOR_FILL;
}
table {
    border-collapse: collapse;
}
code {
    font-family: CODE_FONTS;
    font-size: CODE_SIZE;
}
pre {
    font-family: CODE_FONTS;
    font-size: CODE_SIZE;
    white-space: pre-wrap;
    margin: 0;
}
div.caption {
    font-weight: bold;
    text-align: center;
    page-break-after: avoid;
    page-break-inside: avoid;
}
p.hang {
    text-indent: -INDENT1;
    margin-left: INDENT1;
}
q {
  quotes: '\201C' '\201D' '\2018' '\2019';
}
q:before {
  content: open-quote;
}
q:after {
  content: close-quote;
}
m4_dnl we want outlines to look like 2. B. ...
ol ol > li { 
  list-style-type: upper-alpha; 
}
