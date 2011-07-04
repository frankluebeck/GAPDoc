/* manual.js                                               Frank Lübeck  */

/* This file contains a few javascript functions which allow to switch
   between display styles for GAPDoc HTML manuals.
   If javascript is switched off in a browser or this file in not available
   in a manual directory, this is no problem. Users just cannot switch
   between several styles and don't see the corresponding button.

   A style with name mystyle can be added by providing two files (or only
   one of them).
     mystyle.js:   Additional javascript code for the style, it is 
                   read in the HTML pages after this current file.
                   The additional code may adjust the preprocessing function 
                   jscontent() with is called onload of a file.
                   Make sure, that your style is still usable without
                   javascript.
     mystyle.css:  CSS configuration, read after manual.css (so it can 
                   just reconfigure a few details, or overwrite everything).
                 
  For the style chooser, add information to the variable 'availablestyles'
  below: 
     +';mystyle=A short description of mystyle.'
 
  A user can change the preferred style permanently by using the [Style]
  link and choosing one. Or one can append '?GAPDocStyle=mystyle' to the URL
  when loading any file of the manual (so the style can be configured in
  the GAP user preferences). 

*/

availablestyles='default=the default style'
               +';toggless=allow toggling the display of subsections in TOCs'
               +';times=serif fonts and no justified formatting, toc on left'
               +';rainbow=you don\'t want to use this!'

/* generic helper function */
function deleteCookie(nam) {
  document.cookie = nam+"=;Path=/;expires=Thu, 01 Jan 1970 00:00:00 GMT";
}

/* read a value from a "nam1=val1;nam2=val2;..." string (e.g., the search
   part of an URL or a cookie                                             */
function valueString(str,nam) {
  var cs = str.split(";");
  for (var i=0; i < cs.length; i++) {
    var pos = cs[i].search(nam+"=");
    if (pos > -1) {
      pos = cs[i].indexOf("=");
      return cs[i].slice(pos+1);
    }
  }
  return 0;
}

/* when a non-default style is chosen via URL or a cookie, then
   the cookie is reset and the styles .js and .css files are read  */
function overwriteStyle() {
  /* style in URL? */
  var style = valueString(window.location.search, "GAPDocStyle");
  /* otherwise check cookie */
  if (style == 0)
    style = valueString(document.cookie, "GAPDocStyle");
  if (style == 0)
    return;
  if (style == "default")
    deleteCookie("GAPDocStyle");
  else {
    /* ok, we set the cookie for path "/" */
    var path = "/";
    /* or better like this ???
    var here = window.location.pathname.split("/");
    for (var i=0; i+3 < here.length; i++)
      path = path+"/"+here[i];
    */
    document.cookie = "GAPDocStyle="+style+";Path="+path;
    /* read style's css and js files */
    document.writeln('<link rel="stylesheet" type="text/css" href="'+
                                                           style+'.css" />');
    document.writeln('<script src="'+style+
                                    '.js" type="text/javascript"></script>');
  }
}

/* this adds a "[Style]" link next to the MathJax switcher   */
function addStyleLink() {
  var line = document.getElementById("mathjaxlink");
  var el = document.createElement("a");
  var oncl = document.createAttribute("href");
  oncl.nodeValue = "javascript:showstylechooser()";
  el.setAttributeNode(oncl);
  var cont = document.createTextNode(" [Style]");
  el.appendChild(cont);
  line.appendChild(el);
}

/* this displays information about available styles on top of the page
   and provides links to reload the current file with other styles       */
function showstylechooser() {
  var st = availablestyles.split(";");
  var out = document.createElement("dl");
  var att = document.createAttribute("id");
  att.nodeValue = "stylechooserlist";
  out.setAttributeNode(att);
  for (var i = 0; i < st.length; i++) {
    var pos = st[i].indexOf("=");
    var ch = document.createElement("dt");
    var lnk = document.createElement("a");
    att = document.createAttribute("href");
    att.nodeValue = window.location.pathname+"?GAPDocStyle="+st[i].slice(0,pos);
    lnk.setAttributeNode(att);
    var txt = document.createTextNode( st[i].slice(0,pos) );
    lnk.appendChild(txt);
    ch.appendChild(lnk);
    out.appendChild(ch);
    ch = document.createElement("dd");
    txt = document.createTextNode( st[i].slice(pos+1) );
    ch.appendChild(txt);
    out.appendChild(ch);
  }
  lnk = document.getElementById("mathjaxlink").nextSibling;
  document.getElementsByTagName("body")[0].insertBefore(out, lnk);
}

/* the default jscontent() only adds the [Style] link to the page */
function jscontent () {
  addStyleLink();
}

