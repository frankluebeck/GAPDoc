#############################################################################
##
#W  PrintUtil.gd                 GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: PrintUtil.gd,v 1.1.1.1 2001-01-05 13:37:48 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The  files PrintUtil.gd and  PrintUtil.gi contain utilities  for printing
##  objects or large amounts of data.
##

##  a filter for a bit tricky objects
DeclareFilter("IsObjToBePrinted");
DeclareGlobalVariable("DUMMYTBPTYPE");

DeclareGlobalFunction("PrintTo1");
DeclareGlobalFunction("AppendTo1");

##  meta `String' function for objects without String-method
DeclareGlobalFunction("StringPrint");
DeclareGlobalFunction("StringView");

##  viewing "large" objects
DeclareGlobalFunction("PrintFormattedString");
DeclareGlobalFunction("Page");
DeclareGlobalFunction("PageDisplay");

##  fast copy of file into string and vice versa
DeclareGlobalFunction("StringFile");
DeclareGlobalFunction("FileString");

