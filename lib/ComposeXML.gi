#############################################################################
##
#W  ComposeXML.gi                GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: ComposeXML.gi,v 1.2 2001-01-17 15:31:20 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
## The files ComposeXML.gi/.gd contain a function which allows to construct
## a GAPDoc-XML document from several source files.
##  

##  <#GAPDoc Label="ComposedXMLString">
##  <ManSection >
##  <Func Arg="path, main, source" Name="ComposedXMLString" />
##  <Returns>XML document as string</Returns>
##  <Description>
##  This function returns a string containing a &GAPDoc; XML document
##  constructed from several source files.<P/>
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
##  <Log>
##  gap> doc := ComposedXMLString("/my/dir", "manual.xml", 
##  > ["../lib/func.gd", "../lib/func.gi"]);;
##  </Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(ComposedXMLString, function(path, main, source)
  local pieces, f, str, i, j, pre, pos, name, piece, a, b, len, res;  
  
  if IsString(path) then
    path := Directory(path);
  fi;
  # first we fetch GAPDoc chunks from the source files
  pieces := rec();
  for f in source do
    str := StringFile(Filename(path, f));
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
      i := PositionSublist(str, "<\#GAPDoc Label=\"", pos);
    od;
  od;

  # recursive subtitution of files and chunks from above
  res := StringFile(Filename(path, main));
  if res=fail then
    Error("Cannot open file ", Filename(path, main));
  fi;
  i := PositionSublist(res, "<\#Include ");
  while i <> fail do
    pos := Position(res, '>', i);
    piece := SplitString(res{[i+9..pos-1]}, "", "\"= ");
    if piece[1]="SYSTEM" then
      str := StringFile(Filename(path, piece[2]));
      if str=fail then
        Error("Cannot include file ", Filename(path, piece[2]));
      fi;
      res := Concatenation(res{[1..i-1]}, str, res{[pos+1..Length(res)]});
    elif piece[1]="Label" then 
      if not IsBound(pieces.(piece[2])) then
        Error("Did not find chunk ", piece[2]);
      fi;
      res := Concatenation(res{[1..i-1]}, pieces.(piece[2]), 
                                               res{[pos+1..Length(res)]});
    fi;
    i := i-1;
    i := PositionSublist(res, "<\#Include ", i);
  od; 
  
  return res;
end); 


