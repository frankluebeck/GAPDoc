
############  here we provide some text themes to display the text
############  versions of GAPDoc manuals 

GAPDoc2TextProcs.OtherThemes := rec();

# components must be pairs of strings, but as abbreviations we allow
# - a string a starting with TextAttr.CSI for [a, TextAttr.reset]
# - another string a for [a, a]
GAPDoc2TextProcs.OtherThemes.classic := rec(
  reset := TextAttr.reset,
  Heading := Concatenation(TextAttr.bold, TextAttr.underscore, TextAttr.1),
  Func := Concatenation(TextAttr.bold, TextAttr.4),
  Arg := Concatenation(TextAttr.normal, TextAttr.4),
  Example := Concatenation(TextAttr.normal, TextAttr.5),
  Package := TextAttr.bold,
  Returns := TextAttr.bold,
  URL := TextAttr.4,
  Mark := Concatenation(TextAttr.bold, TextAttr.3),
  K := Concatenation(TextAttr.normal, TextAttr.2),
  C := Concatenation(TextAttr.normal, TextAttr.2),
  F := Concatenation(TextAttr.bold, ""),
  B := Concatenation(TextAttr.bold, TextAttr.b6),
  Emph := Concatenation(TextAttr.normal, TextAttr.6),
  Ref := TextAttr.bold,
  BibReset := TextAttr.reset,
  BibAuthor := Concatenation(TextAttr.bold, TextAttr.1),
  BibTitle := TextAttr.4,
  BibJournal := ["",""],
  BibVolume := TextAttr.4,
  BibLabel := TextAttr.3,
  Q := ["\"","\""],
  M := ["",""],
  Math := ["$","$"],
  Display := ["$$","$$"],
  Prompt := Concatenation(TextAttr.bold,TextAttr.4),
  BrkPrompt := Concatenation(TextAttr.bold,TextAttr.1),
  GAPInput := TextAttr.1,
  GAPOutput := TextAttr.reset,
  DefLineMarker := "> ",
  # must be two visible characters long
  ListBullet := "--", 
  # must be together two visible characters long
  EnumMarks := ["(",")"],
  FillString := "------",
  format := "",
  flush := "both",
);

GAPDoc2TextProcs.OtherThemes.default := rec(
  reset := TextAttr.reset,
  Heading := Concatenation(TextAttr.bold, TextAttr.underscore),
  Func := Concatenation(TextAttr.normal, TextAttr.4),
  Arg := Concatenation(TextAttr.normal, TextAttr.2),
  Example := Concatenation(TextAttr.normal, TextAttr.0),
  Package := TextAttr.bold,
  Returns := TextAttr.normal,
  URL := TextAttr.6,
  Mark := Concatenation(TextAttr.bold, TextAttr.3),
  K := Concatenation(TextAttr.normal, TextAttr.1),
  C := Concatenation(TextAttr.normal, TextAttr.1),
  F := Concatenation(TextAttr.normal, TextAttr.6),
  B := ["<", ">"],
  Emph := Concatenation(TextAttr.bold, ""),
  Ref := TextAttr.6,
  BibReset := TextAttr.reset,
  BibAuthor := Concatenation(TextAttr.bold, TextAttr.1),
  BibTitle := TextAttr.4,
  BibJournal := ["",""],
  BibVolume := TextAttr.4,
  BibLabel := TextAttr.3,
  Q := ["\"","\""],
  M := ["",""],
  Math := ["$","$"],
  Display := ["$$","$$"],
  Prompt := Concatenation(TextAttr.bold,TextAttr.4),
  BrkPrompt := Concatenation(TextAttr.bold,TextAttr.1),
  GAPInput := TextAttr.1,
  GAPOutput := TextAttr.reset,
  DefLineMarker := "\342\200\243 ",
  # must be two visible characters long
  ListBullet := " \342\200\242",
  # must be together two visible characters long
  EnumMarks := ["(",")"],
  FillString := "\342\224\200\342\224\200\342\224\200",
  format := "",
  flush := "both",
);

GAPDoc2TextProcs.OtherThemes.gap3 := rec(
  reset := "", 
  Heading := ["",""],
  Func := ["`","'"],
  Arg := ["<", ">"],
  Example := ["",""],
  Package := ["",""],
  Returns := ["",""],
  URL := ["<",">"],
  Mark := ["",""],
  K := ["`","'"],
  C := ["`","'"],
  F := ["`","'"],
  B := ["",""],
  Q := ["\"","\""],
  Emph := ["*","*"],
  Ref := ["\"","\""],
  BibReset := "",
  BibAuthor := ["",""],
  BibTitle := ["",""],
  BibJournal := ["",""],
  BibVolume := ["",""],
  BibLabel := ["",""],
  M := ["$", "$"],
  Math := ["$", "$"],
  Display := ["$$","$$"],
  Prompt := "",
  BrkPrompt := "",
  GAPInput := "",
  GAPOutput := "",
  DefLineMarker := "> ",
  # must be two visible characters long
  ListBullet := " -",
  # must be together two visible characters long
  EnumMarks := ["(",")"],
  FillString := "---",
  format := "",
  flush := "both"
);



GAPDoc2TextProcs.OtherThemes.none := rec();
GAPDoc2TextProcs.f := function()
  local dt, a;
  dt := GAPDoc2TextProcs.OtherThemes.default;
  # most empty, some copied from default
  for a in RecFields(dt) do
    GAPDoc2TextProcs.OtherThemes.none.(a) := "";
  od;
  for a in ["Q", "DefLineMarker", "ListBullet", "FillString", "EnumMarks"] do
    GAPDoc2TextProcs.OtherThemes.none.(a) := dt.(a);
  od;
end;
GAPDoc2TextProcs.f();
Unbind(GAPDoc2TextProcs.f);

InstallValue(GAPDocTextTheme, rec());

# argument doesn't need all component, the missing ones are taken from default
InstallGlobalFunction(SetGAPDocTextTheme, function(arg)
  local r, len, res, h, af, v, i, f;
  
  if Length(arg) = 0 then
    r := rec();
  else
    r := arg[1];
  fi;
  if IsString(r) then
    if not IsBound(GAPDoc2TextProcs.OtherThemes.(r)) then
      Print("Only the following named text themes are available:\n     ",
            RecFields(GAPDoc2TextProcs.OtherThemes), "\n");
      return;
    else
      r := GAPDoc2TextProcs.OtherThemes.(r);
    fi;
  fi;
  len := function(s) return WidthUTF8String(StripEscapeSequences(s)); end;
  # normalize ListBullet and EnumMarks
  if IsBound(r.ListBullet) then
    if not IsString(r.ListBullet) then
      r.ListBullet := r.ListBullet[1];
    fi;
    while len(r.ListBullet) < 2 do
      Add(r.ListBullet, ' ');
    od;
    if len(r.ListBullet) > 2 then
      r.ListBullet := r.ListBullet{[1..2]};
    fi;
  fi;
  if IsBound(r.EnumMarks) then
    if IsString(r.EnumMarks) then
      r.EnumMarks := [r.EnumMarks, r.EnumMarks];
    fi;
    if Sum(r.EnumMarks, len) > 2 then
      if len(r.EnumMarks[1]) = 0 then
        r.EnumMarks[2] := r.EnumMarks[2]{[1,2]};
      elif len(r.EnumMarks[2]) = 0 then
        r.EnumMarks[1] := r.EnumMarks[1]{[1,2]};
      else
        r.EnumMarks[1] := r.EnumMarks[1]{[1]};
        r.EnumMarks[2] := r.EnumMarks[2]{[1]};
      fi;
    fi;
    while Sum(r.EnumMarks, len) < 2 do
      Add(r.EnumMarks[2], ' ');
    od;
  fi;

  res := rec(hash := [[], []]);
  h := res.hash;
  af := GAPDoc2TextProcs.TextAttrFields;
  for i in [1..Length(af)] do
    if IsBound(r.(af[i])) then
      v := r.(af[i]);
    else
      v := GAPDoc2TextProcs.OtherThemes.default.(af[i]);
    fi;
    if IsString(v) then
      Add(h[1], Concatenation(String(i-1), "X"));
      Add(h[2], v);
      Add(h[1], Concatenation(String(100+i-1), "X"));
      if Length(v) > 1 and v{[1,2]} = TextAttr.CSI then
        Add(h[2], TextAttr.reset);
      else
        Add(h[2], v);
      fi;
    else
      Add(h[1], Concatenation(String(i-1), "X"));
      Add(h[2], v[1]);
      Add(h[1], Concatenation(String(100+i-1), "X"));
      Add(h[2], v[2]);
    fi;
    res.(af[i]) := [[h[1][2*i-1], h[1][2*i]],[h[2][2*i-1], h[2][2*i]]];
  od;
  SortParallel(h[1], h[2]);
  for f in RecFields(res) do
    GAPDocTextTheme.(f) := res.(f);
  od;
end);
SetGAPDocTextTheme(rec());

