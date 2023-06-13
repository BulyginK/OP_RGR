UNIT TreeSort;

INTERFACE
  PROCEDURE InsertStorage(VAR WordTree: STRING; VAR FIn: TEXT);
  PROCEDURE PrintStorage(VAR Words: TEXT);
  
IMPLEMENTATION
USES
  ReadWords;
CONST
  NameTempFile = 'TF.DAT';
  NameStorageFile = 'SF.DAT';
  FirstSeek = 0;
  MaxNumWords = 10000;
TYPE
  Tree = ^Node;
  Node =  RECORD
            Key: STRING;
            Amount: INTEGER;
            LLink, RLink: Tree
          END;  

  WordRecords = RECORD
                  Word: STRING;
                  Count: INTEGER
                END;
                
  FileOfWords = FILE OF WordRecords;        
VAR
  Root: Tree;
  Word: STRING;
  NumWords: INTEGER;
  Storage, TempFile: FileOfWords;
  LenStorage: INTEGER;
  TempElem: WordRecords;  
  i: INTEGER;

PROCEDURE MergeWords(VAR Str: STRING; VAR NumWords: INTEGER);
VAR
  Elem, ElemTree: WordRecords;
  Found: BOOLEAN;
  WordsCompareResult: INTEGER;
BEGIN {MergeWord}
  Found := FALSE;
  IF (LenStorage <> 0) AND (i < LenStorage)
  THEN
    BEGIN {IF}
      WHILE (i < LenStorage) AND NOT Found
      DO
        BEGIN {WHILE}
          SEEK(Storage, i);
          READ(Storage, TempElem);
          WordsCompareResult := GetLessWord(Str, TempElem.Word);
          IF WordsCompareResult = WordsEqual
          THEN 
            BEGIN
              Elem.Word := TempElem.Word;
              Elem.Count := TempElem.Count + NumWords;
              WRITE(TempFile, Elem);
              Found := TRUE;
              i := i + 1 
            END
          ELSE  
            IF WordsCompareResult = FirstWordLess
            THEN
              BEGIN
                ElemTree.Word := Str;
                ElemTree.Count := NumWords;
                WRITE(TempFile, ElemTree);
                Found := TRUE
              END
            ELSE
              BEGIN
                WRITE(TempFile, TempElem);
                i := i + 1
              END  
        END; {WHILE}
      IF (i = LenStorage) AND NOT Found
      THEN
        BEGIN
          ElemTree.Word := Str;
          ElemTree.Count := NumWords;
          WRITE(TempFile, ElemTree);
          Found := TRUE
        END
    END {IF}       
  ELSE
    BEGIN
      ElemTree.Word := Str;
      ElemTree.Count := NumWords;
      WRITE(TempFile, ElemTree)
    END
END; {MergeWord}

PROCEDURE OutputTree(VAR Ptr: Tree);
BEGIN {OutputTree}
  IF Ptr <> NIL
  THEN
    BEGIN
      OutputTree(Ptr^.LLink);
      MergeWords(Ptr^.Key, Ptr^.Amount);
      OutputTree(Ptr^.RLink)
    END
END; {OutputTree}

PROCEDURE RestWords();
BEGIN {RestWords}
  WHILE (i < LenStorage)
  DO
    BEGIN
      SEEK(Storage, i);
      READ(Storage, TempElem);
      WRITE(TempFile, TempElem);
      i := i + 1
    END
END; {RestWords}

PROCEDURE ResetFile(VAR ResetingFile: FileOfWords; NameFile: STRING);
BEGIN {ResetFile}
  CLOSE(ResetingFile);
  Erase(ResetingFile);
  ASSIGN(ResetingFile, NameFile);
  REWRITE(ResetingFile)
END; {ResetFile}

PROCEDURE TransferWords(VAR InF: FileOfWords; VAR OutF: FileOfWords);
VAR
  Elem: WordRecords;
BEGIN {TransferWords}
  i := FirstSeek;
  WHILE (i < FILESIZE(InF))
  DO
    BEGIN
      SEEK(InF, i);
      READ(InF, Elem);
      WRITE(OutF, Elem);
      i := i + 1
    END
END; {TransferWords}

PROCEDURE CleanTree(VAR Ptr: Tree);
BEGIN {CleanTree}
  IF Ptr <> NIL
  THEN
    BEGIN
      CleanTree(Ptr^.LLink);
      CleanTree(Ptr^.RLink);
      DISPOSE(Ptr)
    END         
END; {CleanTree}

PROCEDURE OverflowTree();
BEGIN
  i := 0;
  LenStorage := FILESIZE(Storage);
  SEEK(Storage, FirstSeek);
  OutputTree(Root);
  RestWords();
  ResetFile(Storage, NameStorageFile);  
  SEEK(TempFile, FirstSeek);
  TransferWords(TempFile, Storage);
  ResetFile(TempFile, NameTempFile);
  CleanTree(Root);
  Root := NIL
END;

PROCEDURE InsertWord(VAR Ptr: Tree; VAR Word: STRING; VAR FIn: TEXT);
VAR
  WordsCompareResult: INTEGER;
BEGIN {InsertWord}
  IF (Ptr = NIL)
  THEN
    BEGIN
      NEW(Ptr);
      Ptr^.Key := Word;
      Ptr^.Amount := 1;
      Ptr^.LLink := NIL;
      Ptr^.RLink := NIL;
      NumWords := NumWords + 1;
      IF (NumWords > MaxNumWords) OR (EOF(FIn))
      THEN
        OverflowTree()
    END
  ELSE
    BEGIN
      WordsCompareResult := GetLessWord(Word, Ptr^.Key);
      IF WordsCompareResult = WordsEqual
      THEN 
        Ptr^.Amount := Ptr^.Amount + 1
      ELSE  
        IF WordsCompareResult = FirstWordLess
        THEN
          InsertWord(Ptr^.LLink, Word, FIn)
        ELSE
          InsertWord(Ptr^.RLink, Word, FIn)
    END     
END;  {InsertWord}

PROCEDURE InsertStorage(VAR WordTree: STRING; VAR FIn: TEXT);
VAR
  Elem: WordRecords;
BEGIN {InsertStorage}
  IF Root = NIL
  THEN
    NumWords := 0;
  IF WordTree <> ''
  THEN  
    InsertWord(Root, WordTree, FIn)
END; {InsertStorage}

PROCEDURE CleanStorage();
BEGIN {CleanStorage}
  CLOSE(Storage);
  CLOSE(TempFile);
  Erase(Storage);
  Erase(TempFile)
END; {CleanStorage}

PROCEDURE CopyOut(VAR FIn: FileOfWords; VAR FOut: TEXT);
VAR
  Elem: WordRecords;
BEGIN {CopyOut}
  WHILE NOT EOF(FIn)
  DO
    BEGIN
      READ(FIn, Elem);
      WRITELN(FOut, Elem.Word, ' ', Elem.Count)   
    END;
  CleanStorage()  
END; {CopyOut}

PROCEDURE PrintStorage(VAR Words: TEXT);
BEGIN {PrintStorage}
  SEEK(Storage, FirstSeek);
  CopyOut(Storage, Words)
END; {PrintStorage}

BEGIN
  ASSIGN(Storage, NameStorageFile);
  ASSIGN(TempFile, NameTempFile);
  REWRITE(Storage);
  REWRITE(TempFile);
  Root := NIL;
  NumWords := 0
END.
