#############################################################################
##
#W  BibTeX.gi                    GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: BibTeX.gi,v 1.5 2001-09-03 13:12:26 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files BibTeX.g{d,i} contain a parser for BibTeX files and some
##  functions for printing BibTeX entries in different formats.
##  

##  normalize author/editor name lists: last-name, initial(s) of first
##  name(s) and ...
##  see Lamport: LaTeX App.B 1.2
BindGlobal("NormalizedNameAndKey", function(str)
  local   nbsp,  new,  pp,  p,  a,  i,  names,  norm,  keyshort,  
          keylong,  res;
  # first normalize white space inside braces { ... } and change
  # spaces to non-breakable spaces
  nbsp := CHAR_INT(160);
  new := "";
  pp := 0;
  p := Position(str, '{');
  while p <> fail do
    Append(new, str{[pp+1..p-1]});
    pp := PositionMatchingDelimiter(str, "{}", p);
    a := NormalizedWhitespace(str{[p..pp]});
    for i in [1..Length(a)] do
      if a[i] = ' ' then
        a[i] := nbsp;
      fi;
    od;
    Append(new, a);
    p := Position(str, '{', pp);
  od;
  if Length(new)>0 then
    str := Concatenation(new, str{[pp+1..Length(str)]});
  fi;
  
  # split into names:
  names := [];
  pp := 0;
  p := PositionSublist(str, "and");
  while p <> fail do
    # "and" is only delimiter if surrounded by white space
    if not (str[p-1] in WHITESPACE and Length(str)>p+2 and str[p+3] in
               WHITESPACE) then
      p := PositionSublist(str, "and", p);
    else
      Add(names, str{[pp+1..p-2]});
      pp := p+3;
      p := PositionSublist(str, "and", pp);
    fi;
  od;
  Add(names, str{[pp+1..Length(str)]});
  
  # normalize a single name
  norm := function(str)
    local   n,  i,  lnam,  j,  fnam;
    # special case "et. al."
    if str="others" then
      return ["others", ""];
    fi;
    
    n := SplitString(str, "", WHITESPACE);
    # check if in "lastname, firstname" notation
    # find last ","
    i := Length(n);
    while i>0 and n[i]<>"," and n[i][Length(n[i])] <> ',' do
      i := i-1;
    od;
    if i>0 then
      # last name
      lnam := "";
      for j in [1..i] do
        Append(lnam, n[j]);
        if j<>i-1 or Length(n[i])>1 then
          Add(lnam, ' ');
        fi;
      od;
      # first name initials
      fnam := "";
      for j in [i+1..Length(n)] do
        Add(fnam, First(n[j], x-> x in LETTERS));
        Append(fnam, ". ");
      od;
    else
      # last name is last including words not starting with
      # capital letters
      i := Length(n);
      while i>1 and First(n[i-1], a-> a in LETTERS) in SMALLLETTERS do
        i := i-1;
      od;
      # last name 
      lnam := "";
      for j in [i..Length(n)] do
        Append(lnam, n[j]);
        if j < Length(n) then
          Add(lnam, ' ');
        fi;
      od;
      Append(lnam, ", ");
      # first name capitals
      fnam := "";
      for j in [1..i-1] do
        Add(fnam, First(n[j], x-> x in LETTERS));
        Append(fnam, ". ");
      od;
    fi;
    return [lnam, fnam];
  end;
  
  keyshort := "";
  keylong := "";
  names := List(names, norm);
  res := "";
  for a in names do
    if Length(res)>0 then
      Append(res, "and ");
    fi;
    Append(res, a[1]);
    Append(res, a[2]);
    if a[1] = "others" then
      Add(keyshort, '+');
    else
      p := 1;
      while not a[1][p] in CAPITALLETTERS do
        p := p+1;
      od;
      Add(keyshort, a[1][p]);
      Append(keylong, STRING_LOWER(Filtered(a[1]{[p..Length(a[1])]},
              x-> x in LETTERS)));
    fi;
  od;
  if Length(keyshort)>3 then
    keyshort := keyshort{[1,2]};
    Add(keyshort, '+');
  fi;
  return [res, keyshort, keylong];
end);

##  <#GAPDoc Label="ParseBibFiles">
##  <ManSection >
##  <Func Arg="bibfile" Name="ParseBibFiles" />
##  <Returns>list <C>[list of bib-records, list of abbrevs, list  of 
##  expansions]</C></Returns>
##  <Description>
##  This function parses a file <A>bibfile</A> (if this file does not
##  exist the  extension <C>.bib</C> is appended)  in &BibTeX; format
##  and returns a list  as follows: <C>[entries, strings, texts]</C>.
##  Here <C>entries</C>  is a  list of records,  one record  for each
##  reference  contained in  <A>bibfile</A>.  Then <C>strings</C>  is
##  a  list of  abbreviations  defined  by <C>@string</C>-entries  in
##  <A>bibfile</A> and <C>texts</C>  is a list which  contains in the
##  corresponding position  the full  text for such  an abbreviation.
##  <P/>
##  
##  The  records  in entries  store  key-value  pairs of  a  &BibTeX;
##  reference in the  form <C>rec(key1 = value1,  ...)</C>. The names
##  of  the  keys are  converted  to  lower  case.  The type  of  the
##  reference (i.e.,  book, article,  ...) and  the citation  key are
##  stored as components <C>.Type</C> and <C>.Label</C>.<P/>
##  
##  As an example consider the following &BibTeX; file.
##  
##  <Listing Type="my.bib">
##  @string{ j  = "Important Journal" }
##  @article{ AX2000, Author=  "Fritz A. First and Sec, X. Y.", 
##  TITLE="Short", journal = j, year = 2000 }
##  </Listing> 
##  
##  <Example>
##  gap> bib := ParseBibFiles("my.bib");
##  [ [ rec( Type := "article", Label := "AB2000", 
##            author := "Fritz A. First and Sec, X. Y.", title := "Short", 
##            journal := "Important Journal", year := "2000" ) ], 
##    [ "j" ], 
##    [ "Important Journal" ] ]
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(ParseBibFiles, function(arg)
  local   file,  str,  stringlabels,  strings,  entries,  p,  r,  pb,  s,  
          ende,  comp,  pos;
  
  stringlabels := []; 
  strings := [];
  entries := [];
  
  for file in arg do
    str := StringFile(file);
    if str=fail then
      str := StringFile(Concatenation(file, ".bib"));
    fi;
    if str=fail then 
      Print("#W  Can't find bib-file ", file, "[.bib]\n");
      return fail;
    fi;

    # find entries
    p := Position(str, '@');
    while p<>fail do
      r := rec();
      # type 
      pb := Position(str, '{', p);
      s := LowercaseString(StripBeginEnd(str{[p+1..pb-1]}, WHITESPACE));
      p := pb;
      if s = "string" then
        # a string is normalized and stored for later substitutions 
        pb := Position(str, '=', p);
        Add(stringlabels, 
            LowercaseString(StripBeginEnd(str{[p+1..pb-1]}, WHITESPACE)));
        p := pb;
        pb := PositionMatchingDelimiter(str, "{}", p);
        s := StripBeginEnd(str{[p+1..pb-1]}, WHITESPACE);
        if (s[1]='\"' and s[Length(s)]='\"') or
           (s[1]='{' and s[Length(s)]='}') then
          s := s{[2..Length(s)-1]};
        fi;
        Add(strings, s);
        p := pb;
      else
        # type and label of entry
        r := rec(Type := s);
        # end of bibtex entry, for better recovery from errors
        ende := PositionMatchingDelimiter(str, "{}", p);
        pb := Position(str, ',', p);
        if not IsInt(pb) or pb > ende then 
          # doesn't seem to be a correct entry, ignore
          p := Position(str, '@', ende);
          continue;
        fi;
        r.Label := StripBeginEnd(str{[p+1..pb-1]}, WHITESPACE);
        p := pb;
        # get the components
        pb := Position(str, '=', p);
        while pb<>fail and pb < ende do
          comp := LowercaseString(StripBeginEnd(str{[p+1..pb-1]}, 
                          Concatenation(",", WHITESPACE)));
          pb := pb+1;
          while str[pb] in WHITESPACE do
            pb := pb+1;
          od;
          p := pb;
          if str[p] = '\"' then
            pb := Position(str, '\"', p);
            # if double quote is escaped, then go to next one
            while str[pb-1]='\\' do
              pb := Position(str, '\"', pb);
            od;
            r.(comp) := str{[p+1..pb-1]};
          elif str[p] = '{' then
            pb := PositionMatchingDelimiter(str, "{}", p);
            r.(comp) := str{[p+1..pb-1]};
          else 
            pb := p+1;
            while (not str[pb] in WHITESPACE) and str[pb] <> ',' and 
                       str[pb] <> '}' do
              pb := pb+1;
            od;
            s := str{[p..pb-1]};
            # number 
            if Int(s)<>fail then
              r.(comp) := s;
            else
              # abbrev string, look up and substitute
              s := LowercaseString(s);
              pos := Position(stringlabels, s);
              if pos=fail then
                r.(comp) := Concatenation("STRING-NOT-KNOWN: ", s);
              else
                r.(comp) := strings[pos];
              fi;  
            fi;
          fi;
          p := pb+1;
          pb := Position(str, '=', p);
        od;
        Add(entries, r);
      fi;
      p := Position(str, '@', p);
    od;
  od;
  return [entries, stringlabels, strings];
end);

##  <#GAPDoc Label="NormalizeNameAndKey">
##  <ManSection >
##  <Func Arg="r" Name="NormalizeNameAndKey" />
##  <Returns>nothing</Returns>
##  <Description>
##  This  function  normalizes  in  a record  describing  a  &BibTeX;
##  reference  (see <Ref  Func="ParseBibFiles" />) the  <C>author</C>
##  and  editor  fields using  the  description  in <Cite  Key="La85"
##  Where="Appendix  B 1.2"/>.  The  original entries  are stored  in
##  <C>.authororig</C> and <C>.editororig</C>.<P/>
##  
##  Furthermore a short and a long citation key is generated.<P/> 
##  
##  We continue the example from <Ref  Func="ParseBibFiles"  />.
##  
##  <Example>
##  gap> bib[1][1];
##  rec( Type := "article", Label := "AB2000", 
##    author := "First, F. A. and Sec, X. Y. ", title := "Short", 
##    journal := "Important Journal", year := "2000", 
##    authororig := "Fritz A. First and Sec, X. Y.", key := "FS00", 
##    keylong := "firstsec2000" )
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(NormalizeNameAndKey, function(b)
  local   yy,  y,  names,  nn;
  if IsBound(b.year) then
    if IsInt(b.year) then
      yy := String(b.year);
      y := String(b.year mod 100);
    else
      yy := b.year;
      y := b.year{[Length(b.year)-1, Length(b.year)]};
    fi;
  else
    yy := "";
    y := "";
  fi;
  for names in ["author", "editor"] do
    if IsBound(b.(names)) then
      nn := NormalizedNameAndKey(b.(names));
      if nn[1] <> b.(names) then
        b.(Concatenation(names, "orig")) := b.(names);
        b.(names) := nn[1];
      fi;
      if not IsBound(b.key) then
        b.key := Concatenation(nn[2], y);
      fi;
      if not IsBound(b.keylong) then
        b.keylong := Concatenation(nn[3], yy);
      fi;
    fi;
  od;
end);


# print out a bibtex entry, the ordering of fields is normalized and
# type and field names are in lowercase, also some formatting is done
# arg: entry[, abbrevs, texts]    where abbrevs and texts are lists
#      of same length abbrevs[i] is string macro for texts[i]
InstallGlobalFunction(PrintBibAsBib, function(arg)
  local   r,  abbrevs,  texts,  ind,  fieldlist,  comp,  pos,  lines,  i;
  
  # scan arguments
  r := arg[1];
  if Length(arg)>2 then
    abbrevs := arg[2];
    texts := arg[3];
  else
    abbrevs := [];
    texts := [];
  fi;
  
  if not IsBound(r.Label) then
    Print("%%%%%    no label     %%%%%%%%\n");
    return;
  fi;
  ind := RepeatedString(' ', 22);
  fieldlist := [
                "author",
                "editor",
                "booktitle",
                "title",
                "journal",
                "month",
                "organization",
                "publisher",
                "school",
                "edition",
                "series",
                "volume",
                "number",
                "address",
                "year",
                "pages",
                "chapter",
                "crossref",
                "note",
                "notes",
                "key",
                "keywords" ];
  Print("@", r.Type, "{ ", r.Label);
  for comp in Concatenation(fieldlist,
          Difference(NamesOfComponents(r), Concatenation(fieldlist,
                  ["Type", "Label"]) )) do
    if IsBound(r.(comp)) then
      Print(",\n  ", comp, " = ", List([1..16-Length(comp)], i-> ' '));
      pos := Position(texts, r.(comp));
      if pos <> fail then
        Print(abbrevs[pos]);
      else
        Print("{");
        lines := FormatParagraph(r.(comp), 54, "both", [ind, ""]);
        PrintFormattedString(lines{[Length(ind)+1..Length(lines)-1]});
        Print("}");
      fi;
    fi;
  od;
  Print("\n}\n\n");
end);

##  <#GAPDoc Label="WriteBibFile">
##  <ManSection >
##  <Func Arg="bibfile, bib" Name="WriteBibFile" />
##  <Returns>nothing</Returns>
##  <Description>
##  This  is   the  converse  of  <Ref  Func="ParseBibFiles"/>.  Here
##  <A>bib</A>  must  have  a  format  as  it  is  returned  by  <Ref
##  Func="ParseBibFiles"/>. A &BibTeX; file <A>bibfile</A> is written
##  and  the  entries are  formatted  in  a  uniform way.  All  given
##  abbreviations are used while writing this file.<P/>
##  
##  We continue the example from <Ref   Func="NormalizeNameAndKey"/>.
##  The command
##  
##  <Example>
##  gap> WriteBibFile("nicer.bib", bib);
##  </Example>
##  
##  produces a file <F>nicer.bib</F> as follows:
##  
##  <Listing Type="nicer.bib">
##  @string{j = "Important Journal" }
##  
##  @article{ AB2000,
##    author =           {First, F. A. and Sec, X. Y.},
##    title =            {Short},
##    journal =          j,
##    year =             {2000},
##    key =              {FS00},
##    authororig =       {Fritz A. First and Sec, X. Y.},
##    keylong =          {firstsec2000}
##  }
##  </Listing>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(WriteBibFile, function(file, bib)
  local   p,  b3,  a,  b,  pos,  f;
  
  # collect abbrevs 
  p := [];
  SortParallel(bib[3], bib[2]);
  b3 := Immutable(bib[3]);
  IsSet(b3);
  for a in bib[1] do
    for b in NamesOfComponents(a) do
      pos := Position(b3, a.(b));
      if pos <> fail then
        Add(p, pos);
      fi;
    od;
  od;
  p := Set(p);
  
  f := function()
    local   i,  a;
    Print("\n\n");
    # the `string's
    for i in p do
      Print("@string{", bib[2][i], " = \"", b3[i], "\" }\n");
    od;        
    Print("\n\n");  
    for a in bib[1] do
      PrintBibAsBib(a, bib[2], b3);
    od;
  end;
  
  PrintTo1(file, f);
end);

##  arg: r[, i]  (for link to BibTeX)
InstallGlobalFunction(PrintBibAsHTML, function(arg)
  local   r,  i;
  r := arg[1];
  if Length(arg)=2 then
    i := arg[2];
  else
    i := -1;
  fi;
  
  if not IsBound(r.Label) then
    Print("Error: entry has no label . . .\n");
    return;
  fi;
  
  Print("<p>\n[<font color=\"#8e0000\">", r.Label, "</font>]   ");
  if IsBound(r.author) then
    Print("<b>",r.author,"</b> ");
  fi;
  if IsBound(r.editor) then
    Print("(", r.editor, ",Ed.)");
  fi;
  if IsBound(r.title) then
    Print(",\n <i>", r.title, "</i>");
  fi;
  if IsBound(r.booktitle) then
    if r.Type in ["inproceedings", "incollection"] then
      Print(" in ");
    fi;
    Print(",\n <i>", r.booktitle, "</i>");
  fi;
  if IsBound(r.subtitle) then
    Print(",\n <i> -- ", r.subtitle, "</i>");
  fi;
  if IsBound(r.journal) then
    Print(",\n ", r.journal);
  fi;
  if IsBound(r.organization) then
    Print(",\n ", r.organization);
  fi;
  if IsBound(r.publisher) then
    Print(",\n ", r.publisher);
  fi;
  if IsBound(r.school) then
    Print(",\n ", r.school);
  fi;
  if IsBound(r.edition) then
    Print(",\n ", r.edition, "edition");
  fi;
  if IsBound(r.series) then
    Print(",\n ", r.series);
  fi;
  if IsBound(r.volume) then
    Print(",\n <emph>", r.volume, "</emph>");
  fi;
  if IsBound(r.number) then
    Print(" (", r.number, ")");
  fi;
  if IsBound(r.address) then
    Print(",\n ", r.address);
  fi;
  if IsBound(r.year) then
    Print(",\n (", r.year, ")");
  fi;
  if IsBound(r.pages) then
    Print(",\n p. ", r.pages);
  fi;
  if IsBound(r.chapter) then
    Print(",\n Chapter ", r.chapter);
  fi;
  if IsBound(r.note) then
    Print("<br>\n(", r.note, ")<br>\n");
  fi;
  if IsBound(r.notes) then
    Print("<br>\n(", r.notes, ")<br>\n");
  fi;
 
  if IsBound(r.BUCHSTABE) then
    Print("<br>\nEinsortiert unter ", r.BUCHSTABE, ".<br>\n");
  fi;
  if IsBound(r.LDFM) then
    Print("Signatur ", r.LDFM, ".<br>\n");
  fi;
  if IsBound(r.BUCHSTABE) and i>=0 then
    Print("<a href=\"HTMLldfm", r.BUCHSTABE, ".html#", i, 
          "\"><font color=red>BibTeX Eintrag</font></a>\n<br>");
  fi;
  Print("</p>\n\n");
end);

##  arg: r[, ansi]  (for link to BibTeX)
InstallGlobalFunction(PrintBibAsText, function(arg)
  local   r,  bold,  emph,  us,  lab,  str;
  r := arg[1];
  if Length(arg) = 2  and arg[2] = true then
    bold := Concatenation(TextAttr.bold, TextAttr.1);
    emph := TextAttr.4;
    us := TextAttr.underscore;
    lab := TextAttr.3;
  else
    bold := ""; emph := ""; us := ""; lab := "";  
  fi;
  
  if not IsBound(r.Label) then
    Print("Error: entry has no label . . .\n");
    return;
  fi;
  
  str := "";
  Append(str, lab);
  Add(str, '[');
  if IsBound(r.key) then
    Append(str, r.key);
  else
    Append(str, r.Label);
  fi;
  Append(str, "] ");
  Append(str, TextAttr.reset);
  if IsBound(r.author) then
    Append(str, Concatenation(bold ,r.author, TextAttr.reset));
  fi;
  if IsBound(r.editor) then
    Append(str, Concatenation(" (", r.editor, ",Ed.) "));
  fi;
  if IsBound(r.title) then
    Append(str, Concatenation(", ", emph, r.title, TextAttr.reset));
  fi;
  if IsBound(r.booktitle) then
    Append(str, ", ");
    if r.Type in ["inproceedings", "incollection"] then
      Append(str, " in ");
    fi;
    Append(str, Concatenation(emph, r.booktitle, TextAttr.reset));
  fi;
  if IsBound(r.subtitle) then
    Append(str, Concatenation(" -- ", emph, r.subtitle,
            TextAttr.reset, " "));
  fi;
  if IsBound(r.journal) then
    Append(str, Concatenation(", ", r.journal));
  fi;
  if IsBound(r.organization) then
    Append(str, Concatenation(", ", r.organization));
  fi;
  if IsBound(r.publisher) then
    Append(str, Concatenation(", ", r.publisher));
  fi;
  if IsBound(r.school) then
    Append(str, Concatenation(", ", r.school));
  fi;
  if IsBound(r.edition) then
    Append(str, Concatenation(", ", r.edition, " edition"));
  fi;
  if IsBound(r.series) then
    Append(str, Concatenation(", ", r.series));
  fi;
  if IsBound(r.volume) then
    Append(str, Concatenation(", ", emph, r.volume, TextAttr.reset));
  fi;
  if IsBound(r.number) then
    Append(str, Concatenation(" (", r.number, ")"));
  fi;
  if IsBound(r.address) then
    Append(str, Concatenation(", ", r.address));
  fi;
  if IsBound(r.year) then
    Append(str, Concatenation(" (", r.year, ")"));
  fi;
  if IsBound(r.pages) then
    Append(str, Concatenation(", ", r.pages));
  fi;
  if IsBound(r.chapter) then
    Append(str, Concatenation(", Chapter ", r.chapter));
  fi;
  if IsBound(r.note) then
    Append(str, Concatenation(", (", r.note, ")"));
  fi;
  
  if IsBound(r.BUCHSTABE) then
    Append(str, Concatenation(", Einsortiert unter ", r.BUCHSTABE));
  fi;
  if IsBound(r.LDFM) then
    Append(str, Concatenation(", Signatur ", r.LDFM));
  fi;
  str := FormatParagraph(Filtered(str, x-> not x in "{}"), 72);
  Add(str, '\n');
  PrintFormattedString(str);
end);

