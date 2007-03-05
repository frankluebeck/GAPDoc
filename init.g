#############################################################################
##
#A  init.g                  GAPDoc              Frank Lübeck / Max Neunhöffer
##
#H  @(#)$Id: init.g,v 1.13 2007-03-05 16:51:11 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck and Max Neunhöffer,  
#Y  Lehrstuhl D für Mathematik,  RWTH Aachen
##

ReadPackage("GAPDoc", "lib/UnicodeTools.gd");
ReadPackage("GAPDoc", "lib/PrintUtil.gd");
ReadPackage("GAPDoc", "lib/Text.gd");
ReadPackage("GAPDoc", "lib/ComposeXML.gd");
ReadPackage("GAPDoc", "lib/XMLParser.gd");
ReadPackage("GAPDoc", "lib/GAPDoc.gd");
ReadPackage("GAPDoc", "lib/BibTeX.gd");
ReadPackage("GAPDoc", "lib/BibXMLextTools.gd");
ReadPackage("GAPDoc", "lib/GAPDoc2LaTeX.gd");
ReadPackage("GAPDoc", "lib/GAPDoc2Text.gd");
ReadPackage("GAPDoc", "lib/GAPDoc2HTML.gd");
ReadPackage("GAPDoc", "lib/Make.g");
ReadPackage("GAPDoc", "lib/Examples.gd");

# The handler functions for GAP's help system are read now:
ReadPackage("GAPDoc", "lib/HelpBookHandler.g");

