#############################################################################
##
#W  Make.g                       GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: Make.g,v 1.1.1.1 2001-01-05 13:37:49 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  This file  contains a function  which may  be used for  building all
##  output versions of  a GAPDoc XML document which are  provided by the
##  GAPDoc package.
##  

BindGlobal("MakeGAPDocDoc", function(path, main, files, bookname)
  local  str, r, l, t, h;
  # ensure that path is directory object
  if IsString(path) then
    path := Directory(path);
  fi; 
  # ensure that .xml is striped from name of main file
  if Length(main)>3 and main{[Length(main)-3..Length(main)]} = ".xml" then
    main := main{[1..Length(main)-4]};
  fi;
  # compose the XML document
  str := ComposedXMLString(path, Concatenation(main, ".xml"), files);
  # parse the XML document
  r := ParseTreeXMLString(str);
  # clean the result
  CheckAndCleanGapDocTree(r);
  # produce LaTeX version
  l := GAPDoc2LaTeX(r);
  FileString(Filename(path, Concatenation(main, ".tex")), l);
  # call latex and pdflatex (with bibtex, makeindex and dvips)
  Exec(Concatenation("sh -c \" cd ", Filename(path,""), "; latex ", main,
       ".tex ; bibtex ", main, "; latex ", main, "; makeindex ", main,
       "; latex ", main, "; rm -f ", main, ".aux; pdflatex ", main, 
       "; pdflatex ", main, "; dvips -o ", main, ".ps ", main, 
       "; mv ", main, ".dvi manual.dvi; mv ", main, 
       ".pdf manual.pdf; mv ", main, ".ps manual.ps; ", "\""));
  # produce text version
  t := GAPDoc2Text(r, path);
  GAPDoc2TextPrintTextFiles(t, path);
  # read page number information for .six file
  AddPageNumbersToSix(r, Filename(path, Concatenation(main, ".pnr")));
  # print manual.six file
  PrintSixFile(Filename(path, "manual.six"), r, bookname);
  # produce html version
#  h := GAPDoc2HTML(r);
#  GAPDoc2HTMLPrintHTMLFiles(h, path);
  return r;
end);

