#############################################################################
##
#A  init.g                  GAPDoc              Frank Lübeck / Max Neunhöffer
##
#H  @(#)$Id: init.g,v 1.8 2003-06-20 15:29:01 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck and Max Neunhöffer,  
#Y  Lehrstuhl D für Mathematik,  RWTH Aachen
##

# delete this after 4.4
DeclareAutoPackage("GAPDoc", "0.999", ReturnTrue);
DeclarePackageAutoDocumentation("GAPDoc", "doc", "GAPDoc", 
"Package for Preparing GAP Documentation");
DeclarePackageAutoDocumentation("GAPDoc", "example", "GAPDoc Example",
"Extensive Example for GAPDoc");


# change to ReadPackage(...)  after 4.4
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

