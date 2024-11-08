#############################################################################
##
#W  XMLParser.gd                 GAPDoc                          Frank Lübeck
##
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
DeclareGlobalFunction("XMLValidate");
DeclareGlobalFunction("ValidateGAPDoc");

DeclareGlobalFunction("GetTextXMLTree");
DeclareGlobalFunction("XMLElements");

##  <#GAPDoc Label="InfoXMLParser">
##  <ManSection >
##  <InfoClass Name="InfoXMLParser" />
##  <Description>
##  The default level of this info class is 1. Functions like <Ref
##  Func="ParseTreeXMLString"/> are then printing some information, in
##  particular in case of errors. You can suppress it by setting the 
##  level of <Ref InfoClass="InfoXMLParser"/> to 0. With level 2 there
##  may be some more information for debugging purposes.
##  
##  Messages with warnings (indicating that something should be fixed)
##  start with  the string <C>#W </C> (this can be used in automatized tests).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# Info class with default level 1
BindGlobal("InfoXMLParser", NewInfoClass("InfoXMLParser"));
SetInfoLevel(InfoXMLParser, 1);
if CompareVersionNumbers(GAPInfo.Version, "4.dev") then
  SetInfoHandler(InfoXMLParser, PlainInfoHandler);
fi;
