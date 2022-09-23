#############################################################################
##
#W  GAPDoc2LaTeX.gd                GAPDoc                        Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The  files GAPDoc2LaTeX.g{d,i}  contain a  conversion program  which
##  produces from a GAPDoc XML-document a version which can be processed
##  by LaTeX and pdfLaTeX.
##  

BindGlobal("GAPDoc2LaTeXProcs", rec());

DeclareGlobalFunction("GAPDoc2LaTeX");


