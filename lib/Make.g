#############################################################################
##
#W  Make.g                       GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: Make.g,v 1.2 2001-01-17 15:31:20 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  This file  contains a function  which may  be used for  building all
##  output versions of  a GAPDoc XML document which are  provided by the
##  GAPDoc package.
##  

BindGlobal("MakeGAPDocDoc", function(path, main, files, bookname)
  local  str, r, l, t, h, latex, null;
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
  str := ComposedXMLString(path, Concatenation(main, ".xml"), files);
  # parse the XML document
  Print("Parsing XML document . . .\n");
  r := ParseTreeXMLString(str);
  # clean the result
  Print("Checking XML structure . . .\n");
  CheckAndCleanGapDocTree(r);
  # produce LaTeX version
  Print("LaTeX version and calling latex and pdflatex:\n    ");
  l := GAPDoc2LaTeX(r);
  Print("writing LaTeX file, \c");
  FileString(Filename(path, Concatenation(main, ".tex")), l);
  # call latex and pdflatex (with bibtex, makeindex and dvips)
  latex := "latex -interaction=nonstopmode ";
  null := " &> /dev/null";
  Print("3 x latex, bibtex and makeindex, \c"); 
  Exec(Concatenation("sh -c \" cd ", Filename(path,""), 
  "; ", latex, main, ".tex", null,
  "; bibtex ", main, null,
  "; ", latex, main, null,
  "; makeindex ", main, null,
  "; ", latex, main, null,
  "; rm -f ", main, ".aux\""));
  Print("2 x pdflatex, \c");
  Exec(Concatenation("sh -c \" cd ", Filename(path,""),
  "; pdf", latex, main, null,
  "; pdf", latex, main, null,"\""));
  Print("dvips\n");
  Exec(Concatenation("sh -c \" cd ", Filename(path,""),
  "; dvips -o ", main, ".ps ", main, null,  
  "; mv ", main, ".dvi manual.dvi; mv ", main, 
  ".pdf manual.pdf; mv ", main, ".ps manual.ps; ", "\""));
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
  h := GAPDoc2HTML(r, path);
  GAPDoc2HTMLPrintHTMLFiles(h, path);
  if not IsExistingFile(Filename(path, "manual.html")) then
    Exec("sh -c \"cd ", Filename(path,""), "; ln -s chap0.html manual.html\"");
  fi;
  return r;
end);

