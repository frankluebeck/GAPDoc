#############################################################################
##
#A  init.g                  GAPDoc              Frank Lübeck / Max Neunhöffer
##
#H  @(#)$Id: init.g,v 1.5 2001-11-28 15:07:04 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck and Max Neunhöffer,  
#Y  Lehrstuhl D für Mathematik,  RWTH Aachen
##

DeclareAutoPackage("GAPDoc", "0.99", ReturnTrue);
DeclarePackageAutoDocumentation("GAPDoc", "doc", "GAPDoc", 
"Package for Preparing GAP Documentation");
DeclarePackageAutoDocumentation("GAPDoc", "example", "GAPDoc Example",
"Extensive Example for GAPDoc");

#DeclarePackage("gapdoc", "0.9", ReturnTrue);
#DeclarePackageDocumentation("gapdoc", "doc");

ReadPkg("GAPDoc", "banner.g");

ReadPkg("GAPDoc", "lib/PrintUtil.gd");
ReadPkg("GAPDoc", "lib/Text.gd");
ReadPkg("GAPDoc", "lib/ComposeXML.gd");
ReadPkg("GAPDoc", "lib/XMLParser.gd");
ReadPkg("GAPDoc", "lib/GAPDoc.gd");
ReadPkg("GAPDoc", "lib/BibTeX.gd");
ReadPkg("GAPDoc", "lib/GAPDoc2LaTeX.gd");
ReadPkg("GAPDoc", "lib/GAPDoc2Text.gd");
ReadPkg("GAPDoc", "lib/GAPDoc2HTML.gd");

# The handler functions for GAP's help system are read now:
ReadPkg("GAPDoc", "lib/HelpBookHandler.g");

