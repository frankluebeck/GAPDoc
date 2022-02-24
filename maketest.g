#############################################################################
##
#A  makedocrel.g                          GAPDoc                 Frank Lübeck
##  
##  
##  Rebuild the  whole documentation, provided sufficiently  good (pdf)LaTeX
##  is  available.   This  version  produces  relative   paths  to  external
##  documents, which is ok for the package in standard location.
##  
##  (code borrowed from Browse package)
##  
withLog := false;
pkgname := "GAPDoc";
pathtotst := "tst";
tstfilename := "test.tst";
authors := [ "Frank Lübeck" ];
copyrightyear := "2022";
tstheadertext := Concatenation( "\
This file contains the GAP code of the examples in the package\n\
documentation files.\n\
\n\
In order to run the tests, one starts GAP from the `tst' subdirectory\n\
of the `pkg/", pkgname, "' directory, and calls `Test( \"", tstfilename,
"\" );'.\n" );
main := "gapdoc.xml";
docdir := "doc";
mainfiles :=  ["../lib/BibTeX.gi", 
"../lib/BibTeX.gd", "../lib/BibXMLextTools.gi", "../lib/UnicodeTools.gi", 
"../lib/ComposeXML.gi", "../lib/GAPDoc2HTML.gi", "../lib/GAPDoc.gd",
"../lib/GAPDoc.gi", "../lib/GAPDoc2LaTeX.gi", "../lib/GAPDoc2Text.gi", 
"../lib/PrintUtil.gi", "../lib/Text.gi", "../lib/XMLParser.gi", 
"../lib/Examples.gi", "../lib/TextThemes.g", "../lib/HelpBookHandler.g",
"../lib/XMLParser.gd", "../lib/Make.g" ];

ExampleFileHeader:= function( filename, pkgname, authors, copyrightyear,
                              text, linelen )
    local free1, free2, str, i;

    free1:= Int( ( linelen - Length( pkgname ) - 14 ) / 2 );
    free2:= linelen - free1 - 14 - Length( pkgname ) - Length( authors[1] );

    str:= RepeatedString( "#", linelen );
    Append( str, "\n##\n#W  " );
    Append( str, filename );
    Append( str, RepeatedString( " ", free1 - Length( filename ) - 4 ) );
    Append( str, "GAP 4 package " );
    Append( str, pkgname );
    Append( str, RepeatedString( " ", free2 ) );
    Append( str, authors[1] );
    for i in [ 2 .. Length( authors ) ] do
      Append( str, "\n#W" );
      Append( str, RepeatedString( " ", linelen - Length( authors[i] ) - 2 ) );
      Append( str, authors[i] );
    od;
    Append( str, "\n##\n#Y  Copyright (C) " );
    Append( str, String( copyrightyear ) );
    Append( str, ",  Lehrstuhl f. Alg. u. Zahlenth., RWTH Aachen, Germany" );
    Append( str, "\n##\n##  " );
    Append( str, ReplacedString( text, "\n", "\n##  " ) );

    Append( str, "\ngap> LoadPackage( \"" );
    Append( str, pkgname );
    Append( str, "\", false );\ntrue" );
    Append( str, "\ngap> save:= SizeScreen();;" );
    Append( str, "\ngap> SizeScreen( [ 72 ] );;" );
    Append( str, "\ngap> START_TEST( \"Input file: " );
    Append( str, filename );
    Append( str, "\" );\n" );

    return str;
end;

ExampleFileFooter:= function( filename, linelen )
    local str;
    
    str := "gap> Exec( \"rm -f nonsense nicer.bib test.xml\");;\n";
    Append( str, "\n##\ngap> STOP_TEST( \"");
    Append( str, filename );
    Append( str, "\", 10000000 );\n" );
    Append( str, "gap> SizeScreen( save );;\n\n" );
    Append( str, RepeatedString( "#", linelen ) );
    Append( str, "\n##\n#E\n" );

    return str;
end;


# create the test file with manual examples
# (for a package: combined for all chapters)
CreateManualExamplesFile:= function( pkgname, authors, copyrightyear, text,
                                     path, main, files, tstpath, tstfilename )
    local linelen, str, r, l, tstfilenameold;

    linelen:= 77;
    str:= "# This file was created automatically, do not edit!\n";
    Append( str, ExampleFileHeader( tstfilename, pkgname, authors,
                                    copyrightyear, text, linelen ) );
    Append( str, "\n##\ngap> oldinterval:= BrowseData.defaults.dynamic.replayDefaults.replayInterval;;\ngap> BrowseData.defaults.dynamic.replayDefaults.replayInterval:= 1;;\n" );
    for r in ExtractExamples( path, main, files, "Chapter", withLog ) do
      for l in r do
        Append( str, Concatenation( "\n##  ", l[2][1],
                " (", String( l[2][2] ), "-", String( l[2][3] ), ")" ) );
        Append( str, l[1] );
      od;
    od;
    Append( str, "\n##\ngap> BrowseData.defaults.dynamic.replayDefaults.replayInterval:= oldinterval;;\n" );
    Append( str, ExampleFileFooter( tstfilename, linelen ) );

    tstfilename:= Concatenation( tstpath, "/", tstfilename );
    tstfilenameold:= Concatenation( tstfilename, "~" );
    if IsExistingFile( tstfilename ) then
      Exec( Concatenation( "rm -f ", tstfilenameold ) );
      Exec( Concatenation( "mv ", tstfilename, " ", tstfilenameold ) );
    fi;
    FileString( tstfilename, str );
    if IsExistingFile( tstfilenameold ) then
      Print( "#I  differences in `", tstfilename, "':\n" );
      Exec( Concatenation( "diff ", tstfilenameold, " ", tstfilename ) );
    fi;
    Exec( Concatenation( "chmod 444 ", tstfilename ) );
end;


CreateManualExamplesFile( pkgname, authors, copyrightyear, tstheadertext,
                          docdir, main, mainfiles, pathtotst, tstfilename );

# And a version containing the <Log> elements:
#   this can only run successfully under various conditions, 
#   or test may need interaction,
#   or tests must compare modulo whitespace.
withLog := true;
tstfilename := "test_withLog.tst";
CreateManualExamplesFile( pkgname, authors, copyrightyear, tstheadertext,
                          docdir, main, mainfiles, pathtotst, tstfilename );

