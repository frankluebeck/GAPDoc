#############################################################################
##  
##  PkgInfo file for the    GAPDoc    package.                  Frank Lübeck
##  

SetPackageInfo( rec(
PkgName := "GAPDoc",
Version := "0.99",
Date := "02/04/2002",
PkgInfoCVSRevision := "$Id: PkgInfo.g,v 1.1 2002-06-19 14:52:29 gap Exp $",
ArchiveURL := "http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/gapdoc-0r99",
ArchiveFormats := ".tar.bz2",
Persons := [
  rec(
  LastName := "Lübeck",
  FirstNames := "Frank",
  IsAuthor := true,
  IsMaintainer := true,
  Email := "Frank.Luebeck@Math.RWTH-Aachen.De",
  WWWHome := "http://www.math.rwth-aachen.de/~Frank.Luebeck",
  Place := "Aachen",
  Institution := "Lehrstuhl D für Mathematik, RWTH Aachen"
  ),
  rec(
  LastName := "Neunhöffer",
  FirstNames := "Max",
  IsAuthor := true,
  IsMaintainer := true,
  Email := "Max.Neunhoeffer@Math.RWTH-Aachen.De",
  WWWHome := "http://www.math.rwth-aachen.de/~Max.Neunhoeffer",
  Place := "Aachen",
  Institution := "Lehrstuhl D für Mathematik, RWTH Aachen"
  )
],
Status := "deposited",
#CommunicatedBy := "",
#AcceptDate := "",
README_URL := "http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/README",
PkgInfoURL := "http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/PkgInfo.g",
AbstractHTML := "This package contains a definition of a structure for <span class='pkgname'>GAP</span> (package) documentation, based on XML. It also contains  conversion programs for producing text-, DVI-, PDF- or HTML-versions of such documents.",
PackageWWWHome := "http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc",
PackageDoc := [rec(
  BookName := "GAPDoc",
  Archive := "http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/gapdoc-doc-0r99.tar.bz2",
  HTMLStart := "doc/chap0.html",
  PDFFile := "doc/manual.pdf",
  SixFile := "doc/manual.six",
  LongTitle := "a meta package for GAP documentation",
  AutoLoad := true
  ),
  rec(
  BookName := "GAPDoc Example",
  Archive := "http://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/gapdoc-example-0r99.tar.bz2",
  HTMLStart := "example/chap0.html",
  PDFFile := "example/manual.pdf",
  SixFile := "example/manual.six",
  LongTitle := "example help book for GAPDoc",
  AutoLoad := false
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
Autoload := false,
Keywords := ["GAP documentation", "help system", "XML"]
));


