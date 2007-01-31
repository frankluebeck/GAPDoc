
# for some recode information and functions for the ISO-8859 character sets
BindGlobal("UNICODE_RECODE", rec());

##  declarations of unicode characters and strings as GAP objects
DeclareFilter("IsUnicodeString", IsString and IsHomogeneousList and
                                 IsConstantTimeAccessList);
DeclareFilter("IsUnicodeCharacter", IsInt and IsChar);
BindGlobal("UnicodeStringType", 
              NewType(NewFamily("dummy"), IsUnicodeString and IsMutable));
BindGlobal("UnicodeCharacterType", 
              NewType(NewFamily("dummy"), IsUnicodeCharacter));
BindGlobal("UNICODECHARCACHE", []);

DeclareOperation("UChar", [IsObject]);
DeclareOperation("UChar", [IsObject, IsObject]);

# create unicode strings, from lists of integers or GAP strings,
# optionally with encoding (default UTF-8)
DeclareOperation("U", [IsObject]);
DeclareOperation("U", [IsObject, IsObject]);
DeclareGlobalFunction("IntListUnicodeString");
UNICODE_RECODE.Decoder := rec();

######  Encoding #########
DeclareOperation("Encode", [IsUnicodeString]);
DeclareOperation("Encode", [IsUnicodeString, IsString]);
UNICODE_RECODE.Encoder := rec();

###### Utility for UTF-8 encoded GAP strings ########
DeclareGlobalFunction("NrCharsUTF8String");

