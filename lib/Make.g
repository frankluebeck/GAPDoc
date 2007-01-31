#############################################################################
##
#W  Make.g                       GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: Make.g,v 1.8 2007-01-31 13:45:10 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  This file  contains a function  which may  be used for  building all
##  output versions of  a GAPDoc XML document which are  provided by the
##  GAPDoc package.
##  

##  args: path, main, files, bookname[, gaproot][, "MathML"][, "Tth"]
BindGlobal("MakeGAPDocDoc", function(arg)
  local htmlspecial, path, main, files, bookname, gaproot, 
        str, r, l, latex, null, t, h;
  
  htmlspecial := Filtered(arg, a-> a in ["MathML", "Tth"]);
  if Length(htmlspecial) > 0 then
    arg := Filtered(arg, a-> not a in ["MathML", "Tth"]);
  fi;
  path := arg[1];
  main := arg[2];
  files := arg[3];
  bookname := arg[4];
  if IsBound(arg[5]) then
    gaproot := arg[5];
  else
    gaproot := false;
  fi;
  # ensure that path is directory object
  if IsString(path) then
    path := Directory(path);
  fi; 
  # ensure that .xml is striped from name of main file
  if Length(main)>3 and main{[Length(main)-3..Length(main)]} = ".xml" then
    main := main{[1..Length(main)-4]};
  fi;
  # compose the XML document
  Print("Composing XML document . . .\n");
  str := ComposedXMLString(path, Concatenation(main, ".xml"), files, true);
  # parse the XML document
  Print("Parsing XML document . . .\n");
  r := ParseTreeXMLString(str[1], str[2]);
  # clean the result
  Print("Checking XML structure . . .\n");
  CheckAndCleanGapDocTree(r);
  # produce LaTeX version
  Print("LaTeX version and calling latex and pdflatex:\n    ");
  r.bibpath := path;
  l := GAPDoc2LaTeX(r);
  Print("writing LaTeX file, \c");
  FileString(Filename(path, Concatenation(main, ".tex")), l);
  # call latex and pdflatex (with bibtex, makeindex and dvips)
  latex := "latex -interaction=nonstopmode ";
  # sh-syntax for redirecting stderr and stdout to /dev/null
  null := " > /dev/null 2>&1 ";
##    Print("3 x latex, bibtex and makeindex, \c"); 
##    Exec(Concatenation("sh -c \" cd ", Filename(path,""), 
##    "; ", latex, main, ".tex", null,
##    "; bibtex ", main, null,
##    "; ", latex, main, null,
##    "; makeindex ", main, null,
##    "; ", latex, main, null,
##    "; rm -f ", main, ".aux\""));
  Print("3 x pdflatex, \c");
  Exec(Concatenation("sh -c \" cd ", Filename(path,""),
  "; rm -f ", main, ".aux ",
  "; pdf", latex, main, null,
  "; bibtex ", main, null,
  "; pdf", latex, main, null,
  "; makeindex ", main, null,
  "; pdf", latex, main, null,"\""));
##    Print("dvips\n");
  Exec(Concatenation("sh -c \" cd ", Filename(path,""),
##    "; dvips -o ", main, ".ps ", main, null,  
##    "; mv ", main, ".dvi manual.dvi ", 
  "; mv ", main, ".pdf manual.pdf; ", 
##    "mv ", main, ".ps manual.ps; ", 
  "\""));
  # produce text version
  Print("Text version . . .\n");
  t := GAPDoc2Text(r, path);
  GAPDoc2TextPrintTextFiles(t, path);
  # read page number information for .six file
  Print("Writing manual.six file . . .\n");
  AddPageNumbersToSix(r, Filename(path, Concatenation(main, ".pnr")));
  # print manual.six file
  PrintSixFile(Filename(path, "manual.six"), r, bookname);
  # produce html version
  Print("And finally the HTML version . . .\n");
  h := GAPDoc2HTML(r, path, gaproot);
  GAPDoc2HTMLPrintHTMLFiles(h, path);
  if "Tth" in htmlspecial then
    Print("  - also HTML version with 'tth' translated formulae . . .\n");
    h := GAPDoc2HTML(r, path, gaproot, "Tth");
    GAPDoc2HTMLPrintHTMLFiles(h, path);
  fi;
  if "MathML" in htmlspecial then
    Print("  - also HTML + MathML version with 'ttm' . . .\n");
    h := GAPDoc2HTML(r, path, gaproot, "MathML");
    GAPDoc2HTMLPrintHTMLFiles(h, path);
  fi;

##    if not IsExistingFile(Filename(path, "manual.html")) then
##      Exec("sh -c \"cd ", Filename(path,""), "; ln -s chap0.html manual.html\"");
##    fi;
  return r;
end);

