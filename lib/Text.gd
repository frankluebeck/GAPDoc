#############################################################################
##
#W  Text.gd                      GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: Text.gd,v 1.2 2001-06-06 14:39:17 gap Exp $
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
DeclareGlobalFunction("StripBeginEnd");
DeclareGlobalFunction("FormatParagraph");
DeclareGlobalFunction("StripEscapeSequences");
DeclareGlobalFunction("WordsString");
