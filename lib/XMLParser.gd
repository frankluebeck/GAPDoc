#############################################################################
##
#W  XMLParser.gd                 GAPDoc                          Frank L�beck
##
#H  @(#)$Id: XMLParser.gd,v 1.1.1.1 2001-01-05 13:37:48 gap Exp $
##
#Y  Copyright (C)  2000,  Frank L�beck,  Lehrstuhl D f�r Mathematik,  
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
DeclareGlobalFunction("DisplayXMLStructure");
DeclareGlobalFunction("ApplyToNodesParseTree");
DeclareGlobalFunction("AddRootParseTree");
DeclareGlobalFunction("RemoveRootParseTree");
