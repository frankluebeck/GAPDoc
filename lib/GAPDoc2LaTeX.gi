#############################################################################
##
#W  GAPDoc2LaTeX.gi                GAPDoc                        Frank Lübeck
##
#H  @(#)$Id: GAPDoc2LaTeX.gi,v 1.8 2002-12-23 12:12:50 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The  files GAPDoc2LaTeX.g{d,i}  contain a  conversion program  which
##  produces from a GAPDoc XML-document a version which can be processed
##  by LaTeX and pdfLaTeX.
##  

##  All  the work  is  done by  handler functions  for  each GAPDoc  XML
##  element.  These functions  are  bound as  components  to the  record
##  `GAPDoc2LaTeXProcs'. Most  element markup is easily  translated to a
##  corresponding LaTeX markup. It should  be easy to modify details for
##  some elements  by small local  changes of the  corresponding handler
##  function. The only slight complications  are in places where the XML
##  elements imply some labeling or  indexing. Also for all (sub)section
##  commands  we  add some  commands  which  cause  LaTeX to  produce  a
##  GAP  readable .pnr  file which  contains  the page  numbers for  all
##  subsections.
InstallValue(GAPDoc2LaTeXProcs, rec());

##  <#GAPDoc Label="GAPDoc2LaTeX">
##  <ManSection >
##  <Func Arg="tree" Name="GAPDoc2LaTeX" />
##  <Returns>&LaTeX; document as string</Returns>
##  <Description>
##  The   argument  <A>tree</A>   for   this  function   is  a   tree
##  describing  a   &GAPDoc;  XML   document  as  returned   by  <Ref
##  Func="ParseTreeXMLString"  /> (probably  also  checked with  <Ref
##  Func="CheckAndCleanGapDocTree"  />).  The   output  is  a  string
##  containing a  version of the document  which can be written  to a
##  file  and processed  with  &LaTeX; or  pdf&LaTeX;  (and  probably
##  &BibTeX; and <C>makeindex</C>). <P/>
##  
##  The   output   uses   the  <C>report</C>   document   class   and
##  needs    the   following    &LaTeX;   packages:    <C>a4wide</C>,
##  <C>amssymb</C>,  <C>isolatin1</C>, <C>makeidx</C>,  <C>color</C>,
##  <C>fancyvrb</C>,   <C>pslatex</C>   and  <C>hyperref</C>.   These
##  are  for  example  provided by  the  <Package>teTeX-1.0</Package>
##  distribution   of   &TeX;   (which    in   turn   is   used   for
##  most  &TeX;   packages  of  current  Linux   distributions);  see
##  <URL>http://www.tug.org/tetex/</URL>. <P/>
##  
##  In  particular, the  resulting  <C>dvi</C>- or  <C>pdf</C>-output
##  contains  (internal and  external) hyperlinks  which can  be very
##  useful for online browsing of the document.<P/>
##  
##  The  &LaTeX;  processing  also  produces a  file  with  extension
##  <C>.pnr</C> which is &GAP; readable and contains the page numbers
##  for  all (sub)sections  of  the  document. This  can  be used  by
##  &GAP;'s online help; see <Ref Func="AddPageNumbersToSix" />.
##  
##  There is  support for  two types  or XML  processing instructions
##  which allow to change the options  used for the document class or
##  to add some extra lines to  the preamble of the &LaTeX; document.
##  They can be specified as in the following examples:
##  
##  <Listing Type="in top level of XML document">
##  <![CDATA[<?LaTeX Options="12pt"?>
##  <?LaTeX ExtraPreamble="\usepackage{blabla}
##  \newcommand{\bla}{blabla}
##  "?>
##  ]]></Listing>
##  
##  A hint for  large documents: In many &TeX;  installations one can
##  easily reach some memory limitations with documents which contain
##  many (cross-)references. In <Package>teTeX</Package> you can look
##  for  a  file <F>texmf.cnf</F>  which  allows  to enlarge  certain
##  memory sizes.<P/>
##  
##  This function  works by running recursively  through the document
##  tree  and  calling  a  handler function  for  each  &GAPDoc;  XML
##  element. These handler functions are all quite easy to understand
##  (the greatest complications are  some commands for index entries,
##  labels or the output of page number information). So it should be
##  easy  to  adjust layout  details  to  your  own taste  by  slight
##  modifications of the program.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# the basic call, used recursivly with a result r from GetElement 
# and a string str to which the output should be appended
# arg: r       (then a string is returned)
# or:  r, str  (then the output is appended to string str)
InstallGlobalFunction(GAPDoc2LaTeX, function(arg)
  local  r,  str,  name;
  r := arg[1];
  if Length(arg)>1 then
    str := arg[2];
  else
    str := "";
  fi;
  name := r.name;
  if not IsBound(GAPDoc2LaTeXProcs.(name)) then
    Print("WARNING: Don't know how to process element ", name, 
          " ---- ignored\n");
  else
    GAPDoc2LaTeXProcs.(r.name)(r, str);
  fi;
  if Length(arg)=1 then
    return str;
  fi;
end);

##  a common recursion loop
BindGlobal("GAPDoc2LaTeXContent", function(r, str)
  local   a;
  for a in r.content do
    GAPDoc2LaTeX(a, str);
  od;
end);

# two utilities for labels and text with _ or \ 
GAPDoc2LaTeXProcs.EscapeUsBs := function(str)
  str := SubstitutionSublist(str, "\\", "\\texttt{\\symbol{92}}");
  str := SubstitutionSublist(str, "_", "{\\_}");
  str := SubstitutionSublist(str, "^", "{\\^{}}");
  return str;
end;

GAPDoc2LaTeXProcs.DeleteUsBs := function(str)
  return Filtered(str, x-> not (x in "\\_"));
end;

##  this is for getting a string "[ \"A\", 1, 1 ]" from [ "A", 1, 1 ]
GAPDoc2LaTeXProcs.StringNrs := function(ssnr)
  if IsInt(ssnr[1]) then
    return String(ssnr);
  else
    return Concatenation("[ \"", ssnr[1], "\", ", String(ssnr[2]), ", ",
                   String(ssnr[3]), " ]");
  fi;
end;

##  standard head of LaTeX file - part 1
GAPDoc2LaTeXProcs.Head1 := Concatenation([
"% generated by GAPDoc2LaTeX from XML source (Frank Luebeck)\n",
"\\documentclass["]);

GAPDoc2LaTeXProcs.Head1x := Concatenation([
"]{report}\n",
"\\usepackage{a4wide}\n",
"\\sloppy\n",
"\\pagestyle{myheadings}\n",
"\\usepackage{amssymb}\n",
"\\usepackage[latin1]{inputenc}\n",
"\\usepackage{makeidx}\n",
"\\makeindex\n",
"\\usepackage{color}\n",
"\\definecolor{DarkOlive}{rgb}{0.1047,0.2412,0.0064}\n",
"\\definecolor{FireBrick}{rgb}{0.5812,0.0074,0.0083}\n",
"\\definecolor{RoyalBlue}{rgb}{0.0236,0.0894,0.6179}\n",
"\\definecolor{RoyalGreen}{rgb}{0.0236,0.6179,0.0894}\n",
"\\definecolor{RoyalRed}{rgb}{0.6179,0.0236,0.0894}\n",
"\\definecolor{LightBlue}{rgb}{0.8544,0.9511,1.0000}\n",
"\\definecolor{Black}{rgb}{0.0,0.0,0.0}\n",
"\\definecolor{FuncColor}{rgb}{1.0,0.0,0.0}\n",
"%% strange name because of pdflatex bug:\n",
"\\definecolor{Chapter }{rgb}{0.0,0.0,1.0}\n",
"\n",
"\\usepackage{fancyvrb}\n",
"\n",
"\\usepackage{pslatex}\n",
"\n"]);

##  head - part 2 for dvi, ps and pdf output  (default is "dvi")
GAPDoc2LaTeXProcs.Head2dvi := "\\usepackage[\n";
GAPDoc2LaTeXProcs.Head2ps := "\\usepackage[dvips=true,\n";
GAPDoc2LaTeXProcs.Head2pdf := "\\usepackage[pdftex=true,\n";
GAPDoc2LaTeXProcs.Head2 := GAPDoc2LaTeXProcs.Head2dvi;

##  head - part 3
GAPDoc2LaTeXProcs.Head3 := Concatenation([
"        a4paper=true,bookmarks=false,pdftitle={Written with GAPDoc},\n",
"        colorlinks=true,backref=page,breaklinks=true,linkcolor=RoyalBlue,\n",
"        citecolor=RoyalGreen,filecolor=RoyalRed,\n",
"        urlcolor=RoyalRed,pagecolor=RoyalBlue]{hyperref}\n",
"\n",
"% write page numbers to a .pnr log file for online help\n",
"\\newwrite\\pagenrlog\n",
"\\immediate\\openout\\pagenrlog =\\jobname.pnr\n",
"\\immediate\\write\\pagenrlog{PAGENRS := [}\n",
"\\newcommand{\\logpage}[1]{\\protect\\write\\pagenrlog{#1, \\thepage,}}\n",
"\\newcommand{\\Q}{\\mathbb{Q}}\n",
"\\newcommand{\\R}{\\mathbb{R}}\n",
"\\newcommand{\\C}{\\mathbb{C}}\n",
"\\newcommand{\\Z}{\\mathbb{Z}}\n",
"\\newcommand{\\N}{\\mathbb{N}}\n",
"\\newcommand{\\F}{\\mathbb{F}}\n",
"\n",
"\\newcommand{\\GAP}{\\textsf{GAP}}\n",
"\n",
"\\newsavebox{\\backslashbox}\n",
"\\sbox{\\backslashbox}{\\texttt{\\symbol{92}}}\n",
"\\newcommand{\\bs}{\\usebox{\\backslashbox}}\n",
"\n",                                   
"\\begin{document}\n",
"\n"]);
                                   
GAPDoc2LaTeXProcs.Tail := Concatenation( 
"\\immediate\\write\\pagenrlog{[\"End\"], \\arabic{page}];}\n",
"\\immediate\\closeout\\pagenrlog\n",
"\\end{document}\n");
                                   
##  arg: a list of strings
##  for now only the output type (one of "dvi", "pdf" or "ps") is used
# to be enhanced, we don't document this for now.
SetGapDocLaTeXOptions := function(arg)    
  local   gdp;
  gdp := GAPDoc2LaTeXProcs;
  if "pdf" in arg then
    gdp.Head2 := gdp.Head2pdf;
  elif "dvi" in arg then
    gdp.Head2 := gdp.Head2dvi;
  elif "ps" in arg then
    gdp.Head2 := gdp.Head2ps;
  fi;
end;

##  write head and foot of LaTeX file.
GAPDoc2LaTeXProcs.WHOLEDOCUMENT := function(r, str)
  local   i,  pi,  t,  el,  a;
  
  ##  add internal paragraph numbering
  AddParagraphNumbersGapDocTree(r);
  
  ##  checking for processing instructions
  i := 1;
  pi := rec();
  while not r.content[i].name = "Book" do
    if r.content[i].name = "XMLPI" then
      t := r.content[i].content;
      if Length(t) > 5 and t{[1..6]} = "LaTeX " then
        el := GetSTag(Concatenation("<", t, ">"), 2);
        for a in NamesOfComponents(el.attributes) do
          pi.(a) := el.attributes.(a);
        od;
      fi;
    fi;
    i := i+1;
  od;
  ##  collect headings of labeled sections
  GAPDoc2LaTeXProcs._labeledSections := rec();

  ##  now the actual work starts, we give the found processing instructions
  ##  to the Book handler
  GAPDoc2LaTeXProcs.Book(r.content[i], str, pi);
  Unbind(GAPDoc2LaTeXProcs._labeledSections);
end;

##  comments and processing instructions are generally ignored
GAPDoc2LaTeXProcs.XMLPI := function(r, str);
end;
GAPDoc2LaTeXProcs.XMLCOMMENT := function(r, str);
end;

##  this makes head and foot of the LaTeX output
##  - the only processing instructions handled currently are
##    - options for the report class (german, papersize, ...) and 
##    - extra entries in the preamble (\usepackage, macro definitions, ...)
GAPDoc2LaTeXProcs.Book := function(r, str, pi)
  local   a;
  
  Append(str, GAPDoc2LaTeXProcs.Head1);
  if IsBound(pi.Options) then
    NormalizeWhitespace(pi.Options);
    Append(str, pi.Options);
  else
    Append(str, "11pt");
  fi;
  Append(str, GAPDoc2LaTeXProcs.Head1x);

  if IsBound(pi.ExtraPreamble) then
    Append(str, pi.ExtraPreamble);
  fi;
  Append(str, GAPDoc2LaTeXProcs.Head2);
  Append(str, GAPDoc2LaTeXProcs.Head3);
  
  # and now the text of the document
  GAPDoc2LaTeXContent(r, str);
  
  # that's it
  Append(str, GAPDoc2LaTeXProcs.Tail);
end;

##  the Body  just prints its content
GAPDoc2LaTeXProcs.Body := GAPDoc2LaTeXContent;

##  the title page,  the most complicated looking function
GAPDoc2LaTeXProcs.TitlePage := function(r, str)
  local   l,  a,  s,  cont;
  
  # page number info for online help
  Append(str, Concatenation("\\logpage{", 
          GAPDoc2LaTeXProcs.StringNrs(r.count{[1..3]}), "}\n"));
  Append(str, "\\begin{titlepage}\n\\begin{center}");
  
  # title
  l := Filtered(r.content, a-> a.name = "Title");
  Append(str, "{\\Huge \\textbf{");
  s := "";
  GAPDoc2LaTeXContent(l[1], s);
  Append(str, s);
  Append(str, "}}\\\\[1cm]\n");
  
  # the title is also used for the page headings
  Append(str, "\\markright{\\scriptsize \\mbox{}\\hfill ");
  Append(str, s);
  Append(str, " \\hfill\\mbox{}}\n");

  # subtitle
  l := Filtered(r.content, a-> a.name = "Subtitle");
  if Length(l)>0 then
    Append(str, "{\\Large \\textbf{");
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "}}\\\\[1cm]\n");
  fi;
  
  # version
  l := Filtered(r.content, a-> a.name = "Version");
  if Length(l)>0 then
    Append(str, "{");
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "}\\\\[1cm]\n");
  fi;

  # date
  l := Filtered(r.content, a-> a.name = "Date");
  if Length(l)>0 then
    Append(str, "{");
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "}\\\\[1cm]\n");
  fi;
  Append(str, "\\mbox{}\\\\[2cm]\n");

  # author name(s)
  l := Filtered(r.content, a-> a.name = "Author");
  for a in l do
    Append(str, "{\\large \\textbf{");
    GAPDoc2LaTeXContent(rec(content := Filtered(a.content, b->
                   not b.name in ["Email", "Homepage", "Address"])), str);
    Append(str, "}}\\\\\n");
  od;

  # extra comment for front page
  l := Filtered(r.content, a-> a.name = "TitleComment");
  if Length(l) > 0 then
    Append(str, "\\mbox{}\\\\[2cm]\n\\begin{minipage}{12cm}\\noindent\n");
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "\\end{minipage}\n\n");
  fi;
  Append(str, "\\end{center}\\vfill\n\n\\mbox{}\\\\\n");
  
  # email, WWW-homepage and address of author(s), if given
  l := Filtered(r.content, a-> a.name = "Author");
  for a in l do
    cont := List(a.content, b-> b.name);
    if "Email" in cont or "Homepage" in cont or "Address" in cont then
      Append(str, "{\\mbox{}\\\\\n\\small \\noindent \\textbf{");
      GAPDoc2LaTeXContent(rec(content := Filtered(a.content, b->
                   not b.name in ["Email", "Homepage", "Address"])), str);
      Append(str, "}");
      if "Email" in cont then
        Append(str, " --- Email: ");
        GAPDoc2LaTeX(a.content[Position(cont, "Email")], str);
      fi;
      if "Homepage" in cont then
        Append(str, "\\\\\n");
        Append(str, " --- Homepage: ");
        GAPDoc2LaTeX(a.content[Position(cont, "Homepage")], str);
      fi;
      if "Address" in cont then
        Append(str, "\\\\\n");
        Append(str, " --- Address: \\begin{minipage}[t]{8cm}\\noindent\n");
        GAPDoc2LaTeX(a.content[Position(cont, "Address")], str);
        Append(str, "\\end{minipage}\n");
      fi;
      Append(str, "}\\\\\n");
    fi;
  od;

  # Address outside the Author elements
  l := Filtered(r.content, a-> a.name = "Address");
  if Length(l)>0 then
    Append(str, "\n\\noindent ");
    Append(str, "\\textbf{Address: }\\begin{minipage}[t]{8cm}\\noindent\n");
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "\\end{minipage}\n");
  fi;
  
  Append(str, "\\end{titlepage}\n\n\\newpage");
  
  #  to make physical page numbers same as document page numbers
  Append(str, "\\setcounter{page}{2}\n");

  # abstract
  l := Filtered(r.content, a-> a.name = "Abstract");
  if Length(l)>0 then
    Append(str, "{\\small \n\\section*{Abstract}\n");
    # page number info for online help
    Append(str, Concatenation("\\logpage{", 
            GAPDoc2LaTeXProcs.StringNrs(l[1].count{[1..3]}), "}\n"));
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "}\\\\[1cm]\n");
  fi;
  
  # copyright page
  l := Filtered(r.content, a-> a.name = "Copyright");
  if Length(l)>0 then
    Append(str, "{\\small \n\\section*{Copyright}\n");
    # page number info for online help
    Append(str, Concatenation("\\logpage{", 
            GAPDoc2LaTeXProcs.StringNrs(l[1].count{[1..3]}), "}\n"));
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "}\\\\[1cm]\n");
  fi;

  # acknowledgement page
  l := Filtered(r.content, a-> a.name = "Acknowledgements");
  if Length(l)>0 then
    Append(str, "{\\small \n\\section*{Acknowledgements}\n");
    # page number info for online help
    Append(str, Concatenation("\\logpage{", 
            GAPDoc2LaTeXProcs.StringNrs(l[1].count{[1..3]}), "}\n"));
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "}\\\\[1cm]\n");
  fi;

  # colophon page
  l := Filtered(r.content, a-> a.name = "Colophon");
  if Length(l)>0 then
    Append(str, "{\\small \n\\section*{Colophon}\n");
    # page number info for online help
    Append(str, Concatenation("\\logpage{", 
            GAPDoc2LaTeXProcs.StringNrs(l[1].count{[1..3]}), "}\n"));
    GAPDoc2LaTeXContent(l[1], str);
    Append(str, "}\\\\[1cm]\n");
  fi;  
  Append(str,"\\newpage\n\n");
end;

##  ~ and # characters are correctly escaped
##  arg:  r, str[, pre]
GAPDoc2LaTeXProcs.URL := function(arg)
  local   r,  str,  pre,  s,  p;
  r := arg[1];
  str := arg[2];
  if Length(arg)>2 then
    pre := arg[3];
  else
    pre := "";
  fi;
  s := "";
  GAPDoc2LaTeXContent(r, s);
  s := SubstitutionSublist(s, "{\\textasciitilde}", "~");
  Append(str, "\\href{");
  Append(str, pre);
  Append(str, s);
  p := Position(s, '~');
  while p<>fail do
    s := Concatenation(s{[1..p-1]}, "\\~{}", s{[p+1..Length(s)]});
    p := Position(s, '~', p+3);
  od;
  p := Position(s, '\#');
  while p<>fail do
    s := Concatenation(s{[1..p-1]}, "\\\#", s{[p+1..Length(s)]});
    p := Position(s, '\#', p+1);
  od;
  Append(str, "}{\\texttt{");
  Append(str, s);
  Append(str, "}}");
end;

GAPDoc2LaTeXProcs.Homepage := GAPDoc2LaTeXProcs.URL;

GAPDoc2LaTeXProcs.Email := function(r, str)
  # we add the `mailto://' phrase
  GAPDoc2LaTeXProcs.URL(r, str, "mailto://");
end;

##  the sectioning commands are just translated and labels are
##  generated, if given as attribute
GAPDoc2LaTeXProcs.ChapSect := function(r, str, sect)
  local   posh,  a,  s;
  posh := Position(List(r.content, a-> a.name), "Heading");
  # heading
  Append(str, Concatenation("\n\\", sect, "{"));
  s := "";
  if posh <> fail then      
    GAPDoc2LaTeXProcs.Heading1(r.content[posh], s);
  fi;
  Append(str, "\\textcolor{Chapter }{");
  Append(str, s);
  Append(str, "}}");
  # label for references
  if IsBound(r.attributes.Label) then
    Append(str, "\\label{");
    Append(str, r.attributes.Label);
    Append(str, "}\n");
    # save heading for "Text" style references to section
    GAPDoc2LaTeXProcs._labeledSections.(r.attributes.Label) := s;
  fi;
  # page number info for online help
  Append(str, Concatenation("\\logpage{", 
          GAPDoc2LaTeXProcs.StringNrs(r.count{[1..3]}), "}\n"));
  # the actual content
  Append(str, "{\n");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "}\n\n");
end;

##  this really produces the content of the heading
GAPDoc2LaTeXProcs.Heading1 := function(r, str)
  GAPDoc2LaTeXContent(r, str);
end;
##  and this ignores the heading (for simpler recursion)
GAPDoc2LaTeXProcs.Heading := function(r, str)
end;

GAPDoc2LaTeXProcs.Chapter := function(r, str)
  GAPDoc2LaTeXProcs.ChapSect(r, str, "chapter");
end;

GAPDoc2LaTeXProcs.Appendix := function(r, str)
  if r.count[1] = "A" then
    Append(str, "\n\n\\appendix\n\n");
  fi;
  GAPDoc2LaTeXProcs.ChapSect(r, str, "chapter");
end;

GAPDoc2LaTeXProcs.Section := function(r, str)
  GAPDoc2LaTeXProcs.ChapSect(r, str, "section");
end;

GAPDoc2LaTeXProcs.Subsection := function(r, str)
  GAPDoc2LaTeXProcs.ChapSect(r, str, "subsection");
end;

##  table of contents, the job is completely delegated to LaTeX
GAPDoc2LaTeXProcs.TableOfContents := function(r, str)
  # page number info for online help
  Append(str, Concatenation("\\def\\contentsname{Contents\\logpage{", 
          GAPDoc2LaTeXProcs.StringNrs(r.count{[1..3]}), "}}\n"));
  Append(str, "\n\\tableofcontents\n\\newpage\n\n");
end;

##  bibliography, the job is completely delegated to LaTeX and BibTeX
GAPDoc2LaTeXProcs.Bibliography := function(r, str)
  local   st;
  if IsBound(r.attributes.Style) then
    st := r.attributes.Style;
  else
    st := "plain";
  fi;
  # page number info for online help
  Append(str, Concatenation("\\def\\bibname{References\\logpage{", 
          GAPDoc2LaTeXProcs.StringNrs(r.count{[1..3]}), "}}\n"));
  
  Append(str, "\n\\bibliographystyle{");
  Append(str, st);
  Append(str,"}\n\\bibliography{");
  Append(str, r.attributes.Databases);
  Append(str, "}\n\n");
end;

##  as default we normalize white space in text and split the result 
##  into lines (leading and trailing white space is also substituted 
##  by one space).
GAPDoc2LaTeXProcs.PCDATA := function(r, str)
  local   lines,  i;
  if Length(r.content)>0 and r.content[1] in WHITESPACE then
    Add(str, ' ');
  fi;
  lines := FormatParagraph(r.content, "left");
  if Length(lines)>0 then
    if r.content[Length(r.content)] in WHITESPACE then
      lines[Length(lines)] := ' ';
    else
      Unbind(lines[Length(lines)]);
    fi;
  fi;
  Append(str, lines);
end;

##  end of paragraph 
GAPDoc2LaTeXProcs.P := function(r, str)
  Append(str, "\n\n");
end;

##  forced line break
GAPDoc2LaTeXProcs.Br := function(r, str)
  Append(str, "\\\\\n");
end;

##  setting in typewriter
GAPDoc2LaTeXProcs.WrapTT := function(r, str)
  local   s,  a;
  s := "";
  GAPDoc2LaTeXContent(r, s);
  Append(str, Concatenation("\\texttt{", s, "}"));
end;

##  GAP keywords 
GAPDoc2LaTeXProcs.K := function(r, str)
  GAPDoc2LaTeXProcs.WrapTT(r, str);
end;

##  verbatim GAP code
GAPDoc2LaTeXProcs.C := function(r, str)
  GAPDoc2LaTeXProcs.WrapTT(r, str);
end;

##  file names
GAPDoc2LaTeXProcs.F := function(r, str)
  GAPDoc2LaTeXProcs.WrapTT(r, str);
end;

##  argument names
GAPDoc2LaTeXProcs.A := function(r, str)
  Append(str, "\\mbox{");
  GAPDoc2LaTeXProcs.WrapTT(r, str);
  Append(str, "}");
end;

##  simple maths
GAPDoc2LaTeXProcs.M := function(r, str)
  local   a;
  Append(str, "$");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "$");
end;

##  in LaTeX same as <M>
GAPDoc2LaTeXProcs.Math := function(r, str)
  local   a;
  Append(str, "$");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "$");
end;

##  displayed maths
GAPDoc2LaTeXProcs.Display := function(r, str)
  local   a;
  if Length(str)>0 and str[Length(str)] <> '\n' then
    Add(str, '\n');
  fi;
  Append(str, "\\[");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "\\]\n");
end;

##  emphazised text
GAPDoc2LaTeXProcs.Emph := function(r, str)
  local   a;
  Append(str, "\\emph{");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "}");
end;

##  quoted text
GAPDoc2LaTeXProcs.Q := function(r, str)
  local   a;
  Append(str, "``");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "''");
end;

##  Package names
GAPDoc2LaTeXProcs.Package := function(r, str)
  local   a;
  Append(str, "\\textsf{");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "}");
end;

##  menu items
GAPDoc2LaTeXProcs.B := function(r, str)
  local   a;
  Append(str, "\\textsc{");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "}");
end;

##  verbatim GAP session
GAPDoc2LaTeXProcs.Verb := function(r, str)
  local   cont,  a,  s;
  Append(str, "\n\\begin{verbatim}");
  cont := "";
  for a in r.content do 
    # here we try to avoid reformatting
    if IsString(a.content) then
      Append(cont, a.content); 
    else
      s := "";
      GAPDoc2LaTeX(a, s);
      Append(cont, s);
    fi;
  od;
  cont := SplitString(cont, "", "\n");
  cont := Concatenation(List(cont, a-> Concatenation("  ", a, "\n")));
  Append(str, cont);
  Append(str, "\\end{verbatim}\n");
end;

GAPDoc2LaTeXProcs.ExampleLike := function(r, str, label)
  local   cont,  a,  s;
  Append(str, Concatenation("\n\\begin{Verbatim}[fontsize=\\small,",
          "frame=single,label=", label, "]\n"));
  cont := "";
  for a in r.content do 
    # here we try to avoid reformatting
    if IsString(a.content) then
      Append(cont, a.content); 
    else
      s := "";
      GAPDoc2LaTeX(a, s);
      Append(cont, s);
    fi;
  od;
  cont := SplitString(cont, "\n", "");
  # if first line has white space only, we remove it
  if Length(cont) > 0 and ForAll(cont[1], x-> x in WHITESPACE) then
    cont := cont{[2..Length(cont)]};
  fi;
  cont := Concatenation(List(cont, a-> Concatenation("  ", a, "\n")));
  Append(str, cont);
  Append(str, "\\end{Verbatim}\n");
end;

##  log of session and GAP code is typeset the same way as <Example>
GAPDoc2LaTeXProcs.Example := function(r, str)
  GAPDoc2LaTeXProcs.ExampleLike(r, str, "Example");
end;
GAPDoc2LaTeXProcs.Log := function(r, str)
  GAPDoc2LaTeXProcs.ExampleLike(r, str, "Example");
end;
GAPDoc2LaTeXProcs.Listing := function(r, str)
  if IsBound(r.attributes.Type) then
    GAPDoc2LaTeXProcs.ExampleLike(r, str, r.attributes.Type);
  else
    GAPDoc2LaTeXProcs.ExampleLike(r, str, "");
  fi;
end;

##  explicit labels
GAPDoc2LaTeXProcs.Label := function(r, str)
  Append(str, "\\label{");
  Append(str, r.attributes.Name);
  Append(str, "}");
end;

##  citations
GAPDoc2LaTeXProcs.Cite := function(r, str)
  Append(str, "\\cite");
  if IsBound(r.attributes.Where) then
    Add(str, '[');
    Append(str, r.attributes.Where);
    Add(str, ']');
  fi;
  Add(str, '{');
  Append(str, r.attributes.Key);
  Add(str, '}');
end;

##  explicit index entries
GAPDoc2LaTeXProcs.Index := function(r, str)
  local   s;
  s := "";
  GAPDoc2LaTeXContent(r, s);
  NormalizeWhitespace(s);
  if IsBound(r.attributes.Key) then
    s := Concatenation(r.attributes.Key, "@", s);
  fi;
  if IsBound(r.attributes.Subkey) then
    s := Concatenation(s, "!", r.attributes.Subkey);
  fi;
  Append(str, "\\index{");
  Append(str, s);
  Append(str, "}");
end;

##  for argument list of functions (e.g., "a, b[[c, ], d]")
GAPDoc2LaTeXProcs.NormalizedArgList := function(argl)
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
GAPDoc2LaTeXProcs.LikeFunc := function(r, str, typ)
  local   nam,  namclean, lab;
  Append(str, "\\noindent\\textcolor{FuncColor}{$\\Diamond$\\ \\texttt{");
  nam := r.attributes.Name;
  namclean := GAPDoc2LaTeXProcs.DeleteUsBs(nam);
  # we allow _ and \ here
  nam := GAPDoc2LaTeXProcs.EscapeUsBs(nam);
  Append(str, nam);
  if IsBound(r.attributes.Arg) then
    Append(str, "( ");
    Append(str, GAPDoc2LaTeXProcs.NormalizedArgList(r.attributes.Arg));
    Append(str, " )");
  fi;
  # possible label
  if IsBound(r.attributes.Label) then
    lab := Concatenation("!", r.attributes.Label);
  else
    lab := "";
  fi;
  # index entry
  Append(str, Concatenation("\\index{", namclean, "@\\texttt{",
          nam, "}", lab, "}\n"));
  # label (if not given, the default is the Name)
  if IsBound(r.attributes.Label) then
    namclean := Concatenation(namclean, ":", r.attributes.Label);
  fi;
  Add(GAPDoc2LaTeXProcs._currentSubsection, namclean);
  Append(str, Concatenation("\\label{", namclean, "}\n"));
  # some hint about the type of the variable
  Append(str, "}\\hfill{\\scriptsize (");
  Append(str, typ);
  Append(str, ")}}\\\\\n");
end;

GAPDoc2LaTeXProcs.Func := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, "function");
end;

GAPDoc2LaTeXProcs.Oper := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, "operation");
end;

GAPDoc2LaTeXProcs.Meth := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, "method");
end;

GAPDoc2LaTeXProcs.Filt := function(r, str)
  # r.attributes.Type could be "representation", "category", ...
  if IsBound(r.attributes.Type) then
    GAPDoc2LaTeXProcs.LikeFunc(r, str, r.attributes.Type);
  else
    GAPDoc2LaTeXProcs.LikeFunc(r, str, "filter");
  fi;
end;

GAPDoc2LaTeXProcs.Prop := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, "property");
end;

GAPDoc2LaTeXProcs.Attr := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, "attribute");
end;

GAPDoc2LaTeXProcs.Var := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, "global variable");
end;

GAPDoc2LaTeXProcs.Fam := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, "family");
end;

GAPDoc2LaTeXProcs.InfoClass := function(r, str)
  GAPDoc2LaTeXProcs.LikeFunc(r, str, "info class");
end;

##  using the HelpData(.., .., "ref") interface
GAPDoc2LaTeXProcs.ResolveExternalRef := function(bookname,  label, nr)
  local info, match;
  info := HELP_BOOK_INFO(bookname);
  match := Concatenation(HELP_GET_MATCHES(info, STRING_LOWER(label), true));
  if Length(match) < nr then
    return fail;
  fi;
  return HELP_BOOK_HANDLER.(info.handler).HelpData(info, match[nr][2], "ref");
end;

GAPDoc2LaTeXProcs.Ref := function(r, str)
  local   funclike,  int,  txt,  ref,  lab,  sectlike;
  
  # function like cases
  funclike := [ "Func", "Oper", "Meth", "Filt", "Prop", "Attr", "Var", 
                "Fam", "InfoClass" ];
  int := Intersection(funclike, NamesOfComponents(r.attributes));
  if Length(int)>0 then
    txt := r.attributes.(int[1]);
    if IsBound(r.attributes.Label) then
      lab := Concatenation(txt, ":", r.attributes.Label);
    else
      lab := txt;
    fi;
    if IsBound(r.attributes.BookName) then
      ref := GAPDoc2LaTeXProcs.ResolveExternalRef(
                                          r.attributes.BookName, lab, 1);
      if ref = fail then
        ref := Concatenation(" (", lab, "???)");
      else
        # the search text for online help including book name
        ref := Concatenation(" (\\textbf{", ref[1], "})");
      fi;
    else
      ref := Concatenation(" (\\ref{", GAPDoc2LaTeXProcs.DeleteUsBs(lab), "})");
    fi;
    # delete ref, if pointing to current subsection
    if IsBound(GAPDoc2LaTeXProcs._currentSubsection) and 
                 lab in GAPDoc2LaTeXProcs._currentSubsection then
      ref := "";
    fi;
    Append(str, Concatenation("\\texttt{", GAPDoc2LaTeXProcs.EscapeUsBs(txt), 
            "}", ref));
    return;
  fi;
  
  # section like cases
  sectlike := ["Chap", "Sect", "Subsect", "Appendix"];
  int := Intersection(sectlike, NamesOfComponents(r.attributes));
  if Length(int)>0 then
    txt := r.attributes.(int[1]);
    if IsBound(r.attributes.Label) then
      lab := r.attributes.Label;
    else
      lab := txt;
    fi;
    if IsBound(r.attributes.BookName) then
      ref := GAPDoc2LaTeXProcs.ResolveExternalRef(
                                          r.attributes.BookName, lab, 1);
      if ref = fail then
        ref := Concatenation(" (", lab, "???)");
      else
        # the search text for online help including book name
        ref := Concatenation(" (\\textbf{", ref[1], "})");
      fi;
    elif IsBound(r.attributes.Style) and r.attributes.Style = "Text" then
        ref := Concatenation("`", StripBeginEnd(
                GAPDoc2LaTeXProcs._labeledSections.(lab), WHITESPACE), "'"); 
    else
      # with sectioning references Label must be given
      lab := r.attributes.(int[1]);
      ref := Concatenation("\\ref{", lab, "}");
    fi;
    Append(str, ref);
    return;
  fi;
  
  # neutral reference to a label
  if IsBound(r.attributes.BookName) then
    if IsBound(r.attributes.Label) then
      lab := r.attributes.Label;
    else
      lab := "_X_X_X";
    fi;
    ref := GAPDoc2LaTeXProcs.ResolveExternalRef(
                                        r.attributes.BookName, lab, 1);
    if ref = fail then
      ref := Concatenation(" (", lab, "???)");
    else
      # the search text for online help including book name
      ref := Concatenation(" (\\textbf{", ref[1], "})");
    fi;
  else
    lab := r.attributes.Label;
    ref := Concatenation("\\ref{", lab, "}");
  fi;
  Append(str, ref);
  return;
end;

# just process
GAPDoc2LaTeXProcs.Address := function(r, str)
  GAPDoc2LaTeXContent(r, str);
end;

GAPDoc2LaTeXProcs.Description := function(r, str)
  Append(str, "\n\n");
  GAPDoc2LaTeXContent(r, str);
end;

GAPDoc2LaTeXProcs.Returns := function(r, str)
  Append(str, "\\textbf{\\indent Returns:\\ }\n");
  GAPDoc2LaTeXContent(r, str); 
  Append(str,"\n\n");
end;

GAPDoc2LaTeXProcs.ManSection := function(r, str)
  local   funclike,  f,  lab,  i;
  
  # function like elements
  funclike := [ "Func", "Oper", "Meth", "Filt", "Prop", "Attr", "Var", 
                "Fam", "InfoClass" ];
  
  # heading comes from name of first function like element
  i := 1;
  while not r.content[i].name in funclike do
    i := i+1;
  od;
  f := r.content[i];
  if IsBound(f.attributes.Label) then
    lab := Concatenation(" (", f.attributes.Label, ")");
  else
    lab := "";
  fi;
  Append(str, Concatenation("\n\n\\subsection{\\textcolor{Chapter }{", 
          GAPDoc2LaTeXProcs.EscapeUsBs(f.attributes.Name), lab, "}}\n"));
  # page number info for online help
  Append(str, Concatenation("\\logpage{", 
          GAPDoc2LaTeXProcs.StringNrs(r.count{[1..3]}), "}\\nobreak\n"));
  # to avoid references to local subsection in description:
  GAPDoc2LaTeXProcs._currentSubsection := r.count{[1..3]};
  Append(str, "{");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "}\n\n");
  Unbind(GAPDoc2LaTeXProcs._currentSubsection);
end;

GAPDoc2LaTeXProcs.Mark := function(r, str)
  Append(str, "\n\\item[{");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "}] ");
end;

GAPDoc2LaTeXProcs.Item := function(r, str)
  Append(str, "\n\\item ");
  GAPDoc2LaTeXContent(r, str);
end;

GAPDoc2LaTeXProcs.List := function(r, str)
  local   item,  type,  a;
  if "Mark" in List(r.content, a-> a.name) then
    item := "";
    type := "description";
  else
    item := "\n\\item ";
    type := "itemize";
  fi;
  Append(str, Concatenation("\n\\begin{", type, "}"));
  for a in r.content do
    if a.name = "Mark" then
      GAPDoc2LaTeXProcs.Mark(a, str);
    elif a.name = "Item" then
      Append(str, item);
      GAPDoc2LaTeXContent(a, str);
    fi;
  od;
  Append(str, Concatenation("\n\\end{", type, "}\n"));
end;

GAPDoc2LaTeXProcs.Enum := function(r, str)
  Append(str, "\n\\begin{enumerate}");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "\n\\end{enumerate}\n");
end;

GAPDoc2LaTeXProcs.TheIndex := function(r, str)
  # page number info for online help
  Append(str, Concatenation("\\def\\indexname{Index\\logpage{", 
          GAPDoc2LaTeXProcs.StringNrs(r.count{[1..3]}), "}}\n"));
  Append(str, "\n\n\\printindex\n\n");
end;


# like PCDATA
GAPDoc2LaTeXProcs.EntityValue := GAPDoc2LaTeXProcs.PCDATA;

GAPDoc2LaTeXProcs.Table_old := function(r, str)
  local cap;
  if (IsBound(r.attributes.Only) and r.attributes.Only <> "LaTeX") or
     (IsBound(r.attributes.Not) and r.attributes.Not = "LaTeX") then
    return;
  fi;
  # head part of table and tabular
  Append(str, "\n\\begin{table}[h]");
  if IsBound(r.attributes.Label) then
    Append(str, "\\label{");
    Append(str, r.attributes.Label);
    Add(str, '}');
  fi;
  Append(str, "\\begin{center}\n\\begin{tabular}{");
  Append(str, r.attributes.Align);
  Add(str, '}');
  # the rows of the table
  GAPDoc2LaTeXContent(r, str);
  # the trailing part with caption, if given
  Append(str, "\\end{tabular}\n\\end{center}\n");
  cap := Filtered(r.content, a-> a.name = "Caption");
  if Length(cap) > 0 then
    GAPDoc2LaTeXProcs.Caption1(cap[1], str);
  fi;
  Append(str, "\\end{table}\n");
end;

GAPDoc2LaTeXProcs.Table := function(r, str)
  local cap;
  if (IsBound(r.attributes.Only) and r.attributes.Only <> "LaTeX") or
     (IsBound(r.attributes.Not) and r.attributes.Not = "LaTeX") then
    return;
  fi;
  # head part of table and tabular
  if IsBound(r.attributes.Label) then
    Append(str, "\\mbox{}\\label{");
    Append(str, r.attributes.Label);
    Add(str, '}');
  fi;
  Append(str, "\\begin{center}\n\\begin{tabular}{");
  Append(str, r.attributes.Align);
  Add(str, '}');
  # the rows of the table
  GAPDoc2LaTeXContent(r, str);
  # the trailing part with caption, if given
  Append(str, "\\end{tabular}\\\\[2mm]\n");
  cap := Filtered(r.content, a-> a.name = "Caption");
  if Length(cap) > 0 then
    GAPDoc2LaTeXProcs.Caption1(cap[1], str);
  fi;
  Append(str, "\\end{center}\n\n");
end;

# do nothing, we call .Caption1 directly in .Table
GAPDoc2LaTeXProcs.Caption := function(r, str)
  return;
end;

# here the caption text is produced
GAPDoc2LaTeXProcs.Caption1_old := function(r, str)
  Append(str, "\\caption{");
  GAPDoc2LaTeXContent(r, str);
  Append(str, "}\n");
end;
GAPDoc2LaTeXProcs.Caption1 := function(r, str)
  Append(str, "\\textbf{Table: }");
  GAPDoc2LaTeXContent(r, str);
end;

GAPDoc2LaTeXProcs.HorLine := function(r, str)
  Append(str, "\\hline\n");
end;

GAPDoc2LaTeXProcs.Row := function(r, str)
  local i, l;
  l := Filtered(r.content, a-> a.name = "Item");
  for i in [1..Length(l)-1] do
    GAPDoc2LaTeXContent(l[i], str);
    Append(str, "&\n");
  od;
  GAPDoc2LaTeXContent(l[Length(l)], str);
  Append(str, "\\\\\n");
end;

GAPDoc2LaTeXProcs.Alt := function(r, str)
  if (IsBound(r.attributes.Only) and r.attributes.Only = "LaTeX") or
     (IsBound(r.attributes.Not) and r.attributes.Not <> "LaTeX") then
    GAPDoc2LaTeXContent(r, str);
  fi;
end;

# copy a few entries with two element names
GAPDoc2LaTeXProcs.E := GAPDoc2LaTeXProcs.Emph;
GAPDoc2LaTeXProcs.Keyword := GAPDoc2LaTeXProcs.K;
GAPDoc2LaTeXProcs.Code := GAPDoc2LaTeXProcs.C;
GAPDoc2LaTeXProcs.File := GAPDoc2LaTeXProcs.F;
GAPDoc2LaTeXProcs.Button := GAPDoc2LaTeXProcs.B;
GAPDoc2LaTeXProcs.Arg := GAPDoc2LaTeXProcs.A;
GAPDoc2LaTeXProcs.Quoted := GAPDoc2LaTeXProcs.Q;
GAPDoc2LaTeXProcs.Par := GAPDoc2LaTeXProcs.P;

