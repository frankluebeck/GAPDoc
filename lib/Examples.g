
##  GAPDoc                                             Frank Lübeck
##  
##  $Id: Examples.g,v 1.1 2003-12-04 15:09:06 gap Exp $
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

