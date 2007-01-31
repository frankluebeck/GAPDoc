#############################################################################
##
#W  XMLParser.gd                 GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: XMLParser.gd,v 1.2 2007-01-31 13:45:10 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The files  XMLParser.g{d,i} contain a non-validating XML  parser and some
##  utilities.
##

DeclareGlobalFunction("GetEnt");
DeclareGlobalFunction("GetSTag");
DeclareGlobalFunction("GetETag");
DeclareGlobalFunction("GetElement");

DeclareGlobalFunction("ParseTreeXMLString");
DeclareGlobalFunction("ParseTreeXMLFile");
DeclareGlobalFunction("DisplayXMLStructure");
DeclareGlobalFunction("ApplyToNodesParseTree");
DeclareGlobalFunction("AddRootParseTree");
DeclareGlobalFunction("RemoveRootParseTree");

