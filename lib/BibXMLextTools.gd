#############################################################################
##
#W  BibXMLextTools.gd             GAPDoc                         Frank Lübeck
##
#H  @(#)$Id: BibXMLextTools.gd,v 1.2 2007-04-23 23:57:55 gap Exp $
##
#Y  Copyright (C)  2006,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files BibXMLextTools.g{d,i} contain utility functions for dealing
##  with bibliography data in the BibXMLext format. The corresponding DTD
##  is in ../bibxmlext.dtd. 
##  

# these are utilities to help to translate BibTeX entries to BibXMLext entries
DeclareGlobalFunction("StringBibAsXMLext");
DeclareGlobalFunction("WriteBibXMLextFile");


# translate <entry> elements as parsed XML trees to records for various
# purposes
BindGlobal("BIBXMLHANDLER", rec());
DeclareGlobalFunction("BibRecBibXML");

