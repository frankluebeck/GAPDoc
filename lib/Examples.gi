#############################################################################
##
#W  Examples.gi                  GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: Examples.gi,v 1.1 2007-03-05 16:51:11 gap Exp $
##
#Y  Copyright (C)  2007,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files Examples.g{d,i} contain functions for extracting and checking
##  GAP examples in GAPDoc manuals.
##  

# extract and collect text in elements recursively
InstallGlobalFunction(GetTextXMLTree, function(r)
  local res, fun;
  res := "";
  fun := function(r)
    if IsString(r.content) then
      Append(res, r.content);
    fi;
  end;
  ApplyToNodesParseTree(r, fun);
  return res;
end);

# return list of nodes of elements with name in 'eltnames' from XML tree r
InstallGlobalFunction(XMLElements, function(r, eltnames)
  local res, fun;
  res := [];
  fun := function(r)
    if r.name in eltnames then
      Add(res, r);
    fi;
  end;
  ApplyToNodesParseTree(r, fun);
  return res;
end);

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
      Append(str, String(ex.count));
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

