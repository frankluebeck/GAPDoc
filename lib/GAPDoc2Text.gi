#############################################################################
##
#W  GAPDoc2Text.gi                 GAPDoc                        Frank Lübeck
##
#H  @(#)$Id: GAPDoc2Text.gi,v 1.9 2001-11-16 15:20:48 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The  files GAPDoc2Text.g{d,i}  contain  a  conversion program  which
##  produces from a  GAPDoc XML-document a text version  for viewing the
##  document on screen (GAP online help).
##  

##  
##  We add a link to the document root to all recursively called functions
##  by adding .root entries.    The toc-, index- and  bib-information   is
##  collected in the root.
##  
##  The set of elements is partitioned into two subsets - those which
##  contain whole paragraphs and those which don't. 
##  
##  The     handler  of  a    paragraph       containing  element     (see
##  GAPDoc2TextProcs.ParEls below) gets a list as argument to which it adds
##  entries pairwise: the first of  such a pair  is the paragraph  counter
##  (like [3,2,1,5] meaning Chap.3, Sec.2, Subsec.1, Par.5) and the second
##  is the formatted text of this paragraph.
##  
##  Some   handlers  of paragraph   containing  elements do the formatting
##  themselves (e.g., .List), the others are handled in the main recursion
##  function `GAPDoc2TextContent'.
##  
##  We produce  a full version of  the document  in text format, including
##  title   page, abstract and  other front   matter,  table of  contents,
##  bibliography (via   BibTeX-data  files) and  index.  Highlighting with
##  colors for ANSI color sequence capable terminals is included.
##  
##  In   this text converter  we also   produce  the manual.six  data. For
##  getting page  numbers in .dvi  and .pdf  versions, the LaTeX-converter
##  and LaTeX must be run first. This produces a .pnr file.
##  

InstallValue(GAPDoc2TextProcs, rec());

##  Some text attributes for display on ANSI terminals
GAPDoc2TextProcs.TextAttr := rec();
GAPDoc2TextProcs.TextAttr.reset := TextAttr.reset;
GAPDoc2TextProcs.TextAttr.Heading := Concatenation(TextAttr.bold,
                                       TextAttr.underscore, TextAttr.1);

GAPDoc2TextProcs.TextAttr.Func := Concatenation(TextAttr.bold, TextAttr.4);
GAPDoc2TextProcs.TextAttr.Arg := Concatenation(TextAttr.normal, TextAttr.4);
GAPDoc2TextProcs.TextAttr.Example := Concatenation(TextAttr.normal, TextAttr.5);
GAPDoc2TextProcs.TextAttr.Package := TextAttr.bold;
GAPDoc2TextProcs.TextAttr.Returns := TextAttr.bold;
GAPDoc2TextProcs.TextAttr.URL := TextAttr.4;
GAPDoc2TextProcs.TextAttr.Mark := Concatenation(TextAttr.bold, TextAttr.3);

GAPDoc2TextProcs.TextAttr.K := Concatenation(TextAttr.normal, TextAttr.2);
GAPDoc2TextProcs.TextAttr.C := Concatenation(TextAttr.normal, TextAttr.2);
GAPDoc2TextProcs.TextAttr.F := Concatenation(TextAttr.bold, "");
GAPDoc2TextProcs.TextAttr.B := Concatenation(TextAttr.bold, TextAttr.b6);
GAPDoc2TextProcs.TextAttr.Emph := Concatenation(TextAttr.normal, TextAttr.6);

GAPDoc2TextProcs.TextAttr.Ref := TextAttr.bold;

GAPDoc2TextProcs.ParEls := 
[ "Display", "Example", "Log", "Listing", "List", "Enum", "Item", "Table", 
  "TitlePage", "Abstract", "Copyright", "Acknowledgements", "Colophon", 
  "TableOfContents", "Bibliography", "TheIndex", "Subsection", "ManSection", 
  "Description", "Returns", "Section", "Chapter", "Appendix", "Body", "Book", 
  "WHOLEDOCUMENT", "Attr", "Fam", "Filt", "Func", "Heading", "InfoClass", 
  "Meth", "Oper", "Prop", "Var", "Verb" ];

##  arg: a list of strings
##  nothing for now, may be enhanced and documented later. 
SetGapDocTxtOptions := function(arg)    
  local   gdp;
  gdp := GAPDoc2TextProcs;
  return;  
end;

##  here we collect paragraphs to whole chapters and remember line numbers
##  of subsections for the .six information
GAPDoc2TextProcs.PutFilesTogether := function(l, six)
  local   countandshift,  concat, files,  n,  i,  p,  a;
  
  # count number of lines in txt and add 2 spaces in the beginning of
  # each  line, returns [newtxt, nrlines]
  countandshift := function(txt)
    local   new,  ind,  n,  p,  pos;
    # sometimes there may occur paragraph elements inside text elements
    # (like list in list item) - we concatenate the text here.
    concat := function(txt)
      local new, a;
      if not IsString(txt) then
        new := "";
        for a in txt do
          if IsChar(a) then
            Add(new, a);
          elif IsList(a) then
            Append(new, concat(a));
          fi;
        od;
      else
        new := txt;
      fi;
      ConvertToStringRep(new);
      return new;
    end;
    txt := concat(txt);
    new := "  ";
    ind := "  ";
    n := 0;
    p := 0;
    pos := Position(txt, '\n');
    while pos <> fail do
      Append(new, txt{[p+1..pos]});
      if pos < Length(txt) then
        Append(new, ind);
      fi;
      n := n+1;
      p := pos;
      pos := Position(txt, '\n', p);
    od;
    if p < Length(txt) then
      Append(new, txt{[p+1..Length(txt)]});
    fi;
    return [new, n];
  end;

  # putting the paragraphs together (one string (file) for each chapter)
  files := rec();
  for n in Set(List([2,4..Length(l)], i-> l[i-1][1])) do
    files.(n) := rec(text := "", ssnr := [], linenr := [], len := 0);
  od;
  for i in [2,4..Length(l)] do
    n := files.(l[i-1][1]);
    p := countandshift(l[i]);
    if Length(n.ssnr)=0 or l[i-1]{[1..3]} <> n.ssnr[Length(n.ssnr)] then
      Add(n.ssnr, l[i-1]{[1..3]});
      Add(n.linenr, n.len+1);
    fi;
    Append(n.text, p[1]);
    n.len := n.len + p[2];
  od;
  
  # add line numbers to six information
  for a in six do
    p := Position(files.(a[3][1]).ssnr, a[3]);
    if p = fail then
      Error("don't find subsection ", a[3], " in text documention");
    fi;
    Add(a, files.(a[3][1]).linenr[p]);
  od;
  
  return files;
end;

##  <#GAPDoc Label="GAPDoc2Text">
##  <ManSection >
##  <Func Arg="tree[, bibpath][, width]" Name="GAPDoc2Text" />
##  <Returns>record  containing  text  files  as  strings  and  other
##  information</Returns>
##  <Description>
##  The   argument  <A>tree</A>   for   this  function   is  a   tree
##  describing  a   &GAPDoc;  XML   document  as  returned   by  <Ref
##  Func="ParseTreeXMLString"  /> (probably  also  checked with  <Ref
##  Func="CheckAndCleanGapDocTree" />). This function produces a text
##  version of  the document  which can be  used with  &GAP;'s online
##  help (with  the <C>"screen"</C>  viewer, see  <Ref BookName="Ref"
##  Func="SetHelpViewer"  />). It  includes title  page, bibliography
##  and  index. The  bibliography  is made  from &BibTeX;  databases.
##  Their location must be given with the argument <A>bibpath</A> (as
##  string or directory object).<P/>
##  
##  The  output is  a  record  with one  component  for each  chapter
##  (with  names   <C>"0"</C>,  <C>"1"</C>,  ...,   <C>"Bib"</C>  and
##  <C>"Ind"</C>).  Each  such  component   is  also  a  record  with
##  components
##  
##  <List >
##  <Mark><C>text</C></Mark>
##  <Item>the text of the whole chapter as a string</Item>
##  <Mark><C>ssnr</C></Mark>
##  <Item>list of subsection numbers in  this chapter (like <C>[3, 2,
##  1]</C>  for  chapter&nbsp;3,  section&nbsp;2,  subsection&nbsp;1)
##  </Item>
##  <Mark><C>linenr</C></Mark>
##  <Item>corresponding list  of line  numbers where  the subsections
##  start</Item>
##  <Mark><C>len</C></Mark>
##  <Item>number of lines of this chapter</Item>
##  </List>
##  
##  The  result can  be  written  into files  with  the command  <Ref
##  Func="GAPDoc2TextPrintTextFiles" />.<P/>
##  
##  As   a   side   effect    this   function   also   produces   the
##  <F>manual.six</F>  information which  is  used  for searching  in
##  &GAP;'s  online help.  This is  stored in  <C><A>tree</A>.six</C>
##  and   can  be   printed  into   a  <F>manual.six</F>   file  with
##  <Ref   Func="PrintSixFile"  />   (preferably  after   producing  a
##  &LaTeX;  version  of   the  document  as  well   and  adding  the
##  page  number  information  to  <C><A>tree</A>.six</C>,  see  <Ref
##  Func="GAPDoc2LaTeX"   />   and  <Ref   Func="AddPageNumbersToSix"
##  />).<P/>
##  
##  The  text produced  by this  function contains  color markup  via
##  ANSI  escape  sequences,  see   <Ref  Var="TextAttr"/>.  To  view
##  the  colored text  you  need a  terminal  which interprets  these
##  escape  sequences correctly  and  you have  to  set the  variable
##  <C>ANSI&uscore;COLORS</C> to <K>true</K> (a  good place for doing
##  this is your <F>.gaprc</F> file).<P/>
##  
##  With the optional argument <A>width</A> a different length of the
##  output text lines can be chosen.  The default is 76 and all lines
##  in the resulting text start with two spaces. This looks good on a
##  terminal with a standard width  of 80 characters and you probably
##  don't want to use this argument.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# the basic call, used recursively with a result r from GetElement 
# and a string str or list l to which the output should be appended
# arg: r[, linelength]       (then a list is returned, only for whole document)
# or:  r, str[, linelength]  (then the output is appended to string or
#                             list str)
InstallGlobalFunction(GAPDoc2Text, function(arg)
  local   r,  str,  linelength,  name;
  r := arg[1];
  if Length(arg)=2 and (IsList(arg[2]) or (r.name = "WHOLEDOCUMENT" and
                                                 IsDirectory(arg[2]))) then
    str := arg[2];
    linelength := 76;
  elif Length(arg)=2 and IsInt(arg[2]) then
    linelength := arg[2];
    str := "";
  elif Length(arg)=3 then
    str := arg[2];
    linelength := arg[3];
  else
    str := "";
    linelength := 76;
  fi;
  
  if r.name = "WHOLEDOCUMENT" then
    r.linelength := linelength;
    r.indent := "";
    if IsDirectory(str) then
      r.bibpath := str;
    else
      r.bibpath := Directory(str);
    fi;
    str := "";
  fi;
  
  name := r.name;
  if not IsBound(GAPDoc2TextProcs.(name)) then
    Print("WARNING: Don't know how to process element ", name, 
          " ---- ignored\n");
  else
    GAPDoc2TextProcs.(r.name)(r, str);
  fi;
  
  if r.name = "WHOLEDOCUMENT" then
    # put final record together and return it, also add line numbers to
    # .six entries
    return GAPDoc2TextProcs.PutFilesTogether(str, r.six);  
  fi;

  return str;
end);

##  recursion through the tree and formatting paragraphs
BindGlobal("GAPDoc2TextContent", function(r, l)
  local   par,  cont,  count,  s,  a;
  
  # utility: append counter and formatted paragraph to l
  par := function(s)
    if Length(s)>0 then
      s := FormatParagraph(s, r.root.linelength - Length(r.root.indent), 
                           "both", [r.root.indent, ""]);
      if Length(s)>0 then
        GAPDoc2TextProcs.P(0, s);
        Add(l, count);
        Add(l, s);
      fi;
    fi;
  end;
  
  # if not containing paragraphs, then l is string to append to
  if not r.name in GAPDoc2TextProcs.ParEls then
    for a in r.content do
      GAPDoc2Text(a, l);
    od;
    return;
  fi;
  
  # otherwise we have to collect text and paragraphs
  cont := r.content;
  count := r.count;
  s := "";
  for a in cont do
    if a.count <> count  then
      par(s);
      count := a.count;
      s := "";
    fi;
    if a.name in GAPDoc2TextProcs.ParEls then
      # recursively collect paragraphs
      GAPDoc2Text(a, l);
    else 
      # collect text for current paragraph
      GAPDoc2Text(a, s);
    fi;
  od;
  if Length(s)>0 then
    par(s);
  fi;
end);

  
##  write head and foot of Txt file.
GAPDoc2TextProcs.WHOLEDOCUMENT := function(r, par)
  local   i,  pi,  t,  el,  a,  str,  bib,  keys,  need,  labels,  
          diff,  text,  stream;
  
  ##  add paragraph numbers to all nodes of the document
  AddParagraphNumbersGapDocTree(r);
  
  ##  add a link .root to the root of the document to all nodes
  ##  (then we can collect information about indexing and so on 
  ##  there)
  AddRootParseTree(r);
  r.index := [];
  r.toc := "";
  r.labels := rec();
  r.labeltexts := rec();
  r.bibkeys := [];
  # and the .six information for the online help index
  # will contain pairs [string, [chap, sect, subsect]]
  r.six := [];
  
  ##  checking for processing instructions before the book starts
  ##  example:  <?Txt option1="value1" ?>
  i := 1;
  pi := rec();
  while not r.content[i].name = "Book" do
    if r.content[i].name = "XMLPI" then
      t := r.content[i].content;
      if Length(t) > 3 and t{[1..4]} = "Txt " then
        el := GetSTag(Concatenation("<", t, ">"), 2);
        for a in NamesOfComponents(el.attributes) do
          pi.(a) := el.attributes.(a);
        od;
      fi;
    fi;
    i := i+1;
  od;
  
  ##  Now the actual work starts, we give the processing instructions found
  ##  so far to the Book handler.
  ##  We call the Book handler twice and produce index, bibliography, toc
  ##  in between.
  Print("#I  first run, collecting cross references, index, toc, bib ",
        "and so on . . .\n");
  GAPDoc2TextProcs.Book(r.content[i], [], pi);
  
  # now the toc is ready
  Print("#I  table of contents complete.\n");
  r.toctext := r.toc;
  
  # .index has entries of form [sorttext, subtext, numbertext, entrytext]
  Print("#I  producing the index . . .\n");
  Sort(r.index);
  str := "";
  for a in r.index do
    Append(str, a[4]);
    if Length(a[2])>0 then
      Append(str, ", ");
      Append(str, a[2]);
    fi;
    Append(str, "  ");
    Append(str, a[3]);
    Add(str, '\n');
  od;
  r.indextext := str;
  
  if Length(r.bibkeys)>0 then
    Print("#I  reading bibliography data files . . . \n");
    bib := CallFuncList(ParseBibFiles, List(SplitString(
                    r.bibdata, "", ", \t\t\n"), f-> Filename(r.bibpath, f)));
    keys := Immutable(Set(r.bibkeys));
    need := [];
    for a in bib[1] do
      if a.Label in keys then
        NormalizeNameAndKey(a);
        Add(need, a);
      fi;
    od;
    SortParallel(List(need, a-> a.keylong), need);
    keys := List(need, a-> a.Label);
    labels := List(need, a-> a.key);
    diff := Difference(r.bibkeys, keys);
    if Length(diff) > 0 then
      Print("#W  could not find references: ", diff, "\n");
    fi;
    r.bibkeys := keys;
    r.biblabels := labels;
    Print("#I  writing bibliography . . .\n");
    text := "";
    stream := OutputTextString(text, false);
    PrintTo1(stream, function()
    for a in need do PrintBibAsText(a, true); od;
    end);
    CloseStream(stream);
    r.bibtext := text;
  fi;
  
  # second run
  r.six := [];
  r.index := [];
  Print("#I  second run through document . . .\n");
  GAPDoc2TextProcs.Book(r.content[i], par, pi);
  # adding .six entries from index
  for a in r.index do
    if Length(a[2]) > 0 then
      Add(r.six, [Concatenation(a[4], " ", a[2]), a[3], a[5]]);
    else
      Add(r.six, [a[4],  a[3], a[5]]);
    fi;
  od;
  
  ##  remove the links to the root  ???
##    RemoveRootParseTree(r);
end;

##  comments and processing instructions are in general ignored
GAPDoc2TextProcs.XMLPI := function(r, str)
  return;
end;
GAPDoc2TextProcs.XMLCOMMENT := function(r, str)
  return;
end;

# just process content ??? putting together here
GAPDoc2TextProcs.Book := function(r, par, pi)
  r.root.Name := r.attributes.Name;
  GAPDoc2TextContent(r, par);
end;

##  Body is sectioning element
GAPDoc2TextProcs.Body := GAPDoc2TextContent;

##  the title page,  the most complicated looking function
GAPDoc2TextProcs.TitlePage := function(r, par)
  local   strn,  l,  s,  a,  aa,  cont,  ss;
  
  strn := "\n\n";
  
  # the .six entry 
  Add(r.root.six, ["Title page", 
          GAPDoc2TextProcs.SectionNumber(r.count, "Subsection"),
          r.count{[1..3]}]);
  
  # title
  l := Filtered(r.content, a-> a.name = "Title");
  s := "";
  GAPDoc2TextContent(l[1], s);
  s := FormatParagraph(s, r.root.linelength, "center",
               [GAPDoc2TextProcs.TextAttr.Heading, 
               GAPDoc2TextProcs.TextAttr.reset]); 
  Append(strn, s);
  Append(strn, "\n\n");
  
  # subtitle
  l := Filtered(r.content, a-> a.name = "Subtitle");
  if Length(l)>0 then
    s := "";
    GAPDoc2TextContent(l[1], s);
    s := FormatParagraph(s, r.root.linelength, "center",
                 [GAPDoc2TextProcs.TextAttr.Heading, 
                 GAPDoc2TextProcs.TextAttr.reset]); 
    Append(strn, s);
    Append(strn, "\n\n");
  fi;
  
  # version
  l := Filtered(r.content, a-> a.name = "Version");
  if Length(l)>0 then
    s := "";
    GAPDoc2TextContent(l[1], s);
    while Length(s)>0 and s[Length(s)] in  WHITESPACE do
      Unbind(s[Length(s)]);
    od;
    s := FormatParagraph(s, r.root.linelength, "center");
    Append(strn, s);
    Append(strn, "\n\n");
  fi;

  # date
  l := Filtered(r.content, a-> a.name = "Date");
  if Length(l)>0 then
    s := "";
    GAPDoc2TextContent(l[1], s);
    s := FormatParagraph(s, r.root.linelength, "center");
    Append(strn, s);
    Append(strn, "\n\n");
  fi;

  # author name(s)
  l := Filtered(r.content, a-> a.name = "Author");
  for a in l do
    s := "";
    aa := ShallowCopy(a);
    aa.content := Filtered(a.content, b-> not b.name in ["Email", "Homepage"]);
    GAPDoc2TextContent(aa, s);
    s := FormatParagraph(s, r.root.linelength, "center");
    Append(strn, s);
    Append(strn, "\n");
  od;
  Append(strn, "\n\n");
  
  # email and WWW-homepage of author(s), if given
  for a in l do
    cont := List(a.content, b-> b.name);
    if "Email" in cont or "Homepage" in cont then
      s := "";
      aa := ShallowCopy(a);
      aa.content := Filtered(a.content, b-> not b.name in 
                            ["Email", "Homepage"]);
      GAPDoc2TextContent(aa, s);
      NormalizeWhitespace(s);
      Append(strn, s);
      
      if "Email" in cont then
        Append(strn, " --- Email: ");
        GAPDoc2Text(a.content[Position(cont, "Email")], strn);
      fi;
      if "Homepage" in cont then
        Append(strn, "\n");
        Append(strn, "   --- Homepage: ");
        GAPDoc2Text(a.content[Position(cont, "Homepage")], strn);
      fi;
      Append(strn, "\n");
    fi;
  od;
  Append(strn, "\n-------------------------------------------------------\n");
  
  Add(par, r.count);
  Add(par, strn);
  
  # abstract, copyright page, acknowledgements, colophon
  for ss in ["Abstract", "Copyright", "Acknowledgements", "Colophon" ] do
    l := Filtered(r.content, a-> a.name = ss);
    if Length(l)>0 then
      # the .six entry 
      Add(r.root.six, [ss, 
              GAPDoc2TextProcs.SectionNumber(l[1].count, "Subsection"),
              l[1].count{[1..3]}]);
      Add(par, l[1].count);
      Add(par, Concatenation(GAPDoc2TextProcs.TextAttr.Heading, ss,
            GAPDoc2TextProcs.TextAttr.reset, "\n"));
      GAPDoc2TextContent(l[1], par);
      Append(par[Length(par)], 
             "\n-------------------------------------------------------\n");
    fi;
  od;
end;

##  these produce text for an URL
##  ~ and # characters are correctly escaped
##  arg:  r, str[, pre]
GAPDoc2TextProcs.URL := function(arg)
  local   r,  str,  pre,  s,  p;
  r := arg[1];
  str := arg[2];
  if Length(arg)>2 then
    pre := arg[3];
  else
    pre := "";
  fi;
  
  s := "";
  GAPDoc2TextContent(r, s);
  Append(str, Concatenation(GAPDoc2TextProcs.TextAttr.URL, 
          pre, s, GAPDoc2TextProcs.TextAttr.reset));
end;

GAPDoc2TextProcs.Homepage := GAPDoc2TextProcs.URL;

GAPDoc2TextProcs.Email := function(r, str)
  # we add the `mailto://' phrase
  GAPDoc2TextProcs.URL(r, str, "mailto:");
end;

##  utility: generate a chapter or (sub)section-number string 
GAPDoc2TextProcs.SectionNumber := function(count, sect)
  local   res;
  if IsString(count[1]) or count[1]>0 then
    res := Concatenation(String(count[1]), ".");
  else
    res := "";
  fi;
  if sect="Chapter" then
    return res;
  fi;
  if count[2]>0 then
    Append(res, String(count[2]));
  fi;
  if sect="Section" then
    return res;
  fi;
  if count[3]>0 then
    Append(res, Concatenation("-", String(count[3])));
  fi;
  if sect="Par" then
    Append(res, Concatenation(".", String(count[4])));
    return res;
  fi;
  # default is SubSection or ManSection number
  return res;
end;

  
##  the sectioning commands are just translated and labels are
##  generated, if given as attribute
GAPDoc2TextProcs.ChapSect := function(r, par, sect)
  local   num,  posh,  s,  ind, strn;
  
  # section number as string
  num := GAPDoc2TextProcs.SectionNumber(r.count, sect);
  
  # the heading
  posh := Position(List(r.content, a-> a.name), "Heading");
  if posh <> fail then      
    s := "";
    # first the .six entry
    GAPDoc2TextProcs.Heading1(r.content[posh], s);
    Add(r.root.six, [NormalizedWhitespace(FormatParagraph(s,
                 r.root.linelength, [GAPDoc2TextProcs.TextAttr.Heading,
                 GAPDoc2TextProcs.TextAttr.reset])), num, r.count{[1..3]}]);
    
    # label entry, if present
    if IsBound(r.attributes.Label) then
      r.root.labels.(r.attributes.Label) := num;
      r.root.labeltexts.(r.attributes.Label) := s;
    fi;
  
    # the heading text
    s := Concatenation(num, " ", s);
    Add(par, r.count);
    # here we assume that r.indent = ""
    Add(par, Concatenation("\n", FormatParagraph(s,
                 r.root.linelength, [GAPDoc2TextProcs.TextAttr.Heading,
                         GAPDoc2TextProcs.TextAttr.reset]), "\n"));
    
    # table of contents entry
    if sect="Section" then 
      ind := "  ";
    elif sect="Subsection" then
      ind := "    ";
    else
      ind := "";
    fi;
    Append(r.root.toc, FormatParagraph(s,
            r.root.linelength-Length(ind), "left", [ind, ""]));
  fi;
  
  # the actual content
  GAPDoc2TextContent(r, par);
end;

##  this really produces the content of the heading
GAPDoc2TextProcs.Heading1 := function(r, str)
  local a;
  a := [];
  GAPDoc2TextContent(r, a);
  Append(str, a[2]);
end;
##  and this ignores the heading (for simpler recursion)
GAPDoc2TextProcs.Heading := function(r, str)
end;

GAPDoc2TextProcs.Chapter := function(r, par)
  GAPDoc2TextProcs.ChapSect(r, par, "Chapter");
end;

GAPDoc2TextProcs.Appendix := function(r, par)
  GAPDoc2TextProcs.ChapSect(r, par, "Appendix");
end;

GAPDoc2TextProcs.Section := function(r, par)
  GAPDoc2TextProcs.ChapSect(r, par, "Section");
end;

GAPDoc2TextProcs.Subsection := function(r, par)
  GAPDoc2TextProcs.ChapSect(r, par, "Subsection");
end;

##  table of contents, just puts "TOC" in first run
GAPDoc2TextProcs.TableOfContents := function(r, par)
  # the .six entry 
  Add(r.root.six, ["Table of contents", 
          GAPDoc2TextProcs.SectionNumber(r.count, "Subsection"),
          r.count{[1..3]}]);

  Add(par, r.count);
  if IsBound(r.root.toctext) then
    Add(par, Concatenation("\n\n", GAPDoc2TextProcs.TextAttr.Heading,
        "Content (", r.root.Name, ")", GAPDoc2TextProcs.TextAttr.reset, 
        "\n\n", r.root.toctext,
        "\n\n-------------------------------------------------------\n"));
  else
    Add(par,"TOC\n-----------\n");
  fi;
end;

##  bibliography, just "BIB" in first run, store databases in root
GAPDoc2TextProcs.Bibliography := function(r, par)
  local   s;
  # .six entries
  s := GAPDoc2TextProcs.SectionNumber(r.count, "Chapter");
  Add(r.root.six, ["Bibliography", s, r.count{[1..3]}]);
  Add(r.root.six, ["References", s, r.count{[1..3]}]);  
  
  r.root.bibdata := r.attributes.Databases;
  Add(par, r.count);
  if IsBound(r.root.bibtext) then
    Add(par, Concatenation("\n\n", GAPDoc2TextProcs.TextAttr.Heading,
          "References", GAPDoc2TextProcs.TextAttr.reset, "\n\n", r.root.bibtext,
          "\n\n-------------------------------------------------------\n"));
  else
    Add(par,"BIB\n-----------\n");
  fi;
end;

##  We filter TeX commands and substitute \& -> & and so on, ~ -> NoBrkSpace
GAPDoc2TextProcs.PCDATAFILTERoutdated := function(r, str)
  local   cont,  lc,  i,  s,  j;
  cont := r.content;
  lc := Length(cont);
  i := 1;
  s := "";
  while i <= lc do
    if not cont[i] in "\\~" then
      j := i+1;
      while j <= lc and not cont[j] in "\\~" do
        j := j+1;
      od;
      Append(s, cont{[i..j-1]});
      i := j;
    elif cont[i] = '\\' then
      if i=lc then
        # trailing \ is removed
        break;
      elif cont[i+1] in LETTERS then
        # TeX command is removed
        j := i+2;
        while j <= lc and cont[j] in LETTERS do
          j := j+1;
        od;
        i := j;
      else
        # next character is considered to be escaped by the \
        # only the \ itself is removed
        Add(s, cont[i+1]);
        i := i+2;
      fi;
    elif cont[i] = '~' then
      # character 160 is a non-breakable space in iso-8859-1
      Add(s, CHAR_INT(160));
      i := i+1;
    fi;
  od;
  Append(str, s);
end;

##  inside <M> element we don't want this filtering
GAPDoc2TextProcs.PCDATANOFILTER := function(r, str)
  Append(str, r.content);
end;

## default is with filter ???changed???
GAPDoc2TextProcs.PCDATAFILTER := GAPDoc2TextProcs.PCDATANOFILTER;
GAPDoc2TextProcs.PCDATA := GAPDoc2TextProcs.PCDATAFILTER;

##  end of paragraph (end with double newline)
GAPDoc2TextProcs.P := function(r, str)
  local   l,  i;
  l := Length(str);
  if l>0 and str[l] <> '\n' then
    Append(str, "\n\n");
  elif l>1 and str[l-1] <> '\n' then
    Add(str, '\n');
  else
    # remove too many line breaks
    i := l-2;
    while i>0 and str[i] = '\n' do
      Unbind(str[i+2]);
      i := i-1;
    od;
  fi;
end;

##  wrapping text attributes
GAPDoc2TextProcs.WrapAttr := function(r, str, a)
  local   s;
  s := "";
  GAPDoc2TextContent(r, s);
  Append(str, Concatenation(GAPDoc2TextProcs.TextAttr.(a), s, 
              GAPDoc2TextProcs.TextAttr.reset));
end;

##  GAP keywords 
GAPDoc2TextProcs.K := function(r, str)
  GAPDoc2TextProcs.WrapAttr(r, str, "K");
end;

##  verbatim GAP code
GAPDoc2TextProcs.C := function(r, str)
  GAPDoc2TextProcs.WrapAttr(r, str, "C");
end;

##  file names
GAPDoc2TextProcs.F := function(r, str)
  GAPDoc2TextProcs.WrapAttr(r, str, "F");
end;

##  argument names (same as Arg)
GAPDoc2TextProcs.A := function(r, str)
  GAPDoc2TextProcs.WrapAttr(r, str, "Arg");
end;

##  simple maths, here we try to substitute TeX command to something which
##  looks ok in text mode
GAPDoc2TextProcs.M := function(r, str)
  local s;
  s := "";
  GAPDoc2TextContent(r, s);
  s := TextM(s);
  Append(str, s);
end;


##  in Txt this is shown in TeX format
GAPDoc2TextProcs.Math := function(r, str)
  Add(str, '$');
  GAPDoc2TextProcs.PCDATA := GAPDoc2TextProcs.PCDATANOFILTER;
  GAPDoc2TextContent(r, str);
  GAPDoc2TextProcs.PCDATA := GAPDoc2TextProcs.PCDATAFILTER;
  Add(str, '$');
end;

##  displayed maths (also in TeX format, but printed as  paragraph enclosed
##  by "\[" and "\]")
GAPDoc2TextProcs.Display := function(r, par)
  local   s;
  s := "";
  GAPDoc2TextProcs.PCDATA := GAPDoc2TextProcs.PCDATANOFILTER;
  GAPDoc2TextContent(r, s);
  GAPDoc2TextProcs.PCDATA := GAPDoc2TextProcs.PCDATAFILTER;
  s := Concatenation(Filtered(s, IsString));
#  s := StripBeginEnd(s, "\n");
#  s := Concatenation("\\[\n", s, "\n\\]\n\n");
  s := FormatParagraph(s, r.root.linelength - 10 - Length(r.root.indent), 
                    "left", [Concatenation(r.root.indent, "     "), ""]);
  s := Concatenation("\\[\n", s, "\\]\n\n");
  Add(par, r.count);
  Add(par, s);
end;

##  emphazised text
GAPDoc2TextProcs.Emph := function(r, str)
  GAPDoc2TextProcs.WrapAttr(r, str, "Emph");
end;

##  quoted text
GAPDoc2TextProcs.Q := function(r, str)
  Append(str, "\"");
  GAPDoc2TextContent(r, str);
  Append(str, "\"");
end;

##  Package names
GAPDoc2TextProcs.Package := function(r, str)
  GAPDoc2TextProcs.WrapAttr(r, str, "Package");
end;

##  menu items
GAPDoc2TextProcs.B := function(r, str)
  GAPDoc2TextProcs.WrapAttr(r, str, "B");
end;

GAPDoc2TextProcs.ExampleLike := function(r, par, label)
  local   str,  cont,  a,  s, len, l1;
  len := r.root.linelength - Length(r.root.indent) - 10;
  str := Concatenation(r.root.indent, GAPDoc2TextProcs.TextAttr.Example);
  if Length(label) = 0 then
    Append(str, RepeatedString('-', len));
  else
    l1 := RepeatedString('-', Int((len - 4 - Length(label)) / 2));
    Append(str, Concatenation(l1, "  ", label, "  ", l1));
    while Length(str) < len + Length(GAPDoc2TextProcs.TextAttr.Example) do
      Add(str, '-');
    od;
  fi;
  Append(str, GAPDoc2TextProcs.TextAttr.reset);
  Add(str, '\n');
  cont := "";
  for a in r.content do 
    # here we try to avoid reformatting
    if IsString(a.content) then
      Append(cont, a.content); 
    else
      s := "";
      GAPDoc2Text(a, s);
      Append(cont, s);
    fi;
  od;
  cont := SplitString(cont, "\n", "");
  # delete first line, if whitespace only
  if Length(cont) > 0 and ForAll(cont[1], x-> x in WHITESPACE) then
    cont := cont{[2..Length(cont)]};
  fi;
  cont := Concatenation(List(cont, a-> Concatenation(r.root.indent, 
                        "  ", GAPDoc2TextProcs.TextAttr.Example, a, 
                        GAPDoc2TextProcs.TextAttr.reset, "\n")));
  Append(str, cont);
  Append(str, Concatenation(r.root.indent,
                            GAPDoc2TextProcs.TextAttr.Example, 
                            RepeatedString('-', len), 
                            GAPDoc2TextProcs.TextAttr.reset, "\n\n"));
  Add(par, r.count);
  Add(par, str);
end;

##  log of session and GAP code is typeset the same way as <Example>
GAPDoc2TextProcs.Example := function(r, par)
  GAPDoc2TextProcs.ExampleLike(r, par, "Example");
end;
GAPDoc2TextProcs.Log := function(r, par)
  GAPDoc2TextProcs.ExampleLike(r, par, "Log");
end;
GAPDoc2TextProcs.Listing := function(r, par)
  if IsBound(r.attributes.Type) then
    GAPDoc2TextProcs.ExampleLike(r, par, r.attributes.Type);
  else
    GAPDoc2TextProcs.ExampleLike(r, par, "");
  fi;
end;

##  Verb is without any formatting
GAPDoc2TextProcs.Verb := function(r, par)
  local cont, s, pos, a;
  cont := "";
  for a in r.content do 
    # here we try to avoid reformatting
    if IsString(a.content) then
      Append(cont, a.content); 
    else
      s := "";
      GAPDoc2Text(a, s);
      Append(cont, s);
    fi;
  od;
  # delete first line if it contains only whitespace
  pos := Position(cont, '\n');
  if pos <> fail and ForAll(cont{[1..pos]}, x-> x in WHITESPACE) then
    cont := cont{[pos..Length(cont)]};
  fi;
  Append(par, [r.count, cont]);
end;

##  explicit labels
GAPDoc2TextProcs.Label := function(r, str)
  r.root.labels.(r.attributes.Name) :=
    GAPDoc2TextProcs.SectionNumber(r.count, "Subsection");
end;

##  citations
GAPDoc2TextProcs.Cite := function(r, str)
  local   key,  pos;
  key := r.attributes.Key;
  pos := Position(r.root.bibkeys, key);
  if pos = fail then
    Add(r.root.bibkeys, key);
    Append(str, Concatenation("[?", key, "?]"));
  elif  not IsBound(r.root.biblabels) then
    Append(str, Concatenation("[?", key, "?]"));
  else
    Append(str, Concatenation("[", r.root.biblabels[pos]));
    if IsBound(r.attributes.Where) then
      Append(str, ", ");
      Append(str, r.attributes.Where);
    fi;
    Add(str, ']');
  fi;
end;

##  explicit index entries
GAPDoc2TextProcs.Index := function(r, str)
  local   s,  entry;
  
  s := "";
  GAPDoc2TextContent(r, s);
  NormalizeWhitespace(s);
  if IsBound(r.attributes.Key) then
    entry := [STRING_LOWER(r.attributes.Key)];
  else
    entry := [STRING_LOWER(StripEscapeSequences(s))];
  fi;
  if IsBound(r.attributes.Subkey) then
    Add(entry, r.attributes.Subkey);
  else
    Add(entry, "");
  fi;
  Add(entry, GAPDoc2TextProcs.SectionNumber(r.count, "Subsection"));
  Add(entry, s);
  Add(entry, r.count{[1..3]});
  Add(r.root.index, entry);
end;

##  for argument list of functions (e.g., "a, b[[c, ], d]")
GAPDoc2TextProcs.NormalizedArgList := function(argl)
  local   sp,  res,  i;
  if Length(argl)=0  then
    return "";
  fi;
  sp := SplitString(argl, "", ", \n\r\t");
  res := sp[1];
  for i in [2..Length(sp)] do
    if not sp[i][1] in "[]" then
      Append(res, ", ");
    fi;
    Append(res, sp[i]);
  od;
  return res;
end;

##  this produces an implicit index entry and a label entry
GAPDoc2TextProcs.LikeFunc := function(r, par, typ)
  local   str,  s,  name,  lab,  i;
  s := Concatenation(GAPDoc2TextProcs.TextAttr.Func, "> ", r.attributes.Name);
  if IsBound(r.attributes.Arg) then
    Append(s, "( "); 
    Append(s, GAPDoc2TextProcs.TextAttr.reset);
    Append(s, GAPDoc2TextProcs.TextAttr.Arg);
    Append(s, GAPDoc2TextProcs.NormalizedArgList(r.attributes.Arg));
    Append(s, GAPDoc2TextProcs.TextAttr.reset);
    Append(s, GAPDoc2TextProcs.TextAttr.Func);
    Append(s, " ) ");
  fi;
  # label (if not given, the default is the Name)
  if IsBound(r.attributes.Label) then
    lab := Concatenation(" (", r.attributes.Label, ")");
  else
    lab := "";  
  fi;
  GAPDoc2TextProcs.Label(rec(count := r.count, attributes := rec(Name
              := Concatenation(r.attributes.Name, lab)), root := r.root), par); 
  # index entry
  name := r.attributes.Name;
  Add(r.root.index, [STRING_LOWER(name), "", 
          GAPDoc2TextProcs.SectionNumber(r.count, "Subsection"), 
          Concatenation(GAPDoc2TextProcs.TextAttr.Func, name, 
                        GAPDoc2TextProcs.TextAttr.reset, lab),
          r.count{[1..3]}]);
  # some hint about the type of the variable
  for i in [Length(StripEscapeSequences(s))+1 .. 
          r.root.linelength - Length(typ)] do
    Add(s, '_');
  od;
  Append(s, Concatenation(GAPDoc2TextProcs.TextAttr.reset, typ, "\n"));
  Add(par, r.count);
  Add(par, s);
end;

GAPDoc2TextProcs.Func := function(r, str)
  GAPDoc2TextProcs.LikeFunc(r, str, "function");
end;

GAPDoc2TextProcs.Oper := function(r, str)
  GAPDoc2TextProcs.LikeFunc(r, str, "operation");
end;

GAPDoc2TextProcs.Meth := function(r, str)
  GAPDoc2TextProcs.LikeFunc(r, str, "method");
end;

GAPDoc2TextProcs.Filt := function(r, str)
  # r.attributes.Type could be "representation", "category", ...
  if IsBound(r.attributes.Type) then
    GAPDoc2TextProcs.LikeFunc(r, str, r.attributes.Type);
  else
    GAPDoc2TextProcs.LikeFunc(r, str, "filter");
  fi;
end;

GAPDoc2TextProcs.Prop := function(r, str)
  GAPDoc2TextProcs.LikeFunc(r, str, "property");
end;

GAPDoc2TextProcs.Attr := function(r, str)
  GAPDoc2TextProcs.LikeFunc(r, str, "attribute");
end;

GAPDoc2TextProcs.Var := function(r, str)
  GAPDoc2TextProcs.LikeFunc(r, str, "global variable");
end;

GAPDoc2TextProcs.Fam := function(r, str)
  GAPDoc2TextProcs.LikeFunc(r, str, "family");
end;

GAPDoc2TextProcs.InfoClass := function(r, str)
  GAPDoc2TextProcs.LikeFunc(r, str, "info class");
end;

##  using the HelpData(.., .., "ref") interface
GAPDoc2TextProcs.ResolveExternalRef := function(bookname,  label, nr)
  local info, match;
  info := HELP_BOOK_INFO(bookname);
  match := Concatenation(HELP_GET_MATCHES(info, STRING_LOWER(label), true));
  if Length(match) < nr then
    return fail;
  fi;
  return HELP_BOOK_HANDLER.(info.handler).HelpData(info, match[nr][2], "ref");
end;

GAPDoc2TextProcs.Ref := function(r, str)
  local   funclike,  int,  txt,  ref,  lab,  sectlike;
  
  # function like cases
  funclike := [ "Func", "Oper", "Meth", "Filt", "Prop", "Attr", "Var", 
                "Fam", "InfoClass" ];
  int := Intersection(funclike, NamesOfComponents(r.attributes));
  if Length(int)>0 then
    txt := r.attributes.(int[1]);
    if IsBound(r.attributes.Label) then
      lab := Concatenation(txt, " (", r.attributes.Label, ")");
    else
      lab := txt;
    fi;
    if IsBound(r.attributes.BookName) then
      ref := GAPDoc2TextProcs.ResolveExternalRef(r.attributes.BookName, lab, 1);
      if ref = fail then
        ref := Concatenation(lab, "???");
      else
        # the search text for online help including book name
        ref := ref[1];
      fi;
    else
      if IsBound(r.root.labels.(lab)) then
        ref := r.root.labels.(lab);
      else
        ref := Concatenation("???", lab, "???");
      fi;
    fi;
    Append(str, Concatenation(GAPDoc2TextProcs.TextAttr.Func, txt,
                                      GAPDoc2TextProcs.TextAttr.reset));
    # add reference by subsection number or text if external, 
    # but only if it does not point to current subsection
    if GAPDoc2TextProcs.SectionNumber(r.count, "Subsection") <> ref then
      Append(str, Concatenation(" (", 
                   GAPDoc2TextProcs.TextAttr.Ref, ref, 
                   GAPDoc2TextProcs.TextAttr.reset, ")"));
    fi;
    return;
  fi;
  
  # section like cases
  sectlike := ["Chap", "Sect", "Subsect", "Appendix"];
  int := Intersection(sectlike, NamesOfComponents(r.attributes));
  if Length(int)>0 then
    txt := r.attributes.(int[1]);
    if IsBound(r.attributes.Label) then
      lab := Concatenation(txt, r.attributes.Label);
    else
      lab := txt;
    fi;
    if IsBound(r.attributes.BookName) then
      ref := GAPDoc2TextProcs.ResolveExternalRef(r.attributes.BookName, lab, 1);
      if ref = fail then
        ref := Concatenation(lab, "???");
      else
        # the search text for online help including book name
        ref := Concatenation("`", StripBeginEnd(ref[1], " "), "'");
      fi;
    else
      # with sectioning references Label must be given
      lab := r.attributes.(int[1]);
      # default is printing section number, but we allow a Style="Text"
      # attribute
      if IsBound(r.attributes.Style) and r.attributes.Style = "Text" and
         IsBound(r.root.labeltexts.(lab)) then
        ref := Concatenation("`", StripBeginEnd(
                                  r.root.labeltexts.(lab), WHITESPACE), "'"); 
      elif IsBound(r.root.labels.(lab)) then
        ref := r.root.labels.(lab);
      else
        ref := Concatenation("???", lab, "???");
      fi;
    fi;
    Append(str, Concatenation(GAPDoc2TextProcs.TextAttr.Ref, ref,
            GAPDoc2TextProcs.TextAttr.reset)); 
    return;
  fi;
  
  # neutral reference to a label
  lab := r.attributes.Label;
  if IsBound(r.attributes.BookName) then
    ref := GAPDoc2TextProcs.ResolveExternalRef(r.attributes.BookName, lab, 1);
    if ref = fail then
      ref := Concatenation(lab, "???");
    else
      # the search text for online help including book name
      ref := ref[1];
    fi;
  else
    if IsBound(r.root.labels.(lab)) then
      ref := r.root.labels.(lab);
    else
      ref := Concatenation("???", lab, "???");
    fi;
  fi;
  Append(str, Concatenation(GAPDoc2TextProcs.TextAttr.Ref, ref,
          GAPDoc2TextProcs.TextAttr.reset)); 
  return;
end;

GAPDoc2TextProcs.Description := function(r, par)
  local l, tmp;
  l := [];
  GAPDoc2TextContent(r, l);
  # Add an empty line in front if not yet there
  if Length(par) > 0 and Length(par[Length(par)]) > 1 then
    tmp := par[Length(par)];
  else
    tmp := "";
  fi;
  if tmp[Length(tmp)-1] <> '\n' then
    Add(tmp, '\n');
  fi;
  Append(par, l);
end;

GAPDoc2TextProcs.Returns := function(r, par)
  local ind, l;
  l := [];
  ind := r.root.indent;
  r.root.indent := Concatenation(ind, "          ");
  GAPDoc2TextContent(r, l);
  if Length(l) > 0 then
    l[2] := Concatenation(l[2]{[1..Length(r.root.indent) - 10]},
              GAPDoc2TextProcs.TextAttr.Returns, "Returns:", 
              GAPDoc2TextProcs.TextAttr.reset,
              l[2]{[Length(r.root.indent)-1..Length(l[2])]});
    Append(par, l);
  fi;
  r.root.indent := ind;
end;


GAPDoc2TextProcs.ManSection := function(r, par)
  local   funclike,  i,  num,  s, strn;
  
  strn := "";
  # function like elements
  funclike := [ "Func", "Oper", "Meth", "Filt", "Prop", "Attr", "Var", 
                "Fam", "InfoClass" ];
  
  # heading comes from name of first function like element
  i := 1;
  while not r.content[i].name in funclike do
    i := i+1;
  od;
  
  num := GAPDoc2TextProcs.SectionNumber(r.count, "Subsection");
  s := Concatenation(num, " ", r.content[i].attributes.Name);
  Add(par, r.count);
  Add(par, Concatenation(GAPDoc2TextProcs.TextAttr.Heading, s,
          GAPDoc2TextProcs.TextAttr.reset, "\n\n"));
  # append to TOC as subsection
  Append(r.root.toc, Concatenation("    ", s, "\n"));
  GAPDoc2TextContent(r, par);
end;

GAPDoc2TextProcs.Mark := function(r, str)
  GAPDoc2TextProcs.WrapAttr(r, str, "Mark");
  Append(str, "\n");
end;

GAPDoc2TextProcs.Item := function(r, str)
  local   s;
#  s := "";
  s := r.root.indent;
  r.root.indent := Concatenation(s, "      ");
  GAPDoc2TextContent(r, str);
  r.root.indent := s;
#  s:= FormatParagraph(s, r.root.linelength-6, "both", ["      ", ""]);
#  Append(str, s);
end;

# must do the complete formatting 
GAPDoc2TextProcs.List := function(r, par)
  local   s,  a,  ss;
  if "Mark" in List(r.content, a-> a.name) then
    for a in r.content do
      if a.name = "Mark" then
        s := "";
        GAPDoc2TextProcs.Mark(a, s);
        Append(par, [a.count, s]);
      elif a.name = "Item" then
        GAPDoc2TextProcs.Item(a, par);
      fi;
    od;
  else
    for a in Filtered(r.content, a-> a.name = "Item") do
      ss := [];
      GAPDoc2TextProcs.Item(a, ss);
      ss[2]{[1,2]} := "--";
      Append(par, ss);
    od;
  fi;
end;

GAPDoc2TextProcs.Enum := function(r, par)
  local   s,  i,  a,  ss,  num;
  i := 1;
  for a in Filtered(r.content, a-> a.name = "Item") do
    ss := [];
    GAPDoc2TextProcs.Item(a, ss);
    num := Concatenation("(", String(i), ")");
    ss[2]{[1..Length(num)]} := num;
    Append(par, ss);
    i := i+1;
  od;
end;

GAPDoc2TextProcs.TheIndex := function(r, par)
  local   s;
  # .six entry
  s := GAPDoc2TextProcs.SectionNumber(r.count, "Chapter");
  Add(r.root.six, ["Index", s, r.count{[1..3]}]);
  
  # the text, if available
  Add(par, r.count);
  if IsBound(r.root.indextext) then
    Add(par, Concatenation("\n\n", GAPDoc2TextProcs.TextAttr.Heading,
          "Index", GAPDoc2TextProcs.TextAttr.reset, "\n\n", r.root.indextext,
          "\n\n-------------------------------------------------------\n"));
  else
    Add(par,"INDEX\n-----------\n");
  fi;
end;

GAPDoc2TextProcs.AltYes := function(r)
  if (not IsBound(r.attributes.Only) and not IsBound(r.attributes.Not)) or
     (IsBound(r.attributes.Only) and 
      "Text" in SplitString(r.attributes.Only, "", " ,"))  or
     (IsBound(r.attributes.Not) and 
     not "Text" in SplitString(r.attributes.Not, "", " ,")) then
    return true;
  else
    return false;
  fi;
end;

GAPDoc2TextProcs.Alt := function(r, str)
  if GAPDoc2TextProcs.AltYes(r) then
    GAPDoc2TextContent(r, str);
  fi;
end;

# copy a few entries with two element names
GAPDoc2TextProcs.E := GAPDoc2TextProcs.Emph;
GAPDoc2TextProcs.Keyword := GAPDoc2TextProcs.K;
GAPDoc2TextProcs.Code := GAPDoc2TextProcs.C;
GAPDoc2TextProcs.File := GAPDoc2TextProcs.F;
GAPDoc2TextProcs.Button := GAPDoc2TextProcs.B;
GAPDoc2TextProcs.Arg := GAPDoc2TextProcs.A;
GAPDoc2TextProcs.Quoted := GAPDoc2TextProcs.Q;
GAPDoc2TextProcs.Par := GAPDoc2TextProcs.P;

# like PCDATA
GAPDoc2TextProcs.EntityValue := GAPDoc2TextProcs.PCDATA;

GAPDoc2TextProcs.Table := function(r, str)
  local cap, align, i, j, z, a, b, t, l, s, d, m;
  if not GAPDoc2TextProcs.AltYes(r) then
    return;
  fi;
  # head part of table and tabular
  if IsBound(r.attributes.Label) then
    r.root.labels.(r.attributes.Label) :=
                    GAPDoc2TextProcs.SectionNumber(r.count, "Subsection");
  fi;
  
  # add spaces as separators of colums if no "|" is given
  a := r.attributes.Align;
  align := "";
  for i in [1..Length(a)-1] do
    if a[i] in "crl" then
      Add(align, a[i]);
      if a[i+1] <> '|' then
        Add(align, ' ');
      fi;
    elif a[i] = '|' then
      Add(align, '|');
    fi;
  od;
  Add(align, a[Length(a)]);
  # make all odd positions separator descriptions
  if not align[1] in " |" then
    align := Concatenation(" ", align);
  fi;
  
  # collect entries
  t := [];
  # the rows of the table
  for a in r.content do 
    if a.name = "Row" then
      z := [];
      b := Filtered(a.content, x-> x.name = "Item");
      for i in [1..Length(align)] do
        if i mod 2 = 1 then
          Add(z, Concatenation(" ", align{[i]}, " "));
        elif IsBound(b[i/2]) then
          l := [];
          GAPDoc2TextProcs.Item(b[i/2], l);
          s := Concatenation(l{[2,4..Length(l)]});
          NormalizeWhitespace(s);
          Add(z, s);
        else
          Add(z, "");
        fi;
      od;
      Add(t, z);
    elif a.name = "HorLine" then
      Add(t, List(align, x-> ""));
    fi;
  od;

  # equalize width of entries in columns
  for i in [2,4..2*QuoInt(Length(align), 2)] do
    a := List(t, b-> Length(StripEscapeSequences(b[i])));
    m := Maximum(a);
    z := "";
    for b in [1..m] do 
      Add(z, ' ');
    od;
    if align[i] = 'r' then
      for j in [1..Length(t)] do
        t[j][i] := Concatenation(z{[1..m-a[j]]}, t[j][i]);
      od;
    elif align[i] = 'l' then
      for j in [1..Length(t)] do
        t[j][i] := Concatenation(t[j][i], z{[1..m-a[j]]});
      od;
    else
      for j in [1..Length(t)] do
        d := m - a[j];
        t[j][i] := Concatenation(z{[1..QuoInt(d, 2)]}, t[j][i], 
                                              z{[1..d - QuoInt(d, 2)]});
      od;
    fi;
  od;

  # put lines together
  for i in [1..Length(t)] do
    if Length(t[i][1])=0 then
      t[i] := ["-"];
    fi;
  od;
  t := List(t, Concatenation);
  a := Maximum(List(t, x-> Length(StripEscapeSequences(x))));
  z := "   ";
  for b in [1..a] do 
    Add(z, '-');
  od;
  Add(z, '\n');
  for i in [1..Length(t)] do
    if t[i][1] = '-' then
      t[i] := z;
    else
      t[i] := Concatenation("   ", t[i], "\n");
    fi;
  od;
  t := Concatenation(t);
  Add(t, '\n');

  # the caption, if given
  cap := Filtered(r.content, a-> a.name = "Caption");
  if Length(cap) > 0 then
    s := "";
    GAPDoc2TextProcs.Caption1(cap[1], s);
    Append(t, s);
    Append(t, "\n\n");
  fi;
  Add(str, r.count);
  Add(str, t);
end;

# do nothing, we call .Caption1 directly in .Table
GAPDoc2TextProcs.Caption := function(r, str)
  return;
end;

# here the caption for a table text is produced
GAPDoc2TextProcs.Caption1 := function(r, str)
  local s;
  s := "";
  Append(s, Concatenation(GAPDoc2TextProcs.TextAttr.Heading, "Table:",
              GAPDoc2TextProcs.TextAttr.reset, " "));
  GAPDoc2TextContent(r, s);
  Append(str, FormatParagraph(s, r.root.linelength - 10, 
                                                  "both", ["     ", ""]));
end;

##  
##  <#GAPDoc Label="GAPDoc2TextPrintTextFiles">
##  <ManSection >
##  <Func Arg="t[, path]" Name="GAPDoc2TextPrintTextFiles" />
##  <Returns>nothing</Returns>
##  <Description>
##  The  first   argument  must   be  a   result  returned   by  <Ref
##  Func="GAPDoc2Text"/>. The second argument is a path for the files
##  to write, it can be given as string or directory object. The text
##  of  each  chapter is  written  into  a  separate file  with  name
##  <F>chap0.txt</F>,  <F>chap1.txt</F>, ...,  <F>chapBib.txt</F>, and
##  <F>chapInd.txt</F>.<P/>
##  
##  If  you want  to  make  your document  accessible  via the  &GAP;
##  online  help you  must  put at  least these  files  for the  text
##  version  into a  directory and  use  the name  of this  directory
##  as  an  argument for  one  of  the commands  <Ref  BookName="Ref"
##  Func="DeclarePackageDocumentation"  />   or  <Ref  BookName="Ref"
##  Func="DeclarePackageAutoDocumentation"  />. Furthermore  you need
##  to put the  file <F>manual.six</F> into this  directory, see <Ref
##  Func="PrintSixFile" />. <P/>
##  
##  Optionally you can add the <C>dvi</C>- and <C>pdf</C>-versions of
##  the  document which  are produced  with <Ref  Func="GAPDoc2LaTeX"
##  />   to  this   directory.  The   files  must   have  the   names
##  <F>manual.dvi</F>   and  <F>manual.pdf</F>,   respectively.  Also
##  you  can  add  the  files  of  the  HTML  version  produced  with
##  <Ref   Func="GAPDoc2HTML"  />   to  this   directory,  see   <Ref
##  Func="GAPDoc2HTMLPrintHTMLFiles"  />.  The handler  functions  in
##  &GAP;  for this  help format  detect automatically  which of  the
##  optional formats of a book are actually available.
##  
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# arg: t (result of GAPDoc2Text)[, directory]
InstallGlobalFunction(GAPDoc2TextPrintTextFiles, function(arg)
  local   t, dir, a;
  t := arg[1];
  if Length(arg)>1 then
    dir := arg[2];
    if IsString(dir) then
      dir := Directory(dir);
    fi;
  else
    dir := Directory("");
  fi; 
  
  for a in NamesOfComponents(t) do
    FileString(Filename(dir,Concatenation("chap",a,".txt")), t.(a).text);
  od;
end);

