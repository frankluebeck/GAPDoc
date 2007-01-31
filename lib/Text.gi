#############################################################################
##
#W  Text.gi                      GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: Text.gi,v 1.7 2007-01-31 13:45:10 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The files Text.g{d,i}  contain some utilities for  dealing with text
##  strings.
##  

##  
##  <#GAPDoc Label="CharsColls">
##  <ManSection>
##  <Var Name="WHITESPACE" />
##  <Var Name="CAPITALLETTERS" />
##  <Var Name="SMALLLETTERS" />
##  <Var Name="LETTERS" />
##  <Var Name="DIGITS" />
##  <Var Name="HEXDIGITS" />
##  <Description>
##  These variables contain sets of characters which are useful for
##  text processing. They are defined as follows.<P/>
##  <List >
##  <Mark>WHITESPACE</Mark>
##  <Item><C>" &bslash;n&bslash;t&bslash;r"</C></Item>
##  <Mark>CAPITALLETTERS</Mark><Item><C>"ABCDEFGHIJKLMNOPQRSTUVWXYZ"</C></Item>
##  <Mark>SMALLLETTERS</Mark><Item><C>"abcdefghijklmnopqrstuvwxyz"</C></Item>
##  <Mark>LETTERS</Mark>
##  <Item>concatenation of CAPITALLETTERS and SMALLLETTERS</Item>
##  <Mark>DIGITS</Mark><Item><C>"0123456789"</C></Item>
##  <Mark>HEXDIGITS</Mark><Item><C>"0123456789ABCDEFabcdef"</C></Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallValue(WHITESPACE, " \n\t\r");
InstallValue(CAPITALLETTERS, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
IsSet(CAPITALLETTERS);
InstallValue(SMALLLETTERS, "abcdefghijklmnopqrstuvwxyz");
IsSet(SMALLLETTERS);
InstallValue(LETTERS, Concatenation(CAPITALLETTERS, SMALLLETTERS));
IsSet(LETTERS);
InstallValue(DIGITS, "0123456789");
InstallValue(HEXDIGITS, "0123456789ABCDEFabcdef");


##  
##  <#GAPDoc Label="TextAttr">
##  <ManSection>
##  <Var Name="TextAttr" />
##  <Description>
##  The  record  <Ref Var="TextAttr"/>  contains  strings  which can  be
##  printed  to   change  the  terminal  attribute   for  the  following
##  characters. This  only works  with terminals which  understand basic
##  ANSI escape sequences.  Try the following example to see  if this is
##  the case for the terminal you are  using. It shows the effect of the
##  foreground and background color  attributes and of the <C>.bold</C>,
##  <C>.blink</C>, <C>.normal</C>, <C>.reverse</C> and<C>.underscore</C>
##  which can partly be mixed.
##  
##  <Listing Type="Example">
##  extra := ["CSI", "reset", "delline", "home"];;
##  for t in Difference(RecNames(TextAttr), extra) do
##    Print(TextAttr.(t), "TextAttr.", t, TextAttr.reset,"\n");
##  od;
##  </Listing>
##  
##  The suggested defaults for colors <C>0..7</C> are black, red, green,
##  brown, blue,  magenta, cyan,  white. But this  may be  different for
##  your terminal configuration.<P/>
##  
##  The  escape  sequence <C>.delline</C>  deletes  the  content of  the
##  current line and  <C>.home</C> moves the cursor to  the beginning of
##  the current line.
##  
##  <Listing Type="Example">
##  for i in [1..5] do 
##    Print(TextAttr.home, TextAttr.delline, String(i,-6), "\c"); 
##    Sleep(1); 
##  od;
##  </Listing>
##  
##  <Index>ANSI&uscore;COLORS</Index> 
##  Whenever  you  use  this  in   some  printing  routines  you  should
##  make  it optional.  Use  these attributes  only,  when the  variable
##  <C>ANSI&uscore;COLORS</C> has the value <K>true</K>.
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
##  
InstallValue(TextAttr, rec());
TextAttr.CSI := "\033[";
TextAttr.reset := Concatenation(TextAttr.CSI, "0m");
TextAttr.normal := Concatenation(TextAttr.CSI, "22m");
TextAttr.bold := Concatenation(TextAttr.CSI, "1m");
TextAttr.underscore := Concatenation(TextAttr.CSI, "4m");
TextAttr.blink := Concatenation(TextAttr.CSI, "5m");
TextAttr.reverse := Concatenation(TextAttr.CSI, "7m");
# foreground colors 0..7 (default: black, red, green, brown, blue, magenta,
# cyan, white
TextAttr.0 := Concatenation(TextAttr.CSI, "30m");
TextAttr.1 := Concatenation(TextAttr.CSI, "31m");
TextAttr.2 := Concatenation(TextAttr.CSI, "32m");
TextAttr.3 := Concatenation(TextAttr.CSI, "33m");
TextAttr.4 := Concatenation(TextAttr.CSI, "34m");
TextAttr.5 := Concatenation(TextAttr.CSI, "35m");
TextAttr.6 := Concatenation(TextAttr.CSI, "36m");
TextAttr.7 := Concatenation(TextAttr.CSI, "37m");
# background colors 0..7
TextAttr.b0 := Concatenation(TextAttr.CSI, "40m");
TextAttr.b1 := Concatenation(TextAttr.CSI, "41m");
TextAttr.b2 := Concatenation(TextAttr.CSI, "42m");
TextAttr.b3 := Concatenation(TextAttr.CSI, "43m");
TextAttr.b4 := Concatenation(TextAttr.CSI, "44m");
TextAttr.b5 := Concatenation(TextAttr.CSI, "45m");
TextAttr.b6 := Concatenation(TextAttr.CSI, "46m");
TextAttr.b7 := Concatenation(TextAttr.CSI, "47m");

TextAttr.delline := Concatenation(TextAttr.CSI, "2K");
TextAttr.home := Concatenation(TextAttr.CSI, "1G");



##  <#GAPDoc Label="RepeatedString">
##  <ManSection >
##  <Func Arg="c, len" Name="RepeatedString" />
##  <Description>
##  Here <A>c</A> must be either a  character or a string and <A>len</A>
##  is a non-negative number. Then <Ref Func="RepeatedString" /> returns
##  a string of length <A>len</A> consisting of copies of <A>c</A>.
##  <Example>
##  gap> RepeatedString('=',51);
##  "==================================================="
##  gap> RepeatedString("*=",51);
##  "*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*"
##  </Example>
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction(RepeatedString, function(c, len)
  local s;
  s := "";
  if IsChar(c) then
    while Length(s) < len do
      Add(s, c);
    od;
  elif IsString(c) then
    while Length(s) < len do
      Append(s, c);
    od;
    while Length(s) > len do
      Unbind(s[Length(s)]);
    od;
  else
    Error("First argument must be character or string");
  fi;
  return s;
end);

##  <#GAPDoc Label="PositionMatchingDelimiter">
##  <ManSection >
##  <Func Arg="str, delim, pos" Name="PositionMatchingDelimiter" />
##  <Returns>position as integer or <K>fail</K></Returns>
##  <Description>
##  Here <A>str</A> must  be a string and <A>delim</A>  a string with
##  two  different characters.  This function  searches the  smallest
##  position   <C>r</C>  of   the  character   <C><A>delim</A>[2]</C>
##  in   <A>str</A>   such  that   the   number   of  occurrences  of
##  <C><A>delim</A>[2]</C>    in    <A>str</A>   between    positions
##  <C><A>pos</A>+1</C>  and  <C>r</C> is  by  one  greater than  the
##  corresponding number of occurrences of <C><A>delim</A>[1]</C>.<P/>
##  
##  If such an <C>r</C> exists, it is returned. Otherwise <K>fail</K>
##  is returned.
##  
##  <Example>
##  gap> PositionMatchingDelimiter("{}x{ab{c}d}", "{}", 0);
##  fail
##  gap> PositionMatchingDelimiter("{}x{ab{c}d}", "{}", 1);
##  2
##  gap> PositionMatchingDelimiter("{}x{ab{c}d}", "{}", 6);
##  11
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallGlobalFunction(PositionMatchingDelimiter, function(str, delim, pos)
  local   b,  e,  p,  l,  level;

  b := delim[1];
  e := delim[2];
  
  p := pos+1;
  l := Length(str);
  level := 0;
  while true do
    if p > l then
      return fail;
    elif str[p] = b then
      level := level+1;
    elif str[p] = e then
      if level = 0 then 
        return p;
      else
        level := level-1;
      fi;
    fi;
    p := p+1;
  od;
end);

##  <#GAPDoc Label="SubstitutionSublist">
##  <ManSection >
##  <Func Arg="list, sublist, new[, flag]" Name="SubstitutionSublist" />
##  <Returns>the changed list</Returns>
##  <Description>
##  This function looks for (non-overlapping) occurrences of a sublist
##  <A>sublist</A> in a list <A>list</A> (compare <Ref BookName="ref"
##  Oper="PositionSublist"  />) and  returns a  list where  these are
##  substituted with the list <A>new</A>.<P/>
##  
##  The  optional argument  <A>flag</A>  can  either be  <C>"all"</C>
##  (this is the default if not given) or <C>"one"</C>. In the second
##  case only  the first occurrence of <A>sublist</A> is substituted.
##  <P/>
##  
##  If <A>sublist</A> does not  occur in <A>list</A> then <A>list</A>
##  itself is returned (and not a <C>ShallowCopy(list)</C>).
##  
##  <Example>
##  gap> SubstitutionSublist("xababx", "ab", "a");
##  "xaax"
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallGlobalFunction(SubstitutionSublist, function(arg)
  local   str,  substr,  lss,  subs,  all,  p,  s, off;
  str := arg[1];
  substr := arg[2];
  lss := Length(substr);
  subs := arg[3];
  if Length(arg)>3 then
    all := arg[4]="all";
  else
    all := true;
  fi;
  
  p := PositionSublist(str, substr);
  if p = fail then 
    # return original object in case of no substitution
    return str; 
  fi;
  s := str{[]};
  off := 1-lss;
  while p<>fail do
    Append(s, str{[off+lss..p-1]});
    Append(s, subs);
##      str := str{[p+lss..Length(str)]};
    off := p;
    if all then
      p := PositionSublist(str, substr, p+lss-1);
    else
      p := fail;
    fi;
    if p=fail then
      Append(s, str{[off+lss..Length(str)]});
    fi;
  od;
  return s;
end);
    

##  <#GAPDoc Label="NumberDigits">
##  <ManSection >
##  <Func Arg="str, base" Name="NumberDigits" />
##  <Returns>integer</Returns>
##  <Func Arg="n, base" Name="DigitsNumber" />
##  <Returns>string</Returns>
##  <Description>
##  The argument  <A>str</A> of  <Ref Func="NumberDigits" />  must be
##  a  string  consisting  only  of an  optional  leading  <C>'-'</C>
##  and characters  in  <C>0123456789abcdefABCDEF</C>,  describing an
##  integer  in  base <A>base</A>  with  <M>2  \leq <A>base</A>  \leq
##  16</M>. This function returns the corresponding integer.<P/>
##  
##  The function <Ref Func="DigitsNumber" /> does the reverse.
##  
##  <Example>
##  gap> NumberDigits("1A3F",16);
##  6719
##  gap> DigitsNumber(6719, 16);
##  "1A3F"
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(NumberDigits, function(str, base)
  local   res,  x,  nr, sign;
  res := 0;
  sign := 1;
  for x in str do
    nr := INT_CHAR(x) - 48;
    if nr = -3 then 
      # '-'
      sign := -sign;
    else
      if nr>48 then 
        nr := nr - 39;
      elif nr>15 then
        nr := nr - 7;
      fi;
      res := res*base + nr;
    fi;
  od;
  return sign*res;
end);

InstallGlobalFunction(DigitsNumber, function(n, base)
  local str, s;
  s := "";
  if n<0 then
    Add(s, '-');
    n := -n;
  fi;
  str := "";
  while n <> 0 do
    Add(str, HEXDIGITS[(n mod base) + 1]);
    n := QuoInt(n, base);
  od;
  return Concatenation(s, Reversed(str));
end);

 
##  <#GAPDoc Label="StripBeginEnd">
##  <ManSection >
##  <Func Arg="list, strip" Name="StripBeginEnd" />
##  <Returns>changed string</Returns>
##  <Description>
##  Here <A>list</A>  and <A>strip</A>  must be lists.  This function
##  returns the  sublist of list  which does not contain  the leading
##  and trailing  entries which are  entries of <A>strip</A>.  If the
##  result  is  equal  to  <A>list</A>  then  <A>list</A>  itself  is
##  returned.
##  
##  <Example>
##  gap> StripBeginEnd(" ,a, b,c,   ", ", ");
##  "a, b,c"
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(StripBeginEnd, function(str, chars)
  local   pb,  l,  pe;
  pb := 1;
  l := Length(str);
  while  pb <= l and str[pb] in chars do
    pb := pb + 1;
  od;
  pe := l;
  while pe > 0 and str[pe] in chars do
    pe := pe - 1;
  od;
  if pb > 1 or pe < l then
    return str{[pb..pe]};
  else
    return str;
  fi;
end);


##  <#GAPDoc Label="NormalizedWhitespace">
##  <ManSection >
##  <Func Arg="str" Name="NormalizedWhitespace" />
##  <Returns>new string with white space normalized</Returns>
##  <Description>
##  This  function  gets  a  string  <A>str</A>  and  returns  a  new
##  string  which  is a  copy  of  <A>str</A> with  normalized  white
##  space.  Note  that  the   library  function  <Ref  BookName="ref"
##  Func="NormalizeWhitespace"  />  works in place  and  changes  its
##  argument.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# moved into GAP library
##  InstallGlobalFunction(NormalizedWhitespace, function(str)
##    local   res;
##    res := ShallowCopy(str);
##    NormalizeWhitespace(res);
##    return res;
##  end);

##  <#GAPDoc Label="FormatParagraph">
##  <ManSection >
##  <Func Arg="str[, len[, flush[, attr]]]" Name="FormatParagraph" />
##  <Returns>the formatted paragraph as string</Returns>
##  <Description>
##  This function formats a text given  in the string <A>str</A> as a
##  paragraph. The optional arguments have the following meaning:
##  
##  <List >
##  <Mark><A>len</A></Mark>
##  <Item>the length of  the lines of the resulting  text (default is
##  <C>78</C>)</Item>
##  <Mark><A>flush</A></Mark>
##  <Item>can  be <C>"left"</C>,  <C>"right"</C>, <C>"center"</C>  or
##  <C>"both"</C>, telling that lines should be flushed left, flushed
##  right, centered or left-right justified, respectively (default is
##  <C>"both"</C>)</Item>
##  <Mark><A>attr</A></Mark>
##  <Item>is a  list of two strings;  the first is prepended  and the
##  second  appended to  each line  of  the result  (can for  example
##  be  used  for  indenting,  <C>["  ",  ""]</C>,  or  some  markup,
##  <C>[TextAttr.bold,   TextAttr.reset]</C>,   default  is   <C>["",
##  ""]</C>)</Item>
##  </List>
##  
##  This function  tries to handle  markup with the  escape sequences
##  explained in <Ref Var="TextAttr"/> correctly.
##  
##  <Example>
##  gap> str := "One two three four five six seven eight nine ten eleven.";;
##  gap> Print(FormatParagraph(str, 25, "left", ["/* ", " */"]));           
##  /* One two three four five */
##  /* six seven eight nine ten */
##  /* eleven. */
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
BindGlobal("SPACESTRINGS", [" "]);
InstallGlobalFunction(FormatParagraph, function(arg)
  local   str,  len,  flush,  attr,  i,  words,  esc,  l,  j,  k,  lw,  
          lines,  s,  ss,  nsp,  res,  a,  new,  qr,  b;
  str := arg[1];
  # default line length
  len := 78;
  # default flush (flush left and right)
  flush := "both";
  # default attribute (empty)
  attr := false;
  # scan further arg's
  for i in [2..Length(arg)] do
    if IsInt(arg[i]) then
      len := arg[i];
    elif arg[i] in ["both", "left", "right", "center"] then
      flush := arg[i];
    elif IsList(arg[i]) then
      attr := arg[i];
    else
      Error("wrong argument", arg[i]);
    fi;
  od;
  for i in [Length(SPACESTRINGS)+1..len] do
    SPACESTRINGS[i] := Concatenation(SPACESTRINGS[i-1], " ");
  od;
  # we scan the string
  words := [];
  i := 1;
  esc := CHAR_INT(27);
  l := Length(str);
  while i<=l do
    if str[i] in WHITESPACE then
      # delete leading whitespace
      if Length(words)>0 then
        Add(words, 1);
      fi;
      i := i+1;
      while i<=l and str[i] in WHITESPACE do
        i := i+1;
      od;
    elif str[i] = esc then
      # sequences starting with ESC and stopping with the first letter
      # afterwards are not changed and considered to have length zero
      j := i+1;
      while j<=l and not str[j] in SMALLLETTERS and not str[j] in
        CAPITALLETTERS do
        j := j+1;
      od;
      if j>l then
        Error("string end inside escape sequence");
      else
        Add(words, [0, [i..j]]);
      fi;
      i := j+1;
    else
      j := i+1;
      while j<=l and not (str[j] in WHITESPACE or str[j]=esc) do
        j := j+1;
      od;
      if ForAll([i..j-1], k-> IsChar(str[k])) then
        Add(words, [NrCharsUTF8String(str{[i..j-1]}), [i..j-1]]);
      else
        Add(words, [j-i, [i..j-1]]);
      fi;
      i := j;
    fi;
  od;
  # remove trailing white space
  lw := Length(words);
  if lw>0 and IsInt(words[lw]) then
    Unbind(words[lw]);
  fi;
  
  # split into lines
  lines := [];
  i := 1;
  lw := Length(words);
  while i <= lw do
    s := words[i][1];
    j := i+1;
    nsp := 0;
    while j <= lw and s+nsp < len do
      if IsInt(words[j]) then
        nsp := nsp+1;
        j := j+1;
      else
        # line breaks only at white space
        ss := s+nsp;
        k := j;
        while k <= lw and IsList(words[k]) do
          ss := ss+words[k][1];
          k := k+1;
        od;
        if s=0 or ss <= len then
          s := ss-nsp;
          j := k;
        else
          break;
        fi;
      fi;
    od;
    if IsInt(words[j-1]) then
      Add(lines, [s,nsp-1,[i..j-2]]);
      i := j;
    else
      Add(lines, [s,nsp,[i..j-1]]);
      i := j+1;
    fi;
  od;
  
  # format lines
  res := "";
  for i in [1..Length(lines)] do
    a := lines[i];
    new := words{a[3]};
    # now fill with spaces
    nsp := len - a[1] - a[2];
    if nsp > 0 then
      if flush = "right" then
        new := Concatenation([nsp], new);
      elif flush = "both" and a[2] > 0 and i < Length(lines) then
        qr := QuotientRemainder(nsp, a[2]);
        for j in [1..Length(new)] do
          if IsInt(new[j]) then
            if qr[2]>0 then
              new[j] := new[j]+qr[1]+1;
              qr[2] := qr[2]-1;
            else
              new[j] := new[j]+qr[1];
            fi;
          fi;
        od;
      elif flush = "center" and nsp > 1 then
        new := Concatenation([QuoInt(nsp,2)], new);
      fi;
    fi;
    # add text attribute begin
    if attr <> false and Length(new)>0 then
      if IsInt(new[1]) then
        new := Concatenation([new[1]], [attr[1]], new{[2..Length(new)]});
      else
        Append(res, attr[1]);
      fi;
    fi;
    s := "";
    for b in new do
      if IsInt(b) then
        Append(s, SPACESTRINGS[b]);
      elif IsString(b) then
        Append(s, b);
      else # range
        Append(s, str{b[2]});
      fi;
    od;
    # add text attribute begin after each text attribute reset (if it
    # is an escape sequence) 
    # and the end attribute
    if attr <> false then
      if Length(attr[1])>2 and attr[1]{[1,2]} = TextAttr.CSI then
        s := SubstitutionSublist(s, TextAttr.reset, attr[1]);
      fi;
      Append(s, attr[2]);
    fi;
    Add(s, '\n');
    Append(res, s);
  od;
  return res;
end);

##  <#GAPDoc Label="StripEscapeSequences">
##  <ManSection >
##  <Func Arg="str" Name="StripEscapeSequences" />
##  <Returns>string without escape sequences</Returns>
##  <Description>
##  This  function  returns  the  string one  gets  from  the  string
##  <A>str</A> by  removing all escape sequences  which are explained
##  in <Ref Var="TextAttr"/>.  If <A>str</A> does not  contain such a
##  sequence then <A>str</A> itself is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(StripEscapeSequences, function(str)
  local   esc,  res,  i,  ls,  p;
  esc := CHAR_INT(27);
  res := "";
  i := 1;
  ls := Length(str);
  while i <= ls do
    if str[i] = esc then
      i := i+1;
      while not str[i] in LETTERS do
        i := i+1;
      od;
      # first letter is last character of escape sequence
      i := i+1; 
    else
      p := Position(str, esc, i);
      if p=fail then
        if i=1 then
          # don't copy if no escape there
          return str;
        else
          Append(res, str{[i..ls]});
          return res;
        fi;
      else
        Append(res, str{[i..p-1]});
        i := p;
      fi;
    fi;
  od;
  return res;
end);

##  <#GAPDoc Label="WordsString">
##  <ManSection >
##  <Func Arg="str" Name="WordsString" />
##  <Returns>list of strings containing the words</Returns>
##  <Description>
##  This returns  the list of  words of a  text stored in  the string
##  <A>str</A>. All non-letters are considered as word boundaries and
##  are removed.
##  <Example>
##  gap> WordsString("one_two \n    three!?");
##  [ "one", "two", "three" ]
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(WordsString, function(str)
  local   nonletters, wds;
  nonletters := Set("0123456789 \n\r\t\b+*~^\\\"#'`'/?-_.:,;<>|=()[]{}&%$§!");
  wds := SplitString(str, "", nonletters);
  return wds;
end);


