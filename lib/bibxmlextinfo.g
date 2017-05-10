Bibxmlext := 
[ rec(
      string := [ "EMPTY" ],
      entry := [ "article", "or", "book", "or", "booklet", "or", "manual", 
          "or", "techreport", "or", "mastersthesis", "or", "phdthesis", "or", 
          "inbook", "or", "incollection", "or", "proceedings", "or", 
          "inproceedings", "or", "conference", "or", "unpublished", "or", 
          "misc" ],
      file := [ [ "string", "or", "entry" ], "repeated" ],
      article := [ "author", "title", "journal", "year", "volume", 
          "optional", "number", "optional", "pages", "optional", "month", 
          "optional", "note", "optional", "key", "optional", "annotate", 
          "optional", "crossref", "optional", "abstract", "optional", 
          "affiliation", "optional", "contents", "optional", "copyright", 
          "optional", [ "isbn", "or", "issn" ], "optional", "keywords", 
          "optional", "language", "optional", "lccn", "optional", "location", 
          "optional", "mrnumber", "optional", "mrclass", "optional", 
          "mrreviewer", "optional", "price", "optional", "size", "optional", 
          "url", "optional", "category", "optional", "other", "repeated" ],
      book := [ [ "author", "or", "editor" ], "title", "publisher", "year", 
          [ "volume", "or", "number" ], "optional", "series", "optional", 
          "address", "optional", "edition", "optional", "month", "optional", 
          "note", "optional", "key", "optional", "annotate", "optional", 
          "crossref", "optional", "abstract", "optional", "affiliation", 
          "optional", "contents", "optional", "copyright", "optional", 
          [ "isbn", "or", "issn" ], "optional", "keywords", "optional", 
          "language", "optional", "lccn", "optional", "location", "optional", 
          "mrnumber", "optional", "mrclass", "optional", "mrreviewer", 
          "optional", "price", "optional", "size", "optional", "url", 
          "optional", "category", "optional", "other", "repeated" ],
      booklet := [ "author", "optional", "title", "howpublished", "optional", 
          "address", "optional", "month", "optional", "year", "optional", 
          "note", "optional", "key", "optional", "annotate", "optional", 
          "crossref", "optional", "abstract", "optional", "affiliation", 
          "optional", "contents", "optional", "copyright", "optional", 
          [ "isbn", "or", "issn" ], "optional", "keywords", "optional", 
          "language", "optional", "lccn", "optional", "location", "optional", 
          "mrnumber", "optional", "mrclass", "optional", "mrreviewer", 
          "optional", "price", "optional", "size", "optional", "url", 
          "optional", "category", "optional", "other", "repeated" ],
      conference := [ "author", "title", "booktitle", "year", "editor", 
          "optional", [ "volume", "or", "number" ], "optional", "series", 
          "optional", "pages", "optional", "address", "optional", "month", 
          "optional", "organization", "optional", "publisher", "optional", 
          "note", "optional", "key", "optional", "annotate", "optional", 
          "crossref", "optional", "abstract", "optional", "affiliation", 
          "optional", "contents", "optional", "copyright", "optional", 
          [ "isbn", "or", "issn" ], "optional", "keywords", "optional", 
          "language", "optional", "lccn", "optional", "location", "optional", 
          "mrnumber", "optional", "mrclass", "optional", "mrreviewer", 
          "optional", "price", "optional", "size", "optional", "url", 
          "optional", "category", "optional", "other", "repeated" ],
      inbook := 
       [ [ "author", "or", "editor" ], "title", [ [ "chapter", "pages", 
                  "optional" ], "or", "pages" ], "publisher", "year", 
          [ "volume", "or", "number" ], "optional", "series", "optional", 
          "type", "optional", "address", "optional", "edition", "optional", 
          "month", "optional", "note", "optional", "key", "optional", 
          "annotate", "optional", "crossref", "optional", "abstract", 
          "optional", "affiliation", "optional", "contents", "optional", 
          "copyright", "optional", [ "isbn", "or", "issn" ], "optional", 
          "keywords", "optional", "language", "optional", "lccn", "optional", 
          "location", "optional", "mrnumber", "optional", "mrclass", 
          "optional", "mrreviewer", "optional", "price", "optional", "size", 
          "optional", "url", "optional", "category", "optional", "other", 
          "repeated" ],
      incollection := [ "author", "title", "booktitle", "publisher", "year", 
          "editor", "optional", [ "volume", "or", "number" ], "optional", 
          "series", "optional", "type", "optional", "chapter", "optional", 
          "pages", "optional", "address", "optional", "edition", "optional", 
          "month", "optional", "note", "optional", "key", "optional", 
          "annotate", "optional", "crossref", "optional", "abstract", 
          "optional", "affiliation", "optional", "contents", "optional", 
          "copyright", "optional", [ "isbn", "or", "issn" ], "optional", 
          "keywords", "optional", "language", "optional", "lccn", "optional", 
          "location", "optional", "mrnumber", "optional", "mrclass", 
          "optional", "mrreviewer", "optional", "price", "optional", "size", 
          "optional", "url", "optional", "category", "optional", "other", 
          "repeated" ],
      inproceedings := [ "author", "title", "booktitle", "year", "editor", 
          "optional", [ "volume", "or", "number" ], "optional", "series", 
          "optional", "pages", "optional", "address", "optional", "month", 
          "optional", "organization", "optional", "publisher", "optional", 
          "note", "optional", "key", "optional", "annotate", "optional", 
          "crossref", "optional", "abstract", "optional", "affiliation", 
          "optional", "contents", "optional", "copyright", "optional", 
          [ "isbn", "or", "issn" ], "optional", "keywords", "optional", 
          "language", "optional", "lccn", "optional", "location", "optional", 
          "mrnumber", "optional", "mrclass", "optional", "mrreviewer", 
          "optional", "price", "optional", "size", "optional", "url", 
          "optional", "category", "optional", "other", "repeated" ],
      manual := [ "author", "optional", "title", "organization", "optional", 
          "address", "optional", "edition", "optional", "month", "optional", 
          "year", "optional", "note", "optional", "key", "optional", 
          "annotate", "optional", "crossref", "optional", "abstract", 
          "optional", "affiliation", "optional", "contents", "optional", 
          "copyright", "optional", [ "isbn", "or", "issn" ], "optional", 
          "keywords", "optional", "language", "optional", "lccn", "optional", 
          "location", "optional", "mrnumber", "optional", "mrclass", 
          "optional", "mrreviewer", "optional", "price", "optional", "size", 
          "optional", "url", "optional", "category", "optional", "other", 
          "repeated" ],
      mastersthesis := 
       [ "author", "title", "school", "year", "type", "optional", "address", 
          "optional", "month", "optional", "note", "optional", "key", 
          "optional", "annotate", "optional", "crossref", "optional", 
          "abstract", "optional", "affiliation", "optional", "contents", 
          "optional", "copyright", "optional", [ "isbn", "or", "issn" ], 
          "optional", "keywords", "optional", "language", "optional", "lccn", 
          "optional", "location", "optional", "mrnumber", "optional", 
          "mrclass", "optional", "mrreviewer", "optional", "price", 
          "optional", "size", "optional", "url", "optional", "category", 
          "optional", "other", "repeated" ],
      misc := [ "author", "optional", "title", "optional", "howpublished", 
          "optional", "month", "optional", "year", "optional", "note", 
          "optional", "key", "optional", "annotate", "optional", "crossref", 
          "optional", "abstract", "optional", "affiliation", "optional", 
          "contents", "optional", "copyright", "optional", 
          [ "isbn", "or", "issn" ], "optional", "keywords", "optional", 
          "language", "optional", "lccn", "optional", "location", "optional", 
          "mrnumber", "optional", "mrclass", "optional", "mrreviewer", 
          "optional", "price", "optional", "size", "optional", "url", 
          "optional", "category", "optional", "other", "repeated" ],
      phdthesis := [ "author", "title", "school", "year", "type", "optional", 
          "address", "optional", "month", "optional", "note", "optional", 
          "key", "optional", "annotate", "optional", "crossref", "optional", 
          "abstract", "optional", "affiliation", "optional", "contents", 
          "optional", "copyright", "optional", [ "isbn", "or", "issn" ], 
          "optional", "keywords", "optional", "language", "optional", "lccn", 
          "optional", "location", "optional", "mrnumber", "optional", 
          "mrclass", "optional", "mrreviewer", "optional", "price", 
          "optional", "size", "optional", "url", "optional", "category", 
          "optional", "other", "repeated" ],
      proceedings := 
       [ "editor", "optional", "title", "year", [ "volume", "or", "number" ], 
          "optional", "series", "optional", "address", "optional", "month", 
          "optional", "organization", "optional", "publisher", "optional", 
          "note", "optional", "key", "optional", "annotate", "optional", 
          "crossref", "optional", "abstract", "optional", "affiliation", 
          "optional", "contents", "optional", "copyright", "optional", 
          [ "isbn", "or", "issn" ], "optional", "keywords", "optional", 
          "language", "optional", "lccn", "optional", "location", "optional", 
          "mrnumber", "optional", "mrclass", "optional", "mrreviewer", 
          "optional", "price", "optional", "size", "optional", "url", 
          "optional", "category", "optional", "other", "repeated" ],
      techreport := [ "author", "title", "institution", "year", "type", 
          "optional", "number", "optional", "address", "optional", "month", 
          "optional", "note", "optional", "key", "optional", "annotate", 
          "optional", "crossref", "optional", "abstract", "optional", 
          "affiliation", "optional", "contents", "optional", "copyright", 
          "optional", [ "isbn", "or", "issn" ], "optional", "keywords", 
          "optional", "language", "optional", "lccn", "optional", "location", 
          "optional", "mrnumber", "optional", "mrclass", "optional", 
          "mrreviewer", "optional", "price", "optional", "size", "optional", 
          "url", "optional", "category", "optional", "other", "repeated" ],
      unpublished := [ "author", "title", "note", "month", "optional", 
          "year", "optional", "key", "optional", "annotate", "optional", 
          "crossref", "optional", "abstract", "optional", "affiliation", 
          "optional", "contents", "optional", "copyright", "optional", 
          [ "isbn", "or", "issn" ], "optional", "keywords", "optional", 
          "language", "optional", "lccn", "optional", "location", "optional", 
          "mrnumber", "optional", "mrclass", "optional", "mrreviewer", 
          "optional", "price", "optional", "size", "optional", "url", 
          "optional", "category", "optional", "other", "repeated" ],
      M := [ [ "PCDATA", "or", "Alt" ], "repeated" ],
      Math := [ [ "PCDATA", "or", "Alt" ], "repeated" ],
      URL := [ [ "PCDATA", "or", "Alt" ], "repeated" ],
      value := [ "EMPTY" ],
      C := 
       [ [ "PCDATA", "or", "value", "or", "Alt", "or", "M", "or", "Math", "or"
                , "Wrap", "or", "URL" ], "repeated" ],
      Alt := 
       [ [ "PCDATA", "or", "value", "or", "C", "or", "M", "or", "Math", "or", 
              "Wrap", "or", "URL" ], "repeated" ],
      Wrap := [ "EMPTY" ],
      address := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      author := [ [ "name" ], "repeated" ],
      name := [ "first", "optional", "last" ],
      first := [ "PCDATA" ],
      last := [ "PCDATA" ],
      booktitle := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      chapter := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      edition := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      editor := [ [ "name" ], "repeated" ],
      howpublished := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      institution := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      journal := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      month := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      note := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      number := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      organization := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      pages := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      publisher := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      school := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      series := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      title := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      type := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      volume := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      year := [ "PCDATA" ],
      annotate := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      crossref := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      key := [ "PCDATA" ],
      abstract := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      affiliation := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      contents := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      copyright := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      isbn := [ "PCDATA" ],
      issn := [ "PCDATA" ],
      keywords := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      language := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      lccn := [ "PCDATA" ],
      location := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      mrnumber := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      mrclass := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      mrreviewer := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      price := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      size := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      url := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      category := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ],
      other := 
       [ [ "PCDATA", "or", "value", "or", "M", "or", "Math", "or", "Wrap", 
              "or", "URL", "or", "C", "or", "Alt" ], "repeated" ] ), rec(
      string := [ "key", "CDATA", "REQUIRED", "value", "CDATA", "REQUIRED" ],
      entry := [ "id", "CDATA", "REQUIRED" ],
      URL := [ "Text", "CDATA", "IMPLIED" ],
      value := [ "key", "CDATA", "REQUIRED" ],
      Alt := [ "Only", "CDATA", "IMPLIED", "Not", "CDATA", "IMPLIED" ],
      Wrap := [ "Name", "CDATA", "REQUIRED" ],
      other := [ "type", "CDATA", "REQUIRED" ] ) ];

MakeImmutable(Bibxmlext);
