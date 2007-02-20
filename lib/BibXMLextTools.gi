
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
end;
BibXMLextStructure.fill();

TemplateBibXML := function(type)
  local res, add, a, b;
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
end;



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
  f := Filtered(f, a-> a <> "Type" and a <> "Label");
  for a in f do
    Add(cont, "\n  ");
    Add(cont, rec(name := "other", attributes := rec( type := a ), 
                  content := r.(a)) );
  od;
  Add(cont, "\n");
  res := StringElementAsXML(res);
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
                           content := 0)), "\n");
  od;
  SortParallel(bib[3], bib[2]);
  for a in bib[1] do 
    AppendTo(f, StringBibAsXMLext(a, bib[2], bib[3]), "\n");
  od;
  AppendTo(f, "</file>\n");
end);


# handler to generate bib records
# the handler functions get the tree, a node, an existing bib record 
# structure and the type of conversion
# args: t, r, bib, type
BIBXMLHANDLER.default := rec();
# recursion caller
BIBXMLHANDLER.content := function(t, r, bib, type)
  local nam, h, rr;
  for rr in r.content do
    nam := rr.name;
    if IsBound(BIBXMLHANDLER.(type)) 
               and IsBound(BIBXMLHANDLER.(type).(nam)) then
      h := BIBXMLHANDLER.(type).(nam);
    elif IsBound(BIBXMLHANDLER.default.(nam)) then
      h := BIBXMLHANDLER.default.(nam);
    else
      h := BIBXMLHANDLER.default.default;
    fi;
    h(t, rr, bib, type);
  od;
end;
# default handler collects text in t.tmptext (used for PCDATA)
BIBXMLHANDLER.default.default := function(t, r, bib, type)
  if IsString(r.content) then
    Append(t.tmptext, r.content);
  elif r.content = 0 then
    # ignore
  else
    BIBXMLHANDLER.content(t, r, bib, type);
  fi;
end;
# handler for alternatives
BIBXMLHANDLER.default.Alt := function(t, r, bib, type)
  local attr;
  attr := r.attributes;
  if IsBound(attr.Only) and 
       type in SplitString(attr.Only, "", ", \t\b\n") then
    BIBXMLHANDLER.content(t, r, bib, type);
  elif IsBound(attr.Not) and 
            not type in SplitString(attr.Not, "", ", \t\b\n") then
    BIBXMLHANDLER.content(t, r, bib, type);
  fi;
end;

# first handler functions which produce text which is collected in t.tmptext
BIBXMLHANDLER.default.URL := function(t, r, bib, type)
  # collect content
  BIBXMLHANDLER.content(t, r, bib, type);
end;
BIBXMLHANDLER.default.C := function(t, r, bib, type)
  # collect content
  BIBXMLHANDLER.content(t, r, bib, type);
end;
BIBXMLHANDLER.default.M := function(t, r, bib, type)
  # enclose by $'s
  Add(t.tmptext, '$');
  BIBXMLHANDLER.content(t, r, bib, type);
  Add(t.tmptext, '$');
end;
BIBXMLHANDLER.default.Math := BIBXMLHANDLER.default.M;
# find initials from UTF-8 string, keep '-'s
BIBXMLHANDLER.Initials := function(fnam)
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
BIBXMLHANDLER.AddKey := function(r)
  local nams, letters, res, a;
  if IsBound(r.key) then
    return;
  fi;
  if IsBound(r.authorAsList) then
    nams := r.authorAsList;
  elif IsBound(r.editorAsList) then
    nams := r.editorAsList;
  elif IsBound(r.author) then
    nams := r.author;
  elif IsBound(r.editor) then
    nams := r.editor;
  else
    r.key := "NOAUTHOROREDITOR_SPECIFYKEY";
    return;
  fi;
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
  res := "";
  if Length(nams) = 1 then
    Append(res, letters(nams[1][1], false));
  else
    for a in nams do
      Append(res, letters(a[1], true));
    od;
  fi;
  if IsBound(r.year) and Length(r.year) >= 2 then
    Append(res, r.year{[Length(r.year)-1, Length(r.year)]});
  fi;
  r.key := res;
end;
BIBXMLHANDLER.default.first := function(t, r, bib, type)
  local old;
  old := t.tmptext;
  t.tmptext := "";
  BIBXMLHANDLER.content(t, r, bib, type);
  t.tmpfirst := t.tmptext;
  t.tmptext := old;
end;
BIBXMLHANDLER.default.last := function(t, r, bib, type)
  local old;
  old := t.tmptext;
  t.tmptext := "";
  BIBXMLHANDLER.content(t, r, bib, type);
  t.tmplast := t.tmptext;
  t.tmptext := old;
end;
BIBXMLHANDLER.default.name := function(t, r, bib, type)
  t.tmplast := "";
  t.tmpfirst := "";
  BIBXMLHANDLER.content(t, r, bib, type);
##    Append(t.tmptext, t.tmplast);
##    if Length(t.tmpfirst) > 0 then
##      Append(t.tmptext, ", ");
##      Append(t.tmptext, t.tmpfirst);
##    fi;
##    Append(t.tmptext, " and ");
  Add(t.tmpnames, [t.tmplast, BIBXMLHANDLER.Initials(t.tmpfirst), t.tmpfirst]);
end;

BIBXMLHANDLER.default.value := function(t, r, bib, type)
  local pos;
  pos := Position(bib[2], r.attributes.key);
  if pos = fail then
    Info(InfoBibTools, 1, "#W WARNING: Cannot resolve abbreviation: ", 
                                     r.attributes.key, "\n"); 
    Info(InfoBibTools, 2, r, "\n");
    Append(t.tmptext, r.attributes.key);
    Append(t.tmptext, "???");
  else
    Append(t.tmptext, bib[3][pos]);
  fi;
end;

# now handle the entries
BIBXMLHANDLER.default.WHOLEDOCUMENT := function(t, r, bib, type)
  # create temporary data structures
  t.tmptext := "";
  t.tmprec := rec();
  BIBXMLHANDLER.content(t, r, bib, type);
  Unbind(t.tmptext);
  Unbind(t.tmprec);
end;
BIBXMLHANDLER.default.XMLPI := function(t, r, bib, type)
  # ignore
end;
BIBXMLHANDLER.default.XMLDOCTYPE := function(t, r, bib, type)
  # ignore
end;
BIBXMLHANDLER.default.file := function(t, r, bib, type)
  BIBXMLHANDLER.content(t, r, bib, type);
end;
BIBXMLHANDLER.default.string := function(t, r, bib, type)
  # add the abbreviation to the bib data
  Add(bib[2], r.attributes.key);
  Add(bib[3], NormalizedWhitespace(r.attributes.value));
end;
BIBXMLHANDLER.default.entry := function(t, r, bib, type)
  # empty record and collect content
  t.tmprec := rec(Label := r.attributes.id);
  BIBXMLHANDLER.content(t, r, bib, type);
  BIBXMLHANDLER.AddKey(t.tmprec);
  # add record to bib structure
  Add(bib[1], t.tmprec);
end;
BIBXMLHANDLER.types := function()
  local typ; 
  for typ in  [ "article", "book", "booklet", "manual", "techreport", 
      "mastersthesis", "phdthesis", "inbook", "incollection", "proceedings", 
      "inproceedings", "conference", "unpublished", "misc" ] do
    BIBXMLHANDLER.default.(typ) := function(t, r, bib, type)
      t.tmprec.Type := r.name;
      BIBXMLHANDLER.content(t, r, bib, type);
    end;
  od;
end;
BIBXMLHANDLER.types();

# and finally handler for the fields, first generic then special cases
BIBXMLHANDLER.fields := function()
  local f;
  for f in [ "title", "booktitle", "publisher", "school", "journal", 
      "institution", "year", "volume", "number",  "month", "organization", 
      "howpublished", "note", "key", "annotate", "crossref", "abstract", 
      "affiliation", "contents", "copyright", "isbn", "issn", "address", 
      "edition", "keywords", "language", "lccn", "location", 
      "mrnumber", "mrclass", "mrreviewer", "price", "size", "url", "category"
      ] do
    BIBXMLHANDLER.default.(f) := function(t, r, bib, type)
      t.tmptext := "";
      BIBXMLHANDLER.content(t, r, bib, type);
      NormalizeWhitespace(t.tmptext);
      t.tmprec.(r.name) := ShallowCopy(t.tmptext);
    end;
  od;
end;
BIBXMLHANDLER.fields();
BIBXMLHANDLER.default.authed := function(t, r, bib, type, cmp)
  t.tmptext := "";
  t.tmpnames := [];
  BIBXMLHANDLER.content(t, r, bib, type);
  t.tmprec.(cmp) := t.tmpnames;
end;
BIBXMLHANDLER.default.author := function(t, r, bib, type)
  BIBXMLHANDLER.default.authed(t, r, bib, type, "author");
end;
BIBXMLHANDLER.default.editor := function(t, r, bib, type)
  BIBXMLHANDLER.default.authed(t, r, bib, type, "editor");
end;
BIBXMLHANDLER.default.authorold := function(t, r, bib, type)
  local len;
  # remove trailing " and "
  t.tmptext := "";
  BIBXMLHANDLER.content(t, r, bib, type);
  NormalizeWhitespace(t.tmptext);
  len := Length(t.tmptext);
  if len > 3 and t.tmptext{[len-3..len]} = " and" then
    t.tmptext := t.tmptext{[1..len-4]};
  fi;
  t.tmprec.author := ShallowCopy(t.tmptext);
end;
BIBXMLHANDLER.default.editorold := function(t, r, bib, type)
  local len;
  # remove trailing " and "
  t.tmptext := "";
  BIBXMLHANDLER.content(t, r, bib, type);
  NormalizeWhitespace(t.tmptext);
  len := Length(t.tmptext);
  if len > 3 and t.tmptext{[len-3..len]} = " and" then
    t.tmptext := t.tmptext{[1..len-4]};
  fi;
  t.tmprec.editor := ShallowCopy(t.tmptext);
end;
BIBXMLHANDLER.default.pages := function(t, r, bib, type)
# special heuristic unnecessary now with &ndash; ?
##    # default with one dash
  t.tmptext := "";
  BIBXMLHANDLER.content(t, r, bib, type);
##    NormalizeWhitespace(t.tmptext);
##    if ForAll(t.tmptext, c-> c in "0123456789-") then
##      t.tmptext := SubstitutionSublist(t.tmptext, "--", "-");
##    fi;
  t.tmprec.pages := ShallowCopy(t.tmptext);
end;
BIBXMLHANDLER.default.other := function(t, r, bib, type)
  t.tmptext := "";
  BIBXMLHANDLER.content(t, r, bib, type);
  NormalizeWhitespace(t.tmptext);
  t.tmprec.(r.attributes.type) := ShallowCopy(t.tmptext);
end;

# args: tree, type[, bib]
InstallGlobalFunction(BibRecBibXML, function(arg)
  local t, type, bib;
  t := arg[1];
  type := arg[2];
  if Length(arg) > 2 then
    bib := arg[3];
  else
    bib := [[], [], []];
  fi;
  BIBXMLHANDLER.default.WHOLEDOCUMENT(t, t, bib, type);
  return bib;
end);

#########################################
# now special handler for special formats
# BibTeX. adjust author/editor, <C>, pages with --, URL in \texttt
BIBXMLHANDLER.BibTeX := rec();
BIBXMLHANDLER.BibTeX.pages := function(t, r, bib, type)
  BIBXMLHANDLER.default.pages(t, r, bib, type);
  if PositionSublist(t.tmprec.pages, "--") = fail then
    t.tmprec.pages := SubstitutionSublist(t.tmprec.pages, "-", "--");
  fi;
end;
BIBXMLHANDLER.BibTeX.C := function(t, r, bib, type)
  Add(t.tmptext, '{');
  BIBXMLHANDLER.content(t, r, bib, type);
  Add(t.tmptext, '}');
end;
BIBXMLHANDLER.BibTeX.URL := function(t, r, bib, type)
  local save;
  save := t.tmptext;
  t.tmptext := "";
  BIBXMLHANDLER.content(t, r, bib, type);
  t.tmptext := SubstitutionSublist(t.tmptext, "~", "\\symbol {126}");
  t.tmptext := SubstitutionSublist(t.tmptext, "#", "\\#");
  t.tmptext := Concatenation(save, "\\texttt{", t.tmptext, "}");
end;
BIBXMLHANDLER.BibTeX.authed := function(t, r, bib, type, cmp)
  local f, nams;
  BIBXMLHANDLER.default.(cmp)(t, r, bib, type);
  # save as list
  t.tmprec.(Concatenation(cmp, "AsList")) := t.tmprec.(cmp);
  f := function(nl, i)
    if Length(nl[i]) > 0 then
      return Concatenation(nl[1], ", ", nl[i]);
    else
      return nl[1];
    fi;
  end;
  if ForAny(t.tmprec.(cmp), nl-> nl[2] <> nl[3]) then
    nams := List(t.tmprec.(cmp), nl-> f(nl, 3));
    t.tmprec.(Concatenation(cmp, "orig")) := 
                                 JoinStringsWithSeparator(nams, " and ");
  fi;
  nams := List(t.tmprec.(cmp), nl-> f(nl, 2));
  t.tmprec.(cmp) := JoinStringsWithSeparator(nams, " and ");
end;
BIBXMLHANDLER.BibTeX.author := function(t, r, bib, type)
  BIBXMLHANDLER.BibTeX.authed(t, r, bib, type, "author");
end;
BIBXMLHANDLER.BibTeX.editor := function(t, r, bib, type)
  BIBXMLHANDLER.BibTeX.authed(t, r, bib, type, "editor");
end;

# BibTeXhref    with \href in URLs
BIBXMLHANDLER.BibTeXhref := ShallowCopy(BIBXMLHANDLER.BibTeX);
BIBXMLHANDLER.BibTeXhref.URL := function(t, r, bib, type)
  local save;
  save := t.tmptext;
  t.tmptext := "";
  BIBXMLHANDLER.content(t, r, bib, type);
  Append(save, "\\href{");
  Append(save, t.tmptext);
  Append(save, "} ");
  if IsBound(r.attributes.Text) then
    t.tmptext := r.attributes.Text;
  else
    t.tmptext := SubstitutionSublist(t.tmptext, "~", "\\symbol {126}");
##      t.tmptext := SubstitutionSublist(t.tmptext, "#", "\\#");
    t.tmptext := Concatenation("\\texttt{", t.tmptext, "}");
  fi;
  t.tmptext := Concatenation(save, "{", t.tmptext, "}");
end;

# Text:  with <M> translation
BIBXMLHANDLER.Text := rec();
BIBXMLHANDLER.Text.M := function(t, r, bib, type)
  local save;
  save := t.tmptext;
  t.tmptext := "";
  BIBXMLHANDLER.content(t, r, bib, type);
  t.tmptext := Concatenation(save, TextM(t.tmptext));
end;

# HTML: URLs as links, <M> like Text
BIBXMLHANDLER.HTML := rec();
BIBXMLHANDLER.HTML.entry := function(t, r, bib, type)
  # empty record and collect content, mark as HTML to avoid escaping of
  # markup later (say in PrintBibAsHTML):
  t.tmprec := rec(Label := r.attributes.id);
  BIBXMLHANDLER.content(t, r, bib, type);
  # add record to bib structure
  t.tmprec.HTML := "yes";
  BIBXMLHANDLER.AddKey(t.tmprec);
  Add(bib[1], t.tmprec);
end;
BIBXMLHANDLER.HTML.M := BIBXMLHANDLER.Text.M;
BIBXMLHANDLER.HTML.URL := function(t, r, bib, type)
  local save;
  save := t.tmptext;
  t.tmptext := "";
  BIBXMLHANDLER.content(t, r, bib, type);
  Append(save, "<a href=\"");
  Append(save, t.tmptext);
  Append(save, "\">");
  if IsBound(r.attributes.Text) then
    t.tmptext := r.attributes.Text;
  fi;
  t.tmptext := Concatenation(save, t.tmptext, "</a>");
end;




