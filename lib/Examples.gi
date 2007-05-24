#############################################################################
##
#W  Examples.gi                  GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: Examples.gi,v 1.2 2007-05-24 16:06:36 gap Exp $
##
#Y  Copyright (C)  2007,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files Examples.g{d,i} contain functions for extracting and checking
##  GAP examples in GAPDoc manuals.
##  

# Extract examples units-wise from a GAPDoc document as XML tree, 
# 'units' can either be: "Chapter" or "Section" or "Subsection" or "Single"
#     then a list of strings is returned
# For all other values of 'units' one string with all examples is returned.
# Before each extracted example there is its paragraph number in a comment:
#  [ chapter, section, subsection, paragraph ]

InstallGlobalFunction(ManualExamplesXMLTree, function( tree, units )
  local secelts, sec, exelts, res, str, a, ex;
  if units = "Chapter" then
    secelts := ["Chapter", "Appendix"];
  elif units = "Section" then
    secelts := ["Section"];
  elif units = "Subsection" then
    secelts := ["Subsection", "ManSection"];
  elif units = "Single" then
    secelts := ["Example"];
  else
    secelts := 0;
  fi;
  if secelts <> 0 then
    sec := XMLElements(tree, secelts);
  else
    sec := [tree];
  fi;
  # want to put section numbers in comments
  AddParagraphNumbersGapDocTree(tree);
  exelts := List(sec, a-> XMLElements(a, ["Example"]));
  res := [];
  for a in exelts do
    str := "";
    for ex in a do
      Append(str, "# from paragraph ");
      if IsBound(ex.count) then
        Append(str, String(ex.count));
      else
        Append(str, "in Ignore?");
      fi;
      if IsBound(tree.inputorigins) then
        Append(str, String(OriginalPositionDocument(
                                           tree.inputorigins, ex.start)));
      fi;
      Append(str, "\n");
      Append(str, GetTextXMLTree(ex));
      Append(str, "\n");
    od;
    Add(res, str);
  od;
  if secelts = 0 then
    res := res[1];
  fi;
  return res;
end);

# compose and parse document, then extract examples units-wise
InstallGlobalFunction(ManualExamples, function( path, main, files, units )
  local str, xmltree;
  str:= ComposedDocument( "GAPDoc", path, main, files, true );
  xmltree:= ParseTreeXMLString( str[1], str[2] );
  return ManualExamplesXMLTree(xmltree, units);
end);

# test a string with examples 
InstallGlobalFunction(TestExamplesString, function(str)
  local file;
  file := InputTextString(str);
  ReadTest(file);
  CloseStream(file);
end);

# args:  str, print
guck := function(arg)
  local l, s, z, inp, out, f, lout, pos, bad, i, n, diffs, str;
  str := arg[1];
  l := SplitString(str, "\n", "");
  s := "";
  for i in [1..Length(l)] do
    z := l[i];
    if Length(z) > 4 and z{[1..5]} = "gap> " or
       Length(z) > 1 and z{[1,2]} = "> " then
      Append(s, " #IPL");
      Append(s, String(i));
      Append(s, "--->");
      Append(s, z);
      Add(s, '\n');
    fi;
    Append(s, z);
    Add(s, '\n');
  od;
  inp := InputTextString(s);
  out := "";
  f := OutputTextString(out, false);
  PrintTo1(f, function()
    READ_TEST_STREAM(inp);
  end);
  if not IsClosedStream(inp) then
    CloseStream(inp);
  fi;
  if not IsClosedStream(f) then
    CloseStream(f);
  fi;
  lout := SplitString(out, "\n", "");
  pos := First([1..Length(lout)], i-> Length(lout[i]) > 0 and lout[i][1] = '+');
  if pos = fail then
    return true;
  fi;
  bad := [];
  while pos <> fail do
    i := pos-1;
    while Length(lout[i]) < 7 or lout[i]{[1..7]} <> "-  #IPL" do
      i := i-1;
    od;
    n := lout[i]{[8..Length(lout[i])]};
    n := Int(n{[1..Position(n, '-')-1]});
    diffs := "";
    while IsBound(lout[pos]) and 
           (Length(lout[pos]) < 7 or lout[pos]{[1..7]} <> "-  #IPL") do
      Append(diffs, lout[pos]);
      Add(diffs, '\n');
      pos := pos+1;
    od;
    Add(bad, rec(line := n, input := l[n], diff := diffs));
    pos := First([pos..Length(lout)], i-> Length(lout[i]) > 0 and
                  lout[i][1] = '+');
  od;
  if Length(arg) > 1 and arg[2] = true then
    for z in bad do
      Print("-----------  bad example --------\n",
            "line: ", z.line, "\ninput: ");
      PrintFormattedString(z.input);
      Print("\n");
      Print("differences:\n");
      PrintFormattedString(z.diff);
    od;
  fi;
  return bad;
end;

ggg := function(tree)
  local ex, bad, a, attedStrin;
  ex := ManualExamplesXMLTree(tree,"Single");
  bad := Filtered(ex, a-> guck(a) <> true);
  for a in bad do 
    Print("===========================\n");
    PrintFormattedString(a); 
    guck(a, true);
  od; 
end;

