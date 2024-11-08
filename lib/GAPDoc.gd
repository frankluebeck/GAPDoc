#############################################################################
##
#W  GAPDoc.gd                    GAPDoc                          Frank Lübeck
##
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
DeclareGlobalFunction("PrintGAPDocElementTemplates");
DeclareGlobalFunction("TextM");
DeclareGlobalFunction("NormalizedArgList");

##  <#GAPDoc Label="InfoGAPDoc">
##  <ManSection >
##  <InfoClass Name="InfoGAPDoc" />
##  <Description>
##  The default level of this info class is 1. The converter functions
##  for &GAPDoc; documents are then 
##  printing some information. You can suppress this by setting the 
##  level of <Ref InfoClass="InfoGAPDoc"/> to 0. With level 2 there
##  may be some more information for debugging purposes.
##  
##  Most info statements in GAPDoc just give information about the progress
##  of functions. In some cases there are proper warnings which indicate
##  that something should be fixed. The corresponding messages start with 
##  the string <C>#W </C> (this can be used in automatized tests).
##  In even more serious cases of errors the message starts with <C>#E </C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# Info class with default level 1
BindGlobal("InfoGAPDoc", NewInfoClass("InfoGAPDoc"));
SetInfoLevel(InfoGAPDoc, 1);
SetInfoHandler(InfoGAPDoc, PlainInfoHandler);

DeclareGlobalVariable("GAPDocTexts");
DeclareGlobalFunction("SetGapDocLanguage");
