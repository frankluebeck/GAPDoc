#############################################################################
##
#A  init.g                  GAPDoc              Frank Lübeck / Max Neunhöffer
##
#H  @(#)$Id: init.g,v 1.2 2001-06-11 08:04:27 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck and Max Neunhöffer,  
#Y  Lehrstuhl D für Mathematik,  RWTH Aachen
##

DeclareAutoPackage("gapdoc", "0.9", ReturnTrue);
DeclarePackageAutoDocumentation("GAPDoc", "doc", "GAPDoc", 
"Package for Preparing GAP Documentation");
DeclarePackageAutoDocumentation("GAPDoc", "example", "GAPDoc Example",
"Extensive Example for GAPDoc");

#DeclarePackage("gapdoc", "0.9", ReturnTrue);
#DeclarePackageDocumentation("gapdoc", "doc");

if not "gapdoc" in AUTOLOAD_PACKAGES then
  ReadPkg("gapdoc", "banner.g");
fi;

ReadPkg("gapdoc", "lib/PrintUtil.gd");
ReadPkg("gapdoc", "lib/Text.gd");
ReadPkg("gapdoc", "lib/ComposeXML.gd");
ReadPkg("gapdoc", "lib/XMLParser.gd");
ReadPkg("gapdoc", "lib/GAPDoc.gd");
ReadPkg("gapdoc", "lib/BibTeX.gd");
ReadPkg("gapdoc", "lib/GAPDoc2LaTeX.gd");
ReadPkg("gapdoc", "lib/GAPDoc2Text.gd");
ReadPkg("gapdoc", "lib/GAPDoc2HTML.gd");

# The handler functions for GAP's help system are read now:
ReadPkg("gapdoc", "lib/HelpBookHandler.g");

