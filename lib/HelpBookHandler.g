#############################################################################
##
#W  HelpBookHandler.g                GAPDoc                      Frank Lübeck
##
#H  @(#)$Id: HelpBookHandler.g,v 1.8 2002-05-27 09:02:43 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  This file contains the HELP_BOOK_HANDLER functions for the GapDocGAP
##  format.  This  is  the  interface  between  the  converter  programs
##  contained in the GAPDoc package and GAP's help system.
## 

HELP_BOOK_HANDLER.GapDocGAP := rec();

##  
##  The  .entries info in the GapDocGAP  six-format has  entries of form 
##  
##      [ showstring,  
##        sectionstring,  (allows searching of section numbers, like: "1.3-4")
##        [chapnr, secnr, subsecnr], 
##        linenr  (for "text" format), 
##        pagenr (for .dvi, .pdf-formats)
##      ]
##  

HELPBOOKINFOSIXTMP := 0;
if not IsBound(ANSI_COLORS) then
  ANSI_COLORS := false;
fi;
HELP_BOOK_HANDLER.GapDocGAP.ReadSix := function(stream)
  local fname, res, bname, nam, a;
  # our .six file is directly GAP-readable
  fname := ShallowCopy(stream![2]);
  Read(stream);
  res := HELPBOOKINFOSIXTMP;
  Unbind(HELPBOOKINFOSIXTMP);
  
  # if no ANSI_COLORS we strip the escape sequences:
  if not IsBound(ANSI_COLORS) or ANSI_COLORS <> true then
    for a in res.entries do
      a[1] := StripEscapeSequences(a[1]);
    od;
  fi;
  
  # in position 6 of each entry we put the corresponding search string
  for a in res.entries do
    a[6] := SIMPLE_STRING(StripEscapeSequences(a[1]));
    NormalizeWhitespace(a[6]);
  od;
  
  # We  check the current availability of the different
  # formats. And we add the help directory.
  res.handler := "GapDocGAP";
  res.directory := Directory(fname{[1..Length(fname)-10]});
  res.types := ["text"];
  # check if  .dvi and .pdf files and HTML-version available
  bname := fname{[1..Length(fname)-4]};
  nam := Concatenation(bname, ".dvi");
  if IsExistingFile(nam) then
    res.dvifile := nam;
    Add(res.types, "dvi");
  fi;
  nam := Concatenation(bname, ".pdf");
  if IsExistingFile(nam) then
    res.pdffile := nam;
    Add(res.types, "pdf");
  fi;
  nam := Concatenation(bname{[1..Length(bname)-6]}, "chap0.html");
  if IsExistingFile(nam) then
    Add(res.types, "url");
    Add(res.types, "url-text");
  fi;
  nam := Concatenation(bname{[1..Length(bname)-6]}, "chap0_sym.html");
  if IsExistingFile(nam) then
    Add(res.types, "url");
    Add(res.types, "url-sym");
  fi;
  nam := Concatenation(bname{[1..Length(bname)-6]}, "chap0_mml.xml");
  if IsExistingFile(nam) then
    Add(res.types, "url");
    Add(res.types, "url-mml");
  fi;
  
  return res;
end;
Unbind(HELPBOOKINFOSIXTMP);

# Our help output format contains the table of contents,
# so we just delegate.
HELP_BOOK_HANDLER.GapDocGAP.ShowChapters := function(book)
  local   info, match;
  info := HELP_BOOK_INFO(book);
  match := Concatenation(HELP_BOOK_HANDLER.GapDocGAP.SearchMatches(book, 
                                            "table of contents", true))[1];
  return HELP_BOOK_HANDLER.GapDocGAP.HelpData(info, match, "text");
end;

HELP_BOOK_HANDLER.GapDocGAP.ShowSections := 
                                 HELP_BOOK_HANDLER.GapDocGAP.ShowChapters;

#  very similar to the .default handler, but we allow search for
#  (sub-)section numbers as well
HELP_BOOK_HANDLER.GapDocGAP.SearchMatches := function (book, topic, frombegin)
  local   info,  exact,  match,  i;
  
  info := HELP_BOOK_INFO(book);
  exact := [];
  match := [];
  for i in [1..Length(info.entries)] do
    if topic=info.entries[i][6] or topic=info.entries[i][2] then
      Add(exact, i);
    elif frombegin = true then
      if MATCH_BEGIN(info.entries[i][6], topic) or 
         MATCH_BEGIN(info.entries[i][2], topic) then
        Add(match, i);
      fi;
    else
      if IS_SUBSTRING(info.entries[i][6], topic) then
        Add(match, i);
      fi;
    fi;
  od;
  
  return [exact, match];
end;

##  The data are all easy to get.
if not IsBound(BROWSER_CAP) then
  BROWSER_CAP := [];
fi;
HELP_BOOK_HANDLER.GapDocGAP.HelpData := function(book, entrynr, type)
  local info, a, fname, str, formatted, ext, label;
  
  info := HELP_BOOK_INFO(book);
  # we handle the special type "ref" for cross references first
  if type = "ref" then
    a := HELP_BOOK_HANDLER.HelpDataRef(info, entrynr);
    a[1] := StripEscapeSequences(a[1]);
    return a;
  fi;
  
  a := info.entries[entrynr];
  
  # section number info
  if type = "secnr" then
    return a{[3,2]};
  fi;

  if not type in info.types then 
    return fail;
  fi;
  
  if type = "text" then
    fname := Filename(info.directory, Concatenation("chap", String(a[3][1]),
             ".txt"));
    str := StringFile(fname);
    if str = fail then
      return rec(lines := Concatenation("Sorry, file '", fname, "' seems to ",
                 "be corrupted.\n"), formatted := true);
    fi;
    if not IsBound(ANSI_COLORS) or ANSI_COLORS <> true then
      # strip escape sequences
      str := StripEscapeSequences(str);
    fi;
    return rec(lines := str, formatted := true, start := a[4]);
  fi;
  
  if type = "url" and "url" in info.types then
    # check preferred HTML version/extension
    if not IsBound(BROWSER_CAP) then
      BROWSER_CAP := [];
    fi;
    if "MathML" in BROWSER_CAP and "url-mml" in info.types then
      ext := "_mml.xml";
    elif ("MathML" in BROWSER_CAP or "Symbol" in BROWSER_CAP) and
          "url-sym" in info.types then
      ext := "_sym.html";
    elif "url-text" in info.types then
      ext := ".html";
    else
      return fail;
    fi;
    fname := Filename(info.directory, Concatenation("chap",
                       String(a[3][1]), ext));
    label := Concatenation("#s", String(a[3][2]),
                     "ss", String(a[3][3]));
    # ??? return Concatenation("file:", fname, label);
    return Concatenation("", fname, label);
  fi;
  
  if type = "dvi" then
    return rec(file := info.dvifile, page := a[5]);
  fi;
  
  if type = "pdf" then
    return rec(file := info.pdffile, page := a[5]);
  fi;

  return fail;
end;

##  cache list of chapter numbers, but only if we need them
HELP_BOOK_HANDLER.GapDocGAP.ChapNumbers := function(info)
  local l, sp;
  if not IsBound(info.ChapNumbers) then
    l := Set(List(info.entries,a->a[3][1]));
    sp := IntersectionSet(l, ["Bib", "Ind"]);
    l := Difference(l, sp);
    Append(l, sp);
    info.ChapNumbers := l;
  fi;
end;

##  for ?<<,  ?>>,  ?<  and  ?>
HELP_BOOK_HANDLER.GapDocGAP.MatchPrevChap := function(book, entrynr)
  local info, chnums, ent, cnr, new, nr;
  info := HELP_BOOK_INFO(book);
  HELP_BOOK_HANDLER.GapDocGAP.ChapNumbers(info);
  chnums := info.ChapNumbers;
  ent := info.entries;
  cnr := ent[entrynr][3];
  if cnr[2] <> 0 or cnr[3] <> 0 or cnr[1] = chnums[1] then
    new := [cnr[1], 0, 0];
  else
    new := [chnums[Position(chnums, cnr[1])-1], 0, 0];
  fi;
  nr := First([1..Length(ent)], i-> ent[i][3] = new);
  if nr = fail then
    # return current
    nr := entrynr;
  fi;
  return [info, nr];
end;

HELP_BOOK_HANDLER.GapDocGAP.MatchNextChap := function(book, entrynr)
##    local   info,  ent,  old,  chnrs,  pos,  cnr,  nr;
##    info := HELP_BOOK_INFO(book);
##    HELP_BOOK_HANDLER.GapDocGAP.ChapNumbers(info);
##    ent := info.entries;
##    old := ent[entrynr][3];
##    # this handles appendices as chapters 
##    chnrs := Set(Difference(List(ent, a-> a[1]), ["Bib", "Ind"]));
##    pos := Position(chnrs, old[1]);
##    if pos < Length(chnrs) then
##      cnr := [chnrs[pos+1], 0, 0];
##    else
##      # no next chapter, return the last 
##      cnr := [old[1], 0, 0];
##    fi;
##    nr := First([1..Length(ent)], i-> ent[i][3]=cnr);
##    if nr = fail then
##      # return current
##      nr := entrynr;
##    fi;
##    return [info, nr];
  local info, chnums, ent, cnr, new, nr;
  info := HELP_BOOK_INFO(book);
  HELP_BOOK_HANDLER.GapDocGAP.ChapNumbers(info);
  chnums := info.ChapNumbers;
  ent := info.entries;
  cnr := ent[entrynr][3];
  if cnr[1] = chnums[Length(chnums)] then
    new := [cnr[1], 0, 0];
  else
    new := [chnums[Position(chnums, cnr[1])+1], 0, 0];
  fi;
  nr := First([1..Length(ent)], i-> ent[i][3] = new);
  if nr = fail then
    # return current
    nr := entrynr;
  fi;
  return [info, nr];
end;

HELP_BOOK_HANDLER.GapDocGAP.MatchPrev := function(book, entrynr)
  local   info,  ent,  old,  new,  nr,  i;
  info := HELP_BOOK_INFO(book);
  ent := info.entries;
  old := ent[entrynr][3];
  new := [-1,0,0];
  nr := entrynr;
  for i in [1..Length(ent)] do
    if ent[i][3] < old and ent[i][3] > new and 
       not ent[i][3][1] in ["Bib", "Ind"] then
      new := ent[i][3];
      nr := i;
    fi;
  od;
  return [info, nr];
end;

HELP_BOOK_HANDLER.GapDocGAP.MatchNext := function(book, entrynr)
  local   info,  ent,  old,  new,  nr,  i;
  info := HELP_BOOK_INFO(book);
  ent := info.entries;
  old := ent[entrynr][3];
  new := ["ZZZ",0,0];
  nr := entrynr;
  for i in [1..Length(ent)] do
    if ent[i][3] > old and ent[i][3] < new and 
       not ent[i][3][1] in ["Bib", "Ind"] then
      new := ent[i][3];
      nr := i;
    fi;
  od;
  return [info, nr];
end;

