#############################################################################
##  
##  PackageInfo.g for the package `GAPDoc'                       Frank Lübeck

##  With a new release of the package at least the entries .Version, .Date and
##  .ArchiveURL must be updated.

SetPackageInfo( rec(

CVSVERSION := "$Id: PackageInfo.g,v 1.4 2004-03-29 11:42:21 gap Exp $",

PackageName := "GAPDoc",
Subtitle := "A Meta Package for GAP Documentation",
Version := "0.9999",
Date := "29/03/2004",
ArchiveURL := 
          "http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/gapdoc-0.9999",
ArchiveFormats := ".tar.bz2",
Persons := [
  rec(
  LastName := "Lübeck",
  FirstNames := "Frank",
  IsAuthor := true,
  IsMaintainer := true,
  Email := "Frank.Luebeck@Math.RWTH-Aachen.De",
  WWWHome := "http://www.math.rwth-aachen.de:8001/~Frank.Luebeck",
  Place := "Aachen",
  Institution := "Lehrstuhl D für Mathematik, RWTH Aachen",
  PostalAddress := "Dr. Frank Lübeck\nLehrstuhl D für Mathematik\nRWTH Aachen\nTemplergraben 64\n52062 Aachen\nGERMANY\n"
  ),
  rec(
  LastName := "Neunhöffer",
  FirstNames := "Max",
  IsAuthor := true,
  IsMaintainer := true,
  Email := "Max.Neunhoeffer@Math.RWTH-Aachen.De",
  WWWHome := "http://www.math.rwth-aachen.de/~Max.Neunhoeffer",
  Place := "Aachen",
  Institution := "Lehrstuhl D für Mathematik, RWTH Aachen",
  PostalAddress := "Dr. Max Neunhöffer\nLehrstuhl D für Mathematik\nRWTH Aachen\nTemplergraben 64\n52062 Aachen\nGERMANY\n"
  )
],
Status := "deposited",

# CommunicatedBy := "Mike Atkinson (St. Andrews)",
#CommunicatedBy := "",
# AcceptDate := "08/1999",
#AcceptDate := "",
README_URL := 
"http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/README",
PackageInfoURL := 
"http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/PackageInfo.g",
AbstractHTML := "This package contains a definition of a structure for <span class='pkgname'>GAP</span> (package) documentation, based on XML. It also contains  conversion programs for producing text-, DVI-, PDF- or HTML-versions of such documents, with hyperlinks if possible.",
PackageWWWHome := "http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc",
PackageDoc := [rec(
  BookName := "GAPDoc",
#  Archive := "http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/gapdoc-doc-0r99.tar.bz2",
  ArchiveURLSubset := ["doc", "example"],
  HTMLStart := "doc/chap0.html",
  PDFFile := "doc/manual.pdf",
  SixFile := "doc/manual.six",
  LongTitle := "a meta package for GAP documentation",
  Autoload := true
  ),
  rec(
  BookName := "GAPDoc Example",
#  Archive := "http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/gapdoc-example-0r99.tar.bz2",
  ArchiveURLSubset := ["example", "doc"],
  HTMLStart := "example/chap0.html",
  PDFFile := "example/manual.pdf",
  SixFile := "example/manual.six",
  LongTitle := "example help book for GAPDoc",
  Autoload := false
  )],
Dependencies := rec(
  GAP := "4.3",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [],
  ExternalConditions := 
            [["(La)TeX installation for converting documents to PDF",
              "http://www.latex-project.org"]]
),
AvailabilityTest := ReturnTrue,
Autoload := true,
BannerString := Concatenation( 
"    ######################################################################\n",
"    ##                                                                  ##\n",
"    ##        GAPDoc ", ~.Version, " (a GAP documentation meta-package)          ##\n",
"    ##                                                                  ##\n",
"    ##   Questions and remarks to: Frank.Luebeck@Math.RWTH-Aachen.De    ##\n",
"    ##                             Max.Neunhoeffer@Math.RWTH-Aachen.De  ##\n",
"    ##                                                                  ##\n",
"    ######################################################################\n\n"
),
Keywords := ["GAP documentation", "help system", "XML", "pdf", "hyperlink"]
));


