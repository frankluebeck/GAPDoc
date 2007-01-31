#############################################################################
##
#W  BibTeX.gi                    GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: BibTeX.gd,v 1.2 2007-01-31 13:45:09 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files BibTeX.g{d,i} contain a parser for BibTeX files and some
##  functions for printing BibTeX entries in different formats.
##  

DeclareGlobalFunction("ParseBibFiles");
DeclareGlobalFunction("NormalizeNameAndKey");
DeclareGlobalFunction("WriteBibFile");
DeclareGlobalFunction("StringBibAsBib");
DeclareGlobalFunction("PrintBibAsBib");
DeclareGlobalFunction("StringBibAsText");
DeclareGlobalFunction("PrintBibAsText");
DeclareGlobalFunction("StringBibAsHTML");
DeclareGlobalFunction("PrintBibAsHTML");

