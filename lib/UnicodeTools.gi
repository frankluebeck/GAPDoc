# UNICODE_RECODE is a is a record. For some string enc, describing a
# character encoding, UNICODE_RECODE.(enc) is a function which translates
# a GAP string in encoding enc to a list of integers describing the unicode
# codepoints of the characters in the string.
#
# UNICODE_RECODE.TABLES contains some embeddings of 8 bit code pages into 
# unicode as lists of length 256, codepoint of character i in [0..255] in 
# position i+1.

# normalize encoding names
UNICODE_RECODE.NormalizedEncodings := rec(
  latin1 := "ISO-8859-1",
  latin2 := "ISO-8859-2",
  latin3 := "ISO-8859-3",
  latin4 := "ISO-8859-4",
  latin5 := "ISO-8859-9",
  latin6 := "ISO-8859-10",
  latin7 := "ISO-8859-13",
  latin8 := "ISO-8859-14",
  latin9 := "ISO-8859-15",
  latin0 := "ISO-8859-15",
  utf8 := "UTF-8",
  UTF8 := "UTF-8"
);
_tmpfunction := function()
  local nam, i;
  for i in Concatenation([1..11],[13..15]) do
    nam := Concatenation("ISO-8859-",String(i));
    UNICODE_RECODE.NormalizedEncodings.(nam) := nam;
    UNICODE_RECODE.Decoder.(nam) := function(str)
      return UNICODE_RECODE.TABLES.(nam){List(str, INT_CHAR)};
    end;
  od;
  UNICODE_RECODE.NormalizedEncodings.("UTF-8") := "UTF-8";
end;
_tmpfunction();
Unbind(_tmpfunction);
# slightly more efficient for latin1:
UNICODE_RECODE.Decoder.("ISO-8859-1") := function(str)
  return List(str, INT_CHAR);
end;
# helper function;  arg:  str[, start]
UNICODE_RECODE.UnicodeUTF8Char := function(arg)
  local str, i, a;
  str := arg[1];
  if Length(arg)>1 then
    i := arg[2];
  else
    i := 1;
  fi;
  a := INT_CHAR(str[i]);
  if a < 128 then
    return a;
  elif a < 224 then
    return (a mod 192)*64 + (INT_CHAR(str[i+1]) mod 64);
  elif a < 240 then
    return (a mod 224)*4096 + (INT_CHAR(str[i+1]) mod 64)*64
                            + (INT_CHAR(str[i+2]) mod 64);
  else
    return (a mod 240)*262144 + (INT_CHAR(str[i+1]) mod 64)*4096
                              + (INT_CHAR(str[i+2]) mod 64)*64
                              + (INT_CHAR(str[i+3]) mod 64);
  fi;
end;
UNICODE_RECODE.Decoder.("UTF-8") := function(str)
  local res, c, i;
  res := [];
  for i in [1..Length(str)] do
    c := INT_CHAR(str[i]);
    if c < 128 or c > 191 then
      Add(res, UNICODE_RECODE.UnicodeUTF8Char(str, i));
    fi;
  od;
  return res;
end;

################################################
UNICODE_RECODE.TABLES := 
rec(
  ISO\-8859\-1 := [ 0 .. 255 ],
  ISO\-8859\-2 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 260, 
      728, 321, 163, 317, 346, 166, 167, 352, 350, 356, 377, 172, 381, 379, 
      175, 261, 731, 322, 179, 318, 347, 711, 183, 353, 351, 357, 378, 733, 
      382, 380, 340, 192, 193, 258, 195, 313, 262, 198, 268, 200, 280, 202, 
      282, 204, 205, 270, 272, 323, 327, 210, 211, 336, 213, 214, 344, 366, 
      217, 368, 219, 220, 354, 222, 341, 224, 225, 259, 227, 314, 263, 230, 
      269, 232, 281, 234, 283, 236, 237, 271, 273, 324, 328, 242, 243, 337, 
      245, 246, 345, 367, 249, 369, 251, 252, 355, 729, 255 ],
  ISO\-8859\-3 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 294, 
      728, 162, 163, 164, 292, 166, 167, 304, 350, 286, 308, 172, 173, 379, 
      175, 295, 177, 178, 179, 180, 293, 182, 183, 305, 351, 287, 309, 188, 
      189, 380, 191, 192, 193, 194, 195, 266, 264, 198, 199, 200, 201, 202, 
      203, 204, 205, 206, 207, 208, 209, 210, 211, 288, 213, 214, 284, 216, 
      217, 218, 219, 364, 348, 222, 223, 224, 225, 226, 227, 267, 265, 230, 
      231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 289, 
      245, 246, 285, 248, 249, 250, 251, 365, 349, 729, 255 ],
  ISO\-8859\-4 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 260, 
      312, 342, 163, 296, 315, 166, 167, 352, 274, 290, 358, 172, 381, 174, 
      175, 261, 731, 343, 179, 297, 316, 711, 183, 353, 275, 291, 359, 330, 
      382, 331, 256, 192, 193, 194, 195, 196, 197, 302, 268, 200, 280, 202, 
      278, 204, 205, 298, 272, 325, 332, 310, 211, 212, 213, 214, 215, 370, 
      217, 218, 219, 360, 362, 222, 257, 224, 225, 226, 227, 228, 229, 303, 
      269, 232, 281, 234, 279, 236, 237, 299, 273, 326, 333, 311, 243, 244, 
      245, 246, 247, 371, 249, 250, 251, 361, 363, 729, 255 ],
  ISO\-8859\-5 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 1025, 
      1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 172, 
      1038, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 1046, 1047, 1048, 1049, 
      1050, 1051, 1052, 1053, 1054, 1055, 1056, 1057, 1058, 1059, 1060, 1061, 
      1062, 1063, 1064, 1065, 1066, 1067, 1068, 1069, 1070, 1071, 1072, 1073, 
      1074, 1075, 1076, 1077, 1078, 1079, 1080, 1081, 1082, 1083, 1084, 1085, 
      1086, 1087, 1088, 1089, 1090, 1091, 1092, 1093, 1094, 1095, 1096, 1097, 
      1098, 1099, 1100, 1101, 1102, 1103, 8470, 1105, 1106, 1107, 1108, 1109, 
      1110, 1111, 1112, 1113, 1114, 1115, 1116, 167, 1118, 1119, 255 ],
  ISO\-8859\-6 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 
      161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 1548, 172, 173, 174, 
      175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 1563, 187, 188, 
      189, 1567, 191, 1569, 1570, 1571, 1572, 1573, 1574, 1575, 1576, 1577, 
      1578, 1579, 1580, 1581, 1582, 1583, 1584, 1585, 1586, 1587, 1588, 1589, 
      1590, 1591, 1592, 1593, 1594, 218, 219, 220, 221, 222, 1600, 1601, 
      1602, 1603, 1604, 1605, 1606, 1607, 1608, 1609, 1610, 1611, 1612, 1613, 
      1614, 1615, 1616, 1617, 1618, 242, 243, 244, 245, 246, 247, 248, 249, 
      250, 251, 252, 253, 254, 255 ],
  ISO\-8859\-7 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 701, 
      700, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 8213, 
      175, 176, 177, 178, 900, 901, 902, 182, 904, 905, 906, 186, 908, 188, 
      910, 911, 912, 913, 914, 915, 916, 917, 918, 919, 920, 921, 922, 923, 
      924, 925, 926, 927, 928, 929, 209, 931, 932, 933, 934, 935, 936, 937, 
      938, 939, 940, 941, 942, 943, 944, 945, 946, 947, 948, 949, 950, 951, 
      952, 953, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964, 965, 
      966, 967, 968, 969, 970, 971, 972, 973, 974, 254, 255 ],
  ISO\-8859\-8 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 
      161, 162, 163, 164, 165, 166, 167, 168, 215, 170, 171, 172, 173, 8254, 
      175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 247, 186, 187, 188, 
      189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 
      203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 
      217, 218, 219, 220, 221, 8215, 1488, 1489, 1490, 1491, 1492, 1493, 
      1494, 1495, 1496, 1497, 1498, 1499, 1500, 1501, 1502, 1503, 1504, 1505, 
      1506, 1507, 1508, 1509, 1510, 1511, 1512, 1513, 1514, 250, 251, 252, 
      253, 254, 255 ],
  ISO\-8859\-9 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 
      161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 
      175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 
      189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 
      203, 204, 205, 206, 286, 208, 209, 210, 211, 212, 213, 214, 215, 216, 
      217, 218, 219, 304, 350, 222, 223, 224, 225, 226, 227, 228, 229, 230, 
      231, 232, 233, 234, 235, 236, 237, 238, 287, 240, 241, 242, 243, 244, 
      245, 246, 247, 248, 249, 250, 251, 305, 351, 254, 255 ],
  ISO\-8859\-10 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
      16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
      34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
      52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
      70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
      88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
      104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 
      118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 
      132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 
      146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 
      260, 274, 290, 298, 296, 310, 166, 315, 272, 352, 358, 381, 172, 362, 
      330, 175, 261, 275, 291, 299, 297, 311, 182, 316, 273, 353, 359, 382, 
      8213, 363, 331, 256, 192, 193, 194, 195, 196, 197, 302, 268, 200, 280, 
      202, 278, 204, 205, 206, 207, 325, 332, 210, 211, 212, 213, 360, 215, 
      370, 217, 218, 219, 220, 221, 222, 257, 224, 225, 226, 227, 228, 229, 
      303, 269, 232, 281, 234, 279, 236, 237, 238, 239, 326, 333, 242, 243, 
      244, 245, 361, 247, 371, 249, 250, 251, 252, 253, 312, 255 ],
  ISO\-8859\-11 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
      16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
      34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
      52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
      70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
      88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
      104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 
      118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 
      132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 
      146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 
      3585, 3586, 3587, 3588, 3589, 3590, 3591, 3592, 3593, 3594, 3595, 3596, 
      3597, 3598, 3599, 3600, 3601, 3602, 3603, 3604, 3605, 3606, 3607, 3608, 
      3609, 3610, 3611, 3612, 3613, 3614, 3615, 3616, 3617, 3618, 3619, 3620, 
      3621, 3622, 3623, 3624, 3625, 3626, 3627, 3628, 3629, 3630, 3631, 3632, 
      3633, 3634, 3635, 3636, 3637, 3638, 3639, 3640, 3641, 3642, 218, 219, 
      220, 221, 3647, 3648, 3649, 3650, 3651, 3652, 3653, 3654, 3655, 3656, 
      3657, 3658, 3659, 3660, 3661, 3662, 3663, 3664, 3665, 3666, 3667, 3668, 
      3669, 3670, 3671, 3672, 3673, 3674, 3675, 251, 252, 253, 254, 255 ],
  ISO\-8859\-13 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
      16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
      34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
      52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
      70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
      88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
      104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 
      118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 
      132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 
      146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 
      8221, 161, 162, 163, 8222, 165, 166, 216, 168, 342, 170, 171, 172, 173, 
      198, 175, 176, 177, 178, 8220, 180, 181, 182, 248, 184, 343, 186, 187, 
      188, 189, 230, 260, 302, 256, 262, 195, 196, 280, 274, 268, 200, 377, 
      278, 290, 310, 298, 315, 352, 323, 325, 210, 332, 212, 213, 214, 370, 
      321, 346, 362, 219, 379, 381, 222, 261, 303, 257, 263, 227, 228, 281, 
      275, 269, 232, 378, 279, 291, 311, 299, 316, 353, 324, 326, 242, 333, 
      244, 245, 246, 371, 322, 347, 363, 251, 380, 382, 8217, 255 ],
  ISO\-8859\-14 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
      16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
      34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
      52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
      70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
      88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
      104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 
      118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 
      132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 
      146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 
      7682, 7683, 162, 266, 267, 7690, 166, 7808, 168, 7810, 7691, 7922, 172, 
      173, 376, 7710, 7711, 288, 289, 7744, 7745, 181, 7766, 7809, 7767, 
      7811, 7776, 7923, 7812, 7813, 7777, 191, 192, 193, 194, 195, 196, 197, 
      198, 199, 200, 201, 202, 203, 204, 205, 206, 372, 208, 209, 210, 211, 
      212, 213, 7786, 215, 216, 217, 218, 219, 220, 374, 222, 223, 224, 225, 
      226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 373, 
      240, 241, 242, 243, 244, 245, 7787, 247, 248, 249, 250, 251, 252, 375, 
      254, 255 ],
  ISO\-8859\-15 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
      16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
      34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
      52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
      70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
      88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
      104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 
      118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 
      132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 
      146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 
      160, 161, 162, 8364, 164, 352, 166, 353, 168, 169, 170, 171, 172, 173, 
      174, 175, 176, 177, 178, 381, 180, 181, 182, 382, 184, 185, 186, 338, 
      339, 376, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 
      202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 
      216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 
      230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 
      244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255 ] );
# reverse tables are only generated when needed
UNICODE_RECODE.TABLES.reverse := rec();
##  # this created the code tables for ISO-8859:
##  for i in Concatenation([1..11],[13..15]) do
##    fn := Concatenation("iso8859-",String(i),".txt");
##    str := StringFile(fn);
##    str := SplitString(str,"","\n");
##    str := List(str, a-> SplitString(a,""," \t"));
##    str := List(str, a-> List([1,2], k-> IntHexString(
##                Filtered(a[k], x-> not x in "=+U"))));
##    str := Filtered(str, a-> a[1]<>a[2]);
##    fn := Concatenation("ISO-8859-",String(i));
##    res := [0..255];
##    for a in str do 
##      res[a[1]] := a[2];
##    od;
##    UNICODE_RECODE.TABLES.(fn) := res;
##  od;
################################################


# wrap and cache integers as unicode characters
InstallMethod(UChar, [IsInt], function(n)
  local res;
  if not IsInt(n) or n < 0 or n > 2097151 then
    return fail;
  fi;
  if IsBound(UNICODECHARCACHE[n]) then
    return UNICODECHARCACHE[n];
  fi;
  res := rec(codepoint := n);
  Objectify(UnicodeCharacterType, res);
  UNICODECHARCACHE[n] := res;
  return res;
end);
# interpret GAP characters as latin 1 encoded
InstallMethod(UChar, [IsChar], function(c)
  return UChar(INT_CHAR(c));
end);

# viewing and printing unicode characters
InstallMethod(ViewObj, [IsUnicodeCharacter], function(c)
  Print("'", UNICODE_RECODE.UTF8UnicodeChar(c!.codepoint), "'");
end);
InstallMethod(PrintObj, [IsUnicodeCharacter], function(c)
  Print("UChar(",c!.codepoint,")");
end);
# \=
InstallMethod(\=, [IsUnicodeCharacter, IsUnicodeCharacter],
function(c, d)
  return c!.codepoint = d!.codepoint;
end);

# NC method, assume that l is (plain?) list of integers in correct range
InstallMethod(U, [IsList], function(l)
  local res;
  res := [l];
  Objectify(UnicodeStringType, res);
  return res;
end);
# extract the list of integers
InstallGlobalFunction("IntListUnicodeString", function(ustr)
  return ustr![1];
end);


InstallMethod(U, [IsString, IsString], function(str, enc)
if Length(str) > 0 and not IsStringRep(str) then
  Print("no stringrep: ",str,"\n");
  ConvertToStringRep(str);
fi;
  if not IsBound(UNICODE_RECODE.NormalizedEncodings.(enc)) then
    Error("Sorry, only the following encodings are supported for U:\n",
              RecFields(UNICODE_RECODE.Decoder), "\n");
  fi;
  enc := UNICODE_RECODE.NormalizedEncodings.(enc);
  return U(UNICODE_RECODE.Decoder.(enc)(str));
end);
# just a string as argument is assumed to be in UTF-8 encoding
InstallMethod(U, [IsStringRep], function(str)
  return U(UNICODE_RECODE.Decoder.("UTF-8")(str));
end);

# view and print 
InstallMethod(ViewObj, [IsUnicodeString], function(ustr)
  local l;
  l := IntListUnicodeString(ustr);
  if Length(l) > 40 then
    l := l{[1..37]};
    Append(l, [46,46,46]);
  fi;
  Print("U(");
  ViewObj(Concatenation(List(l, UNICODE_RECODE.UTF8UnicodeChar)));
  Print(")");
end);
InstallMethod(PrintObj, [IsUnicodeString], function(ustr)
  Print("U(");
  PrintObj(Concatenation(List(IntListUnicodeString(ustr), 
           UNICODE_RECODE.UTF8UnicodeChar)));
  Print(")");
end);

# the *basic* list operations
InstallMethod(Length, [IsUnicodeString], function(ustr)
  return Length(IntListUnicodeString(ustr));
end);

InstallMethod(\[\], [IsUnicodeString, IsPosInt], function(ustr, i)
  return UChar(IntListUnicodeString(ustr)[i]);
end);

InstallOtherMethod(\[\]\:\=, [IsUnicodeString and IsMutable, 
                              IsPosInt, IsUnicodeCharacter], 
function(ustr, i, x)
  local l;
  if i > Length(ustr)+1 then
    Error("no unicode string assignment at position ",i,"\n");
  fi;
  l := IntListUnicodeString(ustr);
  l[i] := x!.codepoint;
end);

InstallMethod(Unbind\[\], [IsUnicodeString and IsMutable, IsPosInt],
function(ustr, i)
  local l;
  if i < Length(ustr) then
    Error("can only unbind last character in unicode string\n");
  fi;
  if i = Length(ustr) then
    l := IntListUnicodeString(ustr);
    Unbind(l[Length(l)]);
  fi;
end);

# let ShallowCopy produce a unicode string
InstallMethod(ShallowCopy, [IsUnicodeString], function(ustr)
  return U(ShallowCopy(IntListUnicodeString(ustr)));
end);
# let sublists be unicode strings
InstallMethod(\{\}, [IsUnicodeString, IsList], function(ustr, poss)
  return U(IntListUnicodeString(ustr){poss});
end);

# a better Append for efficiency
InstallMethod(Append, [IsUnicodeString and IsMutable, IsUnicodeString],
function(ustr, ustr2)
  Append(IntListUnicodeString(ustr), IntListUnicodeString(ustr2));
end);

# better \= for efficiency
InstallMethod(\=, [IsUnicodeString, IsUnicodeString], function(ustr1, ustr2)
  return IntListUnicodeString(ustr1) = IntListUnicodeString(ustr2);
end);

# better Position, PositionSublist
InstallMethod(Position, [IsUnicodeString, IsUnicodeCharacter],
function(ustr, c)
  return Position(IntListUnicodeString(ustr), c!.codepoint);
end);
InstallMethod(Position, [IsUnicodeString, IsUnicodeCharacter, IsInt],
function(ustr, c, pos)
  return Position(IntListUnicodeString(ustr), c!.codepoint, pos);
end);
InstallOtherMethod(PositionSublist, [IsUnicodeString, IsUnicodeString],
function(ustr, ustr2)
  return PositionSublist(IntListUnicodeString(ustr),
                                            IntListUnicodeString(ustr2));
end);
InstallMethod(PositionSublist, [IsUnicodeString, IsUnicodeString, IsInt],
function(ustr, ustr2, pos)
  return PositionSublist(IntListUnicodeString(ustr),
                                            IntListUnicodeString(ustr2), pos);
end);

# helper function for encoding a unicode character to UTF-8
UNICODE_RECODE.UTF8UnicodeChar := function(n)
  local res, a, b, c, d;
  res := "";
  if n < 0 then
    return fail;
  elif n < 128 then
    Add(res, CHAR_INT(n));
  elif n < 2048 then
    a := n mod 64;
    b := (n - a) / 64;
    Add(res, CHAR_INT(b + 192));
    Add(res, CHAR_INT(a + 128));
  elif n < 65536 then
    a := n mod 64;
    n := (n - a)/64;
    b := n mod 64;
    c := (n - b)/64;
    Add(res, CHAR_INT(c + 224));
    Add(res, CHAR_INT(b + 128));
    Add(res, CHAR_INT(a + 128));
  elif n < 2097152 then
    a := n mod 64;
    n := (n - a)/64;
    b := n mod 64;
    n := (n - b)/64;
    c := n mod 64;
    d := (n - c)/64;
    Add(res, CHAR_INT(d + 240));
    Add(res, CHAR_INT(c + 128));
    Add(res, CHAR_INT(b + 128));
    Add(res, CHAR_INT(a + 128));
  else
    return fail;
  fi;
  return res;
end;
# encode unicode string to GAP string in UTF-8 encoding
UNICODE_RECODE.Encoder.("UTF-8") := function(ustr)
  local res, f, n;
  res := "";
  f := UNICODE_RECODE.UTF8UnicodeChar;
  for n in IntListUnicodeString(ustr) do
    Append(res, f(n));
  od;
  return res;
end;
# ISO-8859 cases, substitute '?' for unknown characters
_tmpfunction := function()
  local nam, i;
  for i in Concatenation([1..11],[13..15]) do
    nam := Concatenation("ISO-8859-", String(i));
    UNICODE_RECODE.Encoder.(nam) := function(ustr)
      local t, s, res, pos, c;
      if not IsBound(UNICODE_RECODE.TABLES.reverse.(nam)) then
        t := [0..255];
        s := ShallowCopy(UNICODE_RECODE.TABLES.(nam));
        SortParallel(s, t);
        UNICODE_RECODE.TABLES.reverse.(nam) := [s, t];
      fi;
      t := UNICODE_RECODE.TABLES.reverse.(nam);
      res := [];
      for c in IntListUnicodeString(ustr) do
        if c < 160 then
          Add(res, c);
        else
          pos := PositionSorted(t[1], c);
          if pos = fail then
            Add(res, 63); # '?'
          else
            Add(res, t[2][pos]);
          fi;
        fi;
      od;
      return STRING_SINTLIST(res);
    end;
  od;
end;
_tmpfunction();
Unbind(_tmpfunction);
  
InstallMethod(Encode, [IsUnicodeString, IsString], function(ustr, enc)
  if not IsBound(UNICODE_RECODE.NormalizedEncodings.(enc)) then
    Error("Sorry, only the following encodings are supported for Encode:\n",
                    RecFields(UNICODE_RECODE.Encoder, "\n"));
  fi;
  enc := UNICODE_RECODE.NormalizedEncodings.(enc);
  return UNICODE_RECODE.Encoder.(enc)(ustr);
end);

# here the default is UTF-8 encoding
InstallMethod(Encode, [IsUnicodeString], function(ustr)
  return UNICODE_RECODE.Encoder.("UTF-8")(ustr);
end);

InstallGlobalFunction(NrCharsUTF8String, function(str)
  local n, nc, c;
  n := 0;
  for c in str do
    nc := INT_CHAR(c);
    if nc < 128 or nc > 191 then
      n := n+1;
    fi;
  od;
  return n;
end);

