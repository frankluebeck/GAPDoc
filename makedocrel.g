#############################################################################
##
#A  makedocrel.g                          GAPDoc                 Frank Lübeck
##  
#H  @(#)$Id: makedocrel.g,v 1.2 2001-11-16 16:49:21 gap Exp $
##  
##  Rebuild the  whole documentation, provided sufficiently  good (pdf)LaTeX
##  is  available.   This  version  produces  relative   paths  to  external
##  documents, which is ok for the package in standard location.
##  
# main
Print("\n========== converting main documentation for GAPDoc ==============\n");
MakeGAPDocDoc("doc", "gapdoc", ["../lib/BibTeX.gi", 
"../lib/ComposeXML.gi", "../lib/GAPDoc2HTML.gi",
"../lib/GAPDoc.gi", "../lib/GAPDoc2LaTeX.gi", "../lib/GAPDoc2Text.gi", 
"../lib/PrintUtil.gi", "../lib/Text.gi", "../lib/XMLParser.gi",
"../lib/Make.g" ], "GAPDoc", "../../..");

# now load it (for cross reference in example)
Print("\n========== converting example document for GAPDoc ================\n");
DeclarePackageDocumentation("GAPDoc", "doc", "GAPDoc", 
"Package for Preparing GAP Documentation");

# example
MakeGAPDocDoc("example", "example", [], "GAPDocExample", "../../..");

# from first chapter
Print("\n========== converting small example from introduction ============\n");
MakeGAPDocDoc("3k+1", "3k+1", [], "ThreeKPlusOne", "../../..");

