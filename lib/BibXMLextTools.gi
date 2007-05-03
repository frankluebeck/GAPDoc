#############################################################################
##
#W  BibXMLextTools.gi             GAPDoc                         Frank Lübeck
##
#H  @(#)$Id: BibXMLextTools.gi,v 1.9 2007-05-03 20:58:42 gap Exp $
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

# args:  [type]         with no argument prints the possible types
InstallGlobalFunction(TemplateBibXML, function(arg)
  local type, res, add, a, b;
  if Length(arg) = 0 then
    Print(Filtered(RecFields(BibXMLextStructure), a-> not a in ["fill"]), "\n");
    return;
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
      Append(res, ">\n    <name><first>X</first><last>X</last></name>\n  </");
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
    Append(res, "\n");
  end;

  for a in BibXMLextStructure.(type) do
    if IsString(a[1]) then
      add(a);
    else
      for b in a[1] do
        if b <> "or" then
          add([b, a[2]]);
        fi;
      od;
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
    Print(StringElementAsXML(entry)[1]);
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
# args:  bibrec[, abbrevs, strings]
# here the list 'strings' is assumed to be sorted!
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
  res := StringElementAsXML(res)[1];
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


InstallGlobalFunction(WriteBibXMLextFile, function(fname, bib)
  local  i, a, f;
  f := OutputTextFile(fname, false);
  SetPrintFormattingStatus(f, false);
  PrintTo(f, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n",
                         "<!DOCTYPE file SYSTEM \"bibxmlext.dtd\">\n",
                         "<file>\n");
  # make sure, strings are sorted
  bib := ShallowCopy(bib);
  bib[2] := ShallowCopy(bib[2]);
  bib[3] := ShallowCopy(bib[3]);
  # strings first
  for i in [1..Length(bib[2])] do
    AppendTo(f, StringElementAsXML(rec(name := "string",
             attributes := rec(key := bib[2][i], value := bib[3][i]),
                           content := 0))[1], "\n");
  od;
  SortParallel(bib[3], bib[2]);
  for a in bib[1] do 
    AppendTo(f, StringBibAsXMLext(a, bib[2], bib[3]), "\n");
  od;
  AppendTo(f, "</file>\n");
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
  local res, a;
  res := "";
  if IsString(elt.content) then
    return elt.content;
  elif elt.content = 0 then
    return "";
  else
    for a in elt.content do
      Append(res, BuildRecBibXMLEntry(entry, a, type, strings, opts));
    od;
  fi;
  return res;
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
  for a in elt.content do
    if IsRecord(a) and a.name = "name" then
      Add(res, BuildRecBibXMLEntry(entry, a, namesaslists, strings, opts));
    fi;
  od;
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
  local res, a;
  res := "{";
  for a in elt.content do 
    Append(res, BuildRecBibXMLEntry(entry, a, default, strings, opts));
  od;
  Append(res, "}");
  return res;
end);
AddHandlerBuildRecBibXMLEntry("C", ["Text", "HTML"], "Ignore");
# <M>, <Math>
AddHandlerBuildRecBibXMLEntry(["M", "Math"], "default",
function(entry, elt, default, strings, opts)
  local res, a;
  res := "$";
  for a in elt.content do 
    Append(res, BuildRecBibXMLEntry(entry, a, default, strings, opts));
  od;
  Append(res, "$");
  return res;
end);
AddHandlerBuildRecBibXMLEntry("M", ["Text", "HTML"],
function(entry, elt, default, strings, opts)
  local res, a;
  res := "";
  for a in elt.content do 
    Append(res, BuildRecBibXMLEntry(entry, a, default, strings, opts));
  od;
  return TextM(res);
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
  local res, esc, txt, a;
  res := "";
  for a in elt.content do
    Append(res, BuildRecBibXMLEntry(entry, a, default, strings, opts));
  od;
  esc := SubstitutionSublist(res, "~", "\\texttt{\\symbol{126}}");
  esc := Concatenation("\\texttt{", SubstitutionSublist(esc, "#", "\\#"), "}");
  if IsBound(opts.href) and opts.href = false then
    return esc;
  fi;
  if IsBound(elt.attributes.Text) then
    txt := elt.attributes.Text;
  else
    txt := esc;
  fi;
  return Concatenation("\\href{", res, "}{", txt, "}");
end);
AddHandlerBuildRecBibXMLEntry("URL", "HTML",
function(entry, elt, html, strings, opts)
  local res, txt, a;
  res := "";
  for a in elt.content do
    Append(res, BuildRecBibXMLEntry(entry, a, html, strings, opts));
  od;
  if IsBound(elt.attributes.Text) then
    txt := elt.attributes.Text;
  else
    txt := res;
  fi;
  return Concatenation("<a href=\"", res, "\">", res, "</a>");
end);
AddHandlerBuildRecBibXMLEntry("URL", "Text",
function(entry, elt, text, strings, opts)
  local res, a;
  res := "";
  for a in elt.content do
    Append(res, BuildRecBibXMLEntry(entry, a, text, strings, opts));
  od;
  if IsBound(elt.attributes.Text) then
    return Concatenation(elt.attributes.Text, " (", res, ")");
  else
    return res;
  fi;
end);
AddHandlerBuildRecBibXMLEntry("Alt", "default",
function(entry, elt, type, strings, opts)
  local poss, att, ok, res, a;
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

  if (IsBound(att.Only) and ForAny(poss, a-> a in ok)) or
     (IsBound(att.Not) and ForAll(poss, a-> not a in ok)) then
    res := "";
    for a in elt.content do
      Append(res, BuildRecBibXMLEntry(entry, a, type, strings, opts));
    od;
    return res;
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
    res := "";
    for a in elt.content do
      Append(res, BuildRecBibXMLEntry(entry, a, type, strings, opts));
    od;
    return res;
  else
    return hdlr(entry, elt, type, strings, opts);
  fi;
end);

# Finish functions
AddHandlerBuildRecBibXMLEntry("Finish", ["BibTeX", "LaTeX"],
function(entry, res, type, strings, opts)
  local f;
  if not IsBound(opts.utf8) or opts.utf8 <> true then
    # by default we try to translate non-ASCII characters to LaTeX macros
    for f in RecFields(res) do
      if IsString(res.(f)) then
        res.(f) := Encode(Unicode(res.(f), "UTF-8"), "LaTeX");
      fi;
    od;
  fi;
  return res;
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
        
