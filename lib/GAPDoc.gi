#############################################################################
##
#W  GAPDoc.gi                    GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: GAPDoc.gi,v 1.3 2001-01-24 14:05:12 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files GAPDoc.g{d,i} contain some utilities for trees returned by
##  ParseTreeXMLString applied to a GAPDoc document.
##  

##  <#GAPDoc Label="CheckAndCleanGapDocTree">
##  <ManSection >
##  <Func Arg="tree" Name="CheckAndCleanGapDocTree" />
##  <Returns>nothing</Returns>
##  <Description>
##  The argument  <A>tree</A> of this  function is a parse  tree from
##  <Ref Func="ParseTreeXMLString" /> of some &GAPDoc; document. This
##  function  does an  (incomplete)  validity check  of the  document
##  according to the document  type declaration in <F>gapdoc.dtd</F>.
##  It also does some additional  checks which cannot be described in
##  the DTD (like checking whether  chapters and sections have a heading).
##  For elements  with element  content the whitespace  between these
##  elements is removed.<P/>
##  
##  In case of an error the break loop is entered and the position of
##  the error in the original XML document is printed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# GAPDOCDTDINFO contains essentially the declaration information from
# gapdoc.dtd
Add(GAPDOCDTDINFO, rec(name := "WHOLEDOCUMENT", attr := [  ], 
            reqattr := [  ], type := "elements", content := ["Book"]));
BindGlobal("GAPDOCDTDINFOELS", List(GAPDOCDTDINFO, a-> a.name));
InstallGlobalFunction(CheckAndCleanGapDocTree, function(r)
  local   name,  pos,  type,  c,  namc,  l,  namattr, typ;
  name := r.name;
  if name = "PCDATA" then
    return true;
  fi;
  if Length(name)>2 and name{[1..3]} = "XML" then
    return true;
  fi;
  pos := Position(GAPDOCDTDINFOELS, name);
  if pos=fail then
    Error("element ", name, " not known (starts position ", r.start, ")");
  fi;
  type := GAPDOCDTDINFO[pos].type;
  # checking content
  if type = "empty" then
    if not r.content = EMPTYCONTENT then
      Error("element ", name, " must be empty (starts ", r.start, ")");
    fi;
  elif type = "elements" then
    for c in r.content do 
      namc := c.name;
      if not ((Length(namc)>2 and namc{[1..3]}="XML") or
              (namc = "PCDATA" and ForAll(c.content, x-> x in
                      WHITESPACE)) or
              namc in GAPDOCDTDINFO[pos].content) then
        Error("Wrong element in ", name, ": ", namc," (starts ",
              r.start, ")");
      fi;
    od;
    r.content := Filtered(r.content, a-> a.name <> "PCDATA");
  elif type = "mixed" then
    l := List(r.content, c-> (Length(c.name)>2 and c.name{[1..3]}
                 = "XML") or c.name in 
              GAPDOCDTDINFO[pos].content);
    if false in l then
      Error("Wrong element in ", name, ": ", r.content[Position(l,
              false)].name ," (starts ",
            r.start, ")");
    fi;
  fi;
  
  # checking existing attributes:
  namattr := NamesOfComponents(r.attributes);
  for c in namattr do
    if not c in GAPDOCDTDINFO[pos].attr then
      Error("Attribute ", c, " not declared for ", name);
    fi;
  od;
  # checking required attributes
  for c in GAPDOCDTDINFO[pos].reqattr do
    if not c in namattr then
      Error("Attribute ", c, " must be given in element ", name);
    fi;
  od;
  # some extra checks
  if name = "Ref" then
    if IsBound(r.attributes.BookName) and not
       IsBound(r.attributes.Label) then
      typ := Difference(NamesOfComponents(r.attributes), ["BookName"]);
      if Length(typ) <> 1 then
        Error("Ref with strange attribute set (position ", r.start, "): ", 
              typ);
      fi;
    fi;
  elif name in [ "Chapter", "Section", "Subsection" ] and not "Heading"
    in List(r.content, a-> a.name) then
    Error("Chapter, Section or Subsection must have a heading (position ",
          r.start, ")");
  fi;
  
  if r.content = EMPTYCONTENT then
    return true;
  else
    return ForAll(r.content, x-> CheckAndCleanGapDocTree(x));
  fi;
end);

    
##  <#GAPDoc Label="AddParagraphNumbersGapDocTree">
##  <ManSection >
##  <Func Arg="tree" Name="AddParagraphNumbersGapDocTree" />
##  <Returns>nothing</Returns>
##  <Description>
##  The argument  <A>tree</A> must  be an XML  tree returned  by <Ref
##  Func="ParseTreeXMLString" /> applied to a &GAPDoc; document. This
##  function adds to each node  of the tree a component <C>.count</C>
##  which is of form <C>[Chapter[, Section[, Subsection, Paragraph] ]
##  ]</C>.  Here  the first  three  numbers  should  be the  same  as
##  produced  by the  &LaTeX; version  of the  document. Text  before
##  the first chapter  is counted as  chapter <C>0</C> and  similarly for
##  sections and subsections. Some  elements are always considered to
##  start a new paragraph.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(AddParagraphNumbersGapDocTree, function(r)
  local   parels,  cssp,  setcount;
  if IsBound(r.count) then
    return;
  fi;
  
  # these elements are paragraphs  
  parels := [ "List", "Enum", "Table", "Item", "Heading", "Attr", "Fam", 
              "Filt", "Func", "InfoClass", "Meth", "Oper", "Prop", "Var",
              "Display", "Example", "Listing", "Log"];
  # reset counter
  cssp := [0, 0, 0, 1];
  # the counter setting recursive function
  setcount := function(rr)
    local   a;
    if  IsList(rr.content) and not IsString(rr.content) then
      for a in rr.content do
        # new chapter, text before first section is counted as section 0
        if a.name = "Chapter" then
          cssp := [cssp[1]+1, 0, 0, 1];
          a.count := cssp;
        elif a.name = "Section" then
          cssp := [cssp[1], cssp[2]+1, 0, 1];
        elif a.name in ["Subsection", "ManSection", "Abstract", "Copyright",
                "TableOfContents", "Acknowledgements", "Colophon"] then
          cssp := [cssp[1], cssp[2], cssp[3]+1, 1];
        elif a.name = "P" or a.name in parels then
          cssp := [cssp[1], cssp[2], cssp[3], cssp[4]+1];
        elif a.name = "Appendix" then
          # here we number with capital letters
          if IsInt(cssp[1]) then
            cssp := ["A", 0, 0, 1];
          else
            cssp := [[CHAR_INT(INT_CHAR(cssp[1][1])+1)], 0, 0, 1];
          fi;
        # bib and index are counted as new chapters  
        elif  a.name = "Bibliography" then
          cssp := ["Bib", 0, 0, 1];
        elif a.name = "TheIndex" then
          cssp := ["Ind", 0, 0, 1];
        fi;
        a.count := cssp;
        # recursion
        setcount(a);
        if a.name in parels then
          cssp := [cssp[1], cssp[2], cssp[3], cssp[4]+1];
        fi;
      od;
    fi;
  end;
  r.count := cssp;
  setcount(r);
end);

##  <#GAPDoc Label="AddPageNumbersToSix">
##  <ManSection >
##  <Func Arg="tree, pnrfile" Name="AddPageNumbersToSix" />
##  <Returns>nothing</Returns>
##  <Description>
##  Here   <A>tree</A>  must   be  the   XML  tree   of  a   &GAPDoc;
##  document,   returned   by  <Ref   Func="ParseTreeXMLString"   />.
##  Running <C>latex</C>  on the  result of  <Ref Func="GAPDoc2LaTeX"
##  /><C>(<A>tree</A>)</C>  produces  a   file  <A>pnrfile</A>  (with
##  extension  <C>.pnr</C>).  The   command  <Ref  Func="GAPDoc2Text"
##  /><C>(<A>tree</A>)</C> creates a component <C><A>tree</A>.six</C>
##  which contains all  information about the document  for the &GAP;
##  online  help,  except  the  page numbers  in  the  <C>.dvi,  .ps,
##  .pdf</C> versions of the document.  This command adds the missing
##  page number information to <C><A>tree</A>.six</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
PAGENRS := 0;
InstallGlobalFunction(AddPageNumbersToSix, function(r, pnrfile)
  local   six,  a,  pos;
  Read(pnrfile);
  six := r.six;
  for a in six do
    pos := Position(PAGENRS, a[3]);
    a[5] := PAGENRS[pos+1];
  od;
  Unbind(PAGENRS);
end);

##  <#GAPDoc Label="PrintSixFile">
##  <ManSection >
##  <Func Arg="tree, bookname, fname" Name="PrintSixFile" />
##  <Returns>nothing</Returns>
##  <Description>
##  This  function  prints  the  <C>.six</C>  file  <A>fname</A>  for
##  a   &GAPDoc;   document   stored   in   <A>tree</A>   with   name
##  <A>bookname</A>. Such  a file contains all  information about the
##  book which is  needed by the &GAP; online  help. This information
##  must first be created by  calls of <Ref Func="GAPDoc2Text" /> and
##  <Ref Func="AddPageNumbersToSix" />.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(PrintSixFile, function(file, r, bookname)
  local   f;
  # We cannot print strings with escape sequences directly,
  # so we translate them into numbers.
  f := function(a)
    local   res;
    res := ShallowCopy(a);
    res[1] := List(res[1], INT_CHAR);
    res[2] := STRING_LOWER(res[2]);
    return res;
  end;
  PrintTo(file, "#SIXFORMAT  GapDocGAP\nHELPBOOKINFOSIXTMP := rec(\n",
          "bookname := \"", bookname, "\",\n",
          "entries :=\n", List(r.six, f), "\n);\n");
end);

# non-documented utility
##  This prints templates for all elements (e.g., for editor helper functions)
PrintGAPDocElementTemplates := function ( file )
  local a, x;
  PrintTo(file, "<--  Templates for GAPDoc XML Elements  -->\n");
  Sort(GAPDOCDTDINFO, function(a,b) return a.name<b.name;end);
  for a  in GAPDOCDTDINFO  do
    AppendTo(file, "name:",a.name,"\n<", a.name );
    for x  in a.reqattr  do
      AppendTo(file, " ", x, "=\"\"" );
    od;
    for x in Difference (a.attr, a.reqattr)  do
      AppendTo(file, " ??", x, "=\"\"" );
    od;
    if a.type = "empty" then
      AppendTo(file, "/>#\n\n");
    else
      AppendTo(file, ">XXX</", a.name, ">#\n\n" );
    fi;
  od;
  return;
end;

BindGlobal("TEXTMTRANSLATIONS",
  rec(
     ldots := "...",
     mid := "|",
     left := "",
     right := "",
     mathbb := "",
     mathop := "",
     limits := "",
     cdot := "*",
     ast := "*",
     geq := ">=",
     leq := "<=",
     pmod := "mod ",
     equiv := "=",
     rightarrow := "->",
     hookrightarrow := "->",
     to := "->",
     longrightarrow := "-->",
     Rightarrow := "=>",
     Longrightarrow := "==>",
     Leftarrow := "<=",
     iff := "<=>",
     mapsto := "->",            #  "|->"  looks ugly!
     leftarrow := "<-",
     langle := "<",
     rangle := ">",
     setminus := "\\"
     )
);


InstallGlobalFunction(TextM, function(str)
  local subs, res, i, j;
  subs := Immutable(Set(NamesOfComponents(TEXTMTRANSLATIONS)));
  res := "";
  i := 1;
  while i <= Length(str) do
    # handle macros
    if str[i] = '\\' then
      j := i+1;
      while j <= Length(str) and str[j] in LETTERS do
        j := j+1;
      od;
      if str{[i+1..j-1]} in subs then
        Append(res, TEXTMTRANSLATIONS.(str{[i+1..j-1]}));
      else
        Append(res, str{[i+1..j-1]});
      fi;
      i := j;
    elif str[i] = '{' then
      if i < Length(str) and str[i+1] = '{' then
        Add(res, '{');
        i := i + 2;
      else
        i := i + 1;
      fi;
    elif str[i] = '}' then
      if i < Length(str) and str[i+1] = '}' then
        Add(res, '}');
        i := i + 2;
      else
        i := i + 1;
      fi;
    else 
      Add(res, str[i]);
      i := i + 1;
    fi;
  od;
  NormalizeWhitespace(res);
  return res;
end);


