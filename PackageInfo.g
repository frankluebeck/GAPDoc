#############################################################################
##  
##  PackageInfo.g for the package `GAPDoc'                       Frank Lübeck

##  With a new release of the package at least the entries .Version, .Date and
##  .ArchiveURL must be updated.

SetPackageInfo( rec(


PackageName := "GAPDoc",
Subtitle := "A Meta Package for GAP Documentation",
Version := "1.6.7",
##  DD/MM/YYYY format:
Date := "21/02/2024",
License := "GPL-2.0-or-later",
SourceRepository := rec(
    Type := "git",
    URL := "https://github.com/frankluebeck/GAPDoc"
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
ArchiveURL := 
          "https://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/GAPDoc-1.6.7",
ArchiveFormats := ".tar.bz2 .tar.gz -win.zip",
Persons := [
  rec(
  LastName := "Lübeck",
  FirstNames := "Frank",
  IsAuthor := true,
  IsMaintainer := true,
  Email := "Frank.Luebeck@Math.RWTH-Aachen.De",
  WWWHome := "https://www.math.rwth-aachen.de/~Frank.Luebeck",
  Place := "Aachen",
  Institution := "Lehrstuhl für Algebra und Zahlentheorie, RWTH Aachen",
  PostalAddress := "Dr. Frank Lübeck\nLehrstuhl für Algebra und Zahlentheorie\nRWTH Aachen\nPontdriesch 14/16\n52062 Aachen\nGERMANY\n"
  ),
  rec(
  LastName := "Neunhöffer",
  FirstNames := "Max",
  IsAuthor := true,
  IsMaintainer := false,
  #Email := "neunhoef at mcs.st-and.ac.uk",
  #WWWHome := "https://www.math.rwth-aachen.de/~Max.Neunhoeffer/",
  #Place := "St Andrews",
  #Institution := "School of Mathematics and Statistics, St Andrews",
  )
],
Status := "accepted",
CommunicatedBy := "Steve Linton (St Andrews)",
AcceptDate := "10/2006",
              
README_URL := 
"https://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/README.txt",
PackageInfoURL := 
"https://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/PackageInfo.g",
AbstractHTML := "This package contains a definition of a structure for <span class='pkgname'>GAP</span> (package) documentation, based on XML. It also contains  conversion programs for producing text-, PDF- or HTML-versions of such documents, with hyperlinks if possible.",
PackageWWWHome := "https://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc",
PackageDoc := [rec(
  BookName := "GAPDoc",
  ArchiveURLSubset := ["doc", "example"],
  HTMLStart := "doc/chap0.html",
  PDFFile := "doc/manual.pdf",
  SixFile := "doc/manual.six",
  LongTitle := "a meta package for GAP documentation",
  ),
  rec(
  BookName := "GAPDoc Example",
  ArchiveURLSubset := ["example", "doc"],
  HTMLStart := "example/chap0.html",
  PDFFile := "example/manual.pdf",
  SixFile := "example/manual.six",
  LongTitle := "example help book for GAPDoc",
  )],
Dependencies := rec(
  GAP := "4.11.0",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [["IO", ">= 4.7"]],
  ExternalConditions := 
            ["(La)TeX installation for converting documents to PDF",
              "BibTeX installation to produce unified labels for refs",
              "xmllint for optional XML validation" ]
),
AvailabilityTest := ReturnTrue,
TestFile := "tst/test.tst",
Keywords := ["GAP documentation", "help system", "XML", "pdf", "hyperlink",
            "unicode", "BibTeX", "BibXMLext"]
));

