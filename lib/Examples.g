
##  GAPDoc                                             Frank Lübeck
##  
##  $Id: Examples.g,v 1.6 2007-02-20 16:56:27 gap Exp $
##  
##  Some utilities to extract contents of some elements. (First
##  experimental.)

CollectText := function(r)
  local res, a;
  if IsString(r.content) then
    return r.content;
  elif r.content = 0 then
    return "";
  fi;
  res := "";
  for a in r.content do
    if IsString(a) then
      Append(res, a);
    else
      Append(res, CollectText(a));
    fi;
  od;
  return res;
end;

GetTexts := function(r, eltnames, res)
  local t, a;
  if IsString(r.content) or r.content = 0 then
    return;
  fi;
  for a in r.content do
    if IsString(a) then
      continue;
    elif a.name in eltnames then
      t := CollectText(a);
      Append(res, "\n# next collected text (");
      Append(res, a.name);
      Append(res, ")\n");
      Append(res, t);
    else
      GetTexts(a, eltnames, res);
    fi;
  od;
end;

TstExamples := function(r)
  local res;
  res := "";
  GetTexts(r, ["Example"], res);
  return res;
end;

# From Marco
##  ReadPackage("GAPDoc","lib/Examples.g");
##  
##  TstExamples2 := function ( path, main, files )
##      local  str, r, examples, temp_dir, file, otf;
##  
##      str := ComposedDocument( "GAPDoc", path, 
##                                    Concatenation( main, ".xml" ), files );
##      r := ParseTreeXMLString( str );
##  
##  #Print(TstExamples( r ));
##  
##      examples := Concatenation( "gap> START_TEST( \"Test by GapDoc\" );\n",
##         TstExamples( r ),
##         "\ngap> STOP_TEST( \"test\", 10000 );\n",
##         "Test by GapDoc\nGAP4stones: fail\n" );
##  
##      temp_dir := DirectoryTemporary( "gapdoc" );
##      file := Filename( temp_dir, "testfile" );
##      otf := OutputTextFile( file, true );
##      SetPrintFormattingStatus( otf, false );
##      AppendTo( otf, examples );
##      CloseStream( otf );
##  
##      ReadTest( file );
##  
##      RemoveFile( file );
##      RemoveFile( temp_dir![1] );
##  end;
##  
##  # example:
##  
##  path := DirectoriesPackageLibrary("singular", "doc");
##  SizeScreen([80,]);
##  TstExamples2( path, "singular", [] );
##  

