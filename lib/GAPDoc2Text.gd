#############################################################################
##
#W  GAPDoc2Text.gd                 GAPDoc                        Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The  files GAPDoc2Text.g{d,i}  contain  a  conversion program  which
##  produces from a  GAPDoc XML-document a text version  for viewing the
##  document on screen (GAP online help).
##  

DeclareGlobalFunction("GAPDoc2Text");

DeclareGlobalFunction("GAPDoc2TextPrintTextFiles");

BindGlobal("GAPDocTextTheme", rec());
DeclareGlobalFunction("SetGAPDocTextTheme");


