#############################################################################
##
#W  XMLParser.gi                 GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: XMLParser.gi,v 1.11 2004-07-16 21:20:53 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The files  XMLParser.g{d,i} contain a non-validating XML  parser and some
##  utilities.
##

BindGlobal("EMPTYCONTENT", 0);
BindGlobal("NAMECHARS",   
              ## here ':' is missing since it will probably  become reserved 
              ## for name space syntax in future XML
              Set(List(Concatenation([45,46], [48..57], [65..90], 
              [95], [97..122]), CHAR_INT))
           );

##   two helper functions for parsing
# next successive characters not in delim (resp. enddelim) - default WHITESPACE
# arg: str, pos[, delim[, enddelim]]
BindGlobal("GetWord", function(arg)
  local   str,  pos,  delim,  enddelim,  len,  pos2;
  str := arg[1];
  pos := arg[2];
  if Length(arg)>2 then
    delim := arg[3];
    if Length(arg)>3 then
      enddelim := arg[4];
    else
      enddelim := delim;
    fi;
  else
    delim := WHITESPACE;
    enddelim := WHITESPACE;
  fi;
  
  len := Length(str);
  
  while pos <= len and str[pos] in delim do
    pos := pos + 1;
  od;
  pos2 := pos;
  while pos2 <= len and not str[pos2] in enddelim do
    pos2 := pos2 + 1;
  od;
  if pos2>len then
    return fail;
  else
    return [pos, pos2-1];
  fi;
end);

# first position after pos with character outside chars 
BindGlobal("GetChars", function(str, pos, chars)
  local   len;
  len := Length(str);
  while pos <= len and str[pos] in chars do
    pos := pos + 1;
  od;
  if pos > len then
    return fail;
  else
    return pos;
  fi;
end);

# returns for string, position:  [line number, [begin..end position of
# line]] (range without the '\n') 
BindGlobal("LineNumberStringPosition", function(str, pos)
  local p, nl, l;
  p := 0;
  l := 0;
  nl := 0;
  while p<>fail and p < pos do
    l := p;
    p := Position(str, '\n', p);
    nl := nl+1;
  od;
  if p=fail then
    p := Length(str)+1;
  fi;

  if pos = p then
    nl := nl - 1;
  fi;
  return [nl, [l+1..p-1]];
end);

# printing of error message for non-well formed XML document,
# also shows some text around position of error.
BindGlobal("ParseError", function(str, pos, comment)
  local Show, nl;
  # for examination of error
  Show := function()
    Pager(rec(lines := str, start := nl[1]));
  end;
  nl := LineNumberStringPosition(str, pos);
  Print("XML Parse Error: Line ", nl[1]);
  Print(" Character ", pos-nl[2][1]+1, "\n-----------\n", 
        str{nl[2]}, "\n");
  if pos-nl[2][1] >= 1 then
    Print(List([1..pos-nl[2][1]], i-> ' '));
  fi;
  Print("^", "\n-----------\n", comment, "\n!!! Type `Show();' to watch the",
  " input string in pager - starting with\n    line containing error !!!\n");
  Error();
end);

##  the predefined entities of the GAPDoc package
BindGlobal("ENTITYDICT", rec(
 lt := "&#38;#60;",
 gt := "&#62;",
 amp := "&#38;#38;",
 apos := "&#39;",
 quot := "&#34;",
 tamp := "<Alt Only='LaTeX'>\\&amp;</Alt><Alt Not='LaTeX'><Alt Only='HTML'>&amp;amp;</Alt><Alt Not='HTML'>&amp;</Alt></Alt>",
 tlt := "<Alt Only='LaTeX'>{\\textless}</Alt><Alt Not='LaTeX'><Alt Only='HTML'>&amp;lt;</Alt><Alt Not='HTML'>&lt;</Alt></Alt>",
 tgt := "<Alt Only='LaTeX'>{\\textgreater}</Alt><Alt Not='LaTeX'><Alt Only='HTML'>&amp;gt;</Alt><Alt Not='HTML'>&gt;</Alt></Alt>",
 hash := "<Alt Only='LaTeX'>\\#</Alt><Alt Not='LaTeX'>#</Alt>",
 dollar := "<Alt Only='LaTeX'>\\$</Alt><Alt Not='LaTeX'>$</Alt>",
 percent := "<Alt Only='LaTeX'>\\&#37;</Alt><Alt Not='LaTeX'>&#37;</Alt>",
 tilde := "<Alt Only='LaTeX'>{\\textasciitilde}</Alt><Alt Not='LaTeX'>~</Alt>",
 bslash := "<Alt Only='LaTeX'>{\\textbackslash}</Alt><Alt Not='LaTeX'>\\</Alt>",
 obrace := "<Alt Only='LaTeX'>\\{</Alt><Alt Not='LaTeX'>{</Alt>",
 cbrace := "<Alt Only='LaTeX'>\\}</Alt><Alt Not='LaTeX'>}</Alt>",
 uscore := "<Alt Only='LaTeX'>{\\textunderscore}</Alt><Alt Not='LaTeX'>_</Alt>",
 circum := "<Alt Only='LaTeX'>{\\textasciicircum}</Alt><Alt Not='LaTeX'>^</Alt>",
 nbsp := "<Alt Only='LaTeX'>~</Alt><Alt Not='LaTeX'>&#160;</Alt>",
 GAP := "<Package>GAP</Package>",
 GAPDoc := "<Package>GAPDoc</Package>",
 TeX    := "<Alt Only='LaTeX'>{\\TeX}</Alt><Alt Not='LaTeX'>TeX</Alt>",
 LaTeX  := "<Alt Only='LaTeX'>{\\LaTeX}</Alt><Alt Not='LaTeX'>LaTeX</Alt>",
 BibTeX := "<Alt Only='LaTeX'>BibTeX</Alt><Alt Not='LaTeX'>BibTeX</Alt>",
 MeatAxe := "<Package>MeatAxe</Package>",
 XGAP   := "<Package>XGAP</Package>",
 copyright := "<Alt Only='LaTeX'>{\\copyright}</Alt><Alt Not='LaTeX'>(C)</Alt>"
                  )
);

##  Parsing and resolving an entity, the needed substitution text for
##  non-character entities must be bound in ENTITYDICT.
##  -- assuming str[pos-1] = '&'
##  -- returns pseudo-element (Char)EntityValue with content the result string
##  -- character entities are just substituted and returned as string
##  -- the replacement for other entities is reparsed for recursive
##     substitution
InstallGlobalFunction(GetEnt, function(str, pos)
  local   d,  i,  ch,  pos1,  nam,  doc,  res,  ent;
  # character entity
  if str[pos] = '\#' then
     d := "";
    if str[pos+1] = 'x' then
      i := pos + 2;
      while str[i] <> ';' do
        Add(d, str[i]);
        i := i+1;
      od;
      ch := [CHAR_INT(NumberDigits(d, 16))];
    else
      i := pos+1;
      while str[i] <> ';' do
        Add(d, str[i]);
        i := i+1;
      od;
      ch := [CHAR_INT(NumberDigits(d, 10))];
    fi;
    return rec(name := "CharEntityValue", content := ch, next := i+1);
  fi;
  # else replace and reparse for recursive entity replacements
  pos1 := Position(str, ';', pos-1);
  if pos1=pos then
    ParseError(str, pos, "empty entity name not allowed");
  elif pos1 = fail then
    ParseError(str, pos, "no semicolon in entity reference");
  fi;
  nam := str{[pos..pos1-1]};
  if not IsBound(ENTITYDICT.(nam)) then
    # XXX error or better going on here?
##      ParseError(str, pos, "don't know entity name");
    Print("WARNING: Entity with name `", nam, "' not known!\n",
          "         (Specify in <!DOCTYPE ...> tag!)\n");
    doc := Concatenation("UNKNOWNEntity(", nam, ")");
  else
    doc := ENTITYDICT.(nam);
  fi;
  i := 1;
  res := "";
  while i <= Length(doc) do
    if doc[i] <> '&' or (i<Length(doc) and doc[i+1] <> '\#') then
      Add(res, doc[i]);
      i := i+1;
    else
      ent := GetEnt(doc, i+1);
      Append(res, ent.content);
      i := ent.next;
    fi;
  od;
  return rec(name := "EntityValue", content := res, next := pos1+1);
end);
  
##  reading a start tag including attribute values
# returns rec(name := elementname, 
#             attributes := rec( attributename1 := attributevalue1, ...)
#             content := EMPTYCONTENT or [] (to be filled recursively)
#             next := positon in string after start tag )
# Special handling of case pos=1: the element name is not parsed but assumed 
# to be WHOLEDOCUMENT; this way a complete document can be put in one pseudo
# element of this name.
# assuming str[pos-1] = '<' and str[pos]<>'/'
InstallGlobalFunction(GetSTag, function(str, pos)
  local   res,  pos2,  attr, atval, delim, ent;
  res := rec(attributes := rec());
  # a small hack that allows to call GetElement with a whole document
  # after appending "</WHOLEDOCUMENT>"
  if pos=1 then
    res.name := "WHOLEDOCUMENT";
    res.next := 1;
    res.content := [];
    res.input := str;
    return res;
  fi;
  # name of element
  pos2 := GetChars(str, pos, NAMECHARS);
  if pos2=fail then
    ParseError(str, pos, "documents ends in element name");
  fi;
  if pos2=pos then
    ParseError(str, pos, "tag must start with name \'<name ...\'");
  fi;
  res.name := str{[pos..pos2-1]};
  # look for attributes or end of tag
  pos := GetChars(str, pos2, WHITESPACE);
  if pos=fail then
    ParseError(str, pos2, "document ends in tag");
  fi;
  while not str[pos] in "/>" do
    if not str[pos-1] in WHITESPACE then
      ParseError(str, pos-1, Concatenation("there must be white space ",
              "before attribute name"));
    fi;
    pos2 := GetChars(str, pos, NAMECHARS);
    if pos2=fail then
      ParseError(str, pos, "document ends in attribute name");
    fi;
    if pos2=pos then
      ParseError(str, pos, "attribute must have non-empty name");
    fi;
    # reading attribute value
    attr := str{[pos..pos2-1]};
##      if not (str[pos2] = '=' and str[pos2+1] in "\"'") then
##        ParseError(str, pos2, Concatenation("attribute must be specified ",
##                "in form \'attr=\"text\"\'"));
##      fi;
##      delim := str[pos2+1];
    # can be white space around =
    pos2 := GetChars(str, pos2, WHITESPACE);
    if pos2 = fail or str[pos2] <> '=' then
      ParseError(str, pos2, "expecting '=' for attribute value");
    fi;
    pos2 := GetChars(str, pos2+1, WHITESPACE);
    if pos2 = fail or not str[pos2] in "\"'" then
      ParseError(str, pos2, "expecting quotes for attribute value");
    fi;
    delim := str[pos2];
    atval := "";
    pos2 := pos2 + 1;
    while str[pos2] <> delim do
      # we allow     attr='fkjf"fafds'   as well, see AnnStd 2.3  
      pos2 := GetWord(str, pos2, "", "<&\"'");
      if pos2=fail then
        ParseError(str, pos, "document ends in attribute value");
      fi;
      # must allow    &xyz;  for entity resolution as well
      if not str[pos2[2]+1] = delim  then
        if str[pos2[2]+1] = '&' then
          ent := GetEnt(str, pos2[2]+2);
          Append(atval, str{[pos2[1]..pos2[2]]});
          Append(atval, ent.content);
          pos2 := ent.next;
        elif str[pos2[2]+1] in "\"'" then
          Append(atval, str{[pos2[1]..pos2[2]+1]});
          pos2 := pos2[2]+2;
        else
          ParseError(str, pos2[2]+1, "non valid character in attribute value");
        fi;
      else
        Append(atval, str{[pos2[1]..pos2[2]]});
        pos2 := pos2[2]+1;   
      fi;
    od;
    res.attributes.(attr) := atval;
    pos2 := pos2+1;
    pos := GetChars(str, pos2, WHITESPACE);
    if pos=fail then
      ParseError(str, pos2, "document ends in tag");
    fi;
  od;
  if str[pos] = '/' then
    res.content := EMPTYCONTENT;
    pos := pos+1;
  else
    res.content := [];
  fi;
  if not str[pos] = '>' then
    ParseError(str, pos, "expecting end of tag \'>\' here");
  fi;
  res.next := pos+1;
  return res;
end);

##  reading an end tag, 
##  returns rec( name := elementname, 
##               next := first position after this end tag)
# assuming str{[pos-2,pos-1]} = "</"
InstallGlobalFunction(GetETag, function(str, pos)
  local   res,  pos2;
  res := rec();
  # name of element
  pos2 := GetChars(str, pos, NAMECHARS);
  if pos2=fail then
    ParseError(str, pos, "documents ends in element name");
  fi;
  if pos2=pos then
    ParseError(str, pos, "end tag must start with name \'</name ...\'");
  fi;
  res.name := str{[pos..pos2-1]};
  pos := pos2;
  pos2 := GetChars(str, pos, WHITESPACE);
  if pos2=fail then
    ParseError(str, pos, "documents ends inside end tag");
  fi;
  if str[pos2] <> '>' then
    ParseError(str, pos2, "expecting end of tag \'>\' here");
  fi;
  res.next := pos2+1;
  return res;
end);

##  reading an element: start tag, content (with recursive calls of
##  GetElement) and end tag
# returns record explained before GetSTag, but with .content component
# filled
# assuming str[pos-1] = '<' and str[pos] in NAMECHARS
InstallGlobalFunction(GetElement, function(str, pos)
  local   res,  r,  s,  pos2,  lev,  dt,  p,  nam,  val,  el;
  res := GetSTag(str,pos);
  res.start := pos - 1;
  # case of empty element
  if res.content = EMPTYCONTENT then
    res.stop := res.next - 1;
    return res;
  fi;
  pos := res.next;
  while true do
    if str[pos] = '&' then
      # resolve entity
      r := GetEnt(str, pos+1);
      pos := r.next;
      if r.name = "CharEntityValue" then
        # consider as PCDATA
        r.name := "PCDATA";
        Add(res.content, r);
      else
        # we have to parse the result
        s := Concatenation(r.content, "</WHOLEDOCUMENT>");
        r := GetElement(s, 1);
        Append(res.content, r.content);
      fi;
    elif str[pos] = '<' then
      if str[pos+1] = '?' then
        # processing instruction (PI), we repeat it literally
        pos2 := PositionSublist(str, "?>", pos+2);
        if pos2=fail then
          ParseError(str, pos+2, "document ends within processing instruction");
        fi;
        Add(res.content, rec(name := "XMLPI", 
                content := str{[pos+2..pos2-1]}));
        pos := pos2+2;
      elif str[pos+1] = '!' then
        if str[pos+2] = '-' and str[pos+3] = '-' then
          ## comment 
          #  here we ignore the restriction that inside comment 
          #  no "--" is allowed.
          pos2 := PositionSublist(str, "-->", pos+4);
          if pos2=fail then
            ParseError(str,pos+4, "document ends within comment");
          fi;
          Add(res.content, rec(name := "XMLCOMMENT", 
                  content := str{[pos+4..pos2-1]}));
          pos := pos2+3;
        elif str[pos+2] = 'D' and str{[pos+3..pos+8]} = "OCTYPE" and
          str[pos+9] in WHITESPACE then
          ## <!DOCTYPE ....
          ## end of this tag is matching ">"
          ## we have to read ENTITY declarations
          pos2 := pos+10;
          lev := 0;
          while str[pos2] <> '>' or lev > 0 do
            if str[pos2] = '<' then
              lev := lev+1;
            elif str[pos2] = '>' then
              lev := lev-1;
            fi;
            pos2 := pos2+1;
            if pos2>Length(str) then
              ParseError(str,pos+10, "document ends within DOCTYPE tag"); 
            fi;
          od;
          dt := rec(name := "XMLDOCTYPE", 
                  content := str{[pos+10..pos2-1]});
          Add(res.content, dt);
          ##  parse entity declarations in here (no good error checking)
          pos := PositionSublist(dt.content, "<!ENTITY");
          while pos <> fail do
            p := GetWord(dt.content, pos+8);
            nam := dt.content{[p[1]..p[2]]};
            # value enclosed in ".." or '..'
            p := p[2]+1;
            while dt.content[p] in WHITESPACE do
              p := p + 1;
            od;
            p := [p+1];
            Add(p, Position(dt.content, dt.content[p[1]-1], p[1])-1);
            val := dt.content{[p[1]..p[2]]};
            ENTITYDICT.(nam) := val;
            pos := PositionSublist(dt.content, "<!ENTITY", p[2]);
          od;
          pos := pos2+1;
        elif  str[pos+2] = '[' and str{[pos+3..pos+8]} = "CDATA[" then
          ## <![CDATA[   everything is verbose text until "]]>"
          pos2 := PositionSublist(str, "]]>", pos+9);
          if pos2=fail then
            ParseError(str,pos+10, "document ends within CDATA text");
          fi;
          if pos2>pos+9 then
            Add(res.content, rec(name := "PCDATA", 
                    content := str{[pos+9..pos2-1]}));
          fi;
          pos := pos2+3;
        else 
          ParseError(str, pos, "unknown \"<!\"-tag");
        fi;
      elif str[pos+1] = '/' then
        ##  end tag, must be the right one corresponding to the
        ##  current element 
        el := GetETag(str, pos+2);
        if res.name <> el.name then
          ParseError(str, pos, Concatenation("wrong end tag, expecting \"</",
                  res.name, ">\" (starts line ",
                  String(LineNumberStringPosition(str, res.start)[1]), ")"));
        else
          res.stop := el.next - 1;
          res.next := el.next;
          break;
        fi;
      elif not str[pos+1] in NAMECHARS then  
        ParseError(str, pos+1, "not allowed character after '<'");
      else
        ## a new element starts, call GetElement recursively
        el := GetElement(str, pos+1);
        Add(res.content, el);
        pos := el.next;
      fi;
    else
      pos2 := GetWord(str, pos, "", "<&");
      if pos2 = fail then
        ParseError(str, pos, "document ends before end of current element");
      fi;
      if pos2[2] >= pos then
        Add(res.content, rec(name := "PCDATA", 
                content := str{[pos..pos2[2]]}));
      fi;
      pos := pos2[2]+1;
    fi;
  od;
  return res;
end);

##  the user function for parsing an XML document stored in a string, 
##  adds end tag for pseudo element WHOLEDOCUMENT (see before GetSTag)
##  and calls GetElement

##  <#GAPDoc Label="ParseTreeXMLString">
##  <ManSection >
##  <Func Arg="str" Name="ParseTreeXMLString" />
##  <Returns>a record which is root of a tree structure</Returns>
##  <Description>
##  This function parses an  XML-document stored in string <A>str</A>
##  and returns the document in form of a tree.<P/>
##  
##  A node  in this tree  corresponds to an  XML element, or  to some
##  parsed character data. In the first case it looks as follows:
##  
##  <Listing Type="Example Node">
##  rec( name := "Book",
##       attributes := rec( Name := "EDIM" ),
##       content := [ ... list of nodes for content ...],
##       start := 312,
##       stop := 15610,
##       next := 15611     )
##  </Listing>
##  
##  This  means   that  <C><A>str</A>{[312..15610]}</C>   looks  like
##  <C>&tlt;Book Name="EDIM"> ... content ... &tlt;/Book></C>.<P/>
##  
##  The leaves  of the tree  encode parsed  character data as  in the
##  following example:
##  
##  <Listing Type="Example Node">
##  rec( name := "PCDATA", 
##       content := "text without markup "     )
##  </Listing>
##  
##  This function checks whether  the  XML  document   is  <Emph>well
##  formed</Emph>, see  <Ref Chap="XMLvalid"  /> for  an explanation.
##  If   an  error in  the XML  structure is found,  a break  loop is
##  entered and the text around the position where the problem starts
##  is shown. With  <C>Show();</C> one can browse  the original input
##  in  the <Ref  BookName="Ref" Func="Pager"  />, starting  with the
##  line where the error occurred.
##  
##  All entities are  resolved when they are  either entities defined
##  in the &GAPDoc; package (in particular the standard XML entities)
##  or if their definition is included in the <C>&lt;!DOCTYPE ..></C>
##  tag of the document.<P/>
##  
##  Note  that  <Ref  Func="ParseTreeXMLString"  />  does  not  parse
##  and  interpret the  corresponding document  type definition  (the
##  <C>.dtd</C>-file given in the <C>&lt;!DOCTYPE ..></C> tag). Hence
##  it also does not check  the <Emph>validity</Emph> of the document
##  (i.e., it is no <Emph>validating XML parser</Emph>).<P/>
##  
##  If  you are  using this  function  to parse  a &GAPDoc;  document
##  you  can  use  <Ref Func="CheckAndCleanGapDocTree"  />  for  some
##  validation and additional checking of the document structure.
##  
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(ParseTreeXMLString, function(str)  
  str := Concatenation(str, "</WHOLEDOCUMENT>");
  return GetElement(str, 1);
end);

##  Print document tree structure (without the PCDATA entries)

##  <#GAPDoc Label="DisplayXMLStructure">
##  <ManSection >
##  <Func Arg="tree" Name="DisplayXMLStructure" />
##  <Description>
##  This utility displays the tree structure of an XML document as it
##  is  returned by  <Ref Func="ParseTreeXMLString"  /> (without  the
##  <C>PCDATA</C> leaves).<P/>
##  
##  Since this  is usually quite long  the result is shown  using the
##  <Ref BookName="ref" Func="Pager" />.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(DisplayXMLStructure, function(doc)
  local   NL, prs, app, str;
  str := "";
  NL := "\n";
  app := function(arg)
    local i;
    for i in [2..Length(arg)] do
      Append(arg[1], arg[i]);
    od;
  end;  
  prs := function(doc, indent)
    local   a,  c,  indentnext;
    if doc.name = "PCDATA" then
      return;
    fi;
    if IsBound(doc.count) then
      c := String(doc.count);
    else
      c := "";
    fi;
    app(str, indent, c, "  ", doc.name, NL);
    if IsBound(doc.attributes) then
      for a in NamesOfComponents(doc.attributes) do
        app(str, indent,"  #",a,":",doc.attributes.(a), NL);
      od;
    fi;
    if doc.content = EMPTYCONTENT then
      app(str, indent, "  # empty element\n");
    elif IsString(doc.content) then
## ??? too much output
##        Print(indent, "  # data\n");
    else
      for a in doc.content do
        indentnext := Concatenation(indent, "  ");
        prs(a, indentnext);
      od;
    fi;
  end;
  prs(doc, "");
  Page(str);
end);

##  apply a function to all nodes of a parse tree

##  <#GAPDoc Label="ApplyToNodesParseTree">
##  <ManSection >
##  <Func Arg="tree, fun" Name="ApplyToNodesParseTree" />
##  <Func Arg="tree" Name="AddRootParseTree" />
##  <Func Arg="tree" Name="RemoveRootParseTree" />
##  <Description>
##  The  function  <Ref  Func="ApplyToNodesParseTree"  />  applies  a
##  function <A>fun</A>  to all nodes  of the parse  tree <A>tree</A>
##  of  an XML  document returned  by <Ref  Func="ParseTreeXMLString"
##  />.<P/>
##  
##  The function <Ref Func="AddRootParseTree" /> is an application of
##  this.  It adds  to all  nodes a  component <C>.root</C>  to which 
##  the top node tree <A>tree</A> is assigned. These components can be
##  removed afterwards with <Ref Func="RemoveRootParseTree" />.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(ApplyToNodesParseTree, function(r, f)
  local   ff;
  ff := function(rr)
    local   a;
    if IsList(rr.content) and not IsString(rr.content) then
      for a in rr.content do 
        f(a);
        ff(a);
      od;
    fi;
  end;
  f(r);
  ff(r);
end);

##  This is useful for things like indexing where one should have
##  access to the root of the document tree during the whole processing 
InstallGlobalFunction(AddRootParseTree, function(r)
  ApplyToNodesParseTree(r, function(a) a.root := r; end);  
end);

##  And this throws away the links 
InstallGlobalFunction(RemoveRootParseTree, function(r)
  ApplyToNodesParseTree(r, function(a) Unbind(a.root); end);  
end);

