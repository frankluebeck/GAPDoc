#############################################################################
##
#W  GAPDoc.gd                    GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: GAPDoc.gd,v 1.1.1.1 2001-01-05 13:37:48 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files GAPDoc.g{d,i} contain some utilities for trees returned by
##  ParseTreeXMLString applied to a GAPDoc document.
##  

DeclareGlobalFunction("CheckAndCleanGapDocTree");
DeclareGlobalFunction("AddParagraphNumbersGapDocTree");
DeclareGlobalFunction("AddPageNumbersToSix");
DeclareGlobalFunction("PrintSixFile");

