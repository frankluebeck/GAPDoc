
GAPDoc  --- A GAP 4 package for preparing documentation of GAP programs
=======================================================================

                        Frank Lübeck
                       Max Neunhöffer
            (Lehrstuhl D für Mathematik, RWTH Aachen)              

This package provides:

  - Utilities to use the documentation (of GAP packages and in the future the
    GAP manuals as well) which is written in GAPDoc format with the GAP help
    system. If you don't want to write your own (package) documentation you can
    skip the remaining points.
  - The description of a markup language for GAP documentation (which is
    defined using the XML standard).
  - Three example documents using this language: The GAPDoc documentation
    itself, a short example which demonstrates all constructs defined in the
    GAPDoc language, and a very short example explained in the introduction of
    the main documentation.
  - A mechanism for distributing documentation among several files, including
    source code files.
  - GAP programs (written by the first named author) which produce from
    documentation written in the GAPDoc language several document formats:
      * text format with color markup for onscreen browsing.
      * LaTeX format and from this PDF- (and DVI)-versions with hyperlinks.
      * HTML (XHTML 1.0 strict) format for reading with a Web-browser (and many
        hooks for CSS layout).
  - Utility GAP programs which are used for the above but can be of independent
    interest as well:
      * unicode strings with translations to and from other encodings
      * further utilities for manipulating strings
      * tools for dealing with BibTeX data
      * another data format BibXMLext for bibliographical data including tools
        to manipulate/translate them
      * a tool ComposedDocument for composing documents which are distributed
        in many files


For further information see:
   <https://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc/>


INSTALLATION
------------

Just unpack one of the archives in the "pkg" subdirectory of your GAP 
installation. The archive is available in several formats:

  - `GAPDoc-XXX.tar.gz`  (GNU tar archive, gzip'ed)
  - `GAPDoc-XXX.tar.bz2` (GNU tar archive, bzip2'ed)
  - `GAPDoc-XXX-win.zip` (with DOS/Windows style line breaks in text files)

Unpacking generates a subdirectory of form `GAPDoc-x.y.z`. 

That's it! (Maybe you want to read the help section `?SetHelpViewer` 
in the GAP reference manual.)


Installation *outside the GAP main directory*: When you don't have access to
the directory of your main GAP installation you can also install the package
by unpacking inside a directory `MYGAPDIR/pkg`. (Don't forget to call `gap`
with the `-l ";MYGAPDIR"` option or to adjust your `gap` start script.) 

On UNIX/Linux you can put this package in the directory `~/.gap/pkg/` where
is will be found by the default start script.

The only drawback with this installation is  that in the HTML version of the
package  documentation the  links to  the main  GAP
manuals  don't  work.  You  can  correct  this  by  recompiling  the  GAPDoc
documentation: Say `cd GAPDoc*; gap makedocrel.g`.

For questions, suggestions, ... write to

   Frank.Luebeck@Math.RWTH-Aachen.De

or use the issue tracker (<https://github.com/frankluebeck/GAPDoc/issues>) of
the git-repository.


Frank Lübeck


