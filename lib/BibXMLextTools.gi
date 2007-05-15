#############################################################################
##
#W  BibXMLextTools.gi             GAPDoc                         Frank Lübeck
##
#H  @(#)$Id: BibXMLextTools.gi,v 1.15 2007-05-15 21:04:16 gap Exp $
##
#Y  Copyright (C)  2006,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files BibXMLextTools.g{d,i} contain utility functions for dealing
##  with bibliography data in the BibXMLext format. The corresponding DTD
##  is in ../bibxmlext.dtd. 
##  


###########################################################################
##  
##  templates to fill for new entries, this describes the possible entries
##  and their structure
##  (This is generated from Bibxmlext from bibxmlextinfo.g, which is created
##  automatically with the adhoc utility parsedtd.g.)
BindGlobal("BibXMLextStructure", rec());
BibXMLextStructure.fill := function()
  local l, els, i, type;
  for type in Filtered(Bibxmlext[1].entry, a-> a <> "or") do
    l := Bibxmlext[1].(type);
    els := [];
    i := 1;
    while i <= Length(l) do
      if i = Length(l) or not l[i+1] in ["optional", "repeated"] then
        Add(els, [l[i], true]);
        i := i+1;
      else
        Add(els, [l[i], false]);
        i := i+2;
      fi;
    od;
    # Print(type,": ",Filtered(els, a->not IsString(a[1])),"\n");
    BibXMLextStructure.(type) := els;
  od;
  Unbind(BibXMLextStructure.fill);
end;
BibXMLextStructure.fill();


##  <#GAPDoc Label="TemplateBibXML">
##  <ManSection >
##  <Func Arg="[type]" Name="TemplateBibXML" />
##  <Returns>list of types or string</Returns>
##  <Description>
##  Without an argument this function returns a list of the supported entry
##  types in  BibXMLext documents.
##  <P/>
##  With an argument <A>type</A> of one of the supported types the function
##  returns a string which is a template for a corresponding BibXMLext entry.
##  Optional field elements have a <C>*</C> appended. If an element has
##  the word <C>OR</C> appended, then either this element or the next must/can
##  be given, not both. If <C>AND/OR</C> is appended then this and/or the next
##  can/must be given. Elements which can appear several times  have a 
##  <C>+</C> appended. Places to fill are marked by an <C>X</C>.
##  
##  <Example><![CDATA[
##  gap> TemplateBibXML();
##  [ "article", "book", "booklet", "manual", "techreport", "mastersthesis", 
##    "phdthesis", "inbook", "incollection", "proceedings", "inproceedings", 
##    "conference", "unpublished", "misc" ]
##  gap> Print(TemplateBibXML("inbook"));
##  <entry id="X"><inbook>
##    <author>
##      <name><first>X</first><last>X</last></name>+
##    </author>OR
##    <editor>
##      <name><first>X</first><last>X</last></name>+
##    </editor>
##    <title>X</title>
##    <chapter>X</chapter>AND/OR
##    <pages>X</pages>
##    <publisher>X</publisher>
##    <year>X</year>
##    <volume>X</volume>*OR
##    <number>X</number>*
##    <series>X</series>*
##    <type>X</type>*
##    <address>X</address>*
##    <edition>X</edition>*
##    <month>X</month>*
##    <note>X</note>*
##    <key>X</key>*
##    <annotate>X</annotate>*
##    <crossref>X</crossref>*
##    <abstract>X</abstract>*
##    <affiliation>X</affiliation>*
##    <contents>X</contents>*
##    <copyright>X</copyright>*
##    <isbn>X</isbn>*OR
##    <issn>X</issn>*
##    <keywords>X</keywords>*
##    <language>X</language>*
##    <lccn>X</lccn>*
##    <location>X</location>*
##    <mrnumber>X</mrnumber>*
##    <mrclass>X</mrclass>*
##    <mrreviewer>X</mrreviewer>*
##    <price>X</price>*
##    <size>X</size>*
##    <url>X</url>*
##    <category>X</category>*
##    <other type="X">X</other>*+
##  </inbook></entry>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
# args:  [type]         with no argument prints the possible types
InstallGlobalFunction(TemplateBibXML, function(arg)
  local type, res, add, a, b;
  if Length(arg) = 0 then
    return Filtered(RecFields(BibXMLextStructure), a-> not a in ["fill"]);
  fi;
  type := arg[1];
  if type = "fill" or not IsBound(BibXMLextStructure.(type)) then
    Error("There are no bib-entries of type ", type,".\n");
  fi;
  res := "<entry id=\"X\"><";
  Append(res, type);
  Append(res, ">\n");
  add := function(a)
    if a[1] in [ "author", "editor" ] then
      Append(res, "  <");
      Append(res, a[1]);
      Append(res, ">\n    <name><first>X</first><last>X</last></name>+\n  </");
      Append(res, a[1]);
      Append(res, ">");
    elif a[1] = "other" then
      Append(res, "  <other type=\"X\">X</other>");
    else
      Append(res, "  <");
      Append(res, a[1]);
      Append(res, ">X</");
      Append(res, a[1]);
      Append(res, ">");
    fi;
    if not a[2] then 
      Add(res, '*');
    fi;
    if a[1] = "other" then
      Add(res, '+');
    fi;
    Append(res, "\n");
  if not IsString(res) then Error("nanu");fi;
  end;

  for a in BibXMLextStructure.(type) do
    if IsString(a[1]) then
      add(a);
    elif Length(a[1]) = 3 and a[1][2] = "or" then
      if IsString(a[1][1]) then
        add([a[1][1], a[2]]);
        Unbind(res[Length(res)]);
        Append(res,"OR\n");
      elif a[1][1] = [ "chapter", "pages", "optional" ] then
        add([a[1][1][1], a[2]]);
        Unbind(res[Length(res)]);
        Append(res,"AND/OR\n");
      else
        Error("unknown case 1?");
      fi;
      add([a[1][3], a[2]]);
    else
      Error("unknown case 2?");
    fi;
  od;
  Append(res, "</");
  Append(res, type);
  Append(res, "></entry>\n");
  return res;
end);

###########################################################################
##  
##  parsing BibXMLext files
##  
##  <#GAPDoc Label="ParseBibXMLextString">
##  <ManSection >
##  <Func Arg="str" Name="ParseBibXMLextString" />
##  <Func Arg="fname1[, fname2[, ...]]" Name="ParseBibXMLextFiles" />
##  <Returns>a record with fields <C>.entries</C>, <C>.strings</C> and
##  <C>.entities</C></Returns>
##  <Description>
##  The first function gets a string <A>str</A> containing a <C>BibXMLext</C>
##  document or a part of it. It returns a record with the three mentioned
##  fields. Here <C>.entries</C> is a list of partial XML parse trees for
##  the <C>&lt;entry></C>-elements in <A>str</A>. The field <C>.strings</C>
##  is a list of key-value pairs from the <C>&lt;string></C>-elements in 
##  <A>str</A>. And <C>.strings</C> is a list of name-value pairs of the 
##  named entities which were used during the parsing.
##  <P/>
##  
##  The second function <Ref Func="ParseBibXMLextFiles"/> uses the first 
##  on the content of all files given by filenames <A>fname1</A> and so on.
##  It collects the results in a single record.<P/>
##  
##  As an example we parse the file <F>mybib.xml</F>  shown in
##  <Ref Sect="BibXMLformat"/>.
##  
##  <Example>
##  gap> bib := ParseBibXMLextFiles("mybib.xml");;
##  gap> RecFields(bib);
##  [ "entries", "strings", "entities" ]
##  gap> bib.entries;
##  [ &lt;BibXMLext entry: AB2000> ]
##  gap> bib.strings;
##  [ [ "j", "Important Journal" ] ]
##  gap> bib.entities[1]; 
##  [ "amp", "&amp;#38;#38;" ]
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# args:  string with BibXMLext document[, record with three lists]
# the three lists n: 
#                     .entries:  parse trees of <entry> elements,
#                     .strings:  pairs   [ <string> key, <string> value ],
#                     .entities: pairs   [ entity name, entity substitution ]
BindGlobal("BibXMLEntryOps", rec(
  ViewObj := function(entry)
    Print("<BibXMLext entry: ");
    Print(entry.attributes.id, ">");
  end,
  PrintObj := function(entry)
    Print(StringXMLElement(entry)[1]);
  end
  ));
# the entities from bibxmlext.dtd
BindGlobal("ENTITYDICT_bibxml", rec( 
  tamp := "<Alt Only='BibTeX'>\\&amp;</Alt><Alt Not='BibTeX'><Alt Only='HTML'>&amp;amp;</Alt><Alt Not='HTML'>&amp;</Alt></Alt>", 
  tlt := "<Alt Only='BibTeX'>{\\textless}</Alt><Alt Not='BibTeX'><Alt Only='HTML'>&amp;lt;</Alt><Alt Not='HTML'>&lt;</Alt></Alt>", 
  tgt := "<Alt Only='BibTeX'>{\\textgreater}</Alt><Alt Not='BibTeX'><Alt Only='HTML'>&amp;gt;</Alt><Alt Not='HTML'>&gt;</Alt></Alt>", 
  hash := "<Alt Only='BibTeX'>\\#</Alt><Alt Not='BibTeX'>#</Alt>", 
  dollar := "<Alt Only='BibTeX'>\\$</Alt><Alt Not='BibTeX'>$</Alt>", 
  percent := "<Alt Only='BibTeX'>\\&#37;</Alt><Alt Not='BibTeX'>&#37;</Alt>", 
  tilde := "<Alt Only='BibTeX'>\\texttt{\\symbol{126}}</Alt><Alt Not='BibTeX'>~</Alt>", 
  bslash := "<Alt Only='BibTeX'>\\texttt{\\symbol{92}}</Alt><Alt Not='BibTeX'>\\</Alt>", 
  obrace := "<Alt Only='BibTeX'>\\texttt{\\symbol{123}}</Alt><Alt Not='BibTeX'>{</Alt>", 
  cbrace := "<Alt Only='BibTeX'>\\texttt{\\symbol{125}}</Alt><Alt Not='BibTeX'>}</Alt>", 
  uscore := "<Alt Only='BibTeX'>{\\textunderscore}</Alt><Alt Not='BibTeX'>_</Alt>", 
  circum := "<Alt Only='BibTeX'>\\texttt{\\symbol{94}}</Alt><Alt Not='BibTeX'>^</Alt>", 
  nbsp := "<Alt Only='BibTeX'>~</Alt><Alt Not='BibTeX'>&#160;</Alt>" ,
  copyright := "<Alt Only='BibTeX'>{\\copyright}</Alt><Alt Not='BibTeX'>(C)</Alt>",
  ndash := "<Alt Only='BibTeX'>--</Alt><Alt Not='BibTeX'>&#x2013;</Alt>",
));

InstallGlobalFunction(ParseBibXMLextString, function(arg)
  local str, res, tr, ent, strs, entries, a;
  str := arg[1];
  if Length(arg) > 1 then
    res := arg[2];
  else
    res := rec(entries := [], strings := [], entities := []);
  fi;
  tr := ParseTreeXMLString(str, ENTITYDICT_bibxml);
  # get used entities from ENTITYDICT
  ent := List(RecFields(ENTITYDICT), a-> [a, ENTITYDICT.(a)]);
  Append(res.entities, ent);
  res.entities := Set(res.entities);

  # read <string> key value pairs
  strs := XMLElements(tr, ["string"]);
  for a in strs do 
    AddSet(res.strings, [a.attributes.key, a.attributes.value]);
  od;
  entries := XMLElements(tr, ["entry"]);
  for a in entries do 
    a.operations := BibXMLEntryOps;
  od;
  Append(res.entries, entries);
  return res;
end);

InstallGlobalFunction(ParseBibXMLextFiles, function(arg)
  local res, nam;
  if Length(arg) > 0 and not IsString(arg[Length(arg)]) then
    res := arg[Length(arg)];
    arg := arg{[1..Length(arg)-1]};
  else
    res := rec(entries := [], strings := [], entities := []);
  fi;
  for nam in arg do
    ParseBibXMLextString(StringFile(nam), res);
  od;
  return res;
end);




###########################################################################
##  
##  heuristic translation of BibTeX data to BibXMLext
##  
##  <#GAPDoc Label="StringBibAsXMLext">
##  <ManSection >
##  <Func Arg="bibentry[, abbrvs, vals]" Name="StringBibAsXMLext" />
##  <Returns>a string with XML code</Returns>
##  <Description>
##  The argument <A>bibentry</A> is a record representing an entry from a 
##  &BibTeX; file, as returned in the first list of the result of <Ref
##  Func="ParseBibFiles"/>. The optional further two arguments can be 
##  lists of abbreviations and substitution strings, as returned as second
##  an third list element in the result of <Ref Func="ParseBibFiles"/>.
##  <P/>
##  The function <Ref Func="StringBibAsXMLext"/> creates XML code of an
##  <C>&lt;entry></C>-element in   <C>BibXMLext</C> format. It tries to do
##  some heuristic translations, like splitting name lists, finding places for
##  <C>&lt;C></C>-elements, putting formulae in <C>&lt;M></C>-elements,
##  substituting some characters. The result should always be checked and
##  maybe improved by hand.
##  
##  <Example>
##  ???still missing???
##  
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
# args:  bibrec[, abbrevs, strings]
InstallGlobalFunction(StringBibAsXMLext,  function(arg)
  local r, abbrevs, texts, struct, f, res, content, a, 
        tmp, nams, b, cont, MandC, i, pos;

  r := arg[1];
  if Length( arg ) > 2  then
    abbrevs := arg[2];
    texts := arg[3];
  else
    abbrevs := [  ];
    texts := [  ];
  fi;
  if not IsSet(texts) then
    SortParallel(texts, abbrevs);
  fi;

  # helper, to change {}'s outside math mode and $'s in 
  # (book)title <C> and <M>-elements:
  MandC := function(str)
    local res, math, c;
    if Position(str, '{') = fail and Position(str, '$') = fail then
      return str;
    fi;
    # escape & and <
    str := SubstitutionSublist(str, "<", "&lt;");
    str := SubstitutionSublist(str, "&", "&amp;");
    res := "";
    math := false;
    for c in str do
      if c = '$' then
        math := not math;
        if math then
          Append(res, "<M>");
        else
          Append(res, "</M>");
        fi;
      elif c = '{' and not math then
        Append(res, "<C>");
      elif c = '}' and not math then
        Append(res, "</C>");
      else
        Add(res, c);
      fi;
    od;
    return ParseTreeXMLString(res).content;
  end;
  if not (r.Type in RecFields(BibXMLextStructure)) then
    Info(InfoBibTools, 1, "#W WARNING: invalid .Type in Bib-record: ", 
                                                          r.Type, "\n");
    Info(InfoBibTools, 2, r, "\n");
    return fail;
  fi;
  struct := BibXMLextStructure.(r.Type);
  f := RecFields(r);

  # checking conditions on certain related elements in an entry
  if "isbn" in f and "issn" in f then
    Info(InfoBibTools, 1, "#W WARNING: Cannot have both, ISBN and ISSN ",
                            "in Bib-record\n");
    Info(InfoBibTools, 2, r, "\n");
    return fail;
  fi;
  if r.Type in ["book", "inbook", "incollection", "proceedings",
                "inproceedings", "conference"] and
     "volume" in f and "number" in f then
    Info(InfoBibTools, 1, "#W WARNING: Cannot have both in ", 
                            r.Type, "-entry, 'volume' and 'number'\n");
    Info(InfoBibTools, 2, r, "\n");
    return fail;
  fi;
  if r.Type in ["book", "inbook"] then
    if "author" in f and "editor" in f then
      Info(InfoBibTools, 1, "#W WARNING: Cannot have both in ", 
                            r.Type, "-entry, 'author' and 'editor'\n");
      Info(InfoBibTools, 2, r, "\n");
      return fail;
    elif not "author" in f and not "editor" in f then
      Info(InfoBibTools, 1, "#W WARNING: Must have 'author' or 'editor' in ", 
                                        r.Type, "-entry\n");
      Info(InfoBibTools, 2, r, "\n");
      return fail;
    fi;
  fi;
  if r.Type = "inbook" then
    if not "pages" in f then
      if not "chapter" in f then
        Info(InfoBibTools, "#W WARNING: Must have 'chapter' and/or 'pages' ",
                            "in inbook-entry\n");
        Info(InfoBibTools, 2, r, "\n");
        return fail;
      fi;
    fi;
  fi;
  # now we can flatten struct
  struct := Concatenation(List(struct, function(a) if not IsString(a[1]) then
    return List(Filtered(a[1], x-> x<>"or"), 
           b-> [b, false]); else return [a]; fi; end));
  # now construct the result, first as XML tree
  res := rec(name := "entry", attributes := rec(id := r.Label),
         content := [rec(name := r.Type, attributes := rec(), content := [])]);
  cont := res.content[1].content;       
  for a in struct do
    if a[2] = true and not a[1] in f then
      Info(InfoBibTools, 1, "#W WARNING: Must have '", a[1], "' in ", 
                                    r.Type, "-entry\n");
      Info(InfoBibTools, 2, r, "\n");
      return fail;
    fi;
    if a[1] in f then
      Add(cont, "\n  ");
      # special handling of author/editor
      if a[1] in ["author", "editor"] and IsString(r.(a[1])) then
        tmp := rec(name := a[1], attributes := rec(), content := ["\n  "]);
        nams := NormalizedNameAndKey(r.(a[1]));
        for b in nams[4] do
          Add(tmp.content, "  ");
          Add(tmp.content, rec(name := "name", attributes := rec(),
             content := [ rec(name := "first", attributes := rec(),
                          content := b[3]),
                          rec(name := "last", attributes := rec(),
                          content := b[1]) ] ));
          Add(tmp.content, "\n  ");
        od;
        Add(cont, tmp);
        Add(cont, "  ");
      else
        if IsRecord(r.(a[1])) then
          Add(cont, r.(a[1]));
        else # string
          if a[1] in ["title", "booktitle"] then
            tmp := MandC(r.(a[1]));
          else
            tmp := r.(a[1]);
            pos := PositionSet(texts, tmp);
            if pos <> fail then
              tmp := [rec(name := "value", attributes := rec(key :=
                     abbrevs[pos]), content := 0)];
            fi;
          fi;
          Add(cont, rec(name := a[1], attributes := rec(), content := tmp));
        fi;
      fi;
    fi;
  od;
  # additional infos
  f := Difference(f, List(struct, a-> a[1]));
  f := Filtered(f, a-> not a in ["From", "Type", "Label"]);
  for a in f do
    Add(cont, "\n  ");
    Add(cont, rec(name := "other", attributes := rec( type := a ), 
                  content := r.(a)) );
  od;
  Add(cont, "\n");
  res := StringXMLElement(res)[1];
  res := SplitString(res, "\n", "");
  for i in [1..Length(res)] do
    if Length(res[i]) > 76 then
      a := FormatParagraph(res[i], 76, "left", ["      ",""]);
      Unbind(a[Length(a)]);
      a := a{[5..Length(a)]};
      res[i] := a;
    fi;
  od;
  return JoinStringsWithSeparator(res, "\n");
end);


##  <#GAPDoc Label="WriteBibXMLextFile">
##  <ManSection >
##  <Func Arg="fname, bib" Name="WriteBibXMLextFile" />
##  <Returns>nothing</Returns>
##  <Description>
##  This function writes a BibXMLext file with name <A>fname</A>.<P/>
##  
##  There are three possibilities to specify the bibliography entries in the
##  argument <A>bib</A>. It can be a list of three lists as returned by <Ref
##  Func="ParseBibFiles"/>. Or it can be just  the first of such three lists
##  in  which case  the other  two lists  are assumed  to be  empty. To  all
##  entries of the (first) list the function <Ref Func="StringBibAsXMLext"/>
##  is applied and the resulting strings are written to the result file.<P/>
##  
##  The  third   possibility  is  that   <A>bib</A>  is  a  record   in  the
##  format  as  returned  by  <Ref  Func="ParseBibXMLextString"/>  and  <Ref
##  Func="ParseBibXMLextFiles"/>.  In   this  case   the  entries   for  the
##  BibXMLext  file  are  produced  with  <Ref  Func="StringXMLElement"/>,
##  and  if  <A>bib</A><C>.entities</C>  is  bound   then  it  is  tried  to
##  resubstitute  parts  of the  string  by  the  given entities  with  <Ref
##  Func="EntitySubstitution"/>.
##  
##  <Example>
##  ???still missing???
##  
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallGlobalFunction(WriteBibXMLextFile, function(fname, bib)
  local  i, a, s, f;
  f := OutputTextFile(fname, false);
  SetPrintFormattingStatus(f, false);
  PrintTo(f, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n",
                         "<!DOCTYPE file SYSTEM \"bibxmlext.dtd\">\n",
                         "<file>\n");
  # make sure, strings are sorted
  if IsList(bib) then
    if not IsRecord(bib[1]) then
      bib := ShallowCopy(bib);
      bib[2] := ShallowCopy(bib[2]);
      bib[3] := ShallowCopy(bib[3]);
    else
      bib := [bib, [], []];
    fi;
    # strings first
    for i in [1..Length(bib[2])] do
      AppendTo(f, StringXMLElement(rec(name := "string",
               attributes := rec(key := bib[2][i], value := bib[3][i]),
                             content := 0))[1], "\n");
    od;
    SortParallel(bib[3], bib[2]);
    for a in bib[1] do 
      AppendTo(f, StringBibAsXMLext(a, bib[2], bib[3]), "\n");
    od;
  else
    for a in bib.entries do
      s := StringXMLElement(a);
      if IsBound(bib.entities) then
        s := EntitySubstitution(s, bib.entities);
      fi;
      AppendTo(f, s, "\n");
    od;
  fi;
  AppendTo(f, "</file>\n");
end);

###########################################################################
##  
##  translating BibXML entries to records
##  
##  
##  <#GAPDoc Label="RecBibXMLEntry">
##  <ManSection >
##  <Func Arg="entry[, restype][, strings][, options]" Name="RecBibXMLEntry" />
##  <Returns>a record with fields as strings</Returns>
##  <Description>
##  This  function  generates   a  content  string  for  each   field  of  a
##  bibliography entry and  assigns them to record  components. This content
##  may depend on the requested result type and possibly some given options.
##  <P/>
##  
##  The   arguments   are   as    follows:   <A>entry</A>   is   the   parse
##  tree   of   an   <C>&lt;entry></C>   element   as   returned   by   <Ref
##  Func="ParseBibXMLextString"/>   or  <Ref   Func="ParseBibXMLextFiles"/>.
##  The  optional   argument  <A>restype</A>  describes  the   type  of  the
##  result.  This  package  supports currently  the  types  <C>"BibTeX"</C>,
##  <C>"Text"</C>  and <C>"HTML"</C>.  The default  is <C>"BibTeX"</C>.  The
##  optional argument  <A>strings</A> must be  a list of key-value  pairs as
##  returned  in  the  component  <C>.strings</C>  in  the  result  of  <Ref
##  Func="ParseBibXMLextString"/>.  The argument  <A>options</A>  must be  a
##  record.<P/>
##  
##  If the entry  contains an <C>author</C> field then the  result will also
##  contain a component <C>.authorAsList</C> which  is a list containing for
##  each author a  list with three entries of the  form <C>[last name, first
##  name initials, first name]</C> (the third  entry means the first name as
##  given in the data). Similarly,  an <C>editor</C> field is accompanied by
##  a component <C>.editorAsList</C>.<P/>
##  
##  The following <A>options</A> are currently supported. <P/>
##  
##  If <C>options.fullname</C> is bound and set to <K>true</K> then the full
##  given first names  for authors and editors will be  used, the default is
##  to use the initials of the first names. <P/>
##  
##  If   <C>options.href</C>  is   bound   and  set   to   false  then   the
##  <C>"BibTeX"</C> type  result will not use  <C>&bslash;href</C> commands.
##  The   default   is   to  produce   <C>&bslash;href</C>   commands   from
##  <C>&lt;URL></C>-elements   such  that  &LaTeX; with the  <C>hyperref</C>  
##  package can  produce  links  for them.<P/>
##  
##  The content of an  <C>&lt;Alt></C>-element with <C>Only</C>-attribute is
##  included  if  <A>restype</A>  is  given in  the  attribute  and  ignored
##  otherwise,  and  vice  versa  in  case  of  a  <C>Not</C>-attribute.  If
##  <C>options.useAlt</C>  is   bound,  it  must   be  a  list   of  strings
##  to  which  <A>restype</A>  is  added.  Then  an  <C>&lt;Alt></C>-element
##  with  <C>Only</C>-attribute   is  evaluated   if  the   intersection  of
##  <C>options.useAlt</C> and the types given in the attribute is not empty.
##  In  case of  a <C>Not</C>-attribute  the  element is  evaluated if  this
##  intersection is empty. <P/>
##  
##  If  <A>restype</A>  is  <C>"BibTeX"</C>  and  there  are  any  non-ASCII
##  characters in the result then these characters are translated to &LaTeX;
##  via <Ref  Oper="Encode"/>. If  <C>options.utf8</C> is  bound and  set to
##  true then this translation is not done.<P/>
##  
##  <Example>
##  ??? to be done ???
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>


##  <#GAPDoc Label="AddHandlerBuildRecBibXMLEntry">
##  <ManSection >
##  <Func Arg="elementname, restype, handler" 
##                          Name="AddHandlerBuildRecBibXMLEntry" />
##  <Returns>nothing</Returns>
##  <Description>
##  The  argument <A>elementname</A>  must be  the  name of  an entry  field
##  supported  by the  BibXMLext  format, the  name of  one  of the  special
##  elements (<C>"C"</C>, <C>"M"</C>, <C>"Math"</C>,  <C>"URL"</C> or of the
##  form  <C>"Wrap:myname"</C> or  any  string  <C>"mytype"</C> (which  then
##  corresponds to entry fields <C>&lt;other type="mytype"></C>). The string
##  <C>"Finish"</C> has an exceptional meaning, see below. <P/>
##  
##  <A>restype</A>  is a  string describing  the result  type for  which the
##  handler is installed, see <Ref Func="RecBibXMLEntry"/>. <P/>
##  
##  For both  arguments, <A>elementname</A>  and <A>restype</A>, it  is also
##  possible  to give  lists of  the described  ones for  installing several
##  handler at once. <P/>
##  
##  The   argument   <A>handler</A>   must   be   a   function   with   five
##  arguments  of the  form  <A>handler</A><C>(entry,  r, restype,  strings,
##  options)</C>.  Here  <A>entry</A>  is  a   parse  tree  of  a  BibXMLext
##  <C>&lt;entry></C>-element,  <A>r</A>  is a  node  in  this tree  for  an
##  element  <A>elementname</A>,  and   <A>restype</A>,  <A>strings</A>  and
##  <A>options</A>  are   as  explained  in   <Ref  Func="RecBibXMLEntry"/>.
##  The   function  should   return  a   string  representing   the  content
##  of   the  node   <A>r</A>.  If   <A>elementname</A>  is   of  the   form
##  <C>"Wrap:myname"</C>  the   handler  is   used  for  elements   of  form
##  <C>&lt;Wrap Name="myname">...&lt;/Wrap></C>.<P/>
##  
##  If <A>elementname</A>  is <C>"Finish"</C>  the handler should  look like
##  above  except  that  now  <A>r</A>  is  the  record  generated  by  <Ref
##  Func="RecBibXMLEntry"/>  just before  it is  returned. Here  the handler
##  should return nothing. It can be used to manipulate the record <A>r</A>,
##  for example for changing the encoding  of the strings or for adding some
##  more components.<P/>
##  
##  The        installed         handler        is          called        by
##  <C>BuildRecBibXMLEntry(</C><A>entry</A>,    <A>r</A>,    <A>restype</A>,
##  <A>strings</A>,    <A>options</A><C>)</C>.    The   string    for    the
##  whole     content     of     an     element     can     be     generated
##  by       <C>ContentBuildRecBibXMLEntry(</C><A>entry</A>,       <A>r</A>,
##  <A>restype</A>, <A>strings</A>, <A>options</A><C>)</C>.
##  
##  <Example>
##  ??? to be done ???
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

InstallGlobalFunction(ContentBuildRecBibXMLEntry,
function(entry, elt, type, strings, opts)
  local res, a;
  res := "";
  for a in elt.content do
    Append(res, BuildRecBibXMLEntry(entry, a, type, strings, opts));
  od;
  return res;
end);
InstallGlobalFunction(BuildRecBibXMLEntry, 
function(entry, elt, type, strings, opts)
  local res, f, nam, hdlr, a;
  if elt = entry then
    # upper level, create result record
    res := rec(From := rec(BibXML := true, type := type, options := opts));
    res.Label := entry.attributes.id;
    f := First(entry.content, a-> IsRecord(a) and a.name in
                                             RecFields(BibXMLextStructure));
    res.Type := f.name;
    for a in f.content do
      if IsRecord(a) and not a.name = "PCDATA" then
        nam := a.name;
        if nam in ["author", "editor"] then
          res.(Concatenation(nam, "AsList")) :=
                BuildRecBibXMLEntry(entry, a, "namesaslists", strings, opts);
        fi;
        if nam = "other" then
          nam := a.attributes.type;
        fi;
        res.(nam) := BuildRecBibXMLEntry(entry, a, type, strings, opts);
      fi;
    od;
    # a possibility for some final cleanup/additions, e.g., for handling
    # some options
    if IsBound(RECBIBXMLHNDLR.Finish.(type)) then
      res := RECBIBXMLHNDLR.Finish.(type)(entry, res, type, strings, opts);
    fi;
    return res;
  else
    # return a string (or something else if you know what you are doing)
    # call this function recursively
    if IsString(elt) then
      # end of recursion
      return elt;
    fi;
    nam := elt.name;
    if IsBound(RECBIBXMLHNDLR.(nam)) then
      hdlr := RECBIBXMLHNDLR.(nam); else
      hdlr := RECBIBXMLHNDLR.default;
    fi;
    if IsBound(hdlr.(type)) then
      hdlr := hdlr.(type);
    elif IsBound(hdlr.default) then
      hdlr := hdlr.default;
    else
      hdlr := RECBIBXMLHNDLR.default.default;
    fi;
    return hdlr(entry, elt, type, strings, opts);
  fi;
end);

# eltname can be an elementname or a list of elementnames, in the latter
# case fun is installed for all of them, same with type
InstallGlobalFunction(AddHandlerBuildRecBibXMLEntry,  
function(eltname, type, fun)
  local e;
  if not IsString(eltname) and IsList(eltname) then
    for e in eltname do
      AddHandlerBuildRecBibXMLEntry(e, type, fun);
    od;
    return;
  fi;
  if not IsString(type) and IsList(type) then
    for e in type do
      AddHandlerBuildRecBibXMLEntry(eltname, e, fun);
    od;
    return;
  fi;
  if not IsBound(RECBIBXMLHNDLR.(eltname)) then
    RECBIBXMLHNDLR.(eltname) := rec();
  fi;
  if fun = "Ignore" then
    fun := RECBIBXMLHNDLR.default.default;
  fi;
  RECBIBXMLHNDLR.(eltname).(type) := fun;
end);

# this just collect text recursively
AddHandlerBuildRecBibXMLEntry("default", "default",
function(entry, elt, type, strings, opts)
  if IsString(elt.content) then
    return elt.content;
  elif elt.content = 0 then
    return "";
  else
    return ContentBuildRecBibXMLEntry(entry, elt, type, strings, opts);
  fi;
end);

# dealing with names in author and editor fields
# helper function, find initials from UTF-8 string, keep '-'s
RECBIBXMLHNDLR.Initials := function(fnam)
  local pre, res, i;
  fnam := NormalizedWhitespace(fnam);
  fnam := Unicode(fnam, "UTF-8");
  pre := Unicode(" -");
  res := Unicode("");
  for i in [1..Length(fnam)] do
    if i=1 or fnam[i-1] in pre then
      Add(res, fnam[i]);
      Add(res, UChar('.'));
    elif fnam[i] in pre then
      Add(res, fnam[i]);
    fi;
  od;
  return Encode(res, "UTF-8");
end;
# produce the names as lists (result will be bound to elt.AsList
# before 'author' and 'editor' are produced)
AddHandlerBuildRecBibXMLEntry("name", "namesaslists", 
function(entry, elt, type, strings, opts)
  local res, f;
  res := [];
  f := First(elt.content, a-> IsRecord(a) and a.name = "last");
  Add(res, BuildRecBibXMLEntry(entry, f, type, strings, opts));
  NormalizeWhitespace(res[1]);
  f := First(elt.content, a-> IsRecord(a) and a.name = "first");
  if f <> fail then
    res[3] := BuildRecBibXMLEntry(entry, f, type, strings, opts);
    NormalizeWhitespace(res[3]);
    res[2] := RECBIBXMLHNDLR.Initials(res[3]);
  fi;
  return res;
end);
AddHandlerBuildRecBibXMLEntry(["author", "editor"], "namesaslists", 
function(entry, elt, namesaslists, strings, opts)
  local res, a;
  res := [];
  RECBIBXMLHNDLR.recode := false;
  for a in elt.content do
    if IsRecord(a) and a.name = "name" then
      Add(res, BuildRecBibXMLEntry(entry, a, namesaslists, strings, opts));
    fi;
  od;
  RECBIBXMLHNDLR.recode := true;
  elt.AsList := res;
  return res;
end);
# now the default (BibTeX) version
AddHandlerBuildRecBibXMLEntry(["author", "editor"], "default", 
function(entry, elt, default, strings, opts)
  local res, a;
  res := [];
  for a in elt.AsList do
    if Length(a) = 1 then
      Add(res, a[1]);
    elif IsBound(opts.fullname) and opts.fullname = true then
      Add(res, Concatenation(a[1], ", ", a[3]));
    else
      Add(res, Concatenation(a[1], ", ", a[2]));
    fi;
  od;
  return JoinStringsWithSeparator(res, " and ");
end);

# now the special markup elements
# <C>
AddHandlerBuildRecBibXMLEntry("C", "default", 
function(entry, elt, default, strings, opts)
  return Concatenation("{", ContentBuildRecBibXMLEntry(entry, elt,
                                          default, strings, opts), "}");
end);
AddHandlerBuildRecBibXMLEntry("C", ["Text", "HTML"], "Ignore");
# <M>, <Math>
AddHandlerBuildRecBibXMLEntry(["M", "Math"], "default",
function(entry, elt, default, strings, opts)
  local res;
  RECBIBXMLHNDLR.recode := false;
  res := Concatenation("$", ContentBuildRecBibXMLEntry(entry, elt,
                                          default, strings, opts), "$");
  RECBIBXMLHNDLR.recode := true;
  return res;
end);
AddHandlerBuildRecBibXMLEntry("M", "HTML",
function(entry, elt, default, strings, opts)
  local res;
  RECBIBXMLHNDLR.recode := false;
  res := TextM( ContentBuildRecBibXMLEntry(entry, elt, default, strings, opts));
  RECBIBXMLHNDLR.recode := true;
  res := SubstitutionSublist(res, "<", "&lt;");
  res := SubstitutionSublist(res, "&", "&amp;");
  return res;
end);
AddHandlerBuildRecBibXMLEntry("M", "Text",
function(entry, elt, default, strings, opts)
  return TextM( ContentBuildRecBibXMLEntry(entry, elt, default, strings, opts));
end);
# <value key= />
AddHandlerBuildRecBibXMLEntry("value", "default",
function(entry, elt, default, strings, opts)
  local pos;
  pos := PositionFirstComponent(strings, elt.attributes.key);
  if not IsBound(strings[pos]) or strings[pos][1] <> elt.attributes.key then
    return Concatenation("UNKNOWNVALUE(", elt.attributes.key, ")");
  else
    return strings[pos][2];
  fi;
end);
# <URL>
AddHandlerBuildRecBibXMLEntry("URL", "default",
function(entry, elt, default, strings, opts)
  local res, esc, txt;
  RECBIBXMLHNDLR.recode := false;
  res := ContentBuildRecBibXMLEntry(entry, elt, default, strings, opts);
  RECBIBXMLHNDLR.recode := true;
  NormalizeWhitespace(res);
  # escape all LaTeX special characters
  esc := GAPDoc2LaTeXProcs.EscapeAttrVal(res);
  esc := Concatenation("\\texttt{", esc, "}");
  # allow hyphenation of long entries without hyphen dash
  esc := GAPDoc2LaTeXProcs.URLBreaks(esc);
  if IsBound(opts.href) and opts.href = false then
    return esc;
  fi;
  if IsBound(elt.attributes.Text) then
    txt := elt.attributes.Text;
  else
    txt := esc;
  fi;
  return Concatenation("\\href {", res, "} {", txt, "}");
end);
AddHandlerBuildRecBibXMLEntry("URL", "HTML",
function(entry, elt, html, strings, opts)
  local res, txt;
  res := ContentBuildRecBibXMLEntry(entry, elt, html, strings, opts);
  NormalizeWhitespace(res);
  if IsBound(elt.attributes.Text) then
    txt := elt.attributes.Text;
  else
    txt := res;
  fi;
  return Concatenation("<a href=\"", res, "\">", txt, "</a>");
end);
AddHandlerBuildRecBibXMLEntry("URL", "Text",
function(entry, elt, text, strings, opts)
  local res;
  res := ContentBuildRecBibXMLEntry(entry, elt, text, strings, opts);
  NormalizeWhitespace(res);
  if IsBound(elt.attributes.Text) then
    return Concatenation(elt.attributes.Text, " (", res, ")");
  else
    return res;
  fi;
end);
AddHandlerBuildRecBibXMLEntry("Alt", "default",
function(entry, elt, type, strings, opts)
  local poss, att, ok, res;
  poss := [type];
  if IsBound(opts.useAlt) then
    Append(poss, opts.useAlt);
  fi;
  att := elt.attributes;
  if IsBound(att.Only) then
    ok := SplitString(att.Only, "", ", \n\r\t");
  else
    ok := SplitString(att.Not, "", ", \n\r\t");
  fi;

  if (IsBound(att.Only) and ForAny(poss, a-> a in ok)) then
    RECBIBXMLHNDLR.recode := false;
    res := ContentBuildRecBibXMLEntry(entry, elt, type, strings, opts);
    RECBIBXMLHNDLR.recode := true;
    return res;
  elif   (IsBound(att.Not) and ForAll(poss, a-> not a in ok)) then
    return ContentBuildRecBibXMLEntry(entry, elt, type, strings, opts);
  else
    return "";
  fi;
end);
AddHandlerBuildRecBibXMLEntry("Wrap", "default",
function(entry, elt, type, strings, opts)
  local n, hdlr, res, a;
  n := Concatenation("Wrap:", elt.attributes.Name);
  hdlr := fail;
  if IsBound(RECBIBXMLHNDLR.(n)) then
    if IsBound(RECBIBXMLHNDLR.(n).(type)) then
      hdlr := RECBIBXMLHNDLR.(n).(type);
    elif IsBound(RECBIBXMLHNDLR.(n).default) then
      hdlr := RECBIBXMLHNDLR.(n).default;
    fi;
  fi;
  if hdlr = fail then
    # default is to ignore the markup
    return ContentBuildRecBibXMLEntry(entry, elt, type, strings, opts);
  else
    return hdlr(entry, elt, type, strings, opts);
  fi;
end);

RECBIBXMLHNDLR.Finish := rec();
##  # Finish functions
##  AddHandlerBuildRecBibXMLEntry("Finish", ["BibTeX", "LaTeX"],
##  function(entry, res, type, strings, opts)
##    local f;
##    if not IsBound(opts.utf8) or opts.utf8 <> true then
##      # by default we try to translate non-ASCII characters to LaTeX macros
##      for f in RecFields(res) do
##        if IsString(res.(f)) then
##          res.(f) := Encode(Unicode(res.(f), "UTF-8"), "LaTeX");
##        fi;
##      od;
##    fi;
##    return res;
##  end);

RECBIBXMLHNDLR.recode := true;
AddHandlerBuildRecBibXMLEntry("PCDATA", ["BibTeX", "LaTeX"],
function(entry, elt, type, strings, opts)
  if RECBIBXMLHNDLR.recode then
    return Encode(Unicode(elt.content, "UTF-8"), "LaTeX");
  else
    return elt.content;
  fi;
end);
AddHandlerBuildRecBibXMLEntry("PCDATA", "HTML",
function(entry, elt, type, strings, opts)
  local res;
  if RECBIBXMLHNDLR.recode then
    res := SubstitutionSublist(elt.content, "<", "&lt;");
    return SubstitutionSublist(res, "&", "&amp;");
  else
    return elt.content;
  fi;
end);

# args: 
#  xml tree of entry[, type][, strings (as list of pairs)][, options record]
InstallGlobalFunction(RecBibXMLEntry, function(arg)
  local letters, entry, type, strings, opts, res, nams, key, i, a;
  # helper to find a key
  letters := function(str, one)
    local pos;
    str := Unicode(str, "UTF-8");
    if UChar(' ') in str then
      pos := Concatenation([1], 1+Positions(str, UChar(' ')));
      if one then
        return Encode(str{[pos[Length(pos)]]}, "UTF-8");
      else
        return Encode(str{pos}, "UTF-8");
      fi;
    else
      if one then
        pos := Minimum(1, Length(str));
      else
        pos := Minimum(3, Length(str));
      fi;
      return Encode(str{[1..pos]}, "UTF-8");
    fi;
  end;
  entry := arg[1];
  RECBIBXMLHNDLR.recode := true;
  type := fail; strings := fail; opts := fail;
  for i in [2..Length(arg)] do
    if IsString(arg[i]) then
      type := arg[i];
    elif IsDenseList(arg[i]) and ForAll(arg[i], IsList) then
      strings := arg[i];
    elif IsRecord(arg[i]) then
      opts := arg[i];
    fi;
  od;
  if opts = fail then
    opts := rec();
  fi;
  if type = fail or type = "default" then  
    type := "BibTeX";
    if not IsBound(opts.useAlt) then
      opts.useAlt := ["BibTeX", "LaTeX"];
    fi;
  fi;
  if strings = fail then
    strings := [];
  fi;
  res := BuildRecBibXMLEntry(entry, entry, type, strings, opts);
  # we produce a key if not given
  if not IsBound(res.key) then
    if IsBound(res.authorAsList) then
      nams := res.authorAsList;
    elif IsBound(res.editorAsList) then
      nams := res.editorAsList;
    else
      nams := 0;
    fi;
    if nams = 0 then
      key := "NOAUTHOROREDITOR_SPECIFYKEY";
    else
      key := "";
      if Length(nams) = 1 then
        Append(key, letters(nams[1][1], false));
      else
        for a in nams do
          Append(key, letters(a[1], true));
        od;
      fi;
      if IsBound(res.year) and Length(res.year) >= 2 then
        Append(key, res.year{[Length(res.year)-1, Length(res.year)]});
      fi;
    fi;
    res.printedkey := key;
  fi;
  return res;
end);

InstallGlobalFunction(StringBibXMLEntry, function(arg)
  local r, type, opts;
  r := CallFuncList(RecBibXMLEntry, arg);
  type := r.From.type;
  opts := r.From.options;
  if IsBound(STRINGBIBXMLHDLR.(type)) then
    return STRINGBIBXMLHDLR.(type)(r);
  else
    InfoBibTools(1, "Don't know how to make a string of type ", type, "\n");
    return fail;
  fi;
end);
STRINGBIBXMLHDLR.BibTeX := StringBibAsBib;
STRINGBIBXMLHDLR.Text := StringBibAsText;
STRINGBIBXMLHDLR.HTML := StringBibAsHTML;

# Utility for a sort key, can be given as field 'sortkey' or <other
# type="sortkey"> element, respectively: as list of strings separated by ",". 
# If not given we use list of last names of authors/editors (or the title)
# transformed to lower case.
InstallGlobalFunction(SortKeyRecBib, function(r)
  if IsBound(r.sortkey) then
    return List(SplitString(r.sortkey, "", ","), NormalizedWhitespace);
  elif IsBound(r.authorAsList) then
    return List(r.authorAsList, a-> LowercaseString(a[1]));
  elif IsBound(r.editorAsList) then
    return List(r.editorAsList, a-> LowercaseString(a[1]));
  elif IsBound(r.title) then
    return LowercaseString(NormalizedWhitespace(r.title));
  else
    return "zzzzzzzzzz";
  fi;
end);
        
