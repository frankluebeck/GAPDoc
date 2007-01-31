#############################################################################
##
#W  ComposeXML.gi                GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: ComposeXML.gi,v 1.4 2007-01-31 13:45:10 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
## The files ComposeXML.gi/.gd contain a function which allows to construct
## a GAPDoc-XML document from several source files.
##  

##  <#GAPDoc Label="ComposedXMLString">
##  <ManSection >
##  <Func Arg="path, main, source[, info]" Name="ComposedXMLString" />
##  <Returns>XML document as string</Returns>
##  <Description>
##  This function returns a string  containing a &GAPDoc; XML document
##  constructed from  several source files  or a list  containing this
##  string and information about the source positions.<P/>
##  
##  Here  <A>path</A>   must  be  a   path  to  some   directory  (as
##  string  or directory  object),  <A>main</A> the  name  of a  file
##  in  this  directory  and  <A>source</A> a  list  of  file  names,
##  all   of  these   relative  to   <A>path</A>.  The   document  is
##  constructed  via  the  mechanism described  in  Section&nbsp;<Ref
##  Sect="DistrConv"/>.<P/>
##  
##  First  the   files  given   in  <A>source</A>  are   scanned  for
##  chunks of  &GAPDoc;-documentation marked  by <C>&tlt;&hash;GAPDoc
##  Label="..."></C> and  <C>&tlt;/&hash;GAPDoc></C> pairs.  Then the
##  file  <A>main</A>  is  read  and  all  <C>&tlt;&hash;Include  ...
##  ></C>-tags are  substituted recursively by other  files or chunks
##  of documentation found in the first step, respectively.
##  
##  If  the  optional  argument  <A>info</A>   is  given  and  set  to
##  <K>true</K>  this function  returns a  list <C>[str,  origin]</C>,
##  where <C>str</C> is a string  containing the composed document and
##  <C>origin</C> is  a sorted  list of entries  of the  form <C>[pos,
##  filename, line]</C>.  Here <C>pos</C>  runs through  all character
##  positions of starting lines or text pieces from different files in
##  <C>str</C>.  The  <C>filename</C>  and  <C>line</C>  describe  the
##  origin of this part of the collected document.
##  
##  Without the fourth argument only the string <C>str</C> is returned.
##  
##  <Log>
##  gap> doc := ComposedXMLString("/my/dir", "manual.xml", 
##  > ["../lib/func.gd", "../lib/func.gi"], true);;
##  </Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# reset this if not found files or chunks should not run into an error
XMLCOMPOSEERROR := true;
InstallGlobalFunction(ComposedXMLString, function(arg)
  local path, main, source, info,
        pieces, origin, fname, str, posnl, i, j, pre, pos, name, piece, 
        b, len, Collect, res, src, f, a;
  # get arguments, 4th arg is optional for compatibility with older versions
  path := arg[1];
  main := arg[2];
  source := arg[3];
  if Length(arg) > 3 and arg[4] = true then
    info := true;
  else
    info := false;
  fi;
  if IsString(path) then
    path := Directory(path);
  fi;
  # first we fetch GAPDoc chunks from the source files
  pieces := rec();
  origin := rec();
  for f in source do
    fname := Filename(path, f);
    str := StringFile(fname);
    posnl := Positions(str, '\n');
    # here and below we escape # as \# such that this function doesn't
    # interpret the error messages as a GAPDoc chunk
    i := PositionSublist(str, "<\#GAPDoc Label=\"");
    while i <> fail do
      j := i-1;
      while j > 0 and str[j] <> '\n' do
        j := j-1;
      od;
      pre := str{[j+1..i-1]};
      pos := Position(str, '\"', i+15);
      if pos=fail then
        Error(f, ": File ends within \#GAPDoc tag.");
      fi;     
      name := str{[i+16..pos-1]};
      i := Position(str, '\n', pos);
      if i=fail then
        Error(f, ": File ends within \#GAPDoc piece.");
      fi;
      pos := PositionSublist(str, "<\#/GAPDoc>", i);
      while str[pos-1] <> '\n' do
        pos := pos-1;
      od;
      if pos=fail then
        Error(f, ": File ends within \#GAPDoc piece.");
      fi;
      piece := SplitString(str{[i+1..pos-1]}, "\n", "");
      for a in [1..Length(piece)] do 
        b := 1;
        len := Minimum(Length(piece[a]), Length(pre));
        while b <= len and pre[b] = piece[a][b] do
          b := b+1;
        od;
        if b > 1 then
          piece[a] := piece[a]{[b..Length(piece[a])]};
        fi;
      od;
      for a in piece do 
        Add(a, '\n'); 
      od;
      pieces.(name) := Concatenation(piece);
      # for each found piece store the filename and number of the first
      # line of the piece in that file
      origin.(name) := [fname, PositionSorted(posnl, i+1)];
      i := PositionSublist(str, "<\#GAPDoc Label=\"", pos);
    od;
  od;

  # recursive substitution of files and chunks from above
  # In this helper [cont, from] is a pair [piece, orig] from above
  # or a pair [filename, 0].
  Collect := function(res, src, cont, from)
    local posnl, pos, i, len, new, p, j, piece, fname;
    # if piece is a whole file we simulate info as in 'pieces'
    if from = 0 then
      fname := cont;
      cont := StringFile(fname);
      if cont = fail and XMLCOMPOSEERROR = true then
        Error("Cannot include file ", cont, ".\n");
      elif cont = fail then
        cont := Concatenation("MISSING FILE ", cont, "\n");
        from := [cont, 1];
      else
        from := [fname, 1];
      fi;
    fi;
    posnl := Positions(cont, '\n');
    pos := 0;
    while pos <> fail do
      i := PositionSublist(cont, "<\#Include ", pos);
      if i = fail then
        # in this case add the rest to res
        i := Length(cont) + 1;
      fi;
      len := Length(res);
      new := cont{[pos+1..i-1]};
      Append(res, new);
      p := PositionSorted(posnl, pos+1) + from[2] - 1;
      # add entry to 'src' for first character from current piece
      Add(src, [len+1, from[1], p]);
      j := Position(new, '\n');
      while j <> fail and j < Length(new) do
        # further entries to 'src' for each new line in current piece
        Add(src, [len+j+1, from[1], p+1]);
        j := Position(new, '\n', j);
        p := p+1;
      od;
      # now include by recursive call of this function
      if i <= Length(cont) then
        pos := Position(cont, '>', i);
        if pos = fail then
          Error("Input ends within <\#Include ... tag.");
        fi;
        piece := SplitString(cont{[i+9..pos-1]}, "", "\"= ");
        if piece[1]="SYSTEM" then
          Collect(res, src, Filename(path, piece[2]), 0);
        elif piece[1]="Label" then 
          if not IsBound(pieces.(piece[2])) and XMLCOMPOSEERROR=true then
            Error("Did not find chunk ", piece[2]);
          elif not IsBound(pieces.(piece[2])) then
            pieces.(piece[2]) := Concatenation("MISSING CHUNK ", piece[2]);
            origin.(piece[2]) := [Concatenation("MISSINGCHUNK ",piece[2]),1]; 
          fi;
          Collect(res, src, pieces.(piece[2]), origin.(piece[2]));
        fi;
      else
        pos := fail;
      fi;
    od;
  end;
  res := "";
  src := [];
  # now start the recursion as #Include of the main file in empty string
  Collect(res, src, Filename(path, main), 0);
  if info then
    return [res, src];
  else
    # we allow this for compatibility with former versions
    return res;
  fi;
end);

##  <#GAPDoc Label="OriginalPositionComposedXML">
##  <ManSection >
##  <Func Arg="srcinfo, pos" Name="OriginalPositionComposedXML" />
##  <Returns>A pair <C>[filename, linenumber]</C>.</Returns>
##  <Description>
##  Here <A>srcinfo</A>  must   be  a   data  structure  as   returned  as
##  second   entry   by <Ref  Func="ComposedXMLString"  />   called   with
##  <A>info</A>=<K>true</K>. It returns for a given position <A>pos</A> in
##  the composed XML document the file name and line number from which that
##  text was collected.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallGlobalFunction(OriginalPositionComposedXML, function(srcinfo, pos)
  local r;
  r := PositionSorted(srcinfo, [pos]);
  if not IsBound(srcinfo[r]) or srcinfo[r][1] > pos then
    r := r-1;
  fi;
  return [srcinfo[r][2], srcinfo[r][3]];
end);
