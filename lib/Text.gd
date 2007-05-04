#############################################################################
##
#W  Text.gd                      GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: Text.gd,v 1.4 2007-05-04 15:59:03 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The files Text.g{d,i}  contain some utilities for  dealing with text
##  strings.
##  

##  some character lists
DeclareGlobalVariable("WHITESPACE");
DeclareGlobalVariable("CAPITALLETTERS");
DeclareGlobalVariable("SMALLLETTERS");
DeclareGlobalVariable("LETTERS");
DeclareGlobalVariable("HEXDIGITS");
DeclareGlobalVariable("DIGITS");

##  record containing ANSI terminal text attributes
DeclareGlobalVariable("TextAttr");

##  some utility functions for strings
DeclareGlobalFunction("RepeatedString");
DeclareGlobalFunction("PositionMatchingDelimiter");
DeclareGlobalFunction("SubstitutionSublist");
DeclareGlobalFunction("NumberDigits");
DeclareGlobalFunction("DigitsNumber");
DeclareGlobalFunction("Base64String");
DeclareGlobalFunction("StringBase64");
DeclareGlobalFunction("StripBeginEnd");
DeclareGlobalFunction("FormatParagraph");
DeclareGlobalFunction("StripEscapeSequences");
DeclareGlobalFunction("SubstituteEscapeSequences");
DeclareGlobalFunction("WordsString");
DeclareGlobalFunction("CrcText");
