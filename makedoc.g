#############################################################################
##
#A  makedoc.g                             GAPDoc                 Frank Lübeck
##  
#H  @(#)$Id: makedoc.g,v 1.1.1.1 2001-01-05 13:37:46 gap Exp $
##  
##  Rebuild the whole documentation, provided sufficiently good (pdf)LaTeX
##  is available. 
##  
# main
MakeGAPDocDoc("doc", "gapdoc", ["../lib/BibTeX.gi", 
"../lib/ComposeXML.gi", "../lib/GAPDoc2HTML.gi",
"../lib/GAPDoc.gi", "../lib/GAPDoc2LaTeX.gi", "../lib/GAPDoc2Text.gi", 
"../lib/PrintUtil.gi", "../lib/Text.gi", "../lib/XMLParser.gi",
"../lib/Make.g" ], "GAPDoc");

# now load it (for cross reference in example)
DeclarePackageDocumentation("gapdoc","doc");

# example
MakeGAPDocDoc("example", "example", [], "GAPDocExample");
# from first chapter
MakeGAPDocDoc("3k+1", "3k+1", [], "ThreeKPlusOne");

